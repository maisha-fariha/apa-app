import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/apa_assets.dart';
import '../../../../core/constants/apa_dimens.dart';
import '../../../../core/theme/apa_colors.dart';
import '../../../../core/theme/apa_typography.dart';
import '../../../../core/widgets/apa_svg_icon.dart';

/// Primary red pill DONATE CTA with an animated red-to-white border sweep.
class DonateButton extends StatefulWidget {
  const DonateButton({
    super.key,
    this.label = 'DONATE',
    this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  State<DonateButton> createState() => _DonateButtonState();
}

class _DonateButtonState extends State<DonateButton>
    with SingleTickerProviderStateMixin {
  static const double _borderWidth = 2;

  late final AnimationController _borderController;

  @override
  void initState() {
    super.initState();
    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
  }

  @override
  void dispose() {
    _borderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = ApaDimens.donateButtonRadius;
    final border = _borderWidth.w;
    final innerRadius = radius > border ? radius - border : radius;

    return SizedBox(
      width: double.infinity,
      height: ApaDimens.donateButtonHeight,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(radius),
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: AnimatedBuilder(
                  animation: _borderController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _borderController.value * 2 * math.pi,
                      child: Transform.scale(
                        scale: 1.8,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: SweepGradient(
                              colors: const [
                                ApaColors.primaryRed,
                                ApaColors.white,
                                ApaColors.primaryRed,
                                ApaColors.white,
                                ApaColors.primaryRed,
                              ],
                              stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                            ),
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(border),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(innerRadius),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: ApaColors.primaryRed,
                      borderRadius: BorderRadius.circular(innerRadius),
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
                          widget.label.toUpperCase(),
                          style: ApaTypography.donateButton,
                        ),
                        SizedBox(width: ApaDimens.donateArrowLeading),
                        ApaSvgIcon(
                          assetPath: ApaAssets.icArrowRight,
                          size: ApaDimens.kDonateArrowSize,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
