import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Lightweight responsive helpers wrapping flutter_screenutil.
///
/// Usage: `16.w`, `24.h`, `14.sp`, `12.r` via the screenutil extensions,
/// or call [R] static methods when you need context-based breakpoint logic.
abstract final class R {
  static const double baseWidth = 390;
  static const double baseHeight = 884;

  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static bool isSmall(BuildContext context) => screenWidth(context) < 480;
  static bool isMedium(BuildContext context) {
    final w = screenWidth(context);
    return w >= 480 && w < 768;
  }

  static bool isLarge(BuildContext context) => screenWidth(context) >= 768;

  /// Clamps scaled width for tablets so UI doesn't balloon.
  static double cw(double value, BuildContext context) {
    final scaled = value.w;
    if (isLarge(context) || isMedium(context)) {
      return scaled.clamp(value, value * 1.5);
    }
    return scaled;
  }

  /// Clamps scaled height for tablets.
  static double ch(double value, BuildContext context) {
    final scaled = value.h;
    if (isLarge(context) || isMedium(context)) {
      return scaled.clamp(value, value * 1.5);
    }
    return scaled;
  }

  /// Responsive font size with tablet clamping.
  static double csp(double value, BuildContext context) {
    final scaled = value.sp;
    if (isLarge(context) || isMedium(context)) {
      return scaled.clamp(value, value * 1.4);
    }
    return scaled;
  }

  /// Pick value by breakpoint.
  static T pick<T>(BuildContext context, {required T s, T? m, T? l}) {
    if (isLarge(context)) return l ?? m ?? s;
    if (isMedium(context)) return m ?? s;
    return s;
  }
}
