import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/apa_assets.dart';
import '../../../../core/constants/apa_dimens.dart';
import '../../../../core/theme/apa_colors.dart';
import '../../../../core/theme/apa_typography.dart';
import '../../../../core/widgets/apa_svg_icon.dart';

/// Glassmorphism donation amount card with increment / decrement controls.
class DonationAmountCard extends StatelessWidget {
  const DonationAmountCard({
    super.key,
    required this.amount,
    required this.onIncrement,
    required this.onDecrement,
    this.currencyCode = 'USD',
    this.canIncrement = true,
    this.canDecrement = true,
  });

  final int amount;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final String currencyCode;
  final bool canIncrement;
  final bool canDecrement;

  static String formatDate(DateTime date) {
    const months = [
      'JANUARY',
      'FEBRUARY',
      'MARCH',
      'APRIL',
      'MAY',
      'JUNE',
      'JULY',
      'AUGUST',
      'SEPTEMBER',
      'OCTOBER',
      'NOVEMBER',
      'DECEMBER',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(ApaDimens.donationCardRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6.5, sigmaY: 6.5),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(ApaDimens.donationCardPadding),
          decoration: BoxDecoration(
            color: ApaColors.white10,
            borderRadius: BorderRadius.circular(ApaDimens.donationCardRadius),
            border: Border.all(color: ApaColors.white20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ApaSvgIcon(
                    assetPath: ApaAssets.icCalendar,
                    size: ApaDimens.kDonationDateIconSize,
                  ),
                  SizedBox(width: ApaDimens.donationDateGap),
                  Text(
                    formatDate(DateTime.now()),
                    style: ApaTypography.donationDate,
                  ),
                ],
              ),
              SizedBox(height: ApaDimens.donationDividerSpacingTop),
              const Divider(
                height: 1,
                thickness: 1,
                color: ApaColors.white20,
              ),
              SizedBox(height: ApaDimens.donationDividerSpacingBottom),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 4.h),
                    child: Text(
                      '\$',
                      style: ApaTypography.currencySymbol,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    '$amount',
                    style: ApaTypography.donationAmount,
                  ),
                  SizedBox(width: 10.w),
                  Padding(
                    padding: EdgeInsets.only(bottom: 2.h),
                    child: Text(
                      currencyCode.toUpperCase(),
                      style: ApaTypography.currencyCode,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  _AmountStepper(
                    onIncrement: canIncrement ? onIncrement : null,
                    onDecrement: canDecrement ? onDecrement : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmountStepper extends StatelessWidget {
  const _AmountStepper({
    required this.onIncrement,
    required this.onDecrement,
  });

  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28.w,
      decoration: BoxDecoration(
        color: ApaColors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            icon: Icons.keyboard_arrow_up_rounded,
            onPressed: onIncrement,
          ),
          Container(height: 1, color: ApaColors.gray200),
          _StepperButton(
            icon: Icons.keyboard_arrow_down_rounded,
            onPressed: onDecrement,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: SizedBox(
        height: 22.h,
        width: double.infinity,
        child: Center(
          child: Icon(
            icon,
            size: 18.sp,
            color: onPressed == null ? ApaColors.gray400 : ApaColors.nearBlack,
          ),
        ),
      ),
    );
  }
}
