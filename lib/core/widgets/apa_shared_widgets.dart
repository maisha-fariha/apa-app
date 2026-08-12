import 'package:flutter/material.dart';

import '../constants/apa_assets.dart';
import '../constants/apa_dimens.dart';
import '../theme/apa_colors.dart';

/// Reusable hero header used across content screens.
class ApaHeroHeader extends StatelessWidget {
  const ApaHeroHeader({
    super.key,
    required this.imageAsset,
    required this.badge,
    required this.headline,
    this.headlineAccent,
    this.subtitle,
    this.height = 500,
    this.overlayOpacity = 0.7,
    this.logoWidth = 180,
    this.logoHeight = 67.5,
    this.alignLogoCenter = true,
  });

  final String imageAsset;
  final String badge;
  final List<InlineSpan> headline;
  final Widget? headlineAccent;
  final String? subtitle;
  final double height;
  final double overlayOpacity;
  final double logoWidth;
  final double logoHeight;
  final bool alignLogoCenter;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;

    return SizedBox(
      height: height + top,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            imageAsset,
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
          ColoredBox(color: Colors.black.withValues(alpha: overlayOpacity)),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                ApaDimens.horizontalPadding,
                24,
                ApaDimens.horizontalPadding,
                40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: alignLogoCenter
                        ? Alignment.center
                        : Alignment.centerLeft,
                    child: Image.asset(
                      ApaAssets.apaLogo,
                      width: logoWidth,
                      height: logoHeight,
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
                    child: Text(
                      badge.toUpperCase(),
                      style: const TextStyle(
                        color: ApaColors.locationYellow,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        height: 16 / 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text.rich(
                    TextSpan(children: headline),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        color: ApaColors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        height: 20.63 / 15,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Black pill CTA used on Projects / Vision / News.
class ApaBlackPillButton extends StatelessWidget {
  const ApaBlackPillButton({
    super.key,
    required this.label,
    this.onPressed,
    this.expanded = false,
    this.fontSize = 20,
    this.horizontalPadding = 48,
    this.verticalPadding = 16,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expanded;
  final double fontSize;
  final double horizontalPadding;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    final child = Material(
      color: ApaColors.black,
      borderRadius: BorderRadius.circular(9999),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(9999),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ApaColors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: fontSize * 0.025,
              height: 1.4,
            ),
          ),
        ),
      ),
    );

    if (!expanded) return child;
    return SizedBox(width: double.infinity, child: child);
  }
}

/// Bullet list item matching Projects page.
class ApaBulletItem extends StatelessWidget {
  const ApaBulletItem({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 23.25,
            child: Text(
              '•',
              style: TextStyle(
                fontSize: 20,
                height: 1,
                color: ApaColors.black,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: ApaColors.gray900,
                fontSize: 15,
                height: 22.5 / 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ApaSectionLabel extends StatelessWidget {
  const ApaSectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: ApaColors.navy,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        height: 16 / 12,
      ),
    );
  }
}
