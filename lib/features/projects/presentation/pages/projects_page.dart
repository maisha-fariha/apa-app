import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/apa_assets.dart';
import '../../../../core/theme/apa_colors.dart';
import '../../../../core/widgets/apa_shared_widgets.dart';

/// Projects Page — Figma frame `6:203`.
class ProjectsPage extends StatelessWidget {
  const ProjectsPage({
    super.key,
    this.onFundPressed,
  });

  final VoidCallback? onFundPressed;

  static const double _navBottomPad = 120;

  static const TextStyle _headlineWhite = TextStyle(
    color: ApaColors.white,
    fontSize: 36,
    fontWeight: FontWeight.w800,
    height: 40 / 36,
    letterSpacing: -0.5,
  );

  static const TextStyle _headlineRed = TextStyle(
    color: ApaColors.primaryRed,
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
                imageAsset: ApaAssets.projectsHero,
                height: 520,
                overlayOpacity: 0.7,
                logoWidth: 180,
                logoHeight: 67.5,
                badge: 'PHASE ONE · HAITI',
                headline: const [
                  TextSpan(text: 'THREE THINGS\n', style: _headlineWhite),
                  TextSpan(text: 'A STREET NEEDS.', style: _headlineRed),
                ],
                subtitle:
                    'Every project is chosen the same way: it must solve '
                    'something urgent now, and still be working ten years '
                    'from now.',
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 48, 24, _navBottomPad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _ProjectSection(
                      label: 'PARKS & COMMUNITY SPACES',
                      title: 'Somewhere to gather',
                      body: 'Modern public parks for families and children.',
                      bullets: [
                        'Playgrounds built for daily use',
                        'Recreational spaces for families',
                        'Safe gathering places that stay open after dark',
                      ],
                    ),
                    const _BlackSeparator(),
                    const _ProjectSection(
                      label: 'ROAD IMPROVEMENT',
                      title: 'Somewhere to go',
                      body:
                          'Repairing damaged roads in underserved communities.',
                      bullets: [
                        'Access to markets, schools, and clinics',
                        'Safer routes for pedestrians and vendors',
                        'Durable materials chosen for Haitian conditions',
                      ],
                    ),
                    const _BlackSeparator(),
                    const _ProjectSection(
                      label: 'RENEWABLE STREET LIGHTING',
                      title: 'Something to see by',
                      body:
                          'Solar-powered lights where the grid does not reach.',
                      bullets: [
                        'Solar units that need no grid connection',
                        'Safer streets after sunset',
                        'Lower long-term maintenance for neighborhoods',
                      ],
                    ),
                    const _BlackSeparator(),
                    const Text(
                      'HOW WE WORK',
                      style: TextStyle(
                        color: ApaColors.black,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        height: 40 / 36,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Communities help choose, shape, and maintain each '
                      'project. Local crews are hired first. Materials are '
                      'sourced in Haiti wherever they can be. Every stage is '
                      'reported back to donors and to the neighborhood it '
                      'serves.',
                      style: TextStyle(
                        color: ApaColors.gray700,
                        fontSize: 16,
                        height: 24 / 16,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Center(
                      child: ApaBlackPillButton(
                        label: 'FUND A PROJECT',
                        onPressed: onFundPressed,
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

class _BlackSeparator extends StatelessWidget {
  const _BlackSeparator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: ColoredBox(
        color: ApaColors.black,
        child: SizedBox(height: 1, width: double.infinity),
      ),
    );
  }
}

class _ProjectSection extends StatelessWidget {
  const _ProjectSection({
    required this.label,
    required this.title,
    required this.body,
    required this.bullets,
  });

  final String label;
  final String title;
  final String body;
  final List<String> bullets;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ApaSectionLabel(label),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            color: ApaColors.black,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 32 / 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: const TextStyle(
            color: ApaColors.gray700,
            fontSize: 15,
            height: 22.5 / 15,
          ),
        ),
        const SizedBox(height: 12),
        ...bullets.map((b) => ApaBulletItem(text: b)),
      ],
    );
  }
}
