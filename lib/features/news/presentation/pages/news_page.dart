import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/apa_assets.dart';
import '../../../../core/constants/apa_shell_insets.dart';
import '../../../../core/theme/apa_colors.dart';
import '../../../../core/theme/apa_fonts.dart';
import '../../../../core/widgets/apa_shared_widgets.dart';

/// News Page — Figma frame `13:738`.
class NewsPage extends StatelessWidget {
  const NewsPage({
    super.key,
    this.scrollController,
    this.onReadMore,
  });

  final ScrollController? scrollController;
  final VoidCallback? onReadMore;

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
                imageAsset: ApaAssets.newsHero,
                height: 480,
                badge: 'NEWS & UPDATES',
                headline: [
                  TextSpan(
                    text: 'LATEST ',
                    style: ApaFonts.inter(
                      color: ApaColors.white,
                      fontSize: 36.sp,
                      fontWeight: FontWeight.w800,
                      height: 40 / 36,
                      letterSpacing: -0.5,
                    ),
                  ),
                  TextSpan(
                    text: 'NEWS.',
                    style: ApaFonts.inter(
                      color: ApaColors.primaryRedAlt,
                      fontSize: 36.sp,
                      fontWeight: FontWeight.w800,
                      height: 40 / 36,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
                subtitle:
                    'Field notes from Sud — projects starting, finishing, '
                    'and everything reported in between.',
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 40.h, 20.w, navBottomPad),
                child: Column(
                  children: [
                    _NewsCard(
                      imageAsset: ApaAssets.newsFeatured,
                      category: 'FEATURED',
                      title:
                          'Creating opportunities through community '
                          'infrastructure',
                      description:
                          'Discover our latest initiatives and achievements.',
                      showReadMore: true,
                      onReadMore: onReadMore,
                    ),
                    SizedBox(height: 32.h),
                    const _NewsCard(
                      imageAsset: ApaAssets.newsCommunity,
                      category: 'COMMUNITY',
                      title: 'New development project begins',
                      description: 'Short article description.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({
    required this.imageAsset,
    required this.category,
    required this.title,
    required this.description,
    this.showReadMore = false,
    this.onReadMore,
  });

  final String imageAsset;
  final String category;
  final String title;
  final String description;
  final bool showReadMore;
  final VoidCallback? onReadMore;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ApaColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: ApaColors.gray200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 348 / 261,
            child: Image.asset(
              imageAsset,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: ApaFonts.inter(
                    color: ApaColors.navy,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    height: 16 / 12,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  title,
                  style: ApaFonts.inter(
                    color: ApaColors.black,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                    height: 30 / 24,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  description,
                  style: ApaFonts.inter(
                    color: ApaColors.gray600,
                    fontSize: 15.sp,
                    height: 22 / 15,
                  ),
                ),
                if (showReadMore) ...[
                  SizedBox(height: 20.h),
                  ApaBlackPillButton(
                    label: 'READ MORE',
                    fontSize: 14,
                    horizontalPadding: 40,
                    verticalPadding: 14,
                    onPressed: onReadMore,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
