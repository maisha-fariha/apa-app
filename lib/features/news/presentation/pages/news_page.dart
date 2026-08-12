import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/apa_assets.dart';
import '../../../../core/theme/apa_colors.dart';
import '../../../../core/widgets/apa_shared_widgets.dart';

/// News Page — Figma frame `13:738`.
class NewsPage extends StatelessWidget {
  const NewsPage({
    super.key,
    this.onReadMore,
  });

  final VoidCallback? onReadMore;

  static const double _navBottomPad = 120;

  static const TextStyle _headlineWhite = TextStyle(
    color: ApaColors.white,
    fontSize: 36,
    fontWeight: FontWeight.w800,
    height: 40 / 36,
    letterSpacing: -0.5,
  );

  static const TextStyle _headlineRed = TextStyle(
    color: ApaColors.primaryRedAlt,
    fontSize: 36,
    fontWeight: FontWeight.w800,
    height: 40 / 36,
    letterSpacing: -0.5,
  );

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ColoredBox(
        color: ApaColors.white,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: ApaHeroHeader(
                imageAsset: ApaAssets.newsHero,
                height: 480,
                badge: 'NEWS & UPDATES',
                headline: const [
                  TextSpan(text: 'LATEST\n', style: _headlineWhite),
                  TextSpan(text: 'NEWS.', style: _headlineRed),
                ],
                subtitle:
                    'Field notes from Sud — projects starting, finishing, '
                    'and everything reported in between.',
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, _navBottomPad),
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
                    const SizedBox(height: 32),
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
        borderRadius: BorderRadius.circular(12),
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
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    color: ApaColors.navy,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    height: 16 / 12,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: ApaColors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 30 / 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: const TextStyle(
                    color: ApaColors.gray600,
                    fontSize: 15,
                    height: 22 / 15,
                  ),
                ),
                if (showReadMore) ...[
                  const SizedBox(height: 20),
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
