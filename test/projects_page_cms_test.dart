import 'package:apa/core/utils/html_utils.dart';
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
              'title': 'Community park & playground #2',
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
      expect(project.title, contains('#2'));
      expect(project.tagLine, contains('Modern public parks'));
      expect(project.projectTypeLabel, 'Renewable street lighting');
      expect(project.contentBullets, [
        'Safer streets after dark',
        'Local crews',
      ]);
    });

    test('keeps live web API order including #2 and test posts', () {
      final projects = [
        parseProjectCard({
          'id': 347,
          'title': 'Community park & playground #2',
          'acf_fields': {},
        }),
        parseProjectCard({
          'id': 339,
          'title': 'Exercitation ut aut',
          'acf_fields': {},
        }),
        parseProjectCard({
          'id': 132,
          'title': 'Community park & playground',
          'acf_fields': {},
        }),
      ];

      final grid = projectsForWebGrid(projects);
      expect(grid.map((p) => p.id), [347, 339, 132]);
    });

    test('parses ul / ol / blockquote card content like the web', () {
      final content = HtmlUtils.projectCardContentFromHtml('''
<ul><li>Bullet A</li><li>Bullet B</li></ul>
<ol><li>Step 1</li><li>Step 2</li></ol>
<blockquote><p>Red border note</p></blockquote>
''');
      expect(content.bullets, ['Bullet A', 'Bullet B']);
      expect(content.numbered, ['Step 1', 'Step 2']);
      expect(content.callouts, ['Red border note']);
    });
  });
}
