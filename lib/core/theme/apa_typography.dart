import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'apa_colors.dart';
import 'apa_fonts.dart';

/// Typography styles using Inter (Google Fonts).
///
/// All font sizes, line heights, and letter spacings are responsive via
/// flutter_screenutil's `.sp` extension.
abstract final class ApaTypography {
  static TextStyle _base({
    required double fontSize,
    required double height,
    required FontWeight fontWeight,
    required Color color,
    double letterSpacing = 0,
  }) {
    final sp = fontSize.sp;
    return ApaFonts.inter(
      fontSize: sp,
      height: height / fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing.sp,
    );
  }

  static TextStyle get locationBadge => _base(
    fontSize: 12,
    height: 16,
    fontWeight: FontWeight.w700,
    color: ApaColors.locationYellow,
    letterSpacing: 1.2,
  );

  static TextStyle get donationDate => _base(
    fontSize: 12,
    height: 16,
    fontWeight: FontWeight.w700,
    color: ApaColors.white,
    letterSpacing: 1.2,
  );

  static TextStyle get currencySymbol => _base(
    fontSize: 20,
    height: 28,
    fontWeight: FontWeight.w700,
    color: ApaColors.white80,
  );

  static TextStyle get donationAmount => _base(
    fontSize: 36,
    height: 40,
    fontWeight: FontWeight.w700,
    color: ApaColors.white,
    letterSpacing: -1.8,
  );

  static TextStyle get currencyCode => _base(
    fontSize: 12,
    height: 16,
    fontWeight: FontWeight.w700,
    color: ApaColors.white60,
    letterSpacing: 1.2,
  );

  static TextStyle get donateButton => _base(
    fontSize: 20,
    height: 28,
    fontWeight: FontWeight.w700,
    color: ApaColors.white,
    letterSpacing: 2,
  );

  static TextStyle get footerNote => _base(
    fontSize: 10,
    height: 15,
    fontWeight: FontWeight.w700,
    color: ApaColors.white,
    letterSpacing: 1,
  );

  static TextStyle get navLabel => _base(
    fontSize: 9,
    height: 13.5,
    fontWeight: FontWeight.w700,
    color: ApaColors.white,
    letterSpacing: 0.5,
  );

  static TextStyle get navLabelActive => navLabel.copyWith(
    color: ApaColors.primaryRed,
  );

  static TextStyle get navDonationLabel => _base(
    fontSize: 12,
    height: 16,
    fontWeight: FontWeight.w700,
    color: ApaColors.white,
    letterSpacing: 0.8,
  );
}
