import 'package:apa/data/models/post/post_model.dart';
import 'package:apa/features/shell/presentation/mapping/apa_page_templates.dart';
import 'package:apa/features/shell/presentation/models/apa_nav_item.dart';
import 'package:apa/features/shell/presentation/widgets/apa_more_sheet.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses get-all-posts payload with empty nested fields', () {
    final response = GetAllPostsResponse.fromJson({
      'success': true,
      'count': 2,
      'items': [
        {
          'id': 3,
          'title': 'Privacy Policy',
          'slug': 'privacy-policy',
          'type': 'page',
          'status': 'publish',
          'date': '2026-07-07 11:48:48',
          'modified': '2026-07-08 07:12:50',
          'template': 'default',
          'permalink':
              'https://encoder-staging.space/ansanm-pou-haiti/privacy-policy/',
          'featured_image': {'id': 0, 'url': '', 'alt': ''},
          'taxonomies': [],
          'acf_fields': [],
        },
        {
          'id': '12',
          'title': 'Projects',
          'slug': 'projects',
          'template': 'page-project.php',
          'featured_image': {
            'id': 9,
            'url': 'https://example.com/hero.jpg',
            'alt': 'Hero',
          },
          'acf_fields': {'kicker': 'PHASE ONE'},
        },
      ],
    });

    expect(response.success, isTrue);
    expect(response.items, hasLength(2));
    expect(response.items.first.acfFields, isEmpty);
    expect(response.items.last.id, 12);
    expect(response.items.last.featuredImageUrl, 'https://example.com/hero.jpg');
    expect(response.items.last.acfFields['kicker'], 'PHASE ONE');
  });

  test('parses get-post-details payload with content fields', () {
    final page = PostItem.fromJson({
      'success': true,
      'id': 44,
      'title': 'Projects',
      'template': 'page-project.php',
      'content': '<p>Body content</p>',
      'excerpt': 'Short excerpt',
      'featured_image': {
        'id': 85,
        'url': 'https://example.com/projects.webp',
        'alt': '',
      },
    });

    expect(page.id, 44);
    expect(page.content, '<p>Body content</p>');
    expect(page.excerpt, 'Short excerpt');
    expect(page.featuredImageUrl, 'https://example.com/projects.webp');
  });

  test('maps templates to shell pages and ignores unknown templates', () {
    expect(
      ApaPageTemplates.toShellPage('front-page.php'),
      ApaShellPage.home,
    );
    expect(
      ApaPageTemplates.toShellPage('templates/page-project.php'),
      ApaShellPage.projects,
    );
    expect(ApaPageTemplates.toShellPage('default'), isNull);
    expect(ApaPageTemplates.forNavItem(ApaNavItem.more), isNull);
    expect(
      ApaPageTemplates.forMoreDestination(ApaMoreDestination.contact),
      ApaPageTemplates.contact,
    );
  });
}
