import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/apa_assets.dart';
import '../../../../core/constants/apa_shell_insets.dart';
import '../../../../core/theme/apa_colors.dart';
import '../../../../core/theme/apa_fonts.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/apa_shared_widgets.dart';

/// Donation Page — Figma frame `8:322`.
class DonationPage extends StatefulWidget {
  const DonationPage({
    super.key,
    this.scrollController,
    this.onContinuePressed,
  });

  final ScrollController? scrollController;
  final VoidCallback? onContinuePressed;

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  static const List<int> _amounts = [25, 50, 100, 250, 500, 1000];

  bool _monthly = false;
  int? _selectedAmount = 100;
  final TextEditingController _otherController = TextEditingController();

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  int get _displayAmount {
    final other = int.tryParse(_otherController.text.trim());
    if (other != null && other > 0) return other;
    return _selectedAmount ?? 0;
  }

  void _selectAmount(int amount) {
    setState(() {
      _selectedAmount = amount;
      _otherController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final amount = _displayAmount;
    final cadence = _monthly ? 'MONTHLY' : 'ONE TIME';
    final navBottomPad = ApaShellInsets.contentBottom(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ColoredBox(
        color: ApaColors.white,
        child: CustomScrollView(
          controller: widget.scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: ApaHeroHeader(
                imageAsset: ApaAssets.donationHero,
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
                              child: _buildAmountColumn(context, amount, cadence),
                            ),
                            SizedBox(width: 40.w),
                            const Expanded(
                              flex: 4,
                              child: _WhatItPaysFor(embedded: true),
                            ),
                          ],
                        )
                      : _buildAmountColumn(context, amount, cadence),
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
                                rest: ' pooling a gift for a specific project',
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
                          rest: ' groups organizing community fundraisers',
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
    );
  }

  Widget _buildAmountColumn(
    BuildContext context,
    int amount,
    String cadence,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 26.w,
              vertical: 18.h,
            ),
            decoration: BoxDecoration(
              color: ApaColors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: ApaColors.black, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '\$$amount',
                  style: ApaFonts.inter(
                    color: ApaColors.nearBlack,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w800,
                    height: 30 / 28,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  cadence,
                  style: ApaFonts.inter(
                    color: ApaColors.primaryRed,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    height: 20 / 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16.h),
        _FrequencyToggle(
          monthly: _monthly,
          onChanged: (v) => setState(() => _monthly = v),
        ),
        SizedBox(height: 24.h),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = R.isTabletLandscape(context) ? 3 : 2;
            final rowCount = (_amounts.length / crossAxisCount).ceil();
            final mainSpacing = 12.h;
            final cellHeight = 69.h;
            final gridHeight =
                cellHeight * rowCount + mainSpacing * (rowCount - 1);

            return SizedBox(
              height: gridHeight,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: _amounts.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisExtent: cellHeight,
                  mainAxisSpacing: mainSpacing,
                  crossAxisSpacing: 12.w,
                ),
                itemBuilder: (context, index) {
                  final value = _amounts[index];
                  final selected = _selectedAmount == value &&
                      _otherController.text.isEmpty;
                  return _AmountChip(
                    amount: value,
                    selected: selected,
                    onTap: () => _selectAmount(value),
                  );
                },
              ),
            );
          },
        ),
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
                  controller: _otherController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (_) {
                    setState(() => _selectedAmount = null);
                  },
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
        SizedBox(height: 24.h),
        ApaBlackPillButton(
          label: 'CONTINUE TO PAYMENT',
          expanded: true,
          fontSize: 16,
          verticalPadding: 20,
          horizontalPadding: 24,
          onPressed: widget.onContinuePressed,
        ),
        SizedBox(height: 20.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'Gifts are processed securely. You will receive a '
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
