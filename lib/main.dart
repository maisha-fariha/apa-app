import 'package:flutter/material.dart';

import 'core/theme/apa_fonts.dart';
import 'core/theme/apa_theme.dart';
import 'core/utils/responsive.dart';
import 'features/shell/presentation/pages/apa_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ApaApp());
}

class ApaApp extends StatelessWidget {
  const ApaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
