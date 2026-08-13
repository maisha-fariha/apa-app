import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/apa_assets.dart';
import '../../../../core/constants/apa_shell_insets.dart';
import '../../../../core/theme/apa_colors.dart';
import '../../../../core/theme/apa_fonts.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/apa_shared_widgets.dart';

/// Contact Us Page — Figma frame `17:1286`.
class ContactPage extends StatefulWidget {
  const ContactPage({
    super.key,
    this.scrollController,
    this.onSendPressed,
  });

  final ScrollController? scrollController;
  final VoidCallback? onSendPressed;

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  static const List<String> _subjects = [
    'Partnering on a project',
    'Making a donation',
    'Volunteering',
    'Press or media',
    'Something else',
  ];

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  String _subject = _subjects.first;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                imageAsset: ApaAssets.contactHero,
                height: 500,
                badge: 'JOIN OUR MISSION',
                headline: [
                  TextSpan(
                    text: 'PARTNER\n',
                    style: ApaFonts.inter(
                      color: ApaColors.white,
                      fontSize: 40.sp,
                      fontWeight: FontWeight.w800,
                      height: 42 / 40,
                      letterSpacing: -0.5,
                    ),
                  ),
                  TextSpan(
                    text: 'WITH US.',
                    style: ApaFonts.inter(
                      color: ApaColors.primaryRed,
                      fontSize: 40.sp,
                      fontWeight: FontWeight.w800,
                      height: 42 / 40,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
                subtitle:
                    'Tell us how you want to help — projects, funding, '
                    'diaspora partnerships, or simply staying in the loop.',
              ),
            ),
            SliverToBoxAdapter(
              child: ApaPageWidth(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    R.isTabletLandscape(context) ? 48 : 20.w,
                    32.h,
                    R.isTabletLandscape(context) ? 48 : 20.w,
                    navBottomPad,
                  ),
                  child: R.isTabletLandscape(context)
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildForm(context)),
                            SizedBox(width: 48.w),
                            Expanded(child: _buildReachUs(context)),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildForm(context),
                            SizedBox(height: 24.h),
                            _buildReachUs(context),
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

  Widget _buildForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('Name', required: true),
        _ApaTextField(controller: _nameController),
        SizedBox(height: 20.h),
        const _FieldLabel('Email Address'),
        _ApaTextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 20.h),
        const _FieldLabel("I'm reaching out about"),
        _SubjectDropdown(
          value: _subject,
          options: _subjects,
          onChanged: (v) {
            if (v != null) setState(() => _subject = v);
          },
        ),
        SizedBox(height: 20.h),
        const _FieldLabel('Message'),
        _ApaTextField(
          controller: _messageController,
          maxLines: 6,
          minHeight: 180,
        ),
        SizedBox(height: 24.h),
        ApaBlackPillButton(
          label: 'SEND MESSAGE',
          expanded: true,
          fontSize: 15,
          verticalPadding: 14,
          horizontalPadding: 24,
          onPressed: widget.onSendPressed,
        ),
      ],
    );
  }

  Widget _buildReachUs(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'REACH US',
          style: ApaFonts.inter(
            color: ApaColors.black,
            fontSize: 32.sp,
            fontWeight: FontWeight.w800,
            height: 40 / 32,
          ),
        ),
        SizedBox(height: 24.h),
        const _ContactRow(
          label: 'Email',
          value: 'bonjou@ansanmpouhaiti.org',
        ),
        const _ContactRow(
          label: 'Phone',
          value: '+509 00 00 0000',
        ),
        const _ContactRow(
          label: 'Field office',
          value: 'Les Cayes, Sud, Haiti',
        ),
        const _ContactRow(
          label: 'Diaspora relations',
          value: 'diaspora@ansanmpouhaiti.org',
        ),
        SizedBox(height: 32.h),
        Text.rich(
          TextSpan(
            style: ApaFonts.inter(
              color: ApaColors.nearBlack,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              height: 24 / 16,
              letterSpacing: 0.4,
            ),
            children: [
              const TextSpan(
                text:
                    'TOGETHER, WE CAN BUILD SAFER ROADS, BRIGHTER '
                    'COMMUNITIES, AND BETTER OPPORTUNITIES FOR ',
              ),
              TextSpan(
                text: 'FUTURE GENERATIONS',
                style: ApaFonts.inter(
                  color: ApaColors.primaryRed,
                  fontSize: 16.sp,
                ),
              ),
              const TextSpan(text: '.'),
            ],
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, {this.required = false});

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final labelStyle = ApaFonts.inter(
      color: ApaColors.gray700,
      fontSize: 13.sp,
      fontWeight: FontWeight.w700,
      height: 20 / 13,
    );

    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text.rich(
        TextSpan(
          style: labelStyle,
          children: [
            TextSpan(text: text),
            if (required)
              TextSpan(
                text: ' *',
                style: labelStyle.copyWith(color: ApaColors.primaryRed),
              ),
          ],
        ),
      ),
    );
  }
}

class _ApaTextField extends StatelessWidget {
  const _ApaTextField({
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
    this.minHeight = 48,
  });

  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: minHeight.h),
      decoration: BoxDecoration(
        color: ApaColors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: ApaColors.black),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: ApaFonts.inter(
          color: ApaColors.nearBlack,
          fontSize: 15.sp,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
        ),
      ),
    );
  }
}

class _SubjectDropdown extends StatelessWidget {
  const _SubjectDropdown({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: ApaColors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: ApaColors.black),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          highlightColor: ApaColors.primaryRed,
          focusColor: ApaColors.primaryRed,
          hoverColor: ApaColors.primaryRed,
          splashColor: ApaColors.primaryRed.withValues(alpha: 0.24),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            // Intrinsic item height — avoids clipping when .sp/.h scale up.
            itemHeight: null,
            dropdownColor: ApaColors.black,
            icon: Icon(
              Icons.keyboard_arrow_down,
              size: 20.sp,
              color: ApaColors.nearBlack,
            ),
            style: ApaFonts.inter(
              color: ApaColors.nearBlack,
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
            selectedItemBuilder: (context) => options
                .map(
                  (o) => Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      o,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ApaFonts.inter(
                        color: ApaColors.nearBlack,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ),
                )
                .toList(),
            items: options
                .map(
                  (o) {
                    final selected = o == value;
                    return DropdownMenuItem<String>(
                      value: o,
                      child: Container(
                        width: double.infinity,
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 14.h,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? ApaColors.primaryRed
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          o,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          style: ApaFonts.inter(
                            color: ApaColors.white,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                      ),
                    );
                  },
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: ApaColors.gray200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: ApaFonts.inter(
              color: ApaColors.gray500,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: ApaFonts.inter(
              color: ApaColors.nearBlack,
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
