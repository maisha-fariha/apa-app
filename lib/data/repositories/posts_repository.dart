import 'dart:convert';

import 'package:gems_core/gems_core.dart';
import 'package:gems_data_layer/gems_data_layer.dart';

import '../../core/network/apa_api_config.dart';
import '../../core/network/api_endpoints.dart';
import '../models/post/post_model.dart';

/// Pages repository — uses [ApiService] GET query params (`post_type=page`).
class PostsRepository extends BaseRepository<PostItem> {
  PostsRepository({
    required super.apiService,
    required super.databaseService,
    required super.syncService,
  }) : super(baseEndpoint: ApiEndpoints.getAllPosts);

  static const _listCacheKey = 'get-all-posts_page';

  static String _detailsCacheKey(int postId) => 'get-post-details_$postId';

  @override
  PostItem fromJson(Map<String, dynamic> json) => PostItem.fromJson(json);

  @override
  Future<Result<List<PostItem>>> getAll({bool useCache = true}) async {
    try {
      if (useCache) {
        final cached = _readCache();
        if (cached != null && cached.isNotEmpty) {
          _refreshInBackground();
          return Result.success(cached);
        }
      }

      final fetched = await _fetchPages();
      if (fetched.isSuccess) {
        final items = fetched.value ?? const <PostItem>[];
        if (useCache && items.isNotEmpty) {
          await _writeCache(items);
        }
        return Result.success(items);
      }

      if (useCache) {
        final cached = _readCache();
        if (cached != null && cached.isNotEmpty) {
          return Result.success(cached);
        }
      }

      return fetched;
    } catch (e, stackTrace) {
      if (useCache) {
        final cached = _readCache();
        if (cached != null && cached.isNotEmpty) {
          return Result.success(cached);
        }
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

  /// Fetches a single page by WordPress post id (`get-post-details`).
  Future<Result<PostItem>> getPostDetails(
    int postId, {
    bool useCache = true,
  }) async {
    if (postId <= 0) {
      return Result.failure(
        const ApiError(message: 'Invalid page id'),
      );
    }

    try {
      if (useCache) {
        final cached = _readDetailsCache(postId);
        if (cached != null) {
          _refreshDetailsInBackground(postId);
          return Result.success(cached);
        }
      }

      final fetched = await _fetchPostDetails(postId, cacheBust: !useCache);
      if (fetched.isSuccess) {
        final item = fetched.value!;
        await _writeDetailsCache(postId, item);
        return Result.success(item);
      }

      if (useCache) {
        final cached = _readDetailsCache(postId);
        if (cached != null) {
          return Result.success(cached);
        }
      }

      return fetched;
    } catch (e, stackTrace) {
      if (useCache) {
        final cached = _readDetailsCache(postId);
        if (cached != null) {
          return Result.success(cached);
        }
      }
      return Result.failure(NetworkError.fromException(e, stackTrace));
    }
  }

  Future<Result<PostItem>> _fetchPostDetails(
    int postId, {
    bool cacheBust = false,
  }) async {
    final response = await apiService.get<PostItem>(
      ApiEndpoints.getPostDetails,
      queryParameters: {
        'post_id': postId,
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
        // Preserve top-level `posts` inside `acf_fields` so extensions
        // can access news articles without changing the Freezed model.
        if (map.containsKey('posts') && map['posts'] is List) {
          final acf = Map<String, dynamic>.from(
            (map['acf_fields'] is Map)
                ? map['acf_fields'] as Map
                : <String, dynamic>{},
          );
          acf['posts'] = map['posts'];
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

  Future<void> _refreshDetailsInBackground(int postId) async {
    try {
      final fetched = await _fetchPostDetails(postId, cacheBust: true);
      if (fetched.isSuccess && fetched.value != null) {
        await _writeDetailsCache(postId, fetched.value!);
      }
    } catch (_) {
      // Keep cached data if a background refresh fails.
    }
  }

  PostItem? _readDetailsCache(int postId) {
    final cachedJson = databaseService.get<String>(_detailsCacheKey(postId));
    if (cachedJson == null) return null;
    try {
      return fromJson(
        Map<String, dynamic>.from(jsonDecode(cachedJson) as Map),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeDetailsCache(int postId, PostItem item) async {
    await databaseService.save(
      _detailsCacheKey(postId),
      jsonEncode(item.toJson()),
    );
  }

  static String _mediaCacheKey(int mediaId) => 'wp-media-url_$mediaId';

  /// Resolves a WordPress attachment id to its `source_url`.
  Future<String?> mediaSourceUrl(int mediaId) async {
    if (mediaId <= 0) return null;

    final cached = databaseService.get<String>(_mediaCacheKey(mediaId));
    if (cached != null && cached.trim().isNotEmpty) return cached.trim();

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
