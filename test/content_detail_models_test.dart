import 'package:apa/data/models/post/content_detail_models.dart';
import 'package:apa/data/models/post/post_item_extensions.dart';
import 'package:apa/data/models/post/post_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses donate CTA and news labels from Global Settings shape', () {
    final settings = PostItem(
      id: 5,
      title: 'Global Settings',
      acfFields: {
        'donate_cta': {
          'title': 'Help fund the next one.',
          'text': 'Every gift goes straight to project funds, not overhead.',
          'button_label': 'Donate',
        },
        'news_single': {
          'back_label': 'Back to news',
          'facts_title': 'Quick facts',
          'related_title': 'More stories',
        },
        'site_logo_url': 'https://example.com/logo.png',
      },
    );

    expect(settings.donateCta.title, 'Help fund the next one.');
    expect(settings.donateCta.buttonLabel, 'Donate');
    expect(settings.newsLabels.backLabel, 'Back to news');
    expect(settings.siteLogoUrl, 'https://example.com/logo.png');
  });

  test('parses single news fact rows and related posts', () {
    final article = PostItem(
      id: 273,
      title: 'Creating opportunities',
      type: 'post',
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
      },
    );

    expect(article.contentFactRows, hasLength(2));
    expect(article.contentFactRows.first.label, 'Category');
    expect(article.relatedNewsPosts.single.id, 278);
    expect(article.newsLabels.relatedTitle, 'More stories');
  });

  test('ContentLabels.fromJson tolerates empty maps', () {
    expect(ContentLabels.fromJson(null), ContentLabels.empty);
    expect(DonateCta.fromJson({}).isEmpty, isTrue);
  });
}
