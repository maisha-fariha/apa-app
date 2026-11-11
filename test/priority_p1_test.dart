import 'package:apa/core/network/api_endpoints.dart';
import 'package:apa/data/models/post/paginated_posts.dart';
import 'package:apa/data/models/post/post_item_extensions.dart';
import 'package:apa/data/models/post/post_model.dart';
import 'package:apa/data/repositories/stripe_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// P1 — Stripe request body alignment + get-paginated-posts load-more.
void main() {
  group('P1 Stripe payment / subscription body', () {
    test('custom one-time body sends payment_type=custom, source=app, amount',
        () {
      final body = StripeRepository.oneTimePaymentBody(
        email: 'donor@example.com',
        name: 'Ada Lovelace',
        currency: 'usd',
        custom: true,
        amountDollars: 42,
      );

      expect(body['payment_type'], 'custom');
      expect(body['source'], ApiEndpoints.stripeSourceApp);
      expect(body['source'], 'app');
      expect(body['amount'], 42);
      expect(body['currency'], 'usd');
      expect(body['email'], 'donor@example.com');
      expect(body['name'], 'Ada Lovelace');
      expect(body['return_url'], ApiEndpoints.stripeReturnUrl);
      expect(body.containsKey('price_id'), isFalse);
    });

    test(
        'predefined one-time body sends payment_type=predefined + price_id, no amount',
        () {
      final body = StripeRepository.oneTimePaymentBody(
        email: 'donor@example.com',
        name: 'Ada Lovelace',
        currency: 'usd',
        custom: false,
        priceId: 'price_one_time_20',
      );

      expect(body['payment_type'], 'predefined');
      expect(body['source'], 'app');
      expect(body['price_id'], 'price_one_time_20');
      expect(body.containsKey('amount'), isFalse);
      expect(body.containsKey('currency'), isFalse);
    });

    test('subscription body includes source=app and price_id', () {
      final body = StripeRepository.subscriptionBody(
        priceId: 'price_month_20',
        email: 'donor@example.com',
        name: 'Ada Lovelace',
      );

      expect(body['price_id'], 'price_month_20');
      expect(body['source'], 'app');
      expect(body['email'], 'donor@example.com');
      expect(body['name'], 'Ada Lovelace');
      expect(body['return_url'], ApiEndpoints.stripeReturnUrl);
      expect(body.containsKey('payment_type'), isFalse);
    });
  });

  group('P1 get-paginated-posts models', () {
    test('endpoint path matches collection', () {
      expect(
        ApiEndpoints.getPaginatedPosts,
        '/ansanm-pou-haiti/v1/get-paginated-posts',
      );
    });

    test('parses paginated posts response with has_more', () {
      final result = PaginatedPostsResult.fromJson({
        'posts': [
          {'id': 101, 'title': 'Project A', 'acf_fields': {}},
          {'id': 102, 'title': 'Project B', 'acf_fields': {}},
        ],
        'total_posts': 11,
        'has_more': true,
      });

      expect(result.posts, hasLength(2));
      expect(result.posts.first.id, 101);
      expect(result.totalPosts, 11);
      expect(result.hasMore, isTrue);
    });

    test('parses page list pagination from get-post-details', () {
      final pagination = PageListPagination.fromJson({
        'has_more': '1',
        'per_page': 9,
        'load_more_count': 3,
        'page': 1,
        'total_pages': 4,
      });

      expect(pagination.hasMore, isTrue);
      expect(pagination.perPage, 9);
      expect(pagination.loadMoreCount, 3);
      expect(pagination.page, 1);
      expect(pagination.totalPages, 4);
    });

    test('empty pagination is safe', () {
      expect(PageListPagination.fromJson(null), PageListPagination.empty);
      expect(PageListPagination.fromJson({}).hasMore, isFalse);
    });
  });

  group('P1 projects / news first-page fields', () {
    test('relatedProjects prefers projects over related_projects', () {
      final page = PostItem(
        id: 44,
        title: 'Projects',
        acfFields: {
          'projects': [
            {'id': 1, 'title': 'From projects', 'acf_fields': {}},
          ],
          'related_projects': [
            {'id': 2, 'title': 'From related', 'acf_fields': {}},
          ],
          'pagination': {
            'has_more': true,
            'per_page': 9,
            'load_more_count': 9,
          },
        },
      );

      expect(page.relatedProjects.single.id, 1);
      expect(page.listPagination.hasMore, isTrue);
      expect(page.listPagination.perPage, 9);
    });

    test('news nonFeaturedPosts excludes featured_post', () {
      final page = PostItem(
        id: 53,
        title: 'News',
        acfFields: {
          'featured_post': {
            'id': 10,
            'title': 'Featured',
            'is_featured': true,
            'acf_fields': {},
          },
          'posts': [
            {
              'id': 10,
              'title': 'Featured',
              'is_featured': true,
              'acf_fields': {},
            },
            {
              'id': 11,
              'title': 'Other',
              'is_featured': false,
              'acf_fields': {},
            },
          ],
          'pagination': {'has_more': true, 'load_more_count': 3},
        },
      );

      expect(page.featuredPost?.id, 10);
      expect(page.nonFeaturedPosts.map((p) => p.id), [11]);
      expect(page.listPagination.loadMoreCount, 3);
    });
  });
}
