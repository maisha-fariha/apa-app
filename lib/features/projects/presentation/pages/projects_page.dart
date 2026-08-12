import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/apa_assets.dart';
import '../../../../core/constants/apa_shell_insets.dart';
import '../../../../core/theme/apa_colors.dart';
import '../../../../core/theme/apa_fonts.dart';
import '../../../../core/widgets/apa_shared_widgets.dart';

/// Projects Page — Figma frame `6:203`.
class ProjectsPage extends StatelessWidget {
  const ProjectsPage({
    super.key,
    this.scrollController,
    this.onFundPressed,
  });

  final ScrollController? scrollController;
  final VoidCallback? onFundPressed;

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
                imageAsset: ApaAssets.projectsHero,
                height: 520,
                overlayOpacity: 0.7,
                logoWidth: 180,
                logoHeight: 67.5,
                badge: 'PHASE ONE · HAITI',
                headline: [
                  TextSpan(
                    text: 'THREE THINGS\n',
                    style: ApaFonts.inter(
                      color: ApaColors.white,
                      fontSize: 36.sp,
                      fontWeight: FontWeight.w800,
                      height: 40 / 36,
                      letterSpacing: -0.5,
                    ),
                  ),
                  TextSpan(
                    text: 'A STREET NEEDS.',
                    style: ApaFonts.inter(
                      color: ApaColors.primaryRed,
                      fontSize: 36.sp,
                      fontWeight: FontWeight.w800,
                      height: 40 / 36,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
                subtitle:
                    'Every project is chosen the same way: it must solve '
                    'something urgent now, and still be working ten years '
                    'from now.',
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24.w, 48.h, 24.w, navBottomPad),
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
                    Text(
                      'HOW WE WORK',
                      style: ApaFonts.inter(
                        color: ApaColors.black,
                        fontSize: 36.sp,
                        fontWeight: FontWeight.w800,
                        height: 40 / 36,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Communities help choose, shape, and maintain each '
                      'project. Local crews are hired first. Materials are '
                      'sourced in Haiti wherever they can be. Every stage is '
                      'reported back to donors and to the neighborhood it '
                      'serves.',
                      style: ApaFonts.inter(
                        color: ApaColors.gray700,
                        fontSize: 16.sp,
                        height: 24 / 16,
                      ),
                    ),
                    SizedBox(height: 28.h),
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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: const ColoredBox(
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
        SizedBox(height: 8.h),
        Text(
          title,
          style: ApaFonts.inter(
            color: ApaColors.black,
            fontSize: 28.sp,
            fontWeight: FontWeight.w800,
            height: 32 / 28,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          body,
          style: ApaFonts.inter(
            color: ApaColors.gray700,
            fontSize: 15.sp,
            height: 22.5 / 15,
          ),
        ),
        SizedBox(height: 12.h),
        ...bullets.map((b) => ApaBulletItem(text: b)),
      ],
    );
  }
}
