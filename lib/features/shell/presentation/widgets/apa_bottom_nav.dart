import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/constants/apa_assets.dart';
import '../../../../core/constants/apa_dimens.dart';
import '../../../../core/theme/apa_colors.dart';
import '../../../../core/theme/apa_typography.dart';
import '../../../../core/widgets/apa_svg_icon.dart';
import '../models/apa_nav_item.dart';

/// Bottom navigation bar matching the Figma Home Page chrome.
///
/// The center donation FAB (70×70) overlaps the bar by ~51px, matching
/// Figma node `4:66`.
class ApaBottomNav extends StatelessWidget {
  const ApaBottomNav({
    super.key,
    required this.selected,
    this.onItemSelected,
  });

  final ApaNavItem selected;
  final ValueChanged<ApaNavItem>? onItemSelected;

  static const double _labelBlockHeight = 16;
  static const double _barContentHeight =
      ApaDimens.navTopPadding +
          ApaDimens.navIconSize +
          ApaDimens.navLabelTopSpacing +
          _labelBlockHeight +
          ApaDimens.navBottomPadding;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final overlapLift = ApaDimens.navFabOverlap - ApaDimens.navTopPadding;

    return SizedBox(
      height: _barContentHeight + bottomInset + overlapLift,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    ApaDimens.navHorizontalPadding,
                    ApaDimens.navTopPadding,
                    ApaDimens.navHorizontalPadding,
                    ApaDimens.navBottomPadding + bottomInset,
                  ),
                  decoration: const BoxDecoration(
                    color: ApaColors.navBarBackground,
                    border: Border(
                      top: BorderSide(color: ApaColors.white20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _NavSideItem(
                        item: ApaNavItem.home,
                        iconPath: ApaAssets.icHome,
                        selected: selected == ApaNavItem.home,
                        onTap: () => onItemSelected?.call(ApaNavItem.home),
                        useAssetColor: selected == ApaNavItem.home,
                        colorOverride: selected == ApaNavItem.home
                            ? null
                            : ApaColors.white,
                      ),
                      _NavSideItem(
                        item: ApaNavItem.projects,
                        iconPath: ApaAssets.icProjects,
                        selected: selected == ApaNavItem.projects,
                        onTap: () =>
                            onItemSelected?.call(ApaNavItem.projects),
                        colorOverride: selected == ApaNavItem.projects
                            ? ApaColors.primaryRed
                            : ApaColors.white,
                      ),
                      SizedBox(
                        width: ApaDimens.navFabSize,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: ApaDimens.navIconSize),
                            const SizedBox(
                              height: ApaDimens.navLabelTopSpacing,
                            ),
                            Text(
                              ApaNavItem.donation.label,
                              textAlign: TextAlign.center,
                              style: ApaTypography.navDonationLabel.copyWith(
                                color: selected == ApaNavItem.donation
                                    ? ApaColors.primaryRed
                                    : ApaColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _NavSideItem(
                        item: ApaNavItem.transparency,
                        iconPath: ApaAssets.icTransparency,
                        selected: selected == ApaNavItem.transparency,
                        onTap: () =>
                            onItemSelected?.call(ApaNavItem.transparency),
                        colorOverride: selected == ApaNavItem.transparency
                            ? ApaColors.primaryRed
                            : ApaColors.white,
                      ),
                      _NavSideItem(
                        item: ApaNavItem.more,
                        iconPath: ApaAssets.icMore,
                        selected: selected == ApaNavItem.more,
                        onTap: () => onItemSelected?.call(ApaNavItem.more),
                        colorOverride: selected == ApaNavItem.more
                            ? ApaColors.primaryRed
                            : ApaColors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomInset +
                ApaDimens.navBottomPadding +
                _labelBlockHeight +
                ApaDimens.navLabelTopSpacing +
                overlapLift -
                (ApaDimens.navFabSize - ApaDimens.navIconSize) / 2,
            child: Center(
              child: GestureDetector(
                onTap: () => onItemSelected?.call(ApaNavItem.donation),
                child: Container(
                  width: ApaDimens.navFabSize,
                  height: ApaDimens.navFabSize,
                  decoration: BoxDecoration(
                    color: ApaColors.primaryRed,
                    shape: BoxShape.circle,
                    border: Border.all(color: ApaColors.primaryRedBorder),
                    boxShadow: const [
                      BoxShadow(
                        color: ApaColors.donateShadow,
                        offset: Offset(0, 10),
                        blurRadius: 15,
                        spreadRadius: -3,
                      ),
                      BoxShadow(
                        color: ApaColors.donateShadow,
                        offset: Offset(0, 4),
                        blurRadius: 6,
                        spreadRadius: -4,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const ApaSvgIcon(
                    assetPath: ApaAssets.icDonationHeart,
                    size: ApaDimens.navFabIconSize,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavSideItem extends StatelessWidget {
  const _NavSideItem({
    required this.item,
    required this.iconPath,
    required this.selected,
    required this.onTap,
    this.useAssetColor = false,
    this.colorOverride,
  });

  final ApaNavItem item;
  final String iconPath;
  final bool selected;
  final VoidCallback onTap;
  final bool useAssetColor;
  final Color? colorOverride;

  @override
  Widget build(BuildContext context) {
    final labelStyle =
        selected ? ApaTypography.navLabelActive : ApaTypography.navLabel;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ApaSvgIcon(
              assetPath: iconPath,
              size: ApaDimens.navIconSize,
              color: useAssetColor ? null : (colorOverride ?? ApaColors.white),
            ),
            const SizedBox(height: ApaDimens.navLabelTopSpacing),
            Text(
              item.label,
              style: labelStyle,
            ),
          ],
        ),
      ),
    );
  }
}
