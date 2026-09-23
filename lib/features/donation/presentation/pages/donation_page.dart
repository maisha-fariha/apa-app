import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constants/apa_assets.dart';
import '../../../../core/constants/apa_shell_insets.dart';
import '../../../../core/network/connectivity_controller.dart';
import '../../../../core/theme/apa_colors.dart';
import '../../../../core/theme/apa_fonts.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/apa_empty_retry.dart';
import '../../../../core/widgets/apa_shared_widgets.dart';
import '../../data/stripe_checkout.dart';
import '../controllers/donation_controller.dart';

/// Donation Page — Figma frame `8:322`.
class DonationPage extends StatelessWidget {
  const DonationPage({
    super.key,
    this.scrollController,
    this.onContinuePressed,
    this.onPaymentSucceeded,
    this.imageUrl,
  });

  /// Hardcoded predefined amounts shown below the frequency tabs.
  static const List<int> predefinedAmounts = [20, 50, 100];

  final ScrollController? scrollController;
  final VoidCallback? onContinuePressed;
  final ValueChanged<String>? onPaymentSucceeded;
  final String? imageUrl;

  DonationController? get _controller {
    if (!Get.isRegistered<DonationController>()) return null;
    return Get.find<DonationController>();
  }

  @override
  Widget build(BuildContext context) {
    final navBottomPad = ApaShellInsets.contentBottom(context);
    final controller = _controller;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ColoredBox(
        color: ApaColors.white,
        child: RefreshIndicator(
          color: ApaColors.primaryRed,
          onRefresh: () async {
            await controller?.loadCatalog(force: true);
          },
          child: CustomScrollView(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: ApaHeroHeader(
                  imageAsset: ApaAssets.donationHero,
                  imageUrl: imageUrl,
                  height: 500,
                  badge: 'EVERY GIFT FUNDS WORK IN HAITI',
                  headline: [
                    TextSpan(
                      text: 'CHOOSE YOUR\n',
                      style: ApaFonts.inter(
                        color: ApaColors.white,
                        fontSize: 42.sp,
                        fontWeight: FontWeight.w800,
                        height: 46 / 42,
                        letterSpacing: -1,
                      ),
                    ),
                    TextSpan(
                      text: 'AMOUNT.',
                      style: ApaFonts.inter(
                        color: ApaColors.primaryRed,
                        fontSize: 42.sp,
                        fontWeight: FontWeight.w800,
                        height: 46 / 42,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                  subtitle:
                      'One-time or monthly — every dollar goes toward parks, '
                      'roads, and solar lighting in Sud, Haiti.',
                ),
              ),
              SliverToBoxAdapter(
                child: ApaPageWidth(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      R.isTabletLandscape(context) ? 48 : 20.w,
                      24.h,
                      R.isTabletLandscape(context) ? 48 : 20.w,
                      0,
                    ),
                    child: R.isTabletLandscape(context)
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 5,
                                child: _buildAmountColumn(context, controller),
                              ),
                              SizedBox(width: 40.w),
                              const Expanded(
                                flex: 4,
                                child: _WhatItPaysFor(embedded: true),
                              ),
                            ],
                          )
                        : _buildAmountColumn(context, controller),
                  ),
                ),
              ),
              if (!R.isTabletLandscape(context))
                const SliverToBoxAdapter(child: _WhatItPaysFor()),
              SliverToBoxAdapter(
                child: ApaPageWidth(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      R.isTabletLandscape(context) ? 48 : 24.w,
                      40.h,
                      R.isTabletLandscape(context) ? 48 : 24.w,
                      navBottomPad,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WHERE SUPPORT\nCOMES FROM',
                          style: ApaFonts.inter(
                            color: ApaColors.black,
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w800,
                            height: 38 / 32,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        if (R.isTabletLandscape(context))
                          const Wrap(
                            children: [
                              SizedBox(
                                width: 340,
                                child: _SupportItem(
                                  bold: 'Individuals',
                                  rest: ' who give once or monthly',
                                ),
                              ),
                              SizedBox(
                                width: 340,
                                child: _SupportItem(
                                  bold: 'Families',
                                  rest:
                                      ' pooling a gift for a specific project',
                                ),
                              ),
                              SizedBox(
                                width: 340,
                                child: _SupportItem(
                                  bold: 'Diaspora',
                                  rest:
                                      ' groups organizing community fundraisers',
                                ),
                              ),
                              SizedBox(
                                width: 340,
                                child: _SupportItem(
                                  bold: 'Churches',
                                  rest: ' and faith communities',
                                ),
                              ),
                              SizedBox(
                                width: 340,
                                child: _SupportItem(
                                  bold: 'Small businesses',
                                  rest: ' matching employee gifts',
                                ),
                              ),
                              SizedBox(
                                width: 340,
                                child: _SupportItem(
                                  bold: 'Foundations',
                                  rest: ' backing phase-one infrastructure',
                                ),
                              ),
                            ],
                          )
                        else ...[
                          const _SupportItem(
                            bold: 'Individuals',
                            rest: ' who give once or monthly',
                          ),
                          const _SupportItem(
                            bold: 'Families',
                            rest: ' pooling a gift for a specific project',
                          ),
                          const _SupportItem(
                            bold: 'Diaspora',
                            rest:
                                ' groups organizing community fundraisers',
                          ),
                          const _SupportItem(
                            bold: 'Churches',
                            rest: ' and faith communities',
                          ),
                          const _SupportItem(
                            bold: 'Small businesses',
                            rest: ' matching employee gifts',
                          ),
                          const _SupportItem(
                            bold: 'Foundations',
                            rest: ' backing phase-one infrastructure',
                          ),
                        ],
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

  Widget _buildAmountColumn(
    BuildContext context,
    DonationController? controller,
  ) {
    if (controller == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Text('Donations are currently unavailable.'),
      );
    }

    return Obx(() {
      if (ConnectivityController.registered) {
        ConnectivityController.to.isOnline.value;
      }
      final offline = !ConnectivityController.currentlyOnline;
      if (controller.isLoading.value && controller.catalog.value == null) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 48.h),
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.catalog.value == null) {
        if (controller.errorMessage.value.isNotEmpty || offline) {
          return ApaEmptyRetry(
            message: controller.errorMessage.value.isNotEmpty
                ? controller.errorMessage.value
                : (offline
                    ? ApaEmptyRetry.offlineMessage
                    : ApaEmptyRetry.unavailableMessage),
            onRetry: () => controller.loadCatalog(force: true),
          );
        }
        return ApaEmptyRetry.forConnectivity(
          onRetry: () => controller.loadCatalog(force: true),
        );
      }

      final customEnabled = controller.customEnabled;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          _FrequencyToggle(
            monthly: controller.monthly.value,
            onChanged: controller.setMonthly,
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              for (var i = 0; i < DonationPage.predefinedAmounts.length; i++) ...[
                if (i > 0) SizedBox(width: 12.w),
                Expanded(
                  child: SizedBox(
                    height: 69.h,
                    child: _AmountChip(
                      amount: DonationPage.predefinedAmounts[i],
                      selected: controller.isPredefinedSelected(
                        DonationPage.predefinedAmounts[i],
                      ),
                      onTap: () => controller.selectPredefinedAmount(
                        DonationPage.predefinedAmounts[i],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (customEnabled) ...[
            SizedBox(height: 24.h),
            Text(
              'OTHER AMOUNT',
              style: ApaFonts.inter(
                color: ApaColors.gray700,
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                height: 20 / 12,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              height: 77.h,
              decoration: BoxDecoration(
                color: ApaColors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: ApaColors.gray200),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 24.w),
                    child: Text(
                      '\$',
                      style: ApaFonts.inter(
                        color: ApaColors.nearBlack,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller.customAmountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      style: ApaFonts.inter(
                        color: ApaColors.nearBlack,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter an amount',
                        hintStyle: ApaFonts.inter(
                          color: ApaColors.gray400,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 24.h,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (controller.monthly.value) ...[
            SizedBox(height: 16.h),
            Text(
              'Monthly gifts use the listed Stripe prices.',
              style: ApaFonts.inter(
                color: ApaColors.gray500,
                fontSize: 13.sp,
                height: 18 / 13,
              ),
            ),
          ],
          SizedBox(height: 24.h),
          ApaBlackPillButton(
            label: 'CONTINUE TO PAYMENT',
            expanded: true,
            fontSize: 16,
            verticalPadding: 20,
            horizontalPadding: 24,
            onPressed: () {
              if (!ConnectivityController.currentlyOnline) {
                _showSnackBar(
                  context,
                  message: ConnectivityController.offlineMessage,
                  isError: true,
                );
                return;
              }
              final error = controller.validateCurrentSelection();
              if (error != null) {
                _showSnackBar(context, message: error, isError: true);
                return;
              }
              onContinuePressed?.call();
              _showCompleteDonationDialog(context, controller);
            },
          ),
          SizedBox(height: 20.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              'Gifts are processed securely with Stripe. You will receive a '
              'receipt and project updates by email.',
              textAlign: TextAlign.center,
              style: ApaFonts.inter(
                color: ApaColors.gray500,
                fontSize: 13.sp,
                height: 18 / 13,
              ),
            ),
          ),
          SizedBox(height: 40.h),
        ],
      );
    });
  }

  Future<void> _showCompleteDonationDialog(
    BuildContext context,
    DonationController controller,
  ) async {
    final frequencyLabel =
        controller.monthly.value ? 'Monthly' : 'One-time';

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return _CompleteDonationDialog(
          amount: controller.displayAmountDollars,
          frequencyLabel: frequencyLabel,
          controller: controller,
          onFinished: (message, {required isError}) {
            if (!context.mounted) return;
            if (isError) {
              _showSnackBar(context, message: message, isError: true);
              return;
            }
            final goHome = onPaymentSucceeded;
            if (goHome != null) {
              goHome(message);
              return;
            }
            _showSnackBar(context, message: message, isError: false);
          },
        );
      },
    );
  }

  void _showSnackBar(
    BuildContext context, {
    required String message,
    required bool isError,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? ApaColors.primaryRed : ApaColors.black,
        content: Text(
          message,
          style: ApaFonts.inter(
            color: ApaColors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _CompleteDonationDialog extends StatefulWidget {
  const _CompleteDonationDialog({
    required this.amount,
    required this.frequencyLabel,
    required this.controller,
    required this.onFinished,
  });

  final int amount;
  final String frequencyLabel;
  final DonationController controller;
  final void Function(String message, {required bool isError}) onFinished;

  @override
  State<_CompleteDonationDialog> createState() =>
      _CompleteDonationDialogState();
}

class _CompleteDonationDialogState extends State<_CompleteDonationDialog> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String? _localError;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _proceed() async {
    final validation = widget.controller.validateDonor(
      name: _nameController.text,
      email: _emailController.text,
    );
    if (validation != null) {
      setState(() => _localError = validation);
      return;
    }

    setState(() {
      _localError = null;
      _submitting = true;
    });

    final created = await widget.controller.createCheckoutSession(
      name: _nameController.text,
      email: _emailController.text,
    );

    if (!mounted) return;

    if (created.session == null) {
      setState(() {
        _submitting = false;
        _localError = created.message ?? 'Unable to start checkout.';
      });
      return;
    }

    final name = _nameController.text;
    final email = _emailController.text;
    final thanks =
        'Thank you. Your ${widget.frequencyLabel.toLowerCase()} gift of \$${widget.amount} was submitted.';
    final session = created.session!;
    final controller = widget.controller;
    final onFinished = widget.onFinished;

    // Close the form first so Stripe presents above the donation page
    // (UIScene needs a stable key window / root VC).
    if (mounted) Navigator.of(context).pop();
    await StripeCheckout.waitForNativePresentation();

    var wentHome = false;
    final result = await controller.presentCheckout(
      session,
      name: name,
      email: email,
      onAuthorized: () {
        wentHome = true;
        onFinished(thanks, isError: false);
      },
    );

    if (wentHome) {
      if (!result.success && !result.canceled) {
        onFinished(
          result.message ?? 'Payment could not be completed.',
          isError: true,
        );
      }
      return;
    }

    if (result.canceled) return;
    if (!result.success) {
      onFinished(
        result.message ?? 'Payment could not be completed.',
        isError: true,
      );
      return;
    }

    onFinished(thanks, isError: false);
  }

  @override
  Widget build(BuildContext context) {
    final selectedDonation =
        '\$${widget.amount} USD (${widget.frequencyLabel})';
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final landscape = R.isLandscape(context);
    final tablet = R.isTablet(context);

    // Use logical px on tablet so ScreenUtil (phone design) cannot shrink the
    // dialog or inflate title/button into a clipped layout.
    final outerHorizontal = tablet
        ? (landscape ? 48.0 : 40.0)
        : R.pick(context, s: 12.0, m: 20.0, l: 32.0);
    final outerVertical = landscape ? 16.0 : (tablet ? 28.0 : 20.0);
    final innerHorizontal = tablet ? 28.0 : R.pick(context, s: 14.0, m: 18.0, l: 22.0);
    final innerVertical = tablet ? 28.0 : R.pick(context, s: 18.0, m: 22.0, l: 24.0);
    final maxDialogWidth = tablet
        ? (landscape ? 560.0 : 520.0).clamp(400.0, screenWidth - outerHorizontal * 2)
        : (screenWidth - outerHorizontal * 2).clamp(280.0, 420.0);

    final titleSize = tablet
        ? 28.0
        : R.csp(R.pick(context, s: 26.0, m: 26.0, l: 28.0), context);
    final labelSize = tablet ? 13.0 : R.csp(13, context);
    final fieldSize = tablet ? 17.0 : R.csp(R.pick(context, s: 17.0, m: 18.0, l: 19.0), context);
    final summarySize = tablet ? 15.0 : R.csp(15, context);
    final fieldPaddingH = tablet ? 16.0 : R.pick(context, s: 12.0, m: 14.0, l: 16.0);
    final fieldPaddingV = tablet ? 16.0 : R.pick(context, s: 14.0, m: 16.0, l: 18.0);
    final gap = tablet ? 16.0 : R.ch(12, context);

    InputDecoration fieldDecoration(String hint) {
      final border = OutlineInputBorder(
        borderSide: const BorderSide(color: ApaColors.black),
        borderRadius: BorderRadius.circular(0),
      );

      return InputDecoration(
        hintText: hint,
        hintStyle: ApaFonts.inter(
          color: ApaColors.gray400,
          fontSize: fieldSize,
          fontWeight: FontWeight.w500,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: ApaColors.black, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: fieldPaddingH,
          vertical: fieldPaddingV,
        ),
        isDense: true,
      );
    }

    // Pin width so ScreenUtil / shrink-wrap cannot crush the title + CTA.
    final dialogWidth = maxDialogWidth.toDouble();

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(
        horizontal: outerHorizontal,
        vertical: outerVertical,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tablet ? 20.0 : 16.0),
      ),
      child: MediaQuery(
        data: media.copyWith(
          textScaler: media.textScaler.clamp(
            minScaleFactor: 1.0,
            maxScaleFactor: tablet ? 1.15 : 1.3,
          ),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: dialogWidth,
            maxWidth: dialogWidth,
            maxHeight: media.size.height * (landscape ? 0.9 : 0.86),
          ),
          child: SizedBox(
            width: dialogWidth,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                innerHorizontal,
                innerVertical,
                innerHorizontal,
                innerVertical + (tablet ? 8.0 : 0.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'COMPLETE DONATION',
                          softWrap: true,
                          style: ApaFonts.inter(
                            color: ApaColors.black,
                            fontSize: titleSize,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        color: ApaColors.black,
                        iconSize: tablet ? 26.0 : 24.0,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: gap),
                  const Divider(thickness: 1, height: 1),
                  SizedBox(height: gap + 4),

                  Text(
                    'YOUR FULL NAME',
                    style: ApaFonts.inter(
                      color: ApaColors.black,
                      fontSize: labelSize,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(height: gap * 0.5),
                  TextField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    decoration: fieldDecoration('John Doe'),
                    style: ApaFonts.inter(
                      color: ApaColors.nearBlack,
                      fontSize: fieldSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: gap + 2),

                  Text(
                    'YOUR EMAIL ADDRESS',
                    style: ApaFonts.inter(
                      color: ApaColors.black,
                      fontSize: labelSize,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(height: gap * 0.5),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      if (!_submitting) _proceed();
                    },
                    decoration: fieldDecoration('john@example.com'),
                    style: ApaFonts.inter(
                      color: ApaColors.nearBlack,
                      fontSize: fieldSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  SizedBox(height: gap + 2),
                  Text(
                    'Selected Donation: $selectedDonation',
                    style: ApaFonts.inter(
                      color: ApaColors.black,
                      fontSize: summarySize,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),

                  SizedBox(height: gap + 6),
                  if (_localError != null) ...[
                    Text(
                      _localError!,
                      style: ApaFonts.inter(
                        color: ApaColors.primaryRed,
                        fontSize: summarySize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: gap),
                  ],
                  ApaBlackPillButton(
                    label: _submitting
                        ? 'PROCESSING…'
                        : 'PROCEED TO SECURE PAYMENT',
                    expanded: true,
                    isLoading: _submitting,
                    fontSize: 16.0,
                    verticalPadding: tablet ? 16.0 : 18.0,
                    horizontalPadding: tablet ? 20.0 : 16.0,
                    onPressed: _submitting ? null : _proceed,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FrequencyToggle extends StatelessWidget {
  const _FrequencyToggle({
    required this.monthly,
    required this.onChanged,
  });

  final bool monthly;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55.h,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: ApaColors.gray50,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleSegment(
              label: 'ONE TIME',
              selected: !monthly,
              onTap: () => onChanged(false),
            ),
          ),
          Expanded(
            child: _ToggleSegment(
              label: 'MONTHLY',
              selected: monthly,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleSegment extends StatelessWidget {
  const _ToggleSegment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? ApaColors.nearBlack : Colors.transparent,
      borderRadius: BorderRadius.circular(9999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9999),
        child: Center(
          child: Text(
            label,
            style: ApaFonts.inter(
              color: selected ? ApaColors.white : ApaColors.gray700,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ),
    );
  }
}

class _AmountChip extends StatelessWidget {
  const _AmountChip({
    required this.amount,
    required this.selected,
    required this.onTap,
  });

  final int amount;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? ApaColors.nearBlack : ApaColors.white,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: ApaColors.nearBlack,
            ),
          ),
          child: Text(
            '\$$amount',
            style: ApaFonts.inter(
              color: selected ? ApaColors.white : ApaColors.nearBlack,
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _WhatItPaysFor extends StatelessWidget {
  const _WhatItPaysFor({this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: EdgeInsets.fromLTRB(
        embedded ? 28.w : (R.isTabletLandscape(context) ? 48 : 24.w),
        40.h,
        embedded ? 28.w : (R.isTabletLandscape(context) ? 48 : 24.w),
        40.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WHAT IT PAYS FOR',
            style: ApaFonts.inter(
              color: ApaColors.black,
              fontSize: 32.sp,
              fontWeight: FontWeight.w800,
              height: 38 / 32,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Estimated, based on phase-one costing in Haiti.',
            style: ApaFonts.inter(
              color: ApaColors.gray600,
              fontSize: 15.sp,
              height: 22.5 / 15,
            ),
          ),
          SizedBox(height: 16.h),
          const ColoredBox(
            color: ApaColors.black,
            child: SizedBox(height: 3, width: double.infinity),
          ),
          const _PaysRow(label: 'Solar street light', value: '1'),
          const _PaysRow(label: 'Days of local crew wages', value: '14'),
          const _PaysRow(label: 'Community meetings hosted', value: '2'),
          const _PaysRow(label: 'Metres of road repair', value: '4'),
        ],
      ),
    );

    if (embedded) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: ApaColors.gray50,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: content,
      );
    }

    return ColoredBox(
      color: ApaColors.gray50,
      child: ApaPageWidth(child: content),
    );
  }
}

class _PaysRow extends StatelessWidget {
  const _PaysRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.h,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: ApaColors.gray200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: ApaFonts.inter(
                color: ApaColors.gray800,
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: ApaFonts.inter(
              color: ApaColors.nearBlack,
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportItem extends StatelessWidget {
  const _SupportItem({required this.bold, required this.rest});

  final String bold;
  final String rest;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: bold,
              style: ApaFonts.inter(
                color: ApaColors.nearBlack,
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                height: 24 / 16,
              ),
            ),
            TextSpan(
              text: rest,
              style: ApaFonts.inter(
                color: ApaColors.gray700,
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                height: 24 / 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
