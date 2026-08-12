import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/constants/apa_dimens.dart';
import '../../../../core/theme/apa_colors.dart';
import '../../../../core/theme/apa_typography.dart';

/// Pill location badge: "SUD, HAITI".
class LocationBadge extends StatelessWidget {
  const LocationBadge({
    super.key,
    this.label = 'SUD, HAITI',
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(ApaDimens.donateButtonRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: ApaDimens.locationBadgeHorizontalPadding,
            vertical: ApaDimens.locationBadgeVerticalPadding,
          ),
          decoration: BoxDecoration(
            color: ApaColors.locationYellowFill,
            borderRadius: BorderRadius.circular(ApaDimens.donateButtonRadius),
            border: Border.all(color: ApaColors.locationYellowBorder),
          ),
          child: Text(
            label.toUpperCase(),
            style: ApaTypography.locationBadge,
          ),
        ),
      ),
    );
  }
}
