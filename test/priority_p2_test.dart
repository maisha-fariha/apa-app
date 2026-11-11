import 'package:apa/core/network/apa_api_config.dart';
import 'package:apa/data/models/post/content_detail_models.dart';
import 'package:apa/data/models/post/post_item_extensions.dart';
import 'package:apa/data/models/post/post_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// P2 — Single project/news `post_type` details + Global Settings.
void main() {
  group('P2 Global Settings', () {
    test('collection globalSettingsId is 5', () {
      expect(ApaApiConfig.globalSettingsId, 5);
    });

    test('parses donate_cta, news_single, project_single, site logo', () {
      final settings = PostItem(
        id: ApaApiConfig.globalSettingsId,
        title: 'Global Settings',
        acfFields: {
          'donate_cta': {
            'title': 'Help fund the next one.',
            'text': 'Every gift goes straight to project funds, not overhead.',
            'button_label': 'Donate',
            'button_link': 'https://ansanmpouayiti.com/donation/',
          },
          'news_single': {
            'back_label': 'Back to news',
            'facts_title': 'Quick facts',
            'related_title': 'More stories',
            'category_label': 'Category',
          },
          'project_single': {
            'back_label': 'Back to projects',
            'facts_title': 'Project quick facts',
            'related_title': 'More projects',
            'type_label': 'Type',
          },
          'site_logo_url':
              'https://ansanmpouayiti.com/wp-content/uploads/2026/08/apa-logo.png',
        },
      );

      expect(settings.donateCta.title, 'Help fund the next one.');
      expect(settings.donateCta.buttonLabel, 'Donate');
      expect(settings.newsLabels.backLabel, 'Back to news');
      expect(settings.newsLabels.relatedTitle, 'More stories');
      expect(settings.projectLabels.factsTitle, 'Project quick facts');
      expect(
        settings.siteLogoUrl,
        'https://ansanmpouayiti.com/wp-content/uploads/2026/08/apa-logo.png',
      );
    });
  });

  group('P2 single news post_type=post', () {
    test('post type constant matches collection', () {
      expect(ApaApiConfig.postTypePost, 'post');
    });

    test('parses news_facts, related_posts, news_labels, donate_cta', () {
      final article = PostItem(
        id: 273,
        title: 'Creating opportunities through community development',
        type: ApaApiConfig.postTypePost,
        acfFields: {
          'news_facts': [
            {'label': 'Category', 'text': 'Community'},
            {'label': 'Location', 'text': 'Sud'},
          ],
          'related_posts': [
            {
              'id': 278,
              'title': 'Youth vocational apprenticeship',
              'category': 'Education',
              'acf_fields': {},
            },
          ],
          'news_labels': {
            'back_label': 'Back to news',
            'facts_title': 'Quick facts',
            'related_title': 'More stories',
          },
          'donate_cta': {
            'title': 'Help fund the next one.',
            'text': 'Every gift goes straight to project funds, not overhead.',
            'button_label': 'Donate',
          },
        },
      );

      expect(article.contentFactRows, hasLength(2));
      expect(article.contentFactRows.first.label, 'Category');
      expect(article.contentFactRows.first.text, 'Community');
      expect(article.relatedNewsPosts.single.id, 278);
      expect(article.newsLabels.factsTitle, 'Quick facts');
      expect(article.donateCta.buttonLabel, 'Donate');
    });
  });

  group('P2 single project post_type=projects', () {
    test('post type constant matches collection', () {
      expect(ApaApiConfig.postTypeProjects, 'projects');
    });

    test('parses project_details, related_projects, project_labels', () {
      final project = PostItem(
        id: 128,
        title: 'Solar street lighting, phase 1',
        type: ApaApiConfig.postTypeProjects,
        acfFields: {
          'tag_line': 'Modern public parks for families and children.',
          'project_details': [
            {'label': 'Community', 'text': 'Haiti'},
            {'label': 'Status', 'text': 'In progress'},
            {'label': 'Committed', 'text': '\$9,400'},
          ],
          'related_projects': [
            {
              'id': 347,
              'title': 'Community park & playground #2',
              'acf_fields': {
                'tag_line': 'Another park project',
              },
            },
          ],
          'project_labels': {
            'back_label': 'Back to projects',
            'facts_title': 'Project quick facts',
            'related_title': 'More projects',
          },
          'donate_cta': {
            'title': 'Help fund the next one.',
            'text': 'Every gift goes straight to project funds, not overhead.',
            'button_label': 'Donate',
          },
        },
      );

      expect(project.contentFactRows, hasLength(3));
      expect(project.contentFactRows[1].label, 'Status');
      expect(project.relatedProjects.single.id, 347);
      expect(project.tagLine, contains('Modern public parks'));
      expect(project.projectLabels.backLabel, 'Back to projects');
      expect(project.donateCta.isEmpty, isFalse);
    });
  });

  group('P2 content label / CTA parsers', () {
    test('tolerates null and empty maps', () {
      expect(ContentLabels.fromJson(null), ContentLabels.empty);
      expect(ContentLabels.fromJson({}).isEmpty, isTrue);
      expect(DonateCta.fromJson(null).isEmpty, isTrue);
      expect(DonateCta.fromJson({}).buttonLabel, '');
    });

    test('fact rows keep label/text pairs', () {
      final row = ContentFactRow.fromJson({
        'label': 'Category',
        'text': 'Community',
      });
      expect(row.label, 'Category');
      expect(row.text, 'Community');
    });
  });
}
