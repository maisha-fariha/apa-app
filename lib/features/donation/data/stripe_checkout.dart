import 'package:apa/core/network/api_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

enum StripeCheckoutOutcome { completed, canceled }

class StripeCheckoutException implements Exception {
  StripeCheckoutException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Native Stripe Payment Sheet (recommended Flutter mobile checkout).
class StripeCheckout {
  static const merchantDisplayName = 'Ansanm Pou Ayiti';
  static const urlScheme = 'apa';
  static const returnURL = ApiEndpoints.stripeReturnUrl;

  Future<void> configure({required String publishableKey}) async {
    Stripe.publishableKey = publishableKey;
    Stripe.urlScheme = urlScheme;
    Stripe.setReturnUrlSchemeOnAndroid = true;
    await Stripe.instance.applySettings();
  }

  Future<StripeCheckoutOutcome> presentPaymentSheet({
    required String clientSecret,
    required String publishableKey,
    String? email,
    String? name,
    VoidCallback? onAuthorized,
  }) async {
    await configure(publishableKey: publishableKey);

    final isSetupIntent = clientSecret.startsWith('seti_');
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: merchantDisplayName,
          paymentIntentClientSecret:
              isSetupIntent ? null : clientSecret,
          setupIntentClientSecret: isSetupIntent ? clientSecret : null,
          returnURL: returnURL,
          style: ThemeMode.light,
          primaryButtonLabel: 'PAY NOW',
          allowsDelayedPaymentMethods: true,
          billingDetails: BillingDetails(
            name: name?.trim().isEmpty == true ? null : name?.trim(),
            email: email?.trim().isEmpty == true ? null : email?.trim(),
          ),
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFF111111),
            ),
          ),
        ),
      );
      await Stripe.instance.presentPaymentSheet();
      onAuthorized?.call();
      return StripeCheckoutOutcome.completed;
    } on StripeException catch (error) {
      if (error.error.code == FailureCode.Canceled) {
        return StripeCheckoutOutcome.canceled;
      }
      throw StripeCheckoutException(
        error.error.localizedMessage ??
            error.error.message ??
            'Payment could not be completed.',
      );
    }
  }
}
