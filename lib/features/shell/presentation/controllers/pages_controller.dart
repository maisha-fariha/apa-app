import 'package:get/get.dart';
import 'package:gems_core/gems_core.dart';
import 'package:gems_data_layer/gems_data_layer.dart';

import '../../../../core/network/connectivity_controller.dart';
import '../../../../data/models/post/post_model.dart';
import '../../../../data/repositories/posts_repository.dart';
import '../mapping/apa_page_templates.dart';
import '../models/apa_nav_item.dart';
import '../widgets/apa_more_sheet.dart';

class PagesController extends BaseListController<PostItem>
    with BaseControllerMixin<PostItem> {
  PagesController({required this.repository});

  final PostsRepository repository;

  bool _fetched = false;

  /// WordPress post id for the page currently shown in the shell.
  final RxnInt selectedPageId = RxnInt();

  /// Full page payloads loaded via `get-post-details`, keyed by post id.
  final RxMap<int, PostItem> pageDetailsById = <int, PostItem>{}.obs;

  final Set<int> _loadingDetails = <int>{};

  @override
  Future<void> loadItems() async {
    if (isLoading.value) return;
    if (_fetched && items.isNotEmpty) return;

    setLoading(true);
    try {
      final result = await repository.getAll();
      result.when(
        success: (pages) {
          _fetched = true;
          items
            ..clear()
            ..addAll(pages);
          if (pages.isEmpty) {
            if (!ConnectivityController.currentlyOnline) return;
            setError('No pages found');
            return;
          }
          errorMessage.value = '';
          _ensureInitialSelection();
        },
        failure: (error) {
          // Offline: keep any cached/in-memory data and stay silent.
          if (!ConnectivityController.currentlyOnline) return;
          setError(error.message);
          Get.snackbar('Error', error.message);
        },
      );
    } finally {
      setLoading(false);
    }
  }

  void _ensureInitialSelection() {
    if (selectedPageId.value != null) return;
    final home = pageByTemplate(ApaPageTemplates.home);
    if (home != null) {
      selectPage(home, fetchDetails: false);
    }
  }

  PostItem? pageByTemplate(String template) {
    final target = ApaPageTemplates.normalize(template);
    if (target.isEmpty) return null;
    for (final page in items) {
      if (page.normalizedTemplate == target) return page;
    }
    return null;
  }

  int? pageIdForTemplate(String template) => pageByTemplate(template)?.id;

  PostItem? pageForShell(ApaShellPage page) {
    return pageByTemplate(ApaPageTemplates.forShellPage(page));
  }

  PostItem? pageForNavItem(ApaNavItem item) {
    final template = ApaPageTemplates.forNavItem(item);
    if (template == null) return null;
    return pageByTemplate(template);
  }

  PostItem? pageForMore(ApaMoreDestination destination) {
    return pageByTemplate(ApaPageTemplates.forMoreDestination(destination));
  }

  PostItem? detailsForPageId(int? pageId) {
    if (pageId == null || pageId <= 0) return null;
    return pageDetailsById[pageId];
  }

  PostItem? resolvedPageForShell(ApaShellPage page) {
    final listPage = pageForShell(page);
    if (listPage == null) return null;
    return detailsForPageId(listPage.id) ?? listPage;
  }

  /// Resolves [template] against loaded pages, stores the post id, and returns
  /// the shell destination to open.
  ApaShellPage resolveNavigation(String template, ApaShellPage fallback) {
    final page = pageByTemplate(template);
    if (page != null) {
      selectPage(page);
      return ApaPageTemplates.toShellPage(page.template) ?? fallback;
    }
    return ApaPageTemplates.toShellPage(template) ?? fallback;
  }

  ApaShellPage resolveNavItem(ApaNavItem item, ApaShellPage fallback) {
    final template = ApaPageTemplates.forNavItem(item);
    if (template == null) return fallback;
    return resolveNavigation(template, fallback);
  }

  ApaShellPage resolveMoreDestination(
    ApaMoreDestination destination,
    ApaShellPage fallback,
  ) {
    return resolveNavigation(
      ApaPageTemplates.forMoreDestination(destination),
      fallback,
    );
  }

  void selectPage(PostItem page, {bool fetchDetails = true}) {
    selectedPageId.value = page.id;
    if (fetchDetails) {
      loadPageDetails(page.id);
    }
  }

  Future<void> loadPageDetails(int pageId, {bool force = false}) async {
    if (pageId <= 0) return;
    if (!force && pageDetailsById.containsKey(pageId)) return;
    if (!force && _loadingDetails.contains(pageId)) return;

    // Offline: never force a network round-trip; serve cache/memory only.
    final online = ConnectivityController.currentlyOnline;
    final useCache = !force || !online;
    if (!online && pageDetailsById.containsKey(pageId)) return;

    _loadingDetails.add(pageId);
    try {
      final result = await repository.getPostDetails(
        pageId,
        useCache: useCache,
      );
      result.when(
        success: (details) => pageDetailsById[pageId] = details,
        failure: (_) {},
      );
    } finally {
      _loadingDetails.remove(pageId);
    }
  }

  Future<void> loadDetailsForTemplate(
    String template, {
    bool force = false,
  }) async {
    final page = pageByTemplate(template);
    if (page == null) return;
    selectPage(page, fetchDetails: false);
    await loadPageDetails(page.id, force: force);
  }

  Future<String?> mediaSourceUrl(int mediaId) {
    return repository.mediaSourceUrl(mediaId);
  }

  String navLabel(ApaNavItem item) {
    final page = pageForNavItem(item);
    final title = page?.title.trim();
    if (title == null || title.isEmpty) return item.label;
    return title.toUpperCase();
  }

  String moreLabel(ApaMoreDestination destination) {
    final page = pageForMore(destination);
    final title = page?.title.trim();
    if (title == null || title.isEmpty) return destination.label;
    return title.toUpperCase();
  }
}
