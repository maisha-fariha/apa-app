import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App-wide Inter font via Google Fonts.
abstract final class ApaFonts {
  static TextStyle inter({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    FontStyle? fontStyle,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
      decoration: decoration,
    );
  }

  static TextTheme interTextTheme(TextTheme base) => GoogleFonts.interTextTheme(base);
}
