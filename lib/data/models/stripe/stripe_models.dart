class StripePublicConfig {
  const StripePublicConfig({
    required this.mode,
    required this.publishableKey,
    required this.currency,
    required this.customEnabled,
    required this.customMinAmountCents,
    required this.customMaxAmountCents,
  });

  final String mode;
  final String publishableKey;
  final String currency;
  final bool customEnabled;
  final int customMinAmountCents;
  final int customMaxAmountCents;

  bool get isTestMode => mode.toLowerCase() == 'test';

  factory StripePublicConfig.fromJson(Map<String, dynamic> json) {
    final oneTime = json['one_time'];
    final oneTimeMap =
        oneTime is Map ? Map<String, dynamic>.from(oneTime) : <String, dynamic>{};

    return StripePublicConfig(
      mode: json['mode']?.toString() ?? 'test',
      publishableKey: json['publishable_key']?.toString() ?? '',
      currency: (json['currency'] ?? oneTimeMap['custom_currency'] ?? 'usd')
          .toString()
          .toLowerCase(),
      customEnabled: oneTimeMap['custom_enabled'] == true,
      customMinAmountCents: _asInt(oneTimeMap['custom_min_amount']) ?? 100,
      customMaxAmountCents: _asInt(oneTimeMap['custom_max_amount']) ?? 500000,
    );
  }
}

class StripePriceOption {
  const StripePriceOption({
    required this.id,
    required this.productId,
    required this.stripePriceId,
    required this.priceType,
    required this.unitAmountCents,
    required this.currency,
    this.recurringInterval,
  });

  final String id;
  final String productId;
  final String stripePriceId;
  final String priceType;
  final int unitAmountCents;
  final String currency;
  final String? recurringInterval;

  bool get isRecurring => priceType.toLowerCase() == 'recurring';

  int get amountDollars => unitAmountCents ~/ 100;

  factory StripePriceOption.fromJson(Map<String, dynamic> json) {
    return StripePriceOption(
      id: json['id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      stripePriceId: json['stripe_price_id']?.toString() ?? '',
      priceType: json['price_type']?.toString() ?? '',
      unitAmountCents: _asInt(json['unit_amount']) ?? 0,
      currency: (json['currency'] ?? 'usd').toString().toLowerCase(),
      recurringInterval: json['recurring_interval']?.toString(),
    );
  }
}

class StripeCatalog {
  const StripeCatalog({
    required this.config,
    required this.prices,
  });

  final StripePublicConfig config;
  final List<StripePriceOption> prices;

  List<StripePriceOption> chips({required bool monthly}) {
    final type = monthly ? 'recurring' : 'one_time';
    final matches = prices
        .where(
          (price) =>
              price.priceType.toLowerCase() == type &&
              price.stripePriceId.isNotEmpty &&
              price.unitAmountCents > 0,
        )
        .toList()
      ..sort((a, b) => a.unitAmountCents.compareTo(b.unitAmountCents));

    final seen = <int>{};
    return [
      for (final price in matches)
        if (seen.add(price.unitAmountCents)) price,
    ];
  }

  StripePriceOption? priceForDollars({
    required int dollars,
    required bool monthly,
  }) {
    final type = monthly ? 'recurring' : 'one_time';
    final cents = dollars * 100;
    for (final price in prices) {
      if (price.priceType.toLowerCase() == type &&
          price.unitAmountCents == cents &&
          price.stripePriceId.isNotEmpty) {
        return price;
      }
    }
    return null;
  }
}

class StripeCheckoutSession {
  const StripeCheckoutSession({
    required this.clientSecret,
    required this.publishableKey,
    this.paymentReference,
    this.subscriptionReference,
    this.statusAccessToken,
    this.customerId,
    this.amountCents,
    this.currency,
    this.stripeSubscriptionId,
  });

  final String clientSecret;
  final String publishableKey;
  final String? paymentReference;
  final String? subscriptionReference;
  final String? statusAccessToken;
  final String? customerId;
  final int? amountCents;
  final String? currency;
  final String? stripeSubscriptionId;

  factory StripeCheckoutSession.fromJson(Map<String, dynamic> json) {
    return StripeCheckoutSession(
      clientSecret: json['client_secret']?.toString() ?? '',
      publishableKey: json['publishable_key']?.toString() ?? '',
      paymentReference: json['payment_reference']?.toString(),
      subscriptionReference: json['subscription_reference']?.toString(),
      statusAccessToken: json['status_access_token']?.toString(),
      customerId: json['customer_id']?.toString(),
      amountCents: _asInt(json['amount']),
      currency: json['currency']?.toString(),
      stripeSubscriptionId: json['stripe_subscription_id']?.toString(),
    );
  }

  String? get stripeIntentId {
    final secret = clientSecret;
    final secretIndex = secret.indexOf('_secret_');
    if (secretIndex <= 0) return null;
    return secret.substring(0, secretIndex);
  }
}

class StripePaymentStatus {
  const StripePaymentStatus({
    required this.status,
    this.reference,
    this.receiptUrl,
    this.failureMessage,
    this.paidAt,
    this.raw = const {},
  });

  final String status;
  final String? reference;
  final String? receiptUrl;
  final String? failureMessage;
  final String? paidAt;
  final Map<String, dynamic> raw;

  bool get isPaid {
    switch (status.toLowerCase()) {
      case 'succeeded':
      case 'paid':
      case 'processing':
      case 'complete':
      case 'completed':
      case 'active':
      case 'trialing':
        return true;
      default:
        return false;
    }
  }

  factory StripePaymentStatus.fromJson(Map<String, dynamic> json) {
    return StripePaymentStatus(
      status: (json['status'] ?? json['payment_status'] ?? '').toString(),
      reference: (json['payment_reference'] ??
              json['subscription_reference'] ??
              json['reference'])
          ?.toString(),
      receiptUrl: json['receipt_url']?.toString(),
      failureMessage: json['failure_message']?.toString(),
      paidAt: json['paid_at']?.toString(),
      raw: json,
    );
  }
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value.toString());
}
