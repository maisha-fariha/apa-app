import 'package:apa/core/network/apa_api_config.dart';
import 'package:apa/core/network/api_endpoints.dart';
import 'package:apa/data/models/post/paginated_posts.dart';
import 'package:apa/data/models/post/post_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// P3 — Search posts API, cancel subscription, local/staging baseUrl.
void main() {
  group('P3 search posts API', () {
    test('paginated endpoint is the search entry point', () {
      expect(
        ApiEndpoints.getPaginatedPosts,
        '/ansanm-pou-haiti/v1/get-paginated-posts',
      );
      expect(ApaApiConfig.postTypePost, 'post');
    });

    test('parses search-style paginated response', () {
      final result = PaginatedPostsResult.fromJson({
        'posts': [
          {
            'id': 273,
            'title': 'Creating opportunities through community development',
            'acf_fields': {'category': 'Community'},
          },
        ],
        'total_posts': 1,
        'has_more': false,
      });

      expect(result.posts, hasLength(1));
      expect(result.posts.single.title, contains('community'));
      expect(result.hasMore, isFalse);
      expect(result.totalPosts, 1);
    });

    test('search result items remain PostItem-compatible', () {
      final post = PostItem.fromJson({
        'id': 278,
        'title': 'Youth vocational apprenticeship launched with local builders',
        'type': 'post',
        'acf_fields': {
          'category': 'Education',
        },
      });

      expect(post.id, 278);
      expect(post.type, ApaApiConfig.postTypePost);
    });
  });

  group('P3 cancel subscription API', () {
    test('cancel path matches Postman collection', () {
      expect(
        ApiEndpoints.stripeSubscriptionCancel('sub_abc'),
        '/encoderit-stripe/v1/subscriptions/sub_abc/cancel',
      );
    });

    test('subscription status path stays adjacent to cancel', () {
      expect(
        ApiEndpoints.stripeSubscriptionStatus('sub_abc'),
        '/encoderit-stripe/v1/subscriptions/sub_abc',
      );
      expect(
        ApiEndpoints.stripeSubscriptionCancel('sub_abc'),
        '${ApiEndpoints.stripeSubscriptionStatus('sub_abc')}/cancel',
      );
    });
  });

  group('P3 local / staging / production baseUrl', () {
    test('local matches Postman Local environment', () {
      expect(
        ApaApiConfig.localBaseUrl,
        'http://localhost/ansanm-pou-haiti/wp-json',
      );
    });

    test('development uses remote staging, not localhost', () {
      expect(
        ApaApiConfig.developmentBaseUrl,
        'https://encoder-staging.space/ansanm-pou-haiti/wp-json',
      );
      expect(ApaApiConfig.developmentBaseUrl.contains('localhost'), isFalse);
    });

    test('production matches live site', () {
      expect(
        ApaApiConfig.productionBaseUrl,
        'https://ansanmpouayiti.com/wp-json',
      );
    });

    test('default environment remains production (no accidental local)', () {
      expect(ApaApiConfig.environment, AppEnvironment.production);
      expect(ApaApiConfig.isProduction, isTrue);
      // Without APA_BASE_URL override, baseUrl follows environment.
      if (ApaApiConfig.baseUrlOverride.trim().isEmpty) {
        expect(ApaApiConfig.baseUrl, ApaApiConfig.productionBaseUrl);
      }
    });

    test('AppEnvironment exposes local, development, and production', () {
      expect(AppEnvironment.values, containsAll([
        AppEnvironment.local,
        AppEnvironment.development,
        AppEnvironment.production,
      ]));
    });
  });
}
