import 'dart:convert';

import 'package:gems_core/gems_core.dart';
import 'package:gems_data_layer/gems_data_layer.dart';

import '../../core/network/apa_api_config.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/connectivity_controller.dart';
import '../models/post/paginated_posts.dart';
import '../models/post/post_model.dart';

/// Pages repository — uses [ApiService] GET query params (`post_type=page`).
class PostsRepository extends BaseRepository<PostItem> {
  PostsRepository({
    required super.apiService,
    required super.databaseService,
    required super.syncService,
  }) : super(baseEndpoint: ApiEndpoints.getAllPosts);

  static const _listCacheKey = 'get-all-posts_page';

  static String _detailsCacheKey(int postId, {String? postType}) {
    final type = (postType == null || postType.trim().isEmpty)
        ? 'default'
        : postType.trim();
    return 'get-post-details_${type}_$postId';
  }

  bool get _isOnline => ConnectivityController.currentlyOnline;

  @override
  PostItem fromJson(Map<String, dynamic> json) => PostItem.fromJson(json);

  @override
  Future<Result<List<PostItem>>> getAll({bool useCache = true}) async {
    try {
      final online = _isOnline;
      final preferCache = useCache || !online;

      if (preferCache) {
        final cached = _readCache();
        if (cached != null && cached.isNotEmpty) {
          if (online && useCache) {
            _refreshInBackground();
          }
          return Result.success(cached);
        }
      }

      if (!online) {
        return Result.failure(
          const NetworkError(message: ConnectivityController.offlineMessage),
        );
      }

      final fetched = await _fetchPages();
      if (fetched.isSuccess) {
        final items = fetched.value ?? const <PostItem>[];
        if (useCache && items.isNotEmpty) {
          await _writeCache(items);
        }
        return Result.success(items);
      }

      if (preferCache) {
        final cached = _readCache();
        if (cached != null && cached.isNotEmpty) {
          return Result.success(cached);
        }
      }

      return fetched;
    } catch (e, stackTrace) {
      final cached = _readCache();
      if (cached != null && cached.isNotEmpty) {
        return Result.success(cached);
      }
      return Result.failure(NetworkError.fromException(e, stackTrace));
    }
  }

  Future<Result<List<PostItem>>> _fetchPages() async {
    final response = await apiService.get<GetAllPostsResponse>(
      baseEndpoint,
      queryParameters: const {
        'post_type': ApaApiConfig.postTypePage,
        'posts_per_page': -1,
      },
      fromJson: (data) {
        if (data is! Map) {
          throw const FormatException('Malformed get-all-posts response');
        }
        return GetAllPostsResponse.fromJson(
          Map<String, dynamic>.from(data),
        );
      },
    );

    if (!response.success || response.data == null) {
      return Result.failure(
        ApiError(message: response.message ?? 'Failed to fetch pages'),
      );
    }

    final payload = response.data!;
    if (!payload.success) {
      return Result.failure(
        const ApiError(message: 'Pages request was unsuccessful'),
      );
    }

    return Result.success(payload.items);
  }

  Future<void> _refreshInBackground() async {
    if (!_isOnline) return;
    try {
      final fetched = await _fetchPages();
      if (fetched.isSuccess && (fetched.value?.isNotEmpty ?? false)) {
        await _writeCache(fetched.value!);
      }
    } catch (_) {
      // Keep cached data if a background refresh fails.
    }
  }

