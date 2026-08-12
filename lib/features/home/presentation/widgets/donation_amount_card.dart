import 'dart:ui';

import 'package:flutter/material.dart';

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
          padding: const EdgeInsets.all(ApaDimens.donationCardPadding),
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
                  const ApaSvgIcon(
                    assetPath: ApaAssets.icCalendar,
                    size: ApaDimens.donationDateIconSize,
                  ),
                  const SizedBox(width: ApaDimens.donationDateGap),
                  Text(
                    dateLabel.toUpperCase(),
                    style: ApaTypography.donationDate,
                  ),
                ],
              ),
              const SizedBox(height: ApaDimens.donationDividerSpacingTop),
              const Divider(
                height: 1,
                thickness: 1,
                color: ApaColors.white20,
              ),
              const SizedBox(height: ApaDimens.donationDividerSpacingBottom),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      '\$',
                      style: ApaTypography.currencySymbol,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    amountLabel,
                    style: ApaTypography.donationAmount,
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 7),
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
