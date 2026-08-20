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
    this.scrollController,
    this.onDonatePressed,
    this.imageUrl,
  });

  final ScrollController? scrollController;
  final ValueChanged<int>? onDonatePressed;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final topInset = media.padding.top;
    final landscape = R.isTabletLandscape(context);
    final horizontalPadding =
        landscape ? R.pagePadding(context) : ApaDimens.horizontalPadding;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Stack(
        fit: StackFit.expand,
        children: [
          HomeBackground(imageUrl: imageUrl),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                ApaDimens.topPadding - (topInset > 0 ? 8.h : 0),
                horizontalPadding,
                ApaShellInsets.contentBottom(context),
              ),
              child: landscape
                  ? _LandscapeHome(
                      scrollController: scrollController,
                      onDonatePressed: onDonatePressed,
                    )
                  : _PhoneHome(onDonatePressed: onDonatePressed),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhoneHome extends StatelessWidget {
  const _PhoneHome({this.onDonatePressed});

  final ValueChanged<int>? onDonatePressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: ApaDimens.maxContentWidth,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: ApaDimens.headerTopSpacing),
                    const _HomeLogo(),
                    _HomeBody(onDonatePressed: onDonatePressed),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LandscapeHome extends StatelessWidget {
  const _LandscapeHome({
    this.scrollController,
    this.onDonatePressed,
  });

  final ScrollController? scrollController;
  final ValueChanged<int>? onDonatePressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          controller: scrollController,
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: ApaDimens.kMaxContentWidth,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _HomeLogo(),
                    SizedBox(height: ApaDimens.locationBadgeBottomSpacing),
                    _HomeBody(onDonatePressed: onDonatePressed),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HomeLogo extends StatelessWidget {
  const _HomeLogo();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        ApaAssets.apaLogo,
        width: ApaDimens.logoWidth,
        height: ApaDimens.logoHeight,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _HomeBody extends StatefulWidget {
  const _HomeBody({this.onDonatePressed});

  final ValueChanged<int>? onDonatePressed;

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  static const int _minAmount = 1;

  int _amount = 100;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const LocationBadge(),
        SizedBox(height: ApaDimens.locationBadgeBottomSpacing),
        DonationAmountCard(
          amount: _amount,
          minAmount: _minAmount,
          onAmountChanged: (value) => setState(() => _amount = value),
        ),
        SizedBox(height: ApaDimens.donationCardBottomSpacing),
        DonateButton(
          onPressed: widget.onDonatePressed == null
              ? null
              : () => widget.onDonatePressed!(_amount),
        ),
        SizedBox(height: ApaDimens.donateButtonBottomSpacing),
        const HomeFooterNote(),
      ],
    );
  }
}
