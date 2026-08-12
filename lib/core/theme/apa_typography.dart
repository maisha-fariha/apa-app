import 'package:flutter/material.dart';

import 'apa_colors.dart';

/// Typography styles matching the Figma Home Page (Nimbus Sans Bold).
///
/// Until `Nimbus Sans` font files are added under `assets/fonts/`, Flutter
/// falls back to the platform bold sans-serif while preserving size, weight,
/// letter-spacing, and line-height from the design.
abstract final class ApaTypography {
  static const String? fontFamily = null;

  static TextStyle _base({
    required double fontSize,
    required double height,
    required FontWeight fontWeight,
    required Color color,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      height: height / fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle locationBadge = _base(
    fontSize: 12,
    height: 16,
    fontWeight: FontWeight.w700,
    color: ApaColors.locationYellow,
    letterSpacing: 1.2,
  );

  static TextStyle donationDate = _base(
    fontSize: 12,
    height: 16,
    fontWeight: FontWeight.w700,
    color: ApaColors.white,
    letterSpacing: 1.2,
  );

  static TextStyle currencySymbol = _base(
    fontSize: 20,
    height: 28,
    fontWeight: FontWeight.w700,
    color: ApaColors.white80,
  );

  static TextStyle donationAmount = _base(
    fontSize: 36,
    height: 40,
    fontWeight: FontWeight.w700,
    color: ApaColors.white,
    letterSpacing: -1.8,
  );

  static TextStyle currencyCode = _base(
    fontSize: 12,
    height: 16,
    fontWeight: FontWeight.w700,
    color: ApaColors.white60,
    letterSpacing: 1.2,
  );

  static TextStyle donateButton = _base(
    fontSize: 20,
    height: 28,
    fontWeight: FontWeight.w700,
    color: ApaColors.white,
    letterSpacing: 2,
  );

  static TextStyle footerNote = _base(
    fontSize: 10,
    height: 15,
    fontWeight: FontWeight.w700,
    color: ApaColors.white,
    letterSpacing: 1,
  );

  static TextStyle navLabel = _base(
    fontSize: 9,
    height: 13.5,
    fontWeight: FontWeight.w700,
    color: ApaColors.white,
    letterSpacing: 0.9,
  );

  static TextStyle navLabelActive = navLabel.copyWith(
    color: ApaColors.primaryRed,
  );

  static TextStyle navDonationLabel = _base(
    fontSize: 12,
    height: 16,
    fontWeight: FontWeight.w700,
    color: ApaColors.white,
    letterSpacing: 1.2,
  );
}
