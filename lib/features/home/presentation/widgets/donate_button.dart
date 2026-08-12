import 'package:flutter/material.dart';

import '../../../../core/constants/apa_assets.dart';
import '../../../../core/constants/apa_dimens.dart';
import '../../../../core/theme/apa_colors.dart';
import '../../../../core/theme/apa_typography.dart';
import '../../../../core/widgets/apa_svg_icon.dart';

/// Primary red pill DONATE CTA from Figma.
class DonateButton extends StatelessWidget {
  const DonateButton({
    super.key,
    this.label = 'DONATE',
    this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(ApaDimens.donateButtonRadius),
        child: Ink(
          width: double.infinity,
          height: ApaDimens.donateButtonHeight,
          decoration: BoxDecoration(
            color: ApaColors.primaryRed,
            borderRadius: BorderRadius.circular(ApaDimens.donateButtonRadius),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label.toUpperCase(),
                style: ApaTypography.donateButton,
              ),
              const SizedBox(width: ApaDimens.donateArrowLeading),
              const ApaSvgIcon(
                assetPath: ApaAssets.icArrowRight,
                size: ApaDimens.donateArrowSize,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
