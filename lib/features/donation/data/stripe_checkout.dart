import 'dart:async';
import 'dart:convert';

import 'package:apa/core/network/api_endpoints.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/theme/apa_colors.dart';
import '../../../core/theme/apa_fonts.dart';

enum StripeCheckoutOutcome { completed, canceled }

class StripeCheckoutException implements Exception {
  StripeCheckoutException(this.message);

  final String message;

  @override
  String toString() => message;
}

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

  /// Opens the same Stripe.js Payment Element the website uses, including
  /// Cash App Pay QR / Simulate scan in test mode.
  Future<StripeCheckoutOutcome> presentPaymentSheet({
    required String clientSecret,
    required String publishableKey,
    required bool testMode,
    String? email,
    String? name,
  }) async {
    final outcome = await Get.to<StripeCheckoutOutcome>(
      () => StripePaymentElementPage(
        publishableKey: publishableKey,
        clientSecret: clientSecret,
        returnUrl: returnURL,
        email: email,
        name: name,
        testMode: testMode,
      ),
      fullscreenDialog: true,
    );
    return outcome ?? StripeCheckoutOutcome.canceled;
  }
}

class StripePaymentElementPage extends StatefulWidget {
  const StripePaymentElementPage({
    super.key,
    required this.publishableKey,
    required this.clientSecret,
    required this.returnUrl,
    this.email,
    this.name,
    this.testMode = false,
  });

  final String publishableKey;
  final String clientSecret;
  final String returnUrl;
  final String? email;
  final String? name;
  final bool testMode;

  @override
  State<StripePaymentElementPage> createState() =>
      _StripePaymentElementPageState();
}

class _StripePaymentElementPageState extends State<StripePaymentElementPage> {
  late final WebViewController _controller;
  StreamSubscription<Uri>? _linkSubscription;
  bool _completing = false;
  bool _leftPaymentMethods = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(ApaColors.white)
      ..setUserAgent(
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) '
        'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
      )
      ..addJavaScriptChannel(
        'ApaStripe',
        onMessageReceived: (message) {
          try {
            final payload = jsonDecode(message.message);
            if (payload is! Map) return;
            final status = payload['status']?.toString();
            if (status == 'success') {
              _finish(StripeCheckoutOutcome.completed);
            } else if (status == 'cancel') {
              _finish(StripeCheckoutOutcome.canceled);
            }
          } catch (_) {}
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            if (_isReturnUrl(request.url)) {
              _finish(StripeCheckoutOutcome.completed);
              return NavigationDecision.prevent;
            }
            if (_isLeavingPaymentMethods(request.url)) {
              _leftPaymentMethods = true;
            }
            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            setState(() => _loadError = error.description);
          },
        ),
      );
    _loadPaymentHtml();

    _linkSubscription = AppLinks().uriLinkStream.listen((uri) {
      if (_isReturnUrl(uri.toString())) {
        _finish(StripeCheckoutOutcome.completed);
      }
    });
  }

  void _loadPaymentHtml() {
    _leftPaymentMethods = false;
    _controller.loadHtmlString(
      _paymentElementHtml(
        publishableKey: widget.publishableKey,
        clientSecret: widget.clientSecret,
        returnUrl: widget.returnUrl,
        email: widget.email,
        name: widget.name,
        testMode: widget.testMode,
      ),
      baseUrl: 'https://js.stripe.com',
    );
  }

  bool _isLeavingPaymentMethods(String url) {
    if (url.startsWith('data:') ||
        url == 'about:blank' ||
        url.startsWith('https://js.stripe.com')) {
      return false;
    }
    return true;
  }

  bool _isReturnUrl(String url) {
    return url.startsWith(widget.returnUrl) || url.startsWith('apa://');
  }

  Future<void> _handleBack() async {
    if (_completing || !mounted) return;
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return;
    }
    if (_leftPaymentMethods) {
      _loadPaymentHtml();
      return;
    }
    _finish(StripeCheckoutOutcome.canceled);
  }

  void _finish(StripeCheckoutOutcome outcome) {
    if (_completing || !mounted) return;
    _completing = true;
    Get.back(result: outcome);
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
      backgroundColor: ApaColors.white,
      appBar: AppBar(
        backgroundColor: ApaColors.white,
        foregroundColor: ApaColors.black,
        elevation: 0,
        title: Text(
          'SECURE PAYMENT',
          style: ApaFonts.inter(
            color: ApaColors.black,
            fontWeight: FontWeight.w800,
            fontSize: 16,
            letterSpacing: 0.6,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleBack,
        ),
      ),
      body: _loadError == null
          ? WebViewWidget(controller: _controller)
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Unable to load Stripe checkout.\n$_loadError',
                  textAlign: TextAlign.center,
                  style: ApaFonts.inter(color: ApaColors.primaryRed),
                ),
              ),
            ),
      ),
    );
  }
}

