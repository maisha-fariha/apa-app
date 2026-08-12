import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/apa_assets.dart';
import '../../../../core/constants/apa_dimens.dart';
import '../../../../core/theme/apa_colors.dart';
import '../../../../core/theme/apa_typography.dart';
import '../../../../core/widgets/apa_svg_icon.dart';

/// Glassmorphism donation amount card from Figma.
class DonationAmountCard extends StatelessWidget {
  const DonationAmountCard({
    super.key,
    this.dateLabel = 'AUGUST 10 , 2026',
    this.amountLabel = '0.00',
    this.currencyCode = 'USD',
  });

  final String dateLabel;
  final String amountLabel;
  final String currencyCode;

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
                    dateLabel.toUpperCase(),
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
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 3.h),
                    child: Text(
                      '\$',
                      style: ApaTypography.currencySymbol,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    amountLabel,
                    style: ApaTypography.donationAmount,
                  ),
                  SizedBox(width: 8.w),
                  Padding(
                    padding: EdgeInsets.only(bottom: 7.h),
                    child: Text(
                      currencyCode.toUpperCase(),
                      style: ApaTypography.currencyCode,
                    ),
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
