import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/apa_assets.dart';
import '../../../../core/constants/apa_dimens.dart';
import '../../../../core/theme/apa_colors.dart';
import '../../../../core/theme/apa_typography.dart';
import '../../../../core/widgets/apa_svg_icon.dart';

/// Glassmorphism donation amount card with increment / decrement controls.
class DonationAmountCard extends StatefulWidget {
  const DonationAmountCard({
    super.key,
    required this.amount,
    required this.onAmountChanged,
    this.minAmount = 1,
    this.currencyCode = 'USD',
  });

  final int amount;
  final ValueChanged<int> onAmountChanged;
  final int minAmount;
  final String currencyCode;

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
  State<DonationAmountCard> createState() => _DonationAmountCardState();
}

class _DonationAmountCardState extends State<DonationAmountCard> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.amount}');
    _focusNode = FocusNode()..addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant DonationAmountCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = '${widget.amount}';
    if (_controller.text != next && !_focusNode.hasFocus) {
      _controller.value = TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: next.length),
      );
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      _commitAmount();
    }
  }

  int _bounded(int value) =>
      value < widget.minAmount ? widget.minAmount : value;

  double _amountTextWidth() {
    final text = _controller.text.isEmpty ? '0' : _controller.text;
    final painter = TextPainter(
      text: TextSpan(text: text, style: ApaTypography.donationAmount),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return painter.width + 4;
  }

  double _amountFieldWidth(double maxWidth) {
    final minWidth = 24.w;
    final desired = _amountTextWidth();
    if (!maxWidth.isFinite || maxWidth <= minWidth) {
      return minWidth;
    }
    if (desired < minWidth) return minWidth;
    if (desired > maxWidth) return maxWidth;
    return desired;
  }

  void _nudge(int delta) {
    final parsed = int.tryParse(_controller.text.trim()) ?? widget.amount;
    final next = _bounded(parsed + delta);
    final text = '$next';
    if (_controller.text != text) {
      _controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
    if (next != widget.amount) {
      widget.onAmountChanged(next);
    }
  }

  void _onTextChanged(String value) {
    final parsed = int.tryParse(value);
    if (parsed == null) return;
    widget.onAmountChanged(_bounded(parsed));
  }

  void _commitAmount() {
    final parsed = int.tryParse(_controller.text.trim());
    final next = _bounded(parsed ?? widget.amount);
    final text = '$next';
    if (_controller.text != text) {
      _controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
    if (next != widget.amount) {
      widget.onAmountChanged(next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canDecrement = widget.amount > widget.minAmount;

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
                    DonationAmountCard.formatDate(DateTime.now()),
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
              LayoutBuilder(
                builder: (context, constraints) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                    child: Row(
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
                        Flexible(
                          fit: FlexFit.loose,
                          child: LayoutBuilder(
                            builder: (context, amountConstraints) {
                              final width = _amountFieldWidth(
                                amountConstraints.maxWidth,
                              );
                              return SizedBox(
                                width: width,
                                child: TextField(
                                  controller: _controller,
                                  focusNode: _focusNode,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  maxLines: 1,
                                  scrollPhysics:
                                      const BouncingScrollPhysics(),
                                  textAlign: TextAlign.left,
                                  cursorColor: ApaColors.white,
                                  style: ApaTypography.donationAmount,
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onChanged: _onTextChanged,
                                  onSubmitted: (_) => _commitAmount(),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Padding(
                          padding: EdgeInsets.only(bottom: 2.h),
                          child: Text(
                            widget.currencyCode.toUpperCase(),
                            style: ApaTypography.currencyCode,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        _AmountStepper(
                          onIncrement: () => _nudge(1),
                          onDecrement:
                              canDecrement ? () => _nudge(-1) : null,
                        ),
                      ],
                    ),
                  );
                },
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

class _StepperButton extends StatefulWidget {
  const _StepperButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  State<_StepperButton> createState() => _StepperButtonState();
}

class _StepperButtonState extends State<_StepperButton> {
  static const _holdDelay = Duration(milliseconds: 350);
  static const _repeatInterval = Duration(milliseconds: 70);

  Timer? _holdDelayTimer;
  Timer? _repeatTimer;

  @override
  void didUpdateWidget(covariant _StepperButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onPressed == null) {
      _stopRepeat();
    }
  }

  @override
  void dispose() {
    _stopRepeat();
    super.dispose();
  }

  void _startRepeat() {
    if (widget.onPressed == null) return;
    widget.onPressed!();
    _holdDelayTimer?.cancel();
    _repeatTimer?.cancel();
    _holdDelayTimer = Timer(_holdDelay, () {
      _repeatTimer = Timer.periodic(_repeatInterval, (_) {
        widget.onPressed?.call();
      });
    });
  }

  void _stopRepeat() {
    _holdDelayTimer?.cancel();
    _repeatTimer?.cancel();
    _holdDelayTimer = null;
    _repeatTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => _startRepeat() : null,
      onTapUp: (_) => _stopRepeat(),
      onTapCancel: _stopRepeat,
      child: SizedBox(
        height: 22.h,
        width: double.infinity,
        child: Center(
          child: Icon(
            widget.icon,
            size: 18.sp,
            color: enabled ? ApaColors.nearBlack : ApaColors.gray400,
          ),
        ),
      ),
    );
  }
}
