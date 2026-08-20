import 'dart:async';

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

  static bool _gotStripeReturnUrl = false;

  static void noteStripeReturnUrl() {
    _gotStripeReturnUrl = true;
  }

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
    _gotStripeReturnUrl = false;

    final isSetupIntent = clientSecret.startsWith('seti_');
    final lifecycle = _RedirectLifecycle(
      onReturnedWithoutRedirect: _resetProcessingAfterAbandonedAuth,
    )..attach();

    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: merchantDisplayName,
          paymentIntentClientSecret: isSetupIntent ? null : clientSecret,
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
    } finally {
      lifecycle.detach();
    }
  }

  /// User backed out of Cash App / 3DS without paying. Tell Stripe the
  /// redirect failed so Pay Now is not left on "Processing…".
  Future<void> _resetProcessingAfterAbandonedAuth() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (_gotStripeReturnUrl) return;
    try {
      await Stripe.instance.handleURLCallback(
        '$returnURL?redirect_status=failed',
      );
    } catch (_) {}
  }
}

class _RedirectLifecycle with WidgetsBindingObserver {
  _RedirectLifecycle({required this.onReturnedWithoutRedirect});

  final Future<void> Function() onReturnedWithoutRedirect;
  var _leftApp = false;

  void attach() {
    WidgetsBinding.instance.addObserver(this);
  }

  void detach() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _leftApp = true;
    }
    if (state == AppLifecycleState.resumed && _leftApp) {
      _leftApp = false;
      unawaited(onReturnedWithoutRedirect());
    }
  }
}
