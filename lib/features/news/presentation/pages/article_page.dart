import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/apa_assets.dart';
import '../../../../core/theme/apa_colors.dart';
import '../../../../core/theme/apa_fonts.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/apa_svg_icon.dart';

/// Article / Read More page — Figma frame `14:811`.
///
/// Pushed route (no bottom nav).
class ArticlePage extends StatelessWidget {
  const ArticlePage({
    super.key,
    this.onDonatePressed,
    this.onBackToNews,
  });

  final VoidCallback? onDonatePressed;
  final VoidCallback? onBackToNews;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: ApaColors.white,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(
                height: R.isTabletLandscape(context)
                    ? (MediaQuery.sizeOf(context).height * 0.52)
                        .clamp(340.0, 460.0)
                    : 620.h + top,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      ApaAssets.articleHero,
                      fit: BoxFit.cover,
                    ),
                    ColoredBox(
                      color: Colors.black.withValues(alpha: 0.7),
                    ),
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          R.isTabletLandscape(context) ? 48 : 24.w,
                          24.h,
                          R.isTabletLandscape(context) ? 48 : 24.w,
                          40.h,
                        ),
                        child: ApaPageWidth(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Image.asset(
                                  ApaAssets.apaLogo,
                                  width: 180.w,
                                  height: 67.5.h,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 13.w,
                                vertical: 7.h,
                              ),
                              decoration: BoxDecoration(
                                color: ApaColors.locationYellowFill,
                                borderRadius: BorderRadius.circular(9999),
                                border: Border.all(color: ApaColors.white20),
                              ),
                              child: Text(
                                'FIELD REPORT',
                                style: ApaFonts.inter(
                                  color: ApaColors.locationYellow,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'Light returns to the market road',
                              style: ApaFonts.inter(
                                color: ApaColors.white,
                                fontSize: 34.sp,
                                fontWeight: FontWeight.w800,
                                height: 40 / 34,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: ApaPageWidth(
                maxWidth: 760,
                child: Padding(
                padding: EdgeInsets.fromLTRB(
                  R.isTabletLandscape(context) ? 48 : 24.w,
                  40.h,
                  R.isTabletLandscape(context) ? 48 : 24.w,
                  48.h + MediaQuery.paddingOf(context).bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: onBackToNews ?? () => Navigator.of(context).pop(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const ApaSvgIcon(
                            assetPath: ApaAssets.icBack,
                            size: 16,
                            color: ApaColors.primaryRed,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'BACK TO NEWS',
                            style: ApaFonts.inter(
                              color: ApaColors.primaryRed,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'FEATURED  ·  MARCH 2026  ·  SUD, HAITI',
                      style: ApaFonts.inter(
                        color: ApaColors.gray500,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'By the APA field team',
                      style: ApaFonts.inter(
                        color: ApaColors.gray600,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 28.h),
                    const _BodyText(
                      'For years, the stretch of road linking the Sainte-Anne '
                      'neighborhood to the market in Les Cayes went dark after '
                      'sunset. Families finished their errands before dusk and '
                      'stayed inside once the sun dropped — not out of habit, '
                      'but because there was no light, and the road itself was '
                      'more pothole than pavement.',
                    ),
                    SizedBox(height: 20.h),
                    const _BodyText(
                      'That changed this spring. As part of phase one of our '
                      'infrastructure work in Sud, Haiti, a 400-metre section '
                      'of that road was resurfaced and fitted with '
                      'solar-powered street lighting. It is a small project by '
                      'most measures. On the ground, it has changed how the '
                      'neighborhood uses its evenings.',
                    ),
                    SizedBox(height: 28.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.asset(
                        ApaAssets.articleRoad,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                    SizedBox(height: 36.h),
                    Text(
                      'What actually got built',
                      style: ApaFonts.inter(
                        color: ApaColors.black,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                        height: 34 / 28,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    const _BodyText(
                      'The work combined two of our three standing project '
                      'categories: road improvement and renewable street '
                      'lighting. Local crews were hired first, materials were '
                      'sourced in Haiti wherever possible, and the design '
                      'itself came out of three community meetings held before '
                      'a single tool touched the ground.',
                    ),
                    SizedBox(height: 20.h),
                    const _DotItem(
                      '400 metres of road resurfaced with durable materials',
                    ),
                    const _DotItem(
                      'A run of solar-powered street lights along the stretch',
                    ),
                    const _DotItem(
                      'Three community meetings before construction began',
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ColoredBox(
                          color: ApaColors.primaryRed,
                          child: SizedBox(width: 3.w, height: 100.h),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Text(
                            '"Now the children walk to the shop after dark. '
                            'That is the measure that matters."',
                            style: ApaFonts.inter(
                              color: ApaColors.gray800,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.italic,
                              height: 26 / 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40.h),
                    Text(
                      "What's next",
                      style: ApaFonts.inter(
                        color: ApaColors.black,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                        height: 34 / 28,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    const _BodyText(
                      'This project is one line item in a larger phase-one '
                      'goal of \$120,000 for the Sud region. Road and lighting '
                      'work like this is now informing the design of two more '
                      'sites currently in the surveying and design stages. '
                      'Every stage, as always, is reported back to donors and '
                      'to the neighborhood it serves.',
                    ),
                    SizedBox(height: 20.h),
                    const _BodyText(
                      'If you would like to see exactly where funds for '
                      'projects like this one come from and go, our '
                      'transparency page keeps a running ledger, updated as '
                      'each project moves forward.',
                    ),
                    SizedBox(height: 28.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: ApaColors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: ApaColors.gray200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Project quick facts',
                            style: ApaFonts.inter(
                              color: ApaColors.black,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          const _FactRow(
                            label: 'Location',
                            value: 'Sainte-Anne, Les Cayes',
                          ),
                          const _FactRow(label: 'Length', value: '400 metres'),
                          const _FactRow(
                            label: 'Category',
                            value: 'Roads + Lighting',
                          ),
                          const _FactRow(label: 'Status', value: 'Complete'),
                        ],
                      ),
                    ),
                    SizedBox(height: 32.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 32.w,
                        vertical: 36.h,
                      ),
                      decoration: BoxDecoration(
                        color: ApaColors.black,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Help fund the next stretch',
                            textAlign: TextAlign.center,
                            style: ApaFonts.inter(
                              color: ApaColors.white,
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w800,
                              height: 30 / 24,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'Every gift moves phase one forward in Sud.',
                            textAlign: TextAlign.center,
                            style: ApaFonts.inter(
                              color: ApaColors.white80,
                              fontSize: 14.sp,
                              height: 20 / 14,
                            ),
                          ),
                          SizedBox(height: 24.h),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: onDonatePressed,
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                child: Text(
                                  'DONATE →',
                                  style: ApaFonts.inter(
                                    color: ApaColors.primaryRed,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 48.h),
                    Text(
                      'MORE STORIES',
                      style: ApaFonts.inter(
                        color: ApaColors.black,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: ApaColors.gray200),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AspectRatio(
                            aspectRatio: 340 / 256,
                            child: Image.asset(
                              ApaAssets.newsCommunity,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              32.w, 28.h, 32.w, 28.h,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'COMMUNITY',
                                  style: ApaFonts.inter(
                                    color: ApaColors.navy,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  'New development project begins',
                                  style: ApaFonts.inter(
                                    color: ApaColors.black,
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w800,
                                    height: 26 / 20,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'Short article description.',
                                  style: ApaFonts.inter(
                                    color: ApaColors.gray600,
                                    fontSize: 14.sp,
                                    height: 20 / 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BodyText extends StatelessWidget {
  const _BodyText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: ApaFonts.inter(
        color: ApaColors.gray800,
        fontSize: 16.sp,
        height: 26 / 16,
      ),
    );
  }
}

class _DotItem extends StatelessWidget {
  const _DotItem(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 8.h),
            width: 8.w,
            height: 8.w,
            decoration: const BoxDecoration(
              color: ApaColors.navy,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: ApaFonts.inter(
                color: ApaColors.gray800,
                fontSize: 15.sp,
                height: 22 / 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Text(
            label,
            style: ApaFonts.inter(
              color: ApaColors.gray500,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: ApaFonts.inter(
              color: ApaColors.nearBlack,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
