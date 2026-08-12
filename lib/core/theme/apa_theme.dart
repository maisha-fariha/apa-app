import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'apa_colors.dart';
import 'apa_fonts.dart';

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

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: ApaColors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
    );

    final textTheme = ApaFonts.interTextTheme(base.textTheme);

    return base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: ApaFonts.interTextTheme(base.primaryTextTheme),
      appBarTheme: base.appBarTheme.copyWith(
        titleTextStyle: ApaFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: ApaColors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: ApaFonts.inter(
          color: ApaColors.gray400,
          fontWeight: FontWeight.w500,
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: ApaFonts.inter(
          color: ApaColors.nearBlack,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
