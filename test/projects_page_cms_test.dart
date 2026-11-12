import 'package:apa/core/utils/cms_text.dart';
import 'package:apa/data/models/post/post_item_extensions.dart';
import 'package:apa/data/models/post/post_model.dart';
import 'package:apa/data/models/post/project_list_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Projects page CMS parsing', () {
    test('reads structured footer title, content, and button', () {
      final page = PostItem.fromJson({
        'id': 44,
        'title': 'Projects',
        'acf_fields': {
          'footer': {
            'title': 'How we work',
            'content': 'Communities help choose each project.',
            'button_title': 'Fund a project',
            'button_link': 'https://ansanmpouayiti.com/donation/',
          },
        },
      });

      final footer = page.pageFooter;
      expect(footer.title, 'How we work');
      expect(footer.content, contains('Communities help choose'));
      expect(footer.buttonTitle, 'Fund a project');
      expect(footer.buttonLink, contains('/donation/'));
      expect(page.footerHtml, contains('<h2>How we work</h2>'));
    });

    test('project cards use card_content bullets when content is empty', () {
      final page = PostItem.fromJson({
        'id': 44,
        'title': 'Projects',
        'acf_fields': {
          'projects': [
            {
              'id': 1,
              'title': 'Community park',
              'content': '',
              'taxonomies': {
                'project_type': {
                  'terms': [
                    {'name': 'Renewable street lighting'},
                  ],
                },
              },
              'acf_fields': {
                'tag_line': 'Modern public parks for families and children.',
                'card_content':
                    '<ul><li>Safer streets after dark</li><li>Local crews</li></ul>',
              },
            },
          ],
        },
      });

      final project = page.relatedProjects.single;
      expect(project.tagLine, contains('Modern public parks'));
      expect(project.projectTypeLabel, 'Renewable street lighting');
      expect(project.contentBullets, [
        'Safer streets after dark',
        'Local crews',
      ]);
    });

    test('ignores ACF placeholder headings', () {
      expect(isCmsPlaceholder('Heading Text One'), isTrue);
      expect(isCmsPlaceholder('Heading Text Two'), isTrue);
      expect(cmsOr('Heading Text One', 'Three things a'), 'Three things a');
      expect(cmsOr('Phase one · Haiti', 'fallback'), 'Phase one · Haiti');
    });

    test('prefers canonical projects over #2 duplicates and test posts', () {
      final projects = [
        parseProjectCard({
          'id': 347,
          'title': 'Community park & playground #2',
          'acf_fields': {'tag_line': ''},
        }),
        parseProjectCard({
          'id': 339,
          'title': 'Exercitation ut aut',
          'acf_fields': {},
        }),
        parseProjectCard({
          'id': 132,
          'title': 'Community park & playground',
          'acf_fields': {
            'tag_line': 'Solar-powered lights where the grid does not reach.',
          },
        }),
        parseProjectCard({
          'id': 130,
          'title': 'Road repair — market route',
          'acf_fields': {
            'tag_line': 'Repairing damaged roads in underserved communities.',
          },
        }),
        parseProjectCard({
          'id': 346,
          'title': 'Road repair — market route #2',
          'acf_fields': {},
        }),
      ];

      final canonical = preferCanonicalProjects(projects);
      expect(canonical.map((p) => p.id), [132, 130]);
      expect(
        canonical.first.tagLine,
        contains('Solar-powered lights'),
      );
    });
  });
}
