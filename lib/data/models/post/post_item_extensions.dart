import 'content_detail_models.dart';
import 'paginated_posts.dart';
import 'post_model.dart';
import '../../../core/utils/html_utils.dart';

extension PostItemProjectsX on PostItem {
  Map<String, dynamic> get commonHeader {
    final raw = acfFields['common_header'];
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return const {};
  }

  /// First-page project cards from `get-post-details`.
  ///
  /// Prefers the collection field `projects`, falls back to `related_projects`.
  List<PostItem> get relatedProjects {
    final raw = acfFields['projects'] ?? acfFields['related_projects'];
    if (raw is! List) return const [];

    return raw
        .whereType<Map>()
        .map((item) => PostItem.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  PageListPagination get listPagination {
    final raw = acfFields['pagination'];
    if (raw is Map) {
      return PageListPagination.fromJson(Map<String, dynamic>.from(raw));
    }
    return PageListPagination.empty;
  }

  String? get footerHtml {
    final raw = acfFields['footer'];
    if (raw is String && raw.trim().isNotEmpty) {
      return raw.trim();
    }
    return null;
  }

  String? get tagLine {
    final raw = acfFields['tag_line'];
    if (raw is String && raw.trim().isNotEmpty) {
      return raw.trim();
    }
    return null;
  }

  String? get projectTypeLabel {
    for (final entry in taxonomies) {
      if (entry is! Map) continue;
      final map = Map<String, dynamic>.from(entry);
      final projectType = map['project_type'];
      if (projectType is! Map) continue;

      final terms = projectType['terms'];
      if (terms is! List || terms.isEmpty) continue;

      final first = terms.first;
      if (first is! Map) continue;

      final name = first['name'];
      if (name is String && name.trim().isNotEmpty) {
        return HtmlUtils.decodeEntities(name.trim());
      }
    }
    return null;
  }

  List<String> get contentBullets => HtmlUtils.bulletsFromHtml(content);
}

extension PostItemNewsX on PostItem {
  /// News articles embedded in the `get-post-details` response for news pages.
  List<PostItem> get newsPosts {
    final raw = acfFields['posts'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) => _parseNewsPost(Map<String, dynamic>.from(item)))
        .toList();
  }

  static PostItem _parseNewsPost(Map<String, dynamic> json) {
    // Merge root-level news fields into acf_fields so extensions can read them.
    final acf = Map<String, dynamic>.from(
      (json['acf_fields'] is Map)
          ? json['acf_fields'] as Map
          : <String, dynamic>{},
    );
    for (final key in [
      'author',
      'author_name',
      'category',
      'is_featured',
      'quick_facts',
    ]) {
      if (json.containsKey(key) && !acf.containsKey(key)) {
        acf[key] = json[key];
      }
    }
    json['acf_fields'] = acf;
    return PostItem.fromJson(json);
  }

  /// Featured story from `featured_post`, else first `is_featured` post.
  PostItem? get featuredPost {
    final raw = acfFields['featured_post'];
    if (raw is Map) {
      return _parseNewsPost(Map<String, dynamic>.from(raw));
    }

    final posts = newsPosts;
    if (posts.isEmpty) return null;
    for (final p in posts) {
      final flag = p.acfFields['is_featured'];
      if (flag == true ||
          flag == 1 ||
          flag == '1' ||
          flag == 'true') {
        return p;
      }
    }
    return posts.first;
  }

  /// All non-featured posts for the "more stories" list.
  List<PostItem> get nonFeaturedPosts {
    final featured = featuredPost;
    if (featured == null) return newsPosts;
    return newsPosts.where((p) => p.id != featured.id).toList();
  }

  /// Category string from the `category` field or taxonomies.
  String get categoryLabel {
    // Direct `category` field on post items from the news response.
    final direct = acfFields['category'] ?? _taxonomyCategory;
    if (direct is String && direct.trim().isNotEmpty) {
      return HtmlUtils.decodeEntities(direct.trim());
    }
    return _taxonomyCategory ?? '';
  }

  String? get _taxonomyCategory {
    for (final entry in taxonomies) {
      if (entry is! Map) continue;
      final map = Map<String, dynamic>.from(entry);
      final cat = map['category'];
      if (cat is! Map) continue;
      final terms = cat['terms'];
      if (terms is! List || terms.isEmpty) continue;
      final first = terms.first;
      if (first is! Map) continue;
      final name = first['name'];
      if (name is String && name.trim().isNotEmpty) {
        return HtmlUtils.decodeEntities(name.trim());
      }
    }
    return null;
  }

  /// Quick facts map from the `quick_facts` field.
  Map<String, String> get quickFacts {
    final raw = acfFields['quick_facts'];
    if (raw is! Map) return const {};
    final result = <String, String>{};
    for (final entry in raw.entries) {
      if (entry.value != null &&
          entry.value.toString().trim().isNotEmpty) {
        result[entry.key.toString()] = entry.value.toString().trim();
      }
    }
    return result;
  }

  /// Featured quote from acf_fields.
  String? get featuredQuote {
    final raw = acfFields['featured_quote'];
    if (raw is String && raw.trim().isNotEmpty) return raw.trim();
    return null;
  }

  /// Featured quote author from acf_fields.
  String? get featuredQuoteAuthor {
    final raw = acfFields['featured_quote_author'];
    if (raw is String && raw.trim().isNotEmpty) return raw.trim();
    return null;
  }

  /// Author name — from `author_name` or `author` field at root of news post JSON.
  String get authorName {
    // These are stored directly in the post JSON, not in acf_fields.
    // Since we use PostItem.fromJson, they aren't captured by default.
    // The API response has `author_name` at the root level of each post.
    // We inject it via the `acf_fields` approach or read it from there.
    final raw = acfFields['author_name'] ?? acfFields['author'];
    if (raw is String && raw.trim().isNotEmpty) return raw.trim();
    return '';
  }

  /// Location from acf_fields.
  String? get location {
    final raw = acfFields['location'];
    if (raw is String && raw.trim().isNotEmpty) return raw.trim();
    return null;
  }

  /// Whether this post is featured.
  bool get isFeatured {
    final flag = acfFields['is_featured'];
    return flag == true || flag == 1 || flag == '1' || flag == 'true';
  }
}

extension PostItemContentDetailX on PostItem {
  /// Related news cards from a single-news `get-post-details` response.
  List<PostItem> get relatedNewsPosts {
    final raw = acfFields['related_posts'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) => PostItemNewsX._parseNewsPost(Map<String, dynamic>.from(item)))
        .toList();
  }

