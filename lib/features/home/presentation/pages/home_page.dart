import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/apa_assets.dart';
import '../../../../core/constants/apa_dimens.dart';
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
        ? (width - ApaDimens.maxContentWidth).clamp(24.0, 120.0) / 2
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
                ApaDimens.topPadding - (topInset > 0 ? 8 : 0),
                horizontalPadding,
                ApaDimens.contentBottomInset,
              ),
              child: Column(
                children: [
                  const SizedBox(height: ApaDimens.headerTopSpacing),
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
                        constraints: const BoxConstraints(
                          maxWidth: ApaDimens.maxContentWidth,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const LocationBadge(),
                            const SizedBox(
                              height: ApaDimens.locationBadgeBottomSpacing,
                            ),
                            const DonationAmountCard(),
                            const SizedBox(
                              height: ApaDimens.donationCardBottomSpacing,
                            ),
                            DonateButton(onPressed: onDonatePressed),
                            const SizedBox(
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
