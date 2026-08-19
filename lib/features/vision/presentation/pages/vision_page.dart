import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/apa_assets.dart';
import '../../../../core/constants/apa_shell_insets.dart';
import '../../../../core/theme/apa_colors.dart';
import '../../../../core/theme/apa_fonts.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/apa_shared_widgets.dart';
import '../../../../core/widgets/apa_svg_icon.dart';

/// Our Vision Page — Figma frame `16:1107`.
class VisionPage extends StatelessWidget {
  const VisionPage({
    super.key,
    this.scrollController,
    this.onLearnMore,
    this.imageUrl,
  });

  final ScrollController? scrollController;
  final VoidCallback? onLearnMore;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final navBottomPad = ApaShellInsets.contentBottom(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ColoredBox(
        color: ApaColors.white,
        child: CustomScrollView(
          controller: scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: ApaHeroHeader(
                imageAsset: ApaAssets.visionHero,
                imageUrl: imageUrl,
                height: 505,
                badge: 'OUR VISION',
                headline: [
                  TextSpan(
                    text: 'BUILDING A STRONGER,\n',
                    style: ApaFonts.inter(
                      color: ApaColors.white,
                      fontSize: 34.sp,
                      fontWeight: FontWeight.w800,
                      height: 40 / 34,
                      letterSpacing: -0.5,
                    ),
                  ),
                  TextSpan(
                    text: 'SUSTAINABLE FUTURE TOGETHER.',
                    style: ApaFonts.inter(
                      color: ApaColors.primaryRed,
                      fontSize: 34.sp,
                      fontWeight: FontWeight.w800,
                      height: 40 / 34,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
                subtitle:
                    'Infrastructure that lasts — chosen with neighbors, built '
                    'by local crews, reported in the open.',
              ),
            ),
            SliverToBoxAdapter(
              child: ApaPageWidth(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    R.isTabletLandscape(context) ? 48 : 24.w,
                    48.h,
                    R.isTabletLandscape(context) ? 48 : 24.w,
                    navBottomPad,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'OUR VISION STATEMENT',
                        style: ApaFonts.inter(
                          color: ApaColors.black,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          height: 28 / 22,
                        ),
                      ),
                      SizedBox(height: 14.h),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: Text(
                          'We envision resilient communities powered by '
                          'sustainable development, modern infrastructure, '
                          'education, and collaboration.',
                          style: ApaFonts.inter(
                            color: ApaColors.gray700,
                            fontSize: 16.sp,
                            height: 24 / 16,
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      const ColoredBox(
                        color: ApaColors.black,
                        child: SizedBox(height: 1, width: double.infinity),
                      ),
                      SizedBox(height: 28.h),
                      Text(
                        'CORE VALUES',
                        style: ApaFonts.inter(
                          color: ApaColors.black,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          height: 28 / 22,
                        ),
                      ),
                      SizedBox(height: 28.h),
                      if (R.isTabletLandscape(context))
                        const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _ValueBlock(
                                iconPath: ApaAssets.icSustainability,
                                iconSize: 22,
                                title: 'Sustainability',
                                body:
                                    'Creating solutions that protect future generations.',
                              ),
                            ),
                            SizedBox(width: 32),
                            Expanded(
                              child: _ValueBlock(
                                iconPath: ApaAssets.icUnity,
                                iconSize: 26,
                                title: 'Unity',
                                body:
                                    'Bringing people together around shared goals.',
                              ),
                            ),
                            SizedBox(width: 32),
                            Expanded(
                              child: _ValueBlock(
                                iconPath: ApaAssets.icInnovation,
                                iconSize: 22,
                                title: 'Innovation',
                                body:
                                    'Building creative solutions for real challenges.',
                              ),
                            ),
                          ],
                        )
                      else ...[
                        const _ValueBlock(
                          iconPath: ApaAssets.icSustainability,
                          iconSize: 22,
                          title: 'Sustainability',
                          body:
                              'Creating solutions that protect future generations.',
                        ),
                        const _ValueDivider(),
                        const _ValueBlock(
                          iconPath: ApaAssets.icUnity,
                          iconSize: 26,
                          title: 'Unity',
                          body:
                              'Bringing people together around shared goals.',
                        ),
                        const _ValueDivider(),
                        const _ValueBlock(
                          iconPath: ApaAssets.icInnovation,
                          iconSize: 22,
                          title: 'Innovation',
                          body:
                              'Building creative solutions for real challenges.',
                        ),
                      ],
                      SizedBox(height: 40.h),
                      if (R.isTabletLandscape(context))
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Expanded(child: _GoalsColumn()),
                            SizedBox(width: 40.w),
                            const Expanded(child: _StatsCard()),
                          ],
                        )
                      else ...[
                        const _GoalsColumn(),
                        SizedBox(height: 32.h),
                        const _StatsCard(),
                      ],
                      SizedBox(height: 48.h),
                      Text(
                        'JOIN OUR MISSION',
                        style: ApaFonts.inter(
                          color: ApaColors.black,
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w800,
                          height: 34 / 28,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      ApaBlackPillButton(
                        label: 'LEARN MORE',
                        onPressed: onLearnMore,
                        fontSize: 16,
                        horizontalPadding: 40,
                        verticalPadding: 18,
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

class _ValueDivider extends StatelessWidget {
  const _ValueDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: const ColoredBox(
        color: ApaColors.gray200,
        child: SizedBox(height: 1, width: double.infinity),
      ),
    );
  }
}

class _ValueBlock extends StatelessWidget {
  const _ValueBlock({
    required this.iconPath,
    required this.iconSize,
    required this.title,
    required this.body,
  });

  final String iconPath;
  final double iconSize;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ApaSvgIcon(assetPath: iconPath, size: iconSize),
        SizedBox(height: 10.h),
        Text(
          title,
          style: ApaFonts.inter(
            color: ApaColors.black,
            fontSize: 22.sp,
            fontWeight: FontWeight.w800,
            height: 28 / 22,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          body,
          style: ApaFonts.inter(
            color: ApaColors.gray700,
            fontSize: 16.sp,
            height: 24 / 16,
          ),
        ),
      ],
    );
  }
}

class _GoalDivider extends StatelessWidget {
  const _GoalDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: const ColoredBox(
        color: ApaColors.gray200,
        child: SizedBox(height: 1, width: double.infinity),
      ),
    );
  }
}

class _GoalsColumn extends StatelessWidget {
  const _GoalsColumn();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FUTURE GOALS',
          style: ApaFonts.inter(
            color: ApaColors.black,
            fontSize: 22.sp,
            fontWeight: FontWeight.w800,
            height: 28 / 22,
          ),
        ),
        SizedBox(height: 24.h),
        const _GoalRow(
          title: '2026 — Community growth',
          body: 'Expand development programs.',
        ),
        const _GoalDivider(),
        const _GoalRow(
          title: '2030 — Sustainable infrastructure',
          body: 'Deliver long-term impact projects.',
        ),
        const _GoalDivider(),
        const _GoalRow(
          title: '2035 — Global collaboration',
          body: 'Connect communities worldwide.',
        ),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 32.w,
        vertical: 40.h,
      ),
      decoration: BoxDecoration(
        color: ApaColors.black,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Expanded(child: _StatCell(value: '50+', label: 'PROJECTS')),
              Expanded(
                child: _StatCell(value: '20K+', label: 'LIVES REACHED'),
              ),
            ],
          ),
          SizedBox(height: 32.h),
          const Row(
            children: [
              Expanded(child: _StatCell(value: '15+', label: 'PARTNERS')),
              Expanded(child: _StatCell(value: '10', label: 'YEARS AHEAD')),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: ApaFonts.inter(
            color: ApaColors.nearBlack,
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            height: 22 / 16,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          body,
          style: ApaFonts.inter(
            color: ApaColors.gray600,
            fontSize: 14.sp,
            height: 20 / 14,
          ),
        ),
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: ApaFonts.inter(
            color: ApaColors.white,
            fontSize: 32.sp,
            fontWeight: FontWeight.w800,
            height: 40 / 32,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          textAlign: TextAlign.center,
          style: ApaFonts.inter(
            color: ApaColors.white60,
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