  List<PostItem>? _readCache() {
    final cachedJson = databaseService.get<String>(_listCacheKey);
    if (cachedJson == null) return null;
    try {
      final decoded = jsonDecode(cachedJson);
      if (decoded is! List) return null;
      final items = decoded
          .whereType<Map>()
          .map((e) => fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return items.isEmpty ? null : items;
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCache(List<PostItem> items) async {
    await databaseService.save(
      _listCacheKey,
      jsonEncode(items.map((item) => item.toJson()).toList()),
    );
  }

  /// Fetches a CMS item via `get-post-details`.
  ///
  /// Pass [postType] for single news (`post`) / project (`projects`) details.
  /// Optional [slug] resolves by slug when [postId] is unavailable.
  Future<Result<PostItem>> getPostDetails(
    int postId, {
    String? postType,
    String? slug,
    bool useCache = true,
  }) async {
    final trimmedSlug = slug?.trim() ?? '';
    if (postId <= 0 && trimmedSlug.isEmpty) {
      return Result.failure(
        const ApiError(message: 'Invalid page id'),
      );
    }

    try {
      final online = _isOnline;
      final preferCache = useCache || !online;

      if (preferCache && postId > 0) {
        final cached = _readDetailsCache(postId, postType: postType);
        if (cached != null) {
          if (online && useCache) {
            _refreshDetailsInBackground(postId, postType: postType);
          }
          return Result.success(cached);
        }
      }

      if (!online) {
        return Result.failure(
          const NetworkError(message: ConnectivityController.offlineMessage),
        );
      }

      final fetched = await _fetchPostDetails(
        postId,
        postType: postType,
        slug: trimmedSlug.isEmpty ? null : trimmedSlug,
        cacheBust: !useCache,
      );
      if (fetched.isSuccess) {
        final item = fetched.value!;
        await _writeDetailsCache(item.id > 0 ? item.id : postId, item,
            postType: postType);
        return Result.success(item);
      }

      if (preferCache && postId > 0) {
        final cached = _readDetailsCache(postId, postType: postType);
        if (cached != null) {
          return Result.success(cached);
        }
      }

      return fetched;
    } catch (e, stackTrace) {
      if (postId > 0) {
        final cached = _readDetailsCache(postId, postType: postType);
        if (cached != null) {
          return Result.success(cached);
        }
      }
      return Result.failure(NetworkError.fromException(e, stackTrace));
    }
  }

  Future<Result<PostItem>> _fetchPostDetails(
    int postId, {
    String? postType,
    String? slug,
    bool cacheBust = false,
  }) async {
    final response = await apiService.get<PostItem>(
      ApiEndpoints.getPostDetails,
      queryParameters: {
        if (postId > 0) 'post_id': postId,
        if (slug != null && slug.isNotEmpty) 'slug': slug,
        if (postType != null && postType.trim().isNotEmpty)
          'post_type': postType.trim(),
        if (cacheBust) '_': DateTime.now().millisecondsSinceEpoch,
      },
      fromJson: (data) {
        if (data is! Map) {
          throw const FormatException('Malformed get-post-details response');
        }
        final map = Map<String, dynamic>.from(data);
        if (map['success'] != true) {
          throw const FormatException('get-post-details was unsuccessful');
        }
        // Preserve list payloads / pagination / single-item extras inside
        // acf_fields so extensions can read them without Freezed changes.
        final acf = Map<String, dynamic>.from(
          (map['acf_fields'] is Map)
              ? map['acf_fields'] as Map
              : <String, dynamic>{},
        );
        var touched = false;
        for (final key in const [
          'posts',
          'projects',
          'featured_post',
          'pagination',
          'total_projects',
          'count',
          'news_facts',
          'related_posts',
          'news_labels',
          'project_details',
          'related_projects',
          'project_labels',
          'donate_cta',
          'site_logo_url',
        ]) {
          if (!map.containsKey(key)) continue;
          acf[key] = map[key];
          touched = true;
        }
        if (touched) {
          map['acf_fields'] = acf;
        }
        return PostItem.fromJson(map);
      },
    );

    if (!response.success || response.data == null) {
      return Result.failure(
        ApiError(message: response.message ?? 'Failed to fetch page details'),
      );
    }

    return Result.success(response.data!);
  }

  Future<void> _refreshDetailsInBackground(
    int postId, {
    String? postType,
  }) async {
    if (!_isOnline) return;
    try {
      final fetched = await _fetchPostDetails(
        postId,
        postType: postType,
        cacheBust: true,
      );
      if (fetched.isSuccess && fetched.value != null) {
        await _writeDetailsCache(postId, fetched.value!, postType: postType);
      }
    } catch (_) {
      // Keep cached data if a background refresh fails.
    }
  }

  PostItem? _readDetailsCache(int postId, {String? postType}) {
    final cachedJson =
        databaseService.get<String>(_detailsCacheKey(postId, postType: postType));
    if (cachedJson == null) return null;
    try {
      return fromJson(
        Map<String, dynamic>.from(jsonDecode(cachedJson) as Map),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeDetailsCache(
    int postId,
    PostItem item, {
    String? postType,
  }) async {
    await databaseService.save(
      _detailsCacheKey(postId, postType: postType),
      jsonEncode(item.toJson()),
    );
  }

  static String _mediaCacheKey(int mediaId) => 'wp-media-url_$mediaId';

  /// `GET /ansanm-pou-haiti/v1/get-paginated-posts` for Projects/News load-more.
  Future<Result<PaginatedPostsResult>> getPaginatedPosts({
    required String postType,
    required int limit,
    required int offset,
    int? excludeId,
    String? search,
  }) async {
    if (!_isOnline) {
      return Result.failure(
        const NetworkError(message: ConnectivityController.offlineMessage),
      );
    }

    try {
      final response = await apiService.get<PaginatedPostsResult>(
        ApiEndpoints.getPaginatedPosts,
        queryParameters: {
          'post_type': postType,
          'limit': limit,
          'offset': offset,
          if (excludeId != null && excludeId > 0) 'exclude': excludeId,
          if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        },
        fromJson: (data) {
          if (data is! Map) {
            throw const FormatException('Malformed get-paginated-posts response');
          }
          return PaginatedPostsResult.fromJson(Map<String, dynamic>.from(data));
        },
      );

      if (!response.success || response.data == null) {
        return Result.failure(
          ApiError(
            message: response.message ?? 'Failed to load more posts',
          ),
        );
      }

      return Result.success(response.data!);
    } catch (e, stackTrace) {
      return Result.failure(NetworkError.fromException(e, stackTrace));
    }
  }

  /// Resolves a WordPress attachment id to its `source_url`.
  Future<String?> mediaSourceUrl(int mediaId) async {
    if (mediaId <= 0) return null;

    final cached = databaseService.get<String>(_mediaCacheKey(mediaId));
    if (cached != null && cached.trim().isNotEmpty) return cached.trim();

    if (!_isOnline) return null;

    try {
      final response = await apiService.get<Map<String, dynamic>>(
        '${ApiEndpoints.wpMedia}/$mediaId',
        fromJson: (data) {
          if (data is! Map) {
            throw const FormatException('Malformed media response');
          }
          return Map<String, dynamic>.from(data);
        },
      );
      if (!response.success || response.data == null) return null;
      final url = response.data!['source_url']?.toString().trim() ?? '';
      if (url.isEmpty) return null;
      await databaseService.save(_mediaCacheKey(mediaId), url);
      return url;
    } catch (_) {
      return null;
    }
  }
}
