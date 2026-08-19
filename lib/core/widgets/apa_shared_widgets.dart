import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/apa_assets.dart';
import '../constants/apa_dimens.dart';
import '../theme/apa_colors.dart';
import '../theme/apa_fonts.dart';
import '../utils/responsive.dart';

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
    this.imageUrl,
  });

  final String imageAsset;
  final String? imageUrl;
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
    final desktop = R.isTabletLandscape(context);
    final screenH = MediaQuery.sizeOf(context).height;
    final heroHeight = desktop
        ? (screenH * 0.52).clamp(340.0, 460.0)
        : height.h + top;
    final hPad = desktop ? R.pagePadding(context) : ApaDimens.horizontalPadding;

    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _HeroImage(asset: imageAsset, url: imageUrl),
          ColoredBox(color: Colors.black.withValues(alpha: overlayOpacity)),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(hPad, desktop ? 20.h : 24.h, hPad, 32.h),
              child: ApaPageWidth(
                child: Stack(
                  children: [
                    Align(
                      alignment: alignLogoCenter
                          ? Alignment.topCenter
                          : Alignment.topLeft,
                      child: Image.asset(
                        ApaAssets.apaLogo,
                        width: logoWidth.w,
                        height: logoHeight.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: desktop ? 720 : double.infinity,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                badge.toUpperCase(),
                                style: ApaFonts.inter(
                                  color: ApaColors.locationYellow,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6.sp,
                                  height: 16 / 12,
                                ),
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Text.rich(
                              TextSpan(children: headline),
                            ),
                            if (subtitle != null) ...[
                              SizedBox(height: 16.h),
                              Text(
                                subtitle!,
                                style: ApaFonts.inter(
                                  color: ApaColors.white,
                                  fontSize: 15.sp,
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.asset, this.url});

  final String asset;
  final String? url;

  @override
  Widget build(BuildContext context) {
    final networkUrl = url?.trim();
    if (networkUrl != null && networkUrl.isNotEmpty) {
      return Image.network(
        networkUrl,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          asset,
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
      );
    }

    return Image.asset(
      asset,
      fit: BoxFit.cover,
      alignment: Alignment.center,
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
            horizontal: horizontalPadding.w,
            vertical: verticalPadding.h,
          ),
          child: Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: ApaFonts.inter(
              color: ApaColors.white,
              fontSize: fontSize.sp,
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
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 23.25.w,
            child: Text(
              '•',
              style: ApaFonts.inter(
                fontSize: 20.sp,
                height: 1,
                color: ApaColors.black,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: ApaFonts.inter(
                color: ApaColors.gray900,
                fontSize: 15.sp,
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
      style: ApaFonts.inter(
        color: ApaColors.navy,
        fontSize: 12.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        height: 16 / 12,
      ),
    );
  }
}
