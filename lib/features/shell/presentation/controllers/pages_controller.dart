import 'dart:async';

import 'package:get/get.dart';
import 'package:gems_core/gems_core.dart';
import 'package:gems_data_layer/gems_data_layer.dart';

import '../../../../core/network/apa_api_config.dart';
import '../../../../core/network/connectivity_controller.dart';
import '../../../../data/models/post/content_detail_models.dart';
import '../../../../data/models/post/post_item_extensions.dart';
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

  /// True only after an online fetch finishes. A startup offline blip
  /// leaves this false so the shell does not flash the retry screen.
  final RxBool initialLoadSettled = false.obs;

  /// WordPress post id for the page currently shown in the shell.
  final RxnInt selectedPageId = RxnInt();

  /// Full page payloads loaded via `get-post-details`, keyed by post id.
  final RxMap<int, PostItem> pageDetailsById = <int, PostItem>{}.obs;

  /// Current Projects grid page items (web-style numbered pagination).
  final RxList<PostItem> projectsPageItems = <PostItem>[].obs;

  /// Extra news stories loaded via `get-paginated-posts` (after first page).
  final RxList<PostItem> extraNewsPosts = <PostItem>[].obs;

  /// Active news keyword search (`get-paginated-posts?search=`).
  final RxString newsSearchQuery = ''.obs;
  final RxList<PostItem> newsSearchResults = <PostItem>[].obs;
  final RxBool newsSearchHasMore = false.obs;
  final RxBool searchingNews = false.obs;

  /// 1-based Projects grid page (web `pagination.page` / `total_pages`).
  final RxInt projectsPage = 1.obs;
  final RxInt projectsTotalPages = 1.obs;
  final RxInt projectsPerPage = 3.obs;
  final RxBool loadingProjectsPage = false.obs;

  final RxBool newsHasMore = false.obs;
  final RxBool loadingMoreNews = false.obs;

  /// Global Settings page (`post_id=5`) — shared labels / donate CTA / logo.
  final Rxn<PostItem> globalSettings = Rxn<PostItem>();

  final Set<int> _loadingDetails = <int>{};
  final Set<String> _loadingContentKeys = <String>{};

  bool isLoadingDetailsFor(int pageId) => _loadingDetails.contains(pageId);

  bool isLoadingDetailsForTemplate(String template) {
    final page = pageByTemplate(template);
    if (page == null) return isLoading.value && items.isEmpty;
    return isLoadingDetailsFor(page.id);
  }

  /// True when page list + details for [template] have nothing useful yet.
  bool isBlankForTemplate(String template) {
    final page = pageByTemplate(template);
    if (page == null) return true;
    return detailsForPageId(page.id) == null;
  }

  @override
  void onInit() {
    super.onInit();
    unawaited(loadItems());
    unawaited(loadGlobalSettings());
  }

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
          initialLoadSettled.value = true;
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
          // Offline at launch is often a false reading. Stay unsettled so
          // the home screen stays up until connectivity restore retries.
          if (!ConnectivityController.currentlyOnline) return;
          initialLoadSettled.value = true;
          setError(error.message);
          Get.snackbar('Error', error.message);
        },
      );
    } finally {
      setLoading(false);
    }
  }

  /// Clears the one-shot fetch guard and reloads list + optional page details.
  Future<void> retryLoad({String? template}) async {
    if (items.isEmpty) {
      _fetched = false;
      await loadItems();
    }
    if (template != null && template.trim().isNotEmpty) {
      await loadDetailsForTemplate(template, force: true);
    }
  }

  /// Called when connectivity returns — refresh blank/stale CMS data.
  Future<void> onConnectivityRestored() async {
    if (items.isEmpty) {
      _fetched = false;
      await loadItems();
    }
    unawaited(loadGlobalSettings(force: true));
    final selectedId = selectedPageId.value;
    if (selectedId != null && selectedId > 0) {
      await loadPageDetails(selectedId, force: true);
      return;
    }
    final home = pageByTemplate(ApaPageTemplates.home);
    if (home != null) {
      await loadPageDetails(home.id, force: true);
    }
  }

  void _ensureInitialSelection() {
    if (selectedPageId.value != null) return;
    final home = pageByTemplate(ApaPageTemplates.home);
    if (home != null) {
      selectPage(home, fetchDetails: true);
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
    if (!force && pageDetailsById.containsKey(pageId)) {
      // Keep showing memory/cache immediately, but refresh so CMS edits
      // (e.g. Home minimum_donate_amount) appear without an app reinstall.
      if (ConnectivityController.currentlyOnline) {
        unawaited(_refreshPageDetailsInBackground(pageId));
      }
      return;
    }
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
        success: (details) {
          pageDetailsById[pageId] = details;
          _resetListPagingForPage(pageId, details);
        },
        failure: (_) {},
      );
    } finally {
      _loadingDetails.remove(pageId);
    }
  }

  Future<void> _refreshPageDetailsInBackground(int pageId) async {
    if (_loadingDetails.contains(pageId)) return;
    _loadingDetails.add(pageId);
    try {
      final result = await repository.getPostDetails(
        pageId,
        useCache: false,
      );
      result.when(
        success: (details) {
          final previous = pageDetailsById[pageId];
          pageDetailsById[pageId] = details;
          // Reset Projects/News paging when CMS pagination meta changes.
          if (previous?.listPagination.hasMore !=
                  details.listPagination.hasMore ||
              previous?.listPagination.perPage !=
                  details.listPagination.perPage ||
              previous?.listPagination.totalPages !=
                  details.listPagination.totalPages) {
            _resetListPagingForPage(pageId, details);
          }
        },
        failure: (_) {},
      );
    } finally {
      _loadingDetails.remove(pageId);
    }
  }

  /// Loads Global Settings once (labels, donate CTA, site logo).
  Future<void> loadGlobalSettings({bool force = false}) async {
    if (!force && globalSettings.value != null) return;

    final online = ConnectivityController.currentlyOnline;
    final useCache = !force || !online;

    final result = await repository.getPostDetails(
      ApaApiConfig.globalSettingsId,
      useCache: useCache,
    );
    result.when(
      success: (details) => globalSettings.value = details,
      failure: (_) {},
    );
  }

  static String _contentCacheKey(int postId, String postType) =>
      '${postType.trim()}:$postId';

  /// Single news/project details with `post_type` (collection folder 2).
  Future<void> loadContentDetails(
    int postId, {
    required String postType,
    bool force = false,
  }) async {
    if (postId <= 0 || postType.trim().isEmpty) return;

    final key = _contentCacheKey(postId, postType);
    final existing = pageDetailsById[postId];
    if (!force &&
        existing != null &&
        _isTypedContentPayload(existing, postType)) {
      return;
    }
    if (!force && _loadingContentKeys.contains(key)) return;

    final online = ConnectivityController.currentlyOnline;
    final useCache = !force || !online;
    if (!online && existing != null) return;

    _loadingContentKeys.add(key);
    try {
      final result = await repository.getPostDetails(
        postId,
        postType: postType,
        useCache: useCache,
      );
      result.when(
        success: (details) => pageDetailsById[postId] = details,
        failure: (_) {},
      );
    } finally {
      _loadingContentKeys.remove(key);
    }
  }

  bool _isTypedContentPayload(PostItem item, String postType) {
    if (item.type == postType) return true;
    if (postType == ApaApiConfig.postTypePost) {
      return item.acfFields.containsKey('news_facts') ||
          item.acfFields.containsKey('related_posts');
    }
    if (postType == ApaApiConfig.postTypeProjects) {
      return item.acfFields.containsKey('project_details') ||
          item.acfFields.containsKey('related_projects');
    }
    return false;
  }

  bool isLoadingContentDetails(int postId, String postType) =>
      _loadingContentKeys.contains(_contentCacheKey(postId, postType));

  ContentLabels newsLabelsFor(PostItem? detail) {
    final fromDetail = detail?.newsLabels ?? ContentLabels.empty;
    if (!fromDetail.isEmpty) return fromDetail;
    return globalSettings.value?.newsLabels ?? ContentLabels.empty;
  }

  ContentLabels projectLabelsFor(PostItem? detail) {
    final fromDetail = detail?.projectLabels ?? ContentLabels.empty;
    if (!fromDetail.isEmpty) return fromDetail;
    return globalSettings.value?.projectLabels ?? ContentLabels.empty;
  }

  DonateCta donateCtaFor(PostItem? detail) {
    final fromDetail = detail?.donateCta ?? DonateCta.empty;
    if (!fromDetail.isEmpty) return fromDetail;
    return globalSettings.value?.donateCta ?? DonateCta.empty;
  }

  String? get siteLogoUrl =>
      globalSettings.value?.siteLogoUrl ??
      globalSettings.value?.featuredImageUrl;

  Future<void> loadDetailsForTemplate(
    String template, {
    bool force = false,
  }) async {
    final page = pageByTemplate(template);
    if (page == null) return;
    selectPage(page, fetchDetails: false);
    await loadPageDetails(page.id, force: force);
  }

  void _resetListPagingForPage(int pageId, PostItem details) {
    final projectsShell = pageByTemplate(ApaPageTemplates.projects);
    final newsPage = pageByTemplate(ApaPageTemplates.news);
    final pagination = details.listPagination;

    if (projectsShell?.id == pageId) {
      final perPage = pagination.perPage > 0 ? pagination.perPage : 3;
      projectsPerPage.value = perPage;
      projectsTotalPages.value =
          pagination.totalPages > 0 ? pagination.totalPages : 1;
      projectsPage.value = 1;
      projectsPageItems
        ..clear()
        ..addAll(details.relatedProjects);
    }
    if (newsPage?.id == pageId) {
      extraNewsPosts.clear();
      newsHasMore.value = pagination.hasMore;
      clearNewsSearch();
    }
  }

  /// Current Projects grid page (web numbered pagination).
  List<PostItem> projectsForDisplay(PostItem? page) {
    if (projectsPageItems.isNotEmpty) {
      return List<PostItem>.unmodifiable(projectsPageItems);
    }
    return page?.relatedProjects ?? const [];
  }

  /// Jump to a Projects grid page — same `per_page` / `total_pages` model as web.
  Future<void> goToProjectsPage(int pageNumber) async {
    if (loadingProjectsPage.value) return;
    final total = projectsTotalPages.value;
    if (pageNumber < 1 || pageNumber > total) return;

    final details = resolvedPageForShell(ApaShellPage.projects);
    if (details == null) return;

    final perPage = projectsPerPage.value > 0
        ? projectsPerPage.value
        : (details.listPagination.perPage > 0
            ? details.listPagination.perPage
            : 3);

    if (pageNumber == 1) {
      projectsPageItems
        ..clear()
        ..addAll(details.relatedProjects);
      projectsPage.value = 1;
      return;
    }

    if (pageNumber == projectsPage.value && projectsPageItems.isNotEmpty) {
      return;
    }

    if (!ConnectivityController.currentlyOnline) {
      Get.snackbar('Error', ConnectivityController.offlineMessage);
      return;
    }

    loadingProjectsPage.value = true;
    try {
      final result = await repository.getPaginatedPosts(
        postType: ApaApiConfig.postTypeProjects,
        limit: perPage,
        offset: (pageNumber - 1) * perPage,
      );
      result.when(
        success: (pageResult) {
          projectsPageItems
            ..clear()
            ..addAll(pageResult.posts);
          projectsPage.value = pageNumber;
          if (pageResult.totalPosts > 0 && perPage > 0) {
            final pages = (pageResult.totalPosts + perPage - 1) ~/ perPage;
            if (pages > 0) projectsTotalPages.value = pages;
          }
        },
        failure: (error) {
          Get.snackbar('Error', error.message);
        },
      );
    } finally {
      loadingProjectsPage.value = false;
    }
  }

  bool get isNewsSearchActive => newsSearchQuery.value.trim().isNotEmpty;

  /// Non-featured news stories including load-more / search results.
  List<PostItem> newsStoriesForDisplay(PostItem? page) {
    if (isNewsSearchActive) {
      return List<PostItem>.unmodifiable(newsSearchResults);
    }
    final first = page?.nonFeaturedPosts ?? const <PostItem>[];
    if (extraNewsPosts.isEmpty) return first;
    final seen = first.map((p) => p.id).toSet();
    final featuredId = page?.featuredPost?.id;
    return [
      ...first,
      for (final post in extraNewsPosts)
        if (post.id != featuredId && seen.add(post.id)) post,
    ];
  }

  /// Keyword search against `get-paginated-posts?post_type=post&search=`.
  Future<void> searchNews(String query, {int limit = 10}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      clearNewsSearch();
      return;
    }
    if (!ConnectivityController.currentlyOnline) {
      Get.snackbar('Error', ConnectivityController.offlineMessage);
      return;
    }
    if (searchingNews.value) return;

    searchingNews.value = true;
    newsSearchQuery.value = trimmed;
    try {
      final result = await repository.getPaginatedPosts(
        postType: ApaApiConfig.postTypePost,
        limit: limit,
        offset: 0,
        search: trimmed,
      );
      result.when(
        success: (pageResult) {
          newsSearchResults
            ..clear()
            ..addAll(pageResult.posts);
          newsSearchHasMore.value = pageResult.hasMore;
        },
        failure: (error) {
          Get.snackbar('Error', error.message);
        },
      );
    } finally {
      searchingNews.value = false;
    }
  }

  void clearNewsSearch() {
    newsSearchQuery.value = '';
    newsSearchResults.clear();
    newsSearchHasMore.value = false;
    searchingNews.value = false;
  }

  Future<void> loadMoreNews() async {
    if (loadingMoreNews.value) return;
    if (!ConnectivityController.currentlyOnline) {
      Get.snackbar('Error', ConnectivityController.offlineMessage);
      return;
    }

    final searching = isNewsSearchActive;
    if (searching) {
      if (!newsSearchHasMore.value) return;
    } else if (!newsHasMore.value) {
      return;
    }

    final page = resolvedPageForShell(ApaShellPage.news);
    if (!searching && page == null) return;

    final limit = searching
        ? 10
        : (page!.listPagination.loadMoreCount > 0
            ? page.listPagination.loadMoreCount
            : 3);
    final already = searching
        ? newsSearchResults.length
        : page!.newsPosts.length + extraNewsPosts.length;
    final excludeId = searching ? null : page!.featuredPost?.id;

    loadingMoreNews.value = true;
    try {
      final result = await repository.getPaginatedPosts(
        postType: ApaApiConfig.postTypePost,
        limit: limit,
        offset: already,
        excludeId: excludeId,
        search: searching ? newsSearchQuery.value : null,
      );
      result.when(
        success: (pageResult) {
          if (searching) {
            newsSearchResults.addAll(pageResult.posts);
            newsSearchHasMore.value = pageResult.hasMore;
          } else {
            extraNewsPosts.addAll(pageResult.posts);
            newsHasMore.value = pageResult.hasMore;
          }
        },
        failure: (error) {
          Get.snackbar('Error', error.message);
        },
      );
    } finally {
      loadingMoreNews.value = false;
    }
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
