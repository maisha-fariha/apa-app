import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Responsive helper.
///
/// Phone / portrait: 390×884 design (unchanged).
/// Tablet landscape: full-width website/desktop layout. ScreenUtil is bound
/// to a 1024×768 design so `.w` / `.sp` stay modest and do not overflow.
abstract final class R {
  static const double baseWidth = 390;
  static const double baseHeight = 884;
  static const double desktopDesignWidth = 1024;
  static const double desktopDesignHeight = 768;
  static const double desktopMaxWidth = 1120;
  static const double tabletShortestSide = 600;

  static Size screenSize(BuildContext context) => MediaQuery.sizeOf(context);

  static double screenWidth(BuildContext context) => screenSize(context).width;

  static double screenHeight(BuildContext context) => screenSize(context).height;

  static bool isTablet(BuildContext context) =>
      screenSize(context).shortestSide >= tabletShortestSide;

  static bool isLandscape(BuildContext context) =>
      MediaQuery.orientationOf(context) == Orientation.landscape;

  static bool isTabletLandscape(BuildContext context) =>
      isTablet(context) && isLandscape(context);

  static bool isSmall(BuildContext context) => screenWidth(context) < 480;

  static bool isMedium(BuildContext context) {
    final w = screenWidth(context);
    return w >= 480 && w < 768;
  }

  static bool isLarge(BuildContext context) => screenWidth(context) >= 768;

  static double pagePadding(BuildContext context) =>
      isTabletLandscape(context) ? 48 : 24;

  static double cw(double value, BuildContext context) {
    if (!isTabletLandscape(context)) return value.w;
    return value.w.clamp(value * 0.9, value * 1.2);
  }

  static double ch(double value, BuildContext context) {
    if (!isTabletLandscape(context)) return value.h;
    return value.h.clamp(value * 0.85, value * 1.15);
  }

  static double csp(double value, BuildContext context) {
    if (!isTabletLandscape(context)) return value.sp;
    return value.sp.clamp(value * 0.9, value * 1.2);
  }

  static T pick<T>(BuildContext context, {required T s, T? m, T? l}) {
    if (isLarge(context)) return l ?? m ?? s;
    if (isMedium(context)) return m ?? s;
    return s;
  }

  static void bindScreenUtil(Size size, {required Size designSize}) {
    ScreenUtil.configure(
      data: MediaQueryData(size: size),
      designSize: designSize,
      minTextAdapt: true,
      splitScreenMode: true,
    );
  }
}

/// Full-width on phones; website-width centered column on tablet landscape.
class ApaPageWidth extends StatelessWidget {
  const ApaPageWidth({
    super.key,
    required this.child,
    this.maxWidth = R.desktopMaxWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    if (!R.isTabletLandscape(context)) return child;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Binds ScreenUtil. Does not letterbox — landscape uses the full width.
class ApaResponsiveFrame extends StatelessWidget {
  const ApaResponsiveFrame({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final tabletLandscape =
        size.shortestSide >= R.tabletShortestSide && size.width > size.height;

    return ScreenUtilInit(
      designSize: const Size(R.baseWidth, R.baseHeight),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, _) {
        if (tabletLandscape) {
          R.bindScreenUtil(
            size,
            designSize: const Size(R.desktopDesignWidth, R.desktopDesignHeight),
          );
        }
        return child;
      },
    );
  }
}
