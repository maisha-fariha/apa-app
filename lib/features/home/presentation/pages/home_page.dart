import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constants/apa_assets.dart';
import '../../../../core/constants/apa_dimens.dart';
import '../../../../core/constants/apa_shell_insets.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../data/models/post/post_model.dart';
import '../../../shell/presentation/controllers/pages_controller.dart';
import '../../../shell/presentation/models/apa_nav_item.dart';
import '../../domain/home_page_content.dart';
import '../widgets/donate_button.dart';
import '../widgets/donation_amount_card.dart';
import '../widgets/home_background.dart';
import '../widgets/home_footer_note.dart';
import '../widgets/location_badge.dart';

/// APA Home Page — CMS-backed (`get-post-details` for front-page).
class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    this.scrollController,
    this.onDonatePressed,
    this.imageUrl,
    this.page,
  });

  final ScrollController? scrollController;
  final ValueChanged<int>? onDonatePressed;
  final String? imageUrl;
  final PostItem? page;

  PagesController? get _pagesController {
    if (!Get.isRegistered<PagesController>()) return null;
    return Get.find<PagesController>();
  }

  HomePageContent _content(PagesController? controller) {
    final details = controller?.resolvedPageForShell(ApaShellPage.home) ?? page;
    if (details == null) return HomePageContent.fallback;
    return HomePageContent.fromPost(details);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final topInset = media.padding.top;
    final landscape = R.isTabletLandscape(context);
    final horizontalPadding =
        landscape ? R.pagePadding(context) : ApaDimens.horizontalPadding;
    final pagesController = _pagesController;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Obx(() {
        pagesController?.pageDetailsById.length;
        pagesController?.globalSettings.value;
        final content = _content(pagesController);
        final bgUrl = content.imageUrl ?? imageUrl;
        final logoUrl = pagesController?.siteLogoUrl;

        return Stack(
          fit: StackFit.expand,
          children: [
            HomeBackground(imageUrl: bgUrl),
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
                        content: content,
                        logoUrl: logoUrl,
                      )
                    : _PhoneHome(
                        onDonatePressed: onDonatePressed,
                        content: content,
                        logoUrl: logoUrl,
                      ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _PhoneHome extends StatelessWidget {
  const _PhoneHome({
    required this.content,
    this.onDonatePressed,
    this.logoUrl,
  });

  final HomePageContent content;
  final ValueChanged<int>? onDonatePressed;
  final String? logoUrl;

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
                    _HomeLogo(logoUrl: logoUrl),
                    _HomeBody(
                      key: ValueKey(
                        'home-body-${content.minimumDonateAmount}-'
                        '${content.heading}',
                      ),
                      content: content,
                      onDonatePressed: onDonatePressed,
                    ),
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
    required this.content,
    this.scrollController,
    this.onDonatePressed,
    this.logoUrl,
  });

  final HomePageContent content;
  final ScrollController? scrollController;
  final ValueChanged<int>? onDonatePressed;
  final String? logoUrl;

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
                    _HomeLogo(logoUrl: logoUrl),
                    SizedBox(height: ApaDimens.locationBadgeBottomSpacing),
                    _HomeBody(
                      key: ValueKey(
                        'home-body-${content.minimumDonateAmount}-'
                        '${content.heading}',
                      ),
                      content: content,
                      onDonatePressed: onDonatePressed,
                    ),
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
  const _HomeLogo({this.logoUrl});

  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    final url = logoUrl?.trim() ?? '';
    return Center(
      child: url.isNotEmpty
          ? Image.network(
              url,
              width: ApaDimens.logoWidth,
              height: ApaDimens.logoHeight,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                ApaAssets.apaLogo,
                width: ApaDimens.logoWidth,
                height: ApaDimens.logoHeight,
                fit: BoxFit.contain,
              ),
            )
          : Image.asset(
              ApaAssets.apaLogo,
              width: ApaDimens.logoWidth,
              height: ApaDimens.logoHeight,
              fit: BoxFit.contain,
            ),
    );
  }
}

class _HomeBody extends StatefulWidget {
  const _HomeBody({
    super.key,
    required this.content,
    this.onDonatePressed,
  });

  final HomePageContent content;
  final ValueChanged<int>? onDonatePressed;

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  late int _amount;
  late int _minAmount;

  @override
  void initState() {
    super.initState();
    // CMS `minimum_donate_amount` is the default amount shown on Home.
    _minAmount = widget.content.minimumDonateAmount;
    _amount = _minAmount;
  }

  @override
  void didUpdateWidget(covariant _HomeBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextMin = widget.content.minimumDonateAmount;
    if (oldWidget.content.minimumDonateAmount != nextMin) {
      setState(() {
        _minAmount = nextMin;
        _amount = nextMin;
      });
    } else if (_amount < nextMin) {
      setState(() {
        _minAmount = nextMin;
        _amount = nextMin;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.content;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LocationBadge(label: content.heading),
        SizedBox(height: ApaDimens.locationBadgeBottomSpacing),
        DonationAmountCard(
          amount: _amount,
          minAmount: _minAmount,
          onAmountChanged: (value) => setState(() => _amount = value),
        ),
        SizedBox(height: ApaDimens.donationCardBottomSpacing),
        DonateButton(
          label: content.donateButtonText,
          onPressed: widget.onDonatePressed == null
              ? null
              : () => widget.onDonatePressed!(_amount),
        ),
        SizedBox(height: ApaDimens.donateButtonBottomSpacing),
        HomeFooterNote(text: content.afterDonateButtonContent),
      ],
    );
  }
}
