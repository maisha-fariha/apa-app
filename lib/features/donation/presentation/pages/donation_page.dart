import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/apa_assets.dart';
import '../../../../core/theme/apa_colors.dart';
import '../../../../core/widgets/apa_shared_widgets.dart';

/// Donation Page — Figma frame `8:322`.
class DonationPage extends StatefulWidget {
  const DonationPage({
    super.key,
    this.onContinuePressed,
  });

  final VoidCallback? onContinuePressed;

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  static const double _navBottomPad = 120;
  static const List<int> _amounts = [25, 50, 100, 250, 500, 1000];

  bool _monthly = false;
  int? _selectedAmount = 100;
  final TextEditingController _otherController = TextEditingController();

  static const TextStyle _headlineWhite = TextStyle(
    color: ApaColors.white,
    fontSize: 42,
    fontWeight: FontWeight.w800,
    height: 46 / 42,
    letterSpacing: -1,
  );

  static const TextStyle _headlineRed = TextStyle(
    color: ApaColors.primaryRed,
    fontSize: 42,
    fontWeight: FontWeight.w800,
    height: 46 / 42,
    letterSpacing: -1,
  );

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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ColoredBox(
        color: ApaColors.white,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: ApaHeroHeader(
                imageAsset: ApaAssets.donationHero,
                height: 500,
                badge: 'EVERY GIFT FUNDS WORK IN HAITI',
                headline: const [
                  TextSpan(text: 'CHOOSE YOUR\n', style: _headlineWhite),
                  TextSpan(text: 'AMOUNT.', style: _headlineRed),
                ],
                subtitle:
                    'One-time or monthly — every dollar goes toward parks, '
                    'roads, and solar lighting in Sud, Haiti.',
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 26,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: ApaColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ApaColors.black, width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '\$$amount',
                            style: const TextStyle(
                              color: ApaColors.nearBlack,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              height: 30 / 28,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cadence,
                            style: const TextStyle(
                              color: ApaColors.primaryRed,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              height: 20 / 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _FrequencyToggle(
                      monthly: _monthly,
                      onChanged: (v) => setState(() => _monthly = v),
                    ),
                    const SizedBox(height: 24),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _amounts.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 169 / 69,
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
                    const SizedBox(height: 24),
                    const Text(
                      'OTHER AMOUNT',
                      style: TextStyle(
                        color: ApaColors.gray700,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        height: 20 / 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 77,
                      decoration: BoxDecoration(
                        color: ApaColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ApaColors.gray200),
                      ),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 24),
                            child: Text(
                              '\$',
                              style: TextStyle(
                                color: ApaColors.nearBlack,
                                fontSize: 24,
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
                              style: const TextStyle(
                                color: ApaColors.nearBlack,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Enter an amount',
                                hintStyle: TextStyle(
                                  color: ApaColors.gray400,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ApaBlackPillButton(
                      label: 'CONTINUE TO PAYMENT',
                      expanded: true,
                      fontSize: 16,
                      verticalPadding: 20,
                      horizontalPadding: 24,
                      onPressed: widget.onContinuePressed,
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Gifts are processed securely. You will receive a '
                        'receipt and project updates by email.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ApaColors.gray500,
                          fontSize: 13,
                          height: 18 / 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: _WhatItPaysFor()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, _navBottomPad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'WHERE SUPPORT\nCOMES FROM',
                      style: TextStyle(
                        color: ApaColors.black,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        height: 38 / 32,
                      ),
                    ),
                    SizedBox(height: 24),
                    _SupportItem(
                      bold: 'Individuals',
                      rest: ' who give once or monthly',
                    ),
                    _SupportItem(
                      bold: 'Families',
                      rest: ' pooling a gift for a specific project',
                    ),
                    _SupportItem(
                      bold: 'Diaspora',
                      rest: ' groups organizing community fundraisers',
                    ),
                    _SupportItem(
                      bold: 'Churches',
                      rest: ' and faith communities',
                    ),
                    _SupportItem(
                      bold: 'Small businesses',
                      rest: ' matching employee gifts',
                    ),
                    _SupportItem(
                      bold: 'Foundations',
                      rest: ' backing phase-one infrastructure',
                    ),
                  ],
                ),
              ),
            ),
          ],
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
      height: 55,
      padding: const EdgeInsets.all(4),
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
            style: TextStyle(
              color: selected ? ApaColors.white : ApaColors.gray700,
              fontSize: 14,
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
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? ApaColors.nearBlack : ApaColors.gray200,
            ),
          ),
          child: Text(
            '\$$amount',
            style: TextStyle(
              color: selected ? ApaColors.white : ApaColors.nearBlack,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _WhatItPaysFor extends StatelessWidget {
  const _WhatItPaysFor();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: ApaColors.gray50,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'WHAT IT PAYS FOR',
              style: TextStyle(
                color: ApaColors.black,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                height: 38 / 32,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Estimated, based on phase-one costing in Haiti.',
              style: TextStyle(
                color: ApaColors.gray600,
                fontSize: 15,
                height: 22.5 / 15,
              ),
            ),
            SizedBox(height: 16),
            ColoredBox(
              color: ApaColors.black,
              child: SizedBox(height: 3, width: double.infinity),
            ),
            _PaysRow(label: 'Solar street light', value: '1'),
            _PaysRow(label: 'Days of local crew wages', value: '14'),
            _PaysRow(label: 'Community meetings hosted', value: '2'),
            _PaysRow(label: 'Metres of road repair', value: '4'),
          ],
        ),
      ),
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
      height: 60,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: ApaColors.gray200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: ApaColors.gray800,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: ApaColors.nearBlack,
              fontSize: 20,
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
      padding: const EdgeInsets.only(bottom: 16),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: bold,
              style: const TextStyle(
                color: ApaColors.nearBlack,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                height: 24 / 16,
              ),
            ),
            TextSpan(
              text: rest,
              style: const TextStyle(
                color: ApaColors.gray700,
                fontSize: 16,
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
