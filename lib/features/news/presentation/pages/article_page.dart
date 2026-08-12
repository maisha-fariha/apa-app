import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/apa_assets.dart';
import '../../../../core/theme/apa_colors.dart';
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

  static const TextStyle _headlineWhite = TextStyle(
    color: ApaColors.white,
    fontSize: 34,
    fontWeight: FontWeight.w800,
    height: 40 / 34,
    letterSpacing: -0.5,
  );

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
                height: 620 + top,
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
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Image.asset(
                                ApaAssets.apaLogo,
                                width: 180,
                                height: 67.5,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 13,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: ApaColors.locationYellowFill,
                                borderRadius: BorderRadius.circular(9999),
                                border: Border.all(color: ApaColors.white20),
                              ),
                              child: const Text(
                                'FIELD REPORT',
                                style: TextStyle(
                                  color: ApaColors.locationYellow,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Light returns to the market road',
                              style: _headlineWhite,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  24,
                  40,
                  24,
                  48 + MediaQuery.paddingOf(context).bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: onBackToNews ?? () => Navigator.of(context).pop(),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ApaSvgIcon(
                            assetPath: ApaAssets.icBack,
                            size: 16,
                            color: ApaColors.nearBlack,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'BACK TO NEWS',
                            style: TextStyle(
                              color: ApaColors.nearBlack,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'FEATURED  ·  MARCH 2026  ·  SUD, HAITI',
                      style: TextStyle(
                        color: ApaColors.gray500,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'By the APA field team',
                      style: TextStyle(
                        color: ApaColors.gray600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const _BodyText(
                      'For years, the stretch of road linking the Sainte-Anne '
                      'neighborhood to the market in Les Cayes went dark after '
                      'sunset. Families finished their errands before dusk and '
                      'stayed inside once the sun dropped — not out of habit, '
                      'but because there was no light, and the road itself was '
                      'more pothole than pavement.',
                    ),
                    const SizedBox(height: 20),
                    const _BodyText(
                      'That changed this spring. As part of phase one of our '
                      'infrastructure work in Sud, Haiti, a 400-metre section '
                      'of that road was resurfaced and fitted with '
                      'solar-powered street lighting. It is a small project by '
                      'most measures. On the ground, it has changed how the '
                      'neighborhood uses its evenings.',
                    ),
                    const SizedBox(height: 28),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        ApaAssets.articleRoad,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                    const SizedBox(height: 36),
                    const Text(
                      'What actually got built',
                      style: TextStyle(
                        color: ApaColors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 34 / 28,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _BodyText(
                      'The work combined two of our three standing project '
                      'categories: road improvement and renewable street '
                      'lighting. Local crews were hired first, materials were '
                      'sourced in Haiti wherever possible, and the design '
                      'itself came out of three community meetings held before '
                      'a single tool touched the ground.',
                    ),
                    const SizedBox(height: 20),
                    const _DotItem(
                      '400 metres of road resurfaced with durable materials',
                    ),
                    const _DotItem(
                      'A run of solar-powered street lights along the stretch',
                    ),
                    const _DotItem(
                      'Three community meetings before construction began',
                    ),
                    const SizedBox(height: 24),
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ColoredBox(
                          color: ApaColors.primaryRed,
                          child: SizedBox(width: 3, height: 100),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            '"Now the children walk to the shop after dark. '
                            'That is the measure that matters."',
                            style: TextStyle(
                              color: ApaColors.gray800,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.italic,
                              height: 26 / 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      "What's next",
                      style: TextStyle(
                        color: ApaColors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 34 / 28,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _BodyText(
                      'This project is one line item in a larger phase-one '
                      'goal of \$120,000 for the Sud region. Road and lighting '
                      'work like this is now informing the design of two more '
                      'sites currently in the surveying and design stages. '
                      'Every stage, as always, is reported back to donors and '
                      'to the neighborhood it serves.',
                    ),
                    const SizedBox(height: 20),
                    const _BodyText(
                      'If you would like to see exactly where funds for '
                      'projects like this one come from and go, our '
                      'transparency page keeps a running ledger, updated as '
                      'each project moves forward.',
                    ),
                    const SizedBox(height: 28),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: ApaColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ApaColors.gray200),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Project quick facts',
                            style: TextStyle(
                              color: ApaColors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 20),
                          _FactRow(label: 'Location', value: 'Sainte-Anne, Les Cayes'),
                          _FactRow(label: 'Length', value: '400 metres'),
                          _FactRow(label: 'Category', value: 'Roads + Lighting'),
                          _FactRow(label: 'Status', value: 'Complete'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 36,
                      ),
                      decoration: BoxDecoration(
                        color: ApaColors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Help fund the next stretch',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: ApaColors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              height: 30 / 24,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Every gift moves phase one forward in Sud.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: ApaColors.white80,
                              fontSize: 14,
                              height: 20 / 14,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: onDonatePressed,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  'DONATE →',
                                  style: TextStyle(
                                    color: ApaColors.primaryRed,
                                    fontSize: 16,
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
                    const SizedBox(height: 48),
                    const Text(
                      'MORE STORIES',
                      style: TextStyle(
                        color: ApaColors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
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
                          const Padding(
                            padding: EdgeInsets.fromLTRB(32, 28, 32, 28),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'COMMUNITY',
                                  style: TextStyle(
                                    color: ApaColors.navy,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'New development project begins',
                                  style: TextStyle(
                                    color: ApaColors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    height: 26 / 20,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Short article description.',
                                  style: TextStyle(
                                    color: ApaColors.gray600,
                                    fontSize: 14,
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
      style: const TextStyle(
        color: ApaColors.gray800,
        fontSize: 16,
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
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: ApaColors.navy,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: ApaColors.gray800,
                fontSize: 15,
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: ApaColors.gray500,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: ApaColors.nearBlack,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
