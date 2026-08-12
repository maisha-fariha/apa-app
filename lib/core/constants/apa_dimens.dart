import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Layout dimensions from the Figma Home Page (390 × 884 design frame).
///
/// All getters return responsive values via flutter_screenutil.
/// Use the static `k*` constants when you need the raw design value.
abstract final class ApaDimens {
  static const double designWidth = 390;
  static const double designHeight = 884;

  // --- Raw design constants ---
  static const double kHorizontalPadding = 24;
  static const double kTopPadding = 32;
  static const double kContentBottomInset = 96;
  static const double kLogoWidth = 192;
  static const double kLogoHeight = 72;
  static const double kHeaderTopSpacing = 16;

  static const double kLocationBadgeHorizontalPadding = 17;
  static const double kLocationBadgeVerticalPadding = 7;
  static const double kLocationBadgeBottomSpacing = 24;

  static const double kDonationCardPadding = 25;
  static const double kDonationCardRadius = 16;
  static const double kDonationCardBottomSpacing = 24;
  static const double kDonationDateIconSize = 20;
  static const double kDonationDateGap = 12;
  static const double kDonationDividerSpacingTop = 8;
  static const double kDonationDividerSpacingBottom = 16;

  static const double kDonateButtonHeight = 62;
  static const double kDonateButtonRadius = 9999;
  static const double kDonateButtonBottomSpacing = 24;
  static const double kDonateArrowSize = 20;
  static const double kDonateArrowLeading = 12;

  static const double kNavHorizontalPadding = 16;
  static const double kNavTopPadding = 17;
  static const double kNavBottomPadding = 16;
  static const double kNavIconSize = 24;
  static const double kNavLabelTopSpacing = 4;
  static const double kNavFabSize = 60;
  static const double kNavFabIconSize = 30;
  static const double kNavFabOverlap = 51.19;
  static const double kNavMinHeight = 75;

  static const double kMaxContentWidth = 384;
  static const double kTabletBreakpoint = 600;
  static const double kDesktopBreakpoint = 900;

  // --- Responsive accessors ---
  static double get horizontalPadding => kHorizontalPadding.w;
  static double get topPadding => kTopPadding.h;
  static double get contentBottomInset => kContentBottomInset.h;

  static double get logoWidth => kLogoWidth.w;
  static double get logoHeight => kLogoHeight.h;
  static double get headerTopSpacing => kHeaderTopSpacing.h;

  static double get locationBadgeHorizontalPadding =>
      kLocationBadgeHorizontalPadding.w;
  static double get locationBadgeVerticalPadding =>
      kLocationBadgeVerticalPadding.h;
  static double get locationBadgeBottomSpacing =>
      kLocationBadgeBottomSpacing.h;

  static double get donationCardPadding => kDonationCardPadding.w;
  static double get donationCardRadius => kDonationCardRadius.r;
  static double get donationCardBottomSpacing =>
      kDonationCardBottomSpacing.h;
  static double get donationDateIconSize => kDonationDateIconSize.w;
  static double get donationDateGap => kDonationDateGap.w;
  static double get donationDividerSpacingTop =>
      kDonationDividerSpacingTop.h;
  static double get donationDividerSpacingBottom =>
      kDonationDividerSpacingBottom.h;

  static double get donateButtonHeight => kDonateButtonHeight.h;
  static double get donateButtonRadius => kDonateButtonRadius.r;
  static double get donateButtonBottomSpacing =>
      kDonateButtonBottomSpacing.h;
  static double get donateArrowSize => kDonateArrowSize.w;
  static double get donateArrowLeading => kDonateArrowLeading.w;

  static double get navHorizontalPadding => kNavHorizontalPadding.w;
  static double get navTopPadding => kNavTopPadding.h;
  static double get navBottomPadding => kNavBottomPadding.h;
  static double get navIconSize => kNavIconSize.w;
  static double get navLabelTopSpacing => kNavLabelTopSpacing.h;
  static double get navFabSize => kNavFabSize.w;
  static double get navFabIconSize => kNavFabIconSize.w;
  static double get navFabOverlap => kNavFabOverlap.h;
  static double get navMinHeight => kNavMinHeight.h;

  static double get maxContentWidth => kMaxContentWidth.w;
  static double get tabletBreakpoint => kTabletBreakpoint;
  static double get desktopBreakpoint => kDesktopBreakpoint;
}