  /// Fact rows from single news (`news_facts`) or single project (`project_details`).
  List<ContentFactRow> get contentFactRows {
    final raw = acfFields['news_facts'] ??
        acfFields['project_details'] ??
        acfFields['details'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) => ContentFactRow.fromJson(Map<String, dynamic>.from(item)))
        .where((row) => row.label.isNotEmpty || row.text.isNotEmpty)
        .toList();
  }

  ContentLabels get newsLabels {
    final raw = acfFields['news_labels'] ?? acfFields['news_single'];
    if (raw is Map) {
      return ContentLabels.fromJson(Map<String, dynamic>.from(raw));
    }
    return ContentLabels.empty;
  }

  ContentLabels get projectLabels {
    final raw = acfFields['project_labels'] ?? acfFields['project_single'];
    if (raw is Map) {
      return ContentLabels.fromJson(Map<String, dynamic>.from(raw));
    }
    return ContentLabels.empty;
  }

  DonateCta get donateCta {
    final raw = acfFields['donate_cta'];
    if (raw is Map) {
      return DonateCta.fromJson(Map<String, dynamic>.from(raw));
    }
    return DonateCta.empty;
  }

  String? get siteLogoUrl {
    final root = acfFields['site_logo_url'];
    if (root is String && root.trim().isNotEmpty) return root.trim();
    final nested = acfFields['site_logo'];
    if (nested is Map) {
      final url = nested['url'] ?? nested['site_logo_url'];
      if (url is String && url.trim().isNotEmpty) return url.trim();
    }
    if (nested is String && nested.trim().isNotEmpty) return nested.trim();
    return null;
  }
}
