import 'package:apa/data/models/post/post_model.dart';
import 'package:apa/data/repositories/posts_repository.dart';
import 'package:apa/features/shell/presentation/controllers/pages_controller.dart';
import 'package:apa/features/shell/presentation/mapping/apa_page_templates.dart';
import 'package:apa/features/shell/presentation/models/apa_nav_item.dart';
import 'package:apa/features/shell/presentation/widgets/apa_more_sheet.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gems_core/gems_core.dart';
import 'package:gems_data_layer/gems_data_layer.dart';
// Transitive dependency of gems_data_layer, used only for repository stubbing.
// ignore: depend_on_referenced_packages
import 'package:connectivity_plus/connectivity_plus.dart';

void main() {
  group('PagesController navigation', () {
    late PagesController controller;

    setUp(() {
      controller = PagesController(repository: _StubPostsRepository());
      controller.items.addAll(_samplePages);
    });

    test('resolves page id from template', () {
      expect(
        controller.pageIdForTemplate(ApaPageTemplates.projects),
        44,
      );
      expect(
        controller.pageIdForTemplate(ApaPageTemplates.home),
        7,
      );
      expect(controller.pageIdForTemplate('unknown-template.php'), isNull);
    });

    test('resolveNavigation stores post id and returns shell page', () {
      final target = controller.resolveNavigation(
        ApaPageTemplates.donation,
        ApaShellPage.donation,
      );

      expect(target, ApaShellPage.donation);
      expect(controller.selectedPageId.value, 17);
    });

    test('resolveNavItem uses nav template mapping', () {
      final target = controller.resolveNavItem(
        ApaNavItem.transparency,
        ApaShellPage.transparency,
      );

      expect(target, ApaShellPage.transparency);
      expect(controller.selectedPageId.value, 14);
    });

    test('loadDetailsForTemplate fetches get-post-details by contact page id',
        () async {
      await controller.loadDetailsForTemplate(ApaPageTemplates.contact);

      expect(controller.selectedPageId.value, 10);
      expect(controller.detailsForPageId(10)?.id, 10);
    });

    test('resolveMoreDestination uses more template mapping', () {
      final target = controller.resolveMoreDestination(
        ApaMoreDestination.contact,
        ApaShellPage.contact,
      );

      expect(target, ApaShellPage.contact);
      expect(controller.selectedPageId.value, 10);
    });
  });
}

const _samplePages = [
  PostItem(id: 7, title: 'Home', template: 'front-page.php'),
  PostItem(id: 44, title: 'Projects', template: 'page-project.php'),
  PostItem(id: 17, title: 'Donation', template: 'page-donation.php'),
  PostItem(id: 14, title: 'Transparency', template: 'page-transparency.php'),
  PostItem(id: 53, title: 'News', template: 'page-news.php'),
  PostItem(id: 51, title: 'Our Vision', template: 'page-vision.php'),
  PostItem(id: 10, title: 'Contact Us', template: 'page-contact.php'),
];

class _StubPostsRepository extends PostsRepository {
  _StubPostsRepository()
      : super(
          apiService: ApiService(
            ApiConfig(baseUrl: 'https://example.com'),
          ),
          databaseService: DatabaseService(),
          syncService: SyncService(
            ApiService(ApiConfig(baseUrl: 'https://example.com')),
            DatabaseService(),
            Connectivity(),
          ),
        );

  @override
  Future<Result<PostItem>> getPostDetails(
    int postId, {
    bool useCache = true,
  }) {
    return Future.value(Result.success(PostItem(id: postId)));
  }
}