String _paymentElementHtml({
  required String publishableKey,
  required String clientSecret,
  required String returnUrl,
  String? email,
  String? name,
  bool testMode = false,
}) {
  final config = jsonEncode({
    'publishableKey': publishableKey,
    'clientSecret': clientSecret,
    'returnUrl': returnUrl,
    'email': email ?? '',
    'name': name ?? '',
    'testMode': testMode,
  });

  return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
  <script src="https://js.stripe.com/v3/"></script>
  <style>
    html, body { margin: 0; padding: 0; background: #fff; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; }
    .wrap { padding: 16px; max-width: 560px; margin: 0 auto; }
    h1 { font-size: 18px; letter-spacing: 0.4px; margin: 0 0 16px; }
    #payment-element { min-height: 220px; }
    #error { color: #FF0033; font-size: 14px; min-height: 20px; margin: 12px 0; }
    button { width: 100%; border: 0; border-radius: 999px; background: #111; color: #fff; font-weight: 700; font-size: 16px; padding: 16px; }
    button:disabled { opacity: 0.6; }
  </style>
</head>
<body>
  <div class="wrap">
    <h1>CHOOSE A PAYMENT METHOD</h1>
    <p id="test-note" style="display:none;color:#6B7280;font-size:13px;margin:0 0 12px;">
      Test mode: Cash App Pay shows a QR code with Simulate scan, same as the website.
    </p>
    <div id="payment-element"></div>
    <div id="error"></div>
    <button id="submit" type="button">PAY NOW</button>
  </div>
  <script>
    const cfg = $config;
    if (cfg.testMode) {
      document.getElementById('test-note').style.display = 'block';
    }
    const stripe = Stripe(cfg.publishableKey);
    const elements = stripe.elements({
      clientSecret: cfg.clientSecret,
      appearance: {
        theme: 'stripe',
        variables: { colorPrimary: '#111111', borderRadius: '8px' }
      }
    });
    const paymentElement = elements.create('payment', {
      layout: 'tabs',
      defaultValues: {
        billingDetails: {
          name: cfg.name,
          email: cfg.email
        }
      }
    });
    paymentElement.mount('#payment-element');

    const submit = document.getElementById('submit');
    const errorEl = document.getElementById('error');

    function send(status, message) {
      if (window.ApaStripe && window.ApaStripe.postMessage) {
        ApaStripe.postMessage(JSON.stringify({ status: status, message: message || '' }));
      }
    }

    submit.addEventListener('click', async function () {
      errorEl.textContent = '';
      submit.disabled = true;
      submit.textContent = 'PROCESSING…';
      const result = await stripe.confirmPayment({
        elements: elements,
        confirmParams: {
          return_url: cfg.returnUrl,
          payment_method_data: {
            billing_details: {
              name: cfg.name,
              email: cfg.email
            }
          }
        },
        redirect: 'if_required'
      });
      if (result.error) {
        errorEl.textContent = result.error.message || 'Payment failed.';
        submit.disabled = false;
        submit.textContent = 'PAY NOW';
        if (result.error.type === 'validation_error') return;
        return;
      }
      send('success');
    });
  </script>
</body>
</html>
''';
}
