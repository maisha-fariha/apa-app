import 'package:dio/dio.dart';
import 'package:gems_core/gems_core.dart';
import 'package:gems_data_layer/gems_data_layer.dart';

import '../../core/network/apa_api_config.dart';
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

  /// After Stripe checkout, poll GET status so WordPress can sync from Stripe
  /// and the app only treats the gift as done when the backend says so.
  Future<Result<StripePaymentStatus>> confirmCheckoutStatus(
    StripeCheckoutSession session, {
    int attempts = 10,
    Duration delay = const Duration(milliseconds: 1500),
  }) async {
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

  Future<Result<StripePaymentStatus>> _getStatus(
    String endpoint,
    String accessToken,
  ) async {
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
