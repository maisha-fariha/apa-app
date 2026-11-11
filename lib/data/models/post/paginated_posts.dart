import 'post_model.dart';

/// Response from `GET /ansanm-pou-haiti/v1/get-paginated-posts`.
class PaginatedPostsResult {
  const PaginatedPostsResult({
    required this.posts,
    required this.totalPosts,
    required this.hasMore,
  });

  final List<PostItem> posts;
  final int totalPosts;
  final bool hasMore;

  factory PaginatedPostsResult.fromJson(Map<String, dynamic> json) {
    final postsRaw = json['posts'];
    final posts = <PostItem>[];
    if (postsRaw is List) {
      for (final item in postsRaw) {
        if (item is! Map) continue;
        posts.add(PostItem.fromJson(Map<String, dynamic>.from(item)));
      }
    }

    final total = _asInt(json['total_posts']) ??
        _asInt(json['total']) ??
        _asInt(json['count']) ??
        posts.length;

    final hasMoreFlag = json['has_more'];
    final hasMore = hasMoreFlag == true ||
        hasMoreFlag == 1 ||
        hasMoreFlag == '1' ||
        hasMoreFlag == 'true';

    return PaginatedPostsResult(
      posts: posts,
      totalPosts: total,
      hasMore: hasMore,
    );
  }
}

/// Pagination metadata embedded in page `get-post-details` responses.
class PageListPagination {
  const PageListPagination({
    required this.hasMore,
    required this.perPage,
    required this.loadMoreCount,
    required this.page,
    required this.totalPages,
  });

  final bool hasMore;
  final int perPage;
  final int loadMoreCount;
  final int page;
  final int totalPages;

  static const empty = PageListPagination(
    hasMore: false,
    perPage: 0,
    loadMoreCount: 0,
    page: 1,
    totalPages: 1,
  );

  factory PageListPagination.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return empty;

    final hasMoreFlag = json['has_more'];
    final hasMore = hasMoreFlag == true ||
        hasMoreFlag == 1 ||
        hasMoreFlag == '1' ||
        hasMoreFlag == 'true';

    final perPage = _asInt(json['per_page']) ?? 0;
    final loadMore = _asInt(json['load_more_count']) ?? perPage;

    return PageListPagination(
      hasMore: hasMore,
      perPage: perPage,
      loadMoreCount: loadMore > 0 ? loadMore : perPage,
      page: _asInt(json['page']) ?? 1,
      totalPages: _asInt(json['total_pages']) ?? 1,
    );
  }
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value.toString());
}
