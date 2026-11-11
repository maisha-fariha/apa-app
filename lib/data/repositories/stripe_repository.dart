import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:gems_core/gems_core.dart';
import 'package:gems_data_layer/gems_data_layer.dart';

import '../../core/network/apa_api_config.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/connectivity_controller.dart';
import '../models/stripe/stripe_models.dart';

class StripeRepository {
  StripeRepository({
    required this.apiService,
    required this.databaseService,
  });

  final ApiService apiService;
  final DatabaseService databaseService;

  static const _configCacheKey = 'stripe-public-config';
  static const _pricesCacheKey = 'stripe-products-prices';
  static const _lastSubscriptionKey = 'stripe-last-subscription';

  bool get _isOnline => ConnectivityController.currentlyOnline;

  Future<Result<StripePublicConfig>> getConfig({bool useCache = true}) async {
    try {
      final online = _isOnline;
      final preferCache = useCache || !online;

      if (preferCache) {
        final cached = _readConfigCache();
        if (cached != null) {
          if (online && useCache) {
            _refreshConfigInBackground();
          }
          return Result.success(cached);
        }
      }

      if (!online) {
        return Result.failure(
          const NetworkError(message: ConnectivityController.offlineMessage),
        );
      }

      final fetched = await _fetchConfig();
      if (fetched.isSuccess && fetched.value != null) {
        await _writeConfigCache(fetched.value!);
      } else if (preferCache) {
        final cached = _readConfigCache();
        if (cached != null) return Result.success(cached);
      }
      return fetched;
    } catch (e, stackTrace) {
      final cached = _readConfigCache();
      if (cached != null) return Result.success(cached);
      return Result.failure(
        NetworkError(
          message: 'Unable to load payment settings. Please try again.',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<Result<List<StripePriceOption>>> getPrices({
    bool useCache = true,
  }) async {
    try {
      final online = _isOnline;
      final preferCache = useCache || !online;

      if (preferCache) {
        final cached = _readPricesCache();
        if (cached != null) {
          if (online && useCache) {
            _refreshPricesInBackground();
          }
          return Result.success(cached);
        }
      }

      if (!online) {
        return Result.failure(
          const NetworkError(message: ConnectivityController.offlineMessage),
        );
      }

      final fetched = await _fetchPrices();
      if (fetched.isSuccess && fetched.value != null) {
        await _writePricesCache(fetched.value!);
      } else if (preferCache) {
        final cached = _readPricesCache();
        if (cached != null) return Result.success(cached);
      }
      return fetched;
    } catch (e, stackTrace) {
      final cached = _readPricesCache();
      if (cached != null) return Result.success(cached);
      return Result.failure(
        NetworkError(
          message: 'Unable to load donation amounts. Please try again.',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<Result<StripePublicConfig>> _fetchConfig() async {
    final response = await apiService.get<StripePublicConfig>(
      ApiEndpoints.stripeConfig,
      fromJson: (data) {
        if (data is! Map) {
          throw const FormatException('Malformed Stripe config response');
        }
        return StripePublicConfig.fromJson(Map<String, dynamic>.from(data));
      },
    );

    if (!response.success || response.data == null) {
      return Result.failure(
        ApiError(
          message: _friendly(response.message, 'Unable to load payment settings.'),
          statusCode: response.statusCode,
        ),
      );
    }

    final config = response.data!;
    if (config.publishableKey.isEmpty) {
      return Result.failure(
        ApiError(message: 'Stripe publishable key is missing.'),
      );
    }

    return Result.success(config);
  }

  Future<Result<List<StripePriceOption>>> _fetchPrices() async {
    final response = await apiService.get<List<StripePriceOption>>(
      ApiEndpoints.stripeProducts,
      fromJson: (data) {
        if (data is! Map) {
          throw const FormatException('Malformed Stripe products response');
        }
        return StripePriceOption.listFromProductsResponse(data);
      },
    );

    if (!response.success || response.data == null) {
      return Result.failure(
        ApiError(
          message: _friendly(response.message, 'Unable to load donation amounts.'),
          statusCode: response.statusCode,
        ),
      );
    }

    return Result.success(response.data!);
  }

  Future<void> _refreshConfigInBackground() async {
    if (!_isOnline) return;
    try {
      final fetched = await _fetchConfig();
      if (fetched.isSuccess && fetched.value != null) {
        await _writeConfigCache(fetched.value!);
      }
    } catch (_) {}
  }

  Future<void> _refreshPricesInBackground() async {
    if (!_isOnline) return;
    try {
      final fetched = await _fetchPrices();
      if (fetched.isSuccess && fetched.value != null) {
        await _writePricesCache(fetched.value!);
      }
    } catch (_) {}
  }

  StripePublicConfig? _readConfigCache() {
    final cachedJson = databaseService.get<String>(_configCacheKey);
    if (cachedJson == null) return null;
    try {
      return StripePublicConfig.fromJson(
        Map<String, dynamic>.from(jsonDecode(cachedJson) as Map),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeConfigCache(StripePublicConfig config) async {
    await databaseService.save(_configCacheKey, jsonEncode(config.toJson()));
  }

  List<StripePriceOption>? _readPricesCache() {
    final cachedJson = databaseService.get<String>(_pricesCacheKey);
    if (cachedJson == null) return null;
    try {
      final decoded = jsonDecode(cachedJson);
      if (decoded is! List) return null;
      return decoded
          .whereType<Map>()
          .map((e) => StripePriceOption.fromJson(Map<String, dynamic>.from(e)))
          .where(
            (price) =>
                price.stripePriceId.isNotEmpty && price.unitAmountCents > 0,
          )
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> _writePricesCache(List<StripePriceOption> prices) async {
    await databaseService.save(
      _pricesCacheKey,
      jsonEncode(prices.map((price) => price.toJson()).toList()),
    );
  }

  /// Builds the one-time payment POST body to match the Postman collection.
  static Map<String, dynamic> oneTimePaymentBody({
    required String email,
    required String name,
    required String currency,
    required bool custom,
    int? amountDollars,
    String? priceId,
  }) {
    final body = <String, dynamic>{
      'email': email,
      'name': name,
      'source': ApiEndpoints.stripeSourceApp,
      'return_url': ApiEndpoints.stripeReturnUrl,
    };

    if (custom) {
      body['payment_type'] = 'custom';
      body['amount'] = amountDollars;
      body['currency'] = currency;
    } else {
      body['payment_type'] = 'predefined';
      body['price_id'] = priceId;
    }
    return body;
  }

  /// Builds the subscription POST body to match the Postman collection.
  static Map<String, dynamic> subscriptionBody({
    required String priceId,
    required String email,
    required String name,
  }) {
    return {
      'price_id': priceId,
      'email': email,
      'name': name,
      'source': ApiEndpoints.stripeSourceApp,
      'return_url': ApiEndpoints.stripeReturnUrl,
    };
  }

  /// Creates a one-time PaymentIntent session.
  ///
  /// Matches Postman collection:
  /// - predefined chips → `payment_type: predefined` + `price_id`
  /// - custom amount → `payment_type: custom` + `amount`
  Future<Result<StripeCheckoutSession>> createOneTimePayment({
    required String email,
    required String name,
    required String currency,
    required bool custom,
    int? amountDollars,
    String? priceId,
  }) {
    return _createSession(
      ApiEndpoints.stripePayments,
      oneTimePaymentBody(
        email: email,
        name: name,
        currency: currency,
        custom: custom,
        amountDollars: amountDollars,
        priceId: priceId,
      ),
    );
  }

  Future<Result<StripeCheckoutSession>> createSubscription({
    required String priceId,
    required String email,
    required String name,
  }) {
    return _createSession(
      ApiEndpoints.stripeSubscriptions,
      subscriptionBody(priceId: priceId, email: email, name: name),
    );
  }

  Future<Result<StripePaymentStatus>> getPaymentStatus({
    required String paymentReference,
    required String accessToken,
  }) {
    return _getStatus(
      ApiEndpoints.stripePaymentStatus(paymentReference),
      accessToken,
    );
  }

  Future<Result<StripePaymentStatus>> getSubscriptionStatus({
    required String subscriptionReference,
    required String accessToken,
  }) {
    return _getStatus(
      ApiEndpoints.stripeSubscriptionStatus(subscriptionReference),
      accessToken,
    );
  }

  /// Cancels a subscription immediately in Stripe via WordPress.
  ///
  /// Requires the `status_access_token` returned when the subscription was
  /// created (`Authorization: Bearer …`), matching the Postman collection.
  Future<Result<StripePaymentStatus>> cancelSubscription({
    required String subscriptionReference,
    required String accessToken,
  }) async {
    if (!_isOnline) {
      return Result.failure(
        const NetworkError(message: ConnectivityController.offlineMessage),
      );
    }

    final reference = subscriptionReference.trim();
    final token = accessToken.trim();
    if (reference.isEmpty || token.isEmpty) {
      return Result.failure(
        ApiError(message: 'Missing subscription reference or access token.'),
      );
    }

    try {
      final response = await apiService.post<StripePaymentStatus>(
        ApiEndpoints.stripeSubscriptionCancel(reference),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'x-api-key': ApaApiConfig.apiKey,
          },
        ),
        fromJson: (data) {
          if (data is! Map) {
            throw const FormatException('Malformed cancel subscription response');
          }
          return StripePaymentStatus.fromJson(Map<String, dynamic>.from(data));
        },
      );

      if (!response.success || response.data == null) {
        return Result.failure(
          ApiError(
            message: _friendly(
              response.message,
              'Unable to cancel the subscription.',
            ),
            statusCode: response.statusCode,
          ),
        );
      }

      await clearRememberedSubscription();
      return Result.success(response.data!);
    } catch (e, stackTrace) {
      return Result.failure(
        NetworkError(
          message: 'Unable to cancel the subscription.',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Cancels the most recent in-app subscription when credentials were stored.
  Future<Result<StripePaymentStatus>> cancelRememberedSubscription() async {
    final remembered = rememberedSubscription();
    if (remembered == null) {
      return Result.failure(
        ApiError(message: 'No subscription is available to cancel.'),
      );
    }
    return cancelSubscription(
      subscriptionReference: remembered.reference,
      accessToken: remembered.token,
    );
  }

  ({String reference, String token})? rememberedSubscription() {
    final raw = databaseService.get<String>(_lastSubscriptionKey);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final map = jsonDecode(raw);
      if (map is! Map) return null;
      final reference = map['subscription_reference']?.toString().trim() ?? '';
      final token = map['status_access_token']?.toString().trim() ?? '';
      if (reference.isEmpty || token.isEmpty) return null;
      return (reference: reference, token: token);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearRememberedSubscription() async {
    await databaseService.delete(_lastSubscriptionKey);
  }

  Future<void> _rememberSubscriptionCredentials(
    StripeCheckoutSession session,
  ) async {
    final reference = session.subscriptionReference?.trim() ?? '';
    final token = session.statusAccessToken?.trim() ?? '';
    if (reference.isEmpty || token.isEmpty) return;
    await databaseService.save(
      _lastSubscriptionKey,
      jsonEncode({
        'subscription_reference': reference,
        'status_access_token': token,
      }),
    );
  }

  /// After Stripe checkout, poll GET status so WordPress can sync from Stripe
  /// and the app only treats the gift as done when the backend says so.
  Future<Result<StripePaymentStatus>> confirmCheckoutStatus(
    StripeCheckoutSession session, {
    int attempts = 10,
    Duration delay = const Duration(milliseconds: 1500),
  }) async {
    if (!_isOnline) {
      return Result.failure(
        const NetworkError(message: ConnectivityController.offlineMessage),
      );
    }

    final token = session.statusAccessToken;
    if (token == null || token.isEmpty) {
      return Result.failure(
        ApiError(
          message: 'Missing status access token. Unable to confirm with the server.',
        ),
      );
    }

    final references = <String>[
      if (session.paymentReference != null &&
          session.paymentReference!.isNotEmpty)
        session.paymentReference!,
      if (session.subscriptionReference != null &&
          session.subscriptionReference!.isNotEmpty)
        session.subscriptionReference!,
      if (session.stripeSubscriptionId != null &&
          session.stripeSubscriptionId!.isNotEmpty)
        session.stripeSubscriptionId!,
      if (session.stripeIntentId != null) session.stripeIntentId!,
    ];

    if (references.isEmpty) {
      return Result.failure(
        ApiError(message: 'Missing payment reference. Unable to confirm with the server.'),
      );
    }

    StripePaymentStatus? lastStatus;
    String? lastError;

    for (var i = 0; i < attempts; i++) {
      if (i > 0) {
        await Future<void>.delayed(delay);
      }

      for (final reference in references) {
        final isSubscription = session.subscriptionReference != null &&
            (reference == session.subscriptionReference ||
                reference.startsWith('sub_'));
        final result = isSubscription
            ? await getSubscriptionStatus(
                subscriptionReference: reference,
                accessToken: token,
              )
            : await getPaymentStatus(
                paymentReference: reference,
                accessToken: token,
              );

        StripePaymentStatus? status;
        result.when(
          success: (value) => status = value,
          failure: (error) => lastError = error.message,
        );

        final checked = status;
        if (checked == null) continue;
        lastStatus = checked;
        if (checked.isPaid) {
          return Result.success(checked);
        }
        final failure = checked.failureMessage?.trim();
        if (failure != null && failure.isNotEmpty) {
          return Result.failure(ApiError(message: failure));
        }
      }
    }

    if (lastStatus != null) {
      return Result.failure(
        ApiError(
          message:
              'The server has not marked this donation as paid yet (status: ${lastStatus.status}).',
        ),
      );
    }

    return Result.failure(
      ApiError(
        message: lastError ?? 'Unable to confirm payment status with the server.',
      ),
    );
  }

  Future<Result<StripeCheckoutSession>> _createSession(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    if (!_isOnline) {
      return Result.failure(
        const NetworkError(message: ConnectivityController.offlineMessage),
      );
    }

    try {
      final response = await apiService.post<StripeCheckoutSession>(
        endpoint,
        data: body,
        fromJson: (data) {
          if (data is! Map) {
            throw const FormatException('Malformed Stripe checkout response');
          }
          return StripeCheckoutSession.fromJson(Map<String, dynamic>.from(data));
        },
      );

      if (!response.success || response.data == null) {
        return Result.failure(
          ApiError(
            message: _friendly(response.message, 'Unable to start checkout.'),
            statusCode: response.statusCode,
          ),
        );
      }

      final session = response.data!;
      if (session.clientSecret.isEmpty) {
        return Result.failure(
          ApiError(message: 'Checkout did not return a client secret.'),
        );
      }

      await _rememberSubscriptionCredentials(session);
      return Result.success(session);
    } catch (e, stackTrace) {
      return Result.failure(
        NetworkError(
          message: 'Unable to start checkout. Please try again.',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<Result<StripePaymentStatus>> _getStatus(
    String endpoint,
    String accessToken,
  ) async {
    if (!_isOnline) {
      return Result.failure(
        const NetworkError(message: ConnectivityController.offlineMessage),
      );
    }

    try {
      final response = await apiService.get<StripePaymentStatus>(
        endpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'x-api-key': ApaApiConfig.apiKey,
          },
        ),
        fromJson: (data) {
          if (data is! Map) {
            throw const FormatException('Malformed Stripe status response');
          }
          return StripePaymentStatus.fromJson(Map<String, dynamic>.from(data));
        },
      );

      if (!response.success || response.data == null) {
        return Result.failure(
          ApiError(
            message: _friendly(response.message, 'Unable to confirm payment status.'),
            statusCode: response.statusCode,
          ),
        );
      }

      return Result.success(response.data!);
    } catch (e, stackTrace) {
      return Result.failure(
        NetworkError(
          message: 'Unable to confirm payment status.',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  String _friendly(String? message, String fallback) {
    final trimmed = message?.trim() ?? '';
    if (trimmed.isEmpty || trimmed.toLowerCase() == 'null') return fallback;
    return trimmed;
  }
}
