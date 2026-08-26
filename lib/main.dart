import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:gems_core/gems_core.dart';
import 'package:get/get.dart';

import 'core/network/apa_api_config.dart';
import 'core/network/connectivity_controller.dart';
import 'core/theme/apa_fonts.dart';
import 'core/theme/apa_theme.dart';
import 'core/utils/responsive.dart';
import 'core/widgets/apa_offline_banner.dart';
import 'features/contact/presentation/controllers/contact_controller.dart';
import 'features/donation/data/stripe_checkout.dart';
import 'features/donation/presentation/controllers/donation_controller.dart';
import 'features/shell/presentation/controllers/pages_controller.dart';
import 'features/shell/presentation/pages/apa_shell.dart';
import 'services/app_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  StripeCheckout.bindPlatformSettings();

  final appServices = AppServices();
  await appServices.initialize(
    environmentMode: ApaApiConfig.isProduction
        ? EnvironmentMode.production
        : EnvironmentMode.development,
    appConfig: AppConfig(
      apiBaseUrl: ApaApiConfig.baseUrl,
      enableLogging: ApaApiConfig.enableLogging,
      apiTimeout: const Duration(seconds: 30),
      additionalConfig: {
        ApaApiConfig.apiKeyHeader: ApaApiConfig.apiKey,
      },
    ),
  );

  Get.put(AppServices.getIt<ConnectivityController>(), permanent: true);
  await AppServices.getIt<ConnectivityController>().refreshStatus();

  Get.put(AppServices.getIt<PagesController>(), permanent: true);
  Get.put(AppServices.getIt<ContactController>(), permanent: true);
  Get.put(AppServices.getIt<DonationController>(), permanent: true);

  AppServices.getIt<ConnectivityController>().onRestored = () {
    unawaited(Get.find<PagesController>().onConnectivityRestored());
    unawaited(Get.find<ContactController>().onConnectivityRestored());
    unawaited(Get.find<DonationController>().onConnectivityRestored());
  };

  runApp(const ApaApp());
}

class ApaApp extends StatefulWidget {
  const ApaApp({super.key});

  @override
  State<ApaApp> createState() => _ApaAppState();
}

class _ApaAppState extends State<ApaApp> {
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _listenForStripeReturnUrls();
  }

  void _listenForStripeReturnUrls() {
    final appLinks = AppLinks();
    appLinks.getInitialLink().then((uri) {
      if (uri == null || uri.scheme != 'apa') return;
      StripeCheckout.noteStripeReturnUrl();
      Stripe.instance.handleURLCallback(uri.toString());
    }).catchError((_) {});
    _linkSubscription = appLinks.uriLinkStream.listen((uri) async {
      if (uri.scheme != 'apa') return;
      StripeCheckout.noteStripeReturnUrl();
      await Stripe.instance.handleURLCallback(uri.toString());
    }, onError: (_) {});
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'APA — Ansanm Pou Ayiti',
      debugShowCheckedModeBanner: false,
      theme: ApaTheme.light,
      builder: (context, child) {
        return ApaResponsiveFrame(
          child: ApaOfflineBannerHost(
            child: DefaultTextStyle(
              style: ApaFonts.inter(),
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
      home: const ApaShell(),
    );
  }
}
