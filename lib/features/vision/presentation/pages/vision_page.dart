import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/apa_assets.dart';
import '../../../../core/theme/apa_colors.dart';
import '../../../../core/widgets/apa_shared_widgets.dart';
import '../../../../core/widgets/apa_svg_icon.dart';

/// Our Vision Page — Figma frame `16:1107`.
class VisionPage extends StatelessWidget {
  const VisionPage({
    super.key,
    this.onLearnMore,
  });

  final VoidCallback? onLearnMore;

  static const double _navBottomPad = 120;

  static const TextStyle _headlineWhite = TextStyle(
    color: ApaColors.white,
    fontSize: 34,
    fontWeight: FontWeight.w800,
    height: 40 / 34,
    letterSpacing: -0.5,
  );

  static const TextStyle _headlineRed = TextStyle(
    color: ApaColors.primaryRed,
    fontSize: 34,
    fontWeight: FontWeight.w800,
    height: 40 / 34,
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
                imageAsset: ApaAssets.visionHero,
                height: 505,
                badge: 'OUR VISION',
                headline: const [
                  TextSpan(
                    text: 'BUILDING A STRONGER,\n',
                    style: _headlineWhite,
                  ),
                  TextSpan(
                    text: 'SUSTAINABLE FUTURE TOGETHER.',
                    style: _headlineRed,
                  ),
                ],
                subtitle:
                    'Infrastructure that lasts — chosen with neighbors, built '
                    'by local crews, reported in the open.',
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 48, 24, _navBottomPad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'OUR VISION STATEMENT',
                      style: TextStyle(
                        color: ApaColors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 28 / 22,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'We envision resilient communities powered by '
                      'sustainable development, modern infrastructure, '
                      'education, and collaboration.',
                      style: TextStyle(
                        color: ApaColors.gray700,
                        fontSize: 16,
                        height: 24 / 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const ColoredBox(
                      color: ApaColors.black,
                      child: SizedBox(height: 1, width: double.infinity),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'CORE VALUES',
                      style: TextStyle(
                        color: ApaColors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 28 / 22,
                      ),
                    ),
                    const SizedBox(height: 28),
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
                    const SizedBox(height: 40),
                    const Text(
                      'FUTURE GOALS',
                      style: TextStyle(
                        color: ApaColors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 28 / 22,
                      ),
                    ),
                    const SizedBox(height: 24),
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
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 40,
                      ),
                      decoration: BoxDecoration(
                        color: ApaColors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _StatCell(
                                  value: '50+',
                                  label: 'PROJECTS',
                                ),
                              ),
                              Expanded(
                                child: _StatCell(
                                  value: '20K+',
                                  label: 'LIVES REACHED',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: _StatCell(
                                  value: '15+',
                                  label: 'PARTNERS',
                                ),
                              ),
                              Expanded(
                                child: _StatCell(
                                  value: '10',
                                  label: 'YEARS AHEAD',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                    const Text(
                      'JOIN OUR MISSION',
                      style: TextStyle(
                        color: ApaColors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 34 / 28,
                      ),
                    ),
                    const SizedBox(height: 24),
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
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: ColoredBox(
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
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
            color: ApaColors.black,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            height: 28 / 22,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: const TextStyle(
            color: ApaColors.gray700,
            fontSize: 16,
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
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: ColoredBox(
        color: ApaColors.gray200,
        child: SizedBox(height: 1, width: double.infinity),
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
          style: const TextStyle(
            color: ApaColors.nearBlack,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            height: 22 / 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          body,
          style: const TextStyle(
            color: ApaColors.gray600,
            fontSize: 14,
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
          style: const TextStyle(
            color: ApaColors.white,
            fontSize: 32,
            fontWeight: FontWeight.w800,
            height: 40 / 32,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: ApaColors.white60,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
