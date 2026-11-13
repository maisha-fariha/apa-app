import '../../../data/models/post/post_model.dart';

/// CMS labels for the News listing (`news_grid` + `news_messages`).
class NewsPageContent {
  const NewsPageContent({
    required this.hideHeader,
    required this.topTagLine,
    required this.headingTextOne,
    required this.headingTextTwo,
    required this.lastContent,
    required this.imageUrl,
    required this.readMoreLabel,
    required this.loadingLabel,
    required this.endMessage,
    required this.emptyTitle,
    required this.emptyMessage,
  });

  final bool hideHeader;
  final String topTagLine;
  final String headingTextOne;
  final String headingTextTwo;
  final String lastContent;
  final String? imageUrl;
  final String readMoreLabel;
  final String loadingLabel;
  final String endMessage;
  final String emptyTitle;
  final String emptyMessage;

  bool get hasHeaderText =>
      topTagLine.isNotEmpty ||
      headingTextOne.isNotEmpty ||
      headingTextTwo.isNotEmpty ||
      lastContent.isNotEmpty;

  bool get showHeader => !hideHeader && (hasHeaderText || imageUrl != null);

  factory NewsPageContent.fromPost(PostItem page) {
    final acf = page.acfFields;
    final header = _asMap(acf['common_header']);
    final grid = _asMap(acf['news_grid']);
    final messages = _asMap(acf['news_messages']);

    return NewsPageContent(
      hideHeader: _asBool(header['hide_header']),
      topTagLine: _asString(header['top_tag_line']),
      headingTextOne: _asString(header['heading_text_one']),
      headingTextTwo: _asString(header['heading_text_two']),
      lastContent: _asString(header['last_content']),
      imageUrl: page.featuredImageUrl,
      readMoreLabel: _asString(grid['read_more_label']).isNotEmpty
          ? _asString(grid['read_more_label'])
          : 'Read More',
      loadingLabel: _asString(messages['loading_label']).isNotEmpty
          ? _asString(messages['loading_label'])
          : 'Loading more stories...',
      endMessage: _asString(messages['end_message']).isNotEmpty
          ? _asString(messages['end_message'])
          : 'You’ve reached the end of our latest news.',
      emptyTitle: _asString(messages['empty_title']).isNotEmpty
          ? _asString(messages['empty_title'])
          : 'No news articles found',
      emptyMessage: _asString(messages['empty_message']).isNotEmpty
          ? _asString(messages['empty_message'])
          : 'We are actively preparing new updates and stories from Haiti. Please check back soon.',
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return {};
}

String _asString(dynamic value) {
  if (value == null || value is bool) return '';
  return value.toString().trim();
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }
  return false;
}
