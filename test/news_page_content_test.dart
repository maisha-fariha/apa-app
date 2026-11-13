import 'package:apa/data/models/post/post_model.dart';
import 'package:apa/features/news/domain/news_page_content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses news_grid and news_messages from get-post-details', () {
    final page = PostItem.fromJson({
      'id': 53,
      'title': 'News',
      'template': 'page-news.php',
      'featured_image': {
        'url': 'https://example.com/news.jpg',
      },
      'acf_fields': {
        'common_header': {
          'top_tag_line': 'News & updates',
          'heading_text_one': 'Latest ',
          'heading_text_two': 'News.',
          'last_content':
              'Stay updated with our latest news, project updates, and community impact.',
        },
        'news_grid': {
          'initial_posts': '4',
          'load_more_posts': '4',
          'read_more_label': 'Read More',
        },
        'news_messages': {
          'loading_label': 'Loading more stories...',
          'end_message': 'You’ve reached the end of our latest news.',
          'empty_title': 'No news articles found',
          'empty_message': 'Please check back soon.',
        },
      },
    });

    final content = NewsPageContent.fromPost(page);
    expect(content.topTagLine, 'News & updates');
    expect(content.headingTextOne, 'Latest');
    expect(content.headingTextTwo, 'News.');
    expect(content.readMoreLabel, 'Read More');
    expect(content.loadingLabel, 'Loading more stories...');
    expect(content.endMessage, contains('end of our latest news'));
    expect(content.showHeader, isTrue);
  });
}
