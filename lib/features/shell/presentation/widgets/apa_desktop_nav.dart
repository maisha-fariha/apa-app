import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/apa_assets.dart';
import '../../../../core/constants/apa_dimens.dart';
import '../../../../core/theme/apa_colors.dart';
import '../../../../core/theme/apa_typography.dart';
import '../../../../core/widgets/apa_svg_icon.dart';
import '../models/apa_nav_item.dart';

/// Tablet-landscape bottom nav — same design as the phone bar.
///
/// Five equal columns share one icon row and one label baseline.
/// The donation FAB is centered on the bar's top edge.
class ApaDesktopNav extends StatelessWidget {
  const ApaDesktopNav({
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
    final labelRowHeight = ApaDimens.navLabelRowHeight;
    final topPad = ApaDimens.navTopPadding;
    final bottomPad = ApaDimens.navBottomPadding;
    final fabSize = ApaDimens.navFabSize;
    final barBodyHeight = ApaDimens.navBarBodyHeight;
    final overlapLift = ApaDimens.navFabOverlap;

    return SizedBox(
      height: overlapLift + barBodyHeight + bottomInset,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                ApaDimens.navHorizontalPadding,
                topPad,
                ApaDimens.navHorizontalPadding,
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
                    child: _NavColumn(
                      iconSize: iconSize,
                      labelGap: labelGap,
                      labelRowHeight: labelRowHeight,
                      onTap: () => onItemSelected?.call(ApaNavItem.home),
                      icon: ApaSvgIcon(
                        assetPath: ApaAssets.icHome,
                        size: ApaDimens.kNavIconSize,
                        color: selected == ApaNavItem.home
                            ? null
                            : ApaColors.white,
                      ),
                      label: ApaNavItem.home.label,
                      labelStyle: selected == ApaNavItem.home
                          ? ApaTypography.navLabelActive
                          : ApaTypography.navLabel,
                    ),
                  ),
                  Expanded(
                    child: _NavColumn(
                      iconSize: iconSize,
                      labelGap: labelGap,
                      labelRowHeight: labelRowHeight,
                      onTap: () => onItemSelected?.call(ApaNavItem.projects),
                      icon: ApaSvgIcon(
                        assetPath: ApaAssets.icProjects,
                        size: ApaDimens.kNavIconSize,
                        color: selected == ApaNavItem.projects
                            ? ApaColors.primaryRed
                            : ApaColors.white,
                      ),
                      label: ApaNavItem.projects.label,
                      labelStyle: selected == ApaNavItem.projects
                          ? ApaTypography.navLabelActive
                          : ApaTypography.navLabel,
                    ),
                  ),
                  Expanded(
                    child: _NavColumn(
                      iconSize: iconSize,
                      labelGap: labelGap,
                      labelRowHeight: labelRowHeight,
                      onTap: () => onItemSelected?.call(ApaNavItem.donation),
                      icon: SizedBox(width: iconSize, height: iconSize),
                      label: ApaNavItem.donation.label,
                      labelStyle: ApaTypography.navDonationLabel,
                    ),
                  ),
                  Expanded(
                    child: _NavColumn(
                      iconSize: iconSize,
                      labelGap: labelGap,
                      labelRowHeight: labelRowHeight,
                      onTap: () =>
                          onItemSelected?.call(ApaNavItem.transparency),
                      icon: ApaSvgIcon(
                        assetPath: ApaAssets.icTransparency,
                        size: ApaDimens.kNavIconSize,
                        color: selected == ApaNavItem.transparency
                            ? ApaColors.primaryRed
                            : ApaColors.white,
                      ),
                      label: ApaNavItem.transparency.label,
                      labelStyle: selected == ApaNavItem.transparency
                          ? ApaTypography.navLabelActive
                          : ApaTypography.navLabel,
                    ),
                  ),
                  Expanded(
                    child: _NavColumn(
                      iconSize: iconSize,
                      labelGap: labelGap,
                      labelRowHeight: labelRowHeight,
                      onTap: () => onItemSelected?.call(ApaNavItem.more),
                      icon: ApaSvgIcon(
                        assetPath: ApaAssets.icMore,
                        size: ApaDimens.kNavIconSize,
                        color: selected == ApaNavItem.more
                            ? ApaColors.primaryRed
                            : ApaColors.white,
                      ),
                      label: ApaNavItem.more.label,
                      labelStyle: selected == ApaNavItem.more
                          ? ApaTypography.navLabelActive
                          : ApaTypography.navLabel,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomInset + barBodyHeight - fabSize / 2,
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

class _NavColumn extends StatelessWidget {
  const _NavColumn({
    required this.iconSize,
    required this.labelGap,
    required this.labelRowHeight,
    required this.onTap,
    required this.icon,
    required this.label,
    required this.labelStyle,
  });

  final double iconSize;
  final double labelGap;
  final double labelRowHeight;
  final VoidCallback onTap;
  final Widget icon;
  final String label;
  final TextStyle labelStyle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: iconSize,
              child: Center(child: icon),
            ),
            SizedBox(height: labelGap),
            SizedBox(
              height: labelRowHeight,
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  textAlign: TextAlign.center,
                  style: labelStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
                offset: Offset(0, 8.h),
                blurRadius: 12.r,
                spreadRadius: -2,
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
