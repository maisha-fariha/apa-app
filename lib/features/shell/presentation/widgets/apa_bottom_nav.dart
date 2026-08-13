import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/apa_assets.dart';
import '../../../../core/constants/apa_dimens.dart';
import '../../../../core/theme/apa_colors.dart';
import '../../../../core/theme/apa_typography.dart';
import '../../../../core/widgets/apa_svg_icon.dart';
import '../models/apa_nav_item.dart';

/// Bottom navigation bar matching the Figma / reference chrome.
///
/// Five equal slots with a center donation FAB overlapping the bar top edge.
class ApaBottomNav extends StatelessWidget {
  const ApaBottomNav({
    super.key,
    required this.selected,
    this.onItemSelected,
  });

  final ApaNavItem selected;
  final ValueChanged<ApaNavItem>? onItemSelected;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final iconSize = ApaDimens.navIconSize;
    final labelGap = ApaDimens.navLabelTopSpacing;
    final topPad = ApaDimens.navTopPadding;
    final bottomPad = ApaDimens.navBottomPadding;
    final fabSize = ApaDimens.navFabSize;
    final fabOverlap = ApaDimens.navFabOverlap;

    // Use tallest nav label line height so every label fits vertically.
    final labelRowHeight = 16.h;
    final barBodyHeight =
        topPad + iconSize + labelGap + labelRowHeight + bottomPad;
    final overlapLift = fabOverlap - topPad;
    final totalHeight = barBodyHeight + bottomInset + overlapLift;

    final fabBottom = bottomInset +
        bottomPad +
        labelRowHeight +
        labelGap +
        overlapLift -
        (fabSize - iconSize) / 2;

    return SizedBox(
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                0,
                topPad,
                0,
                bottomPad + bottomInset,
              ),
              decoration: const BoxDecoration(
                color: ApaColors.navBarBackground,
                border: Border(
                  top: BorderSide(color: ApaColors.white20),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: _NavSideItem(
                      item: ApaNavItem.home,
                      iconPath: ApaAssets.icHome,
                      selected: selected == ApaNavItem.home,
                      onTap: () => onItemSelected?.call(ApaNavItem.home),
                      useAssetColor: selected == ApaNavItem.home,
                      colorOverride: selected == ApaNavItem.home
                          ? null
                          : ApaColors.white,
                    ),
                  ),
                  Expanded(
                    child: _NavSideItem(
                      item: ApaNavItem.projects,
                      iconPath: ApaAssets.icProjects,
                      selected: selected == ApaNavItem.projects,
                      onTap: () => onItemSelected?.call(ApaNavItem.projects),
                      colorOverride: selected == ApaNavItem.projects
                          ? ApaColors.primaryRed
                          : ApaColors.white,
                    ),
                  ),
                  Expanded(
                    child: _DonationLabelSlot(
                      iconSize: iconSize,
                      labelGap: labelGap,
                    ),
                  ),
                  Expanded(
                    child: _NavSideItem(
                      item: ApaNavItem.transparency,
                      iconPath: ApaAssets.icTransparency,
                      selected: selected == ApaNavItem.transparency,
                      onTap: () =>
                          onItemSelected?.call(ApaNavItem.transparency),
                      colorOverride: selected == ApaNavItem.transparency
                          ? ApaColors.primaryRed
                          : ApaColors.white,
                    ),
                  ),
                  Expanded(
                    child: _NavSideItem(
                      item: ApaNavItem.more,
                      iconPath: ApaAssets.icMore,
                      selected: selected == ApaNavItem.more,
                      onTap: () => onItemSelected?.call(ApaNavItem.more),
                      colorOverride: selected == ApaNavItem.more
                          ? ApaColors.primaryRed
                          : ApaColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: fabBottom,
            child: Center(
              child: _DonationFab(
                size: fabSize,
                onTap: () => onItemSelected?.call(ApaNavItem.donation),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Spacer + label for the center column; FAB is stacked above in [ApaBottomNav].
class _DonationLabelSlot extends StatelessWidget {
  const _DonationLabelSlot({
    required this.iconSize,
    required this.labelGap,
  });

  final double iconSize;
  final double labelGap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: iconSize),
        SizedBox(height: labelGap),
        _NavLabelText(
          label: ApaNavItem.donation.label,
          style: ApaTypography.navDonationLabel,
        ),
      ],
    );
  }
}

/// Scales label down only when needed so the full word stays visible.
class _NavLabelText extends StatelessWidget {
  const _NavLabelText({
    required this.label,
    required this.style,
  });

  final String label;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: style.fontSize != null
          ? (style.height ?? 1.2) * style.fontSize!
          : 16.h,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Text(
          label,
          maxLines: 1,
          softWrap: false,
          textAlign: TextAlign.center,
          style: style,
        ),
      ),
    );
  }
}

/// Elevated red circle with heart icon and soft glow at the bar edge.
class _DonationFab extends StatelessWidget {
  const _DonationFab({
    required this.size,
    required this.onTap,
  });

  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: ApaColors.primaryRed,
            shape: BoxShape.circle,
            border: Border.all(color: ApaColors.primaryRedBorder),
            boxShadow: [
              BoxShadow(
                color: ApaColors.donateShadow,
                offset: Offset(0, 10.h),
                blurRadius: 15.r,
                spreadRadius: -3,
              ),
              BoxShadow(
                color: ApaColors.donateShadow,
                offset: Offset(0, 4.h),
                blurRadius: 6.r,
                spreadRadius: -4,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: ApaSvgIcon(
            assetPath: ApaAssets.icDonationHeart,
            size: ApaDimens.kNavFabIconSize,
          ),
        ),
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ApaSvgIcon(
                assetPath: iconPath,
                size: ApaDimens.kNavIconSize,
                color: useAssetColor ? null : (colorOverride ?? ApaColors.white),
              ),
              SizedBox(height: ApaDimens.navLabelTopSpacing),
              _NavLabelText(label: item.label, style: labelStyle),
            ],
          ),
        ),
      ),
    );
  }
}
