import 'package:gems_core/gems_core.dart';
import 'package:gems_data_layer/gems_data_layer.dart';

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

  @override
  Future<void> loadItems() async {
    if (isLoading.value) return;
    if (_fetched && items.isNotEmpty) return;

    await handleResult(
      () => repository.getAll(),
      onSuccess: (pages) {
        _fetched = true;
        items
          ..clear()
          ..addAll(pages);
        if (pages.isEmpty) {
          setError('No pages found');
        }
      },
    );
  }

  PostItem? pageByTemplate(String template) {
    final target = ApaPageTemplates.normalize(template);
    if (target.isEmpty) return null;
    for (final page in items) {
      if (page.normalizedTemplate == target) return page;
    }
    return null;
  }

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
