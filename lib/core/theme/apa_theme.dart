import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'apa_colors.dart';

/// Material 3 theme aligned with the APA Figma Home Page.
abstract final class ApaTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: ApaColors.primaryRed,
      brightness: Brightness.dark,
      primary: ApaColors.primaryRed,
      surface: ApaColors.black,
      onPrimary: ApaColors.white,
      onSurface: ApaColors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: ApaColors.black,
      fontFamily: null,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
    );
  }
}
