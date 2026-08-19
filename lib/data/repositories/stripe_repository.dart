import 'package:dio/dio.dart';
import 'package:gems_core/gems_core.dart';
import 'package:gems_data_layer/gems_data_layer.dart';

import '../../core/network/api_endpoints.dart';
import '../models/stripe/stripe_models.dart';

class StripeRepository {
  StripeRepository({required this.apiService});

  final ApiService apiService;

  Future<Result<StripePublicConfig>> getConfig() async {
    try {
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
    } catch (e, stackTrace) {
      return Result.failure(
        NetworkError(
          message: 'Unable to load payment settings. Please try again.',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<Result<List<StripePriceOption>>> getPrices() async {
    try {
      final response = await apiService.get<List<StripePriceOption>>(
        ApiEndpoints.stripeProducts,
        fromJson: (data) {
          if (data is! Map) {
            throw const FormatException('Malformed Stripe products response');
          }
          final prices = data['prices'];
          if (prices is! List) return const <StripePriceOption>[];
          return prices
              .whereType<Map>()
              .map((item) => StripePriceOption.fromJson(
                    Map<String, dynamic>.from(item),
                  ))
              .toList();
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
    } catch (e, stackTrace) {
      return Result.failure(
        NetworkError(
          message: 'Unable to load donation amounts. Please try again.',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<Result<StripeCheckoutSession>> createOneTimePayment({
    required int amountDollars,
    required String email,
    required String name,
    required String currency,
  }) {
    return _createSession(
      ApiEndpoints.stripePayments,
      {
        'amount': amountDollars,
        'currency': currency,
        'email': email,
        'name': name,
        'return_url': ApiEndpoints.stripeReturnUrl,
      },
    );
  }

  Future<Result<StripeCheckoutSession>> createSubscription({
    required String priceId,
    required String email,
    required String name,
  }) {
    return _createSession(
      ApiEndpoints.stripeSubscriptions,
      {
        'price_id': priceId,
        'email': email,
        'name': name,
        'return_url': ApiEndpoints.stripeReturnUrl,
      },
    );
  }

  Future<Result<Map<String, dynamic>>> getPaymentStatus({
    required String paymentReference,
    required String accessToken,
  }) {
    return _getStatus(
      ApiEndpoints.stripePaymentStatus(paymentReference),
      accessToken,
    );
  }

  Future<Result<Map<String, dynamic>>> getSubscriptionStatus({
    required String subscriptionReference,
    required String accessToken,
  }) {
    return _getStatus(
      ApiEndpoints.stripeSubscriptionStatus(subscriptionReference),
      accessToken,
    );
  }

  Future<Result<StripeCheckoutSession>> _createSession(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
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

  Future<Result<Map<String, dynamic>>> _getStatus(
    String endpoint,
    String accessToken,
  ) async {
    try {
      final response = await apiService.get<Map<String, dynamic>>(
        endpoint,
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
        fromJson: (data) {
          if (data is! Map) {
            throw const FormatException('Malformed Stripe status response');
          }
          return Map<String, dynamic>.from(data);
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
