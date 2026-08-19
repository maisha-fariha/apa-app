import 'package:flutter/material.dart';
import 'package:gems_core/gems_core.dart';
import 'package:get/get.dart';

import 'core/network/apa_api_config.dart';
import 'core/theme/apa_fonts.dart';
import 'core/theme/apa_theme.dart';
import 'core/utils/responsive.dart';
import 'features/shell/presentation/controllers/pages_controller.dart';
import 'features/shell/presentation/pages/apa_shell.dart';
import 'services/app_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appServices = AppServices();
  await appServices.initialize(
    environmentMode: EnvironmentMode.staging,
    appConfig: AppConfig(
      apiBaseUrl: ApaApiConfig.baseUrl,
      enableLogging: true,
      apiTimeout: const Duration(seconds: 30),
      additionalConfig: {
        ApaApiConfig.apiKeyHeader: ApaApiConfig.apiKey,
      },
    ),
  );

  Get.put(AppServices.getIt<PagesController>(), permanent: true);

  runApp(const ApaApp());
}

class ApaApp extends StatelessWidget {
  const ApaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'APA — Ansanm Pou Ayiti',
      debugShowCheckedModeBanner: false,
      theme: ApaTheme.light,
      builder: (context, child) {
        return ApaResponsiveFrame(
          child: DefaultTextStyle(
            style: ApaFonts.inter(),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      home: const ApaShell(),
    );
  }
}
