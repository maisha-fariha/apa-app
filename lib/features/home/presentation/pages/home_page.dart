import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/apa_assets.dart';
import '../../../../core/constants/apa_dimens.dart';
import '../../../../core/constants/apa_shell_insets.dart';
import '../../../../core/utils/responsive.dart';
import '../widgets/donate_button.dart';
import '../widgets/donation_amount_card.dart';
import '../widgets/home_background.dart';
import '../widgets/home_footer_note.dart';
import '../widgets/location_badge.dart';

/// APA Home Page — pixel-aligned to Figma node `4:2`.
class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    this.onDonatePressed,
  });

  final VoidCallback? onDonatePressed;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final topInset = media.padding.top;
    final width = media.size.width;
    final isWide = width >= ApaDimens.tabletBreakpoint;
    final horizontalPadding = isWide
        ? R.cw((width - ApaDimens.kMaxContentWidth).clamp(24.0, 120.0) / 2, context)
        : ApaDimens.horizontalPadding;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const HomeBackground(),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                ApaDimens.topPadding - (topInset > 0 ? 8.h : 0),
                horizontalPadding,
                ApaShellInsets.contentBottom(context),
              ),
              child: Column(
                children: [
                  SizedBox(height: ApaDimens.headerTopSpacing),
                  Center(
                    child: Image.asset(
                      ApaAssets.apaLogo,
                      width: ApaDimens.logoWidth,
                      height: ApaDimens.logoHeight,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: ApaDimens.maxContentWidth,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const LocationBadge(),
                            SizedBox(
                              height: ApaDimens.locationBadgeBottomSpacing,
                            ),
                            const DonationAmountCard(),
                            SizedBox(
                              height: ApaDimens.donationCardBottomSpacing,
                            ),
                            DonateButton(onPressed: onDonatePressed),
                            SizedBox(
                              height: ApaDimens.donateButtonBottomSpacing,
                            ),
                            const HomeFooterNote(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
