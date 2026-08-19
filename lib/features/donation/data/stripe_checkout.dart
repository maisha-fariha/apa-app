import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

enum StripeCheckoutOutcome { completed, canceled }

class StripeCheckoutException implements Exception {
  StripeCheckoutException(this.message);

  final String message;

  @override
  String toString() => message;
}

class StripeCheckout {
  static const merchantDisplayName = 'Ansanm Pou Ayiti';
  static const returnURL = 'apa://stripe-redirect';

  Future<void> configure({required String publishableKey}) async {
    Stripe.publishableKey = publishableKey;
    await Stripe.instance.applySettings();
  }

  Future<StripeCheckoutOutcome> presentPaymentSheet({
    required String clientSecret,
    required bool testMode,
    String? email,
    String? name,
  }) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: merchantDisplayName,
          returnURL: returnURL,
          style: ThemeMode.light,
          billingDetails: BillingDetails(
            email: email,
            name: name,
          ),
          googlePay: !kIsWeb &&
                  defaultTargetPlatform == TargetPlatform.android
              ? PaymentSheetGooglePay(
                  merchantCountryCode: 'US',
                  currencyCode: 'USD',
                  testEnv: testMode,
                )
              : null,
        ),
      );
      await Stripe.instance.presentPaymentSheet();
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
