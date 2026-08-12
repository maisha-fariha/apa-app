import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/apa_assets.dart';
import '../../../../core/theme/apa_colors.dart';
import '../../../../core/widgets/apa_shared_widgets.dart';
import '../../../../core/widgets/apa_svg_icon.dart';

/// Contact Us Page — Figma frame `17:1286`.
class ContactPage extends StatefulWidget {
  const ContactPage({
    super.key,
    this.onSendPressed,
  });

  final VoidCallback? onSendPressed;

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  static const double _navBottomPad = 120;
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

  static const TextStyle _headlineWhite = TextStyle(
    color: ApaColors.white,
    fontSize: 40,
    fontWeight: FontWeight.w800,
    height: 42 / 40,
    letterSpacing: -0.5,
  );

  static const TextStyle _headlineRed = TextStyle(
    color: ApaColors.primaryRed,
    fontSize: 40,
    fontWeight: FontWeight.w800,
    height: 42 / 40,
    letterSpacing: -0.5,
  );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ColoredBox(
        color: ApaColors.white,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: ApaHeroHeader(
                imageAsset: ApaAssets.contactHero,
                height: 500,
                badge: 'JOIN OUR MISSION',
                headline: const [
                  TextSpan(text: 'PARTNER\n', style: _headlineWhite),
                  TextSpan(text: 'WITH US.', style: _headlineRed),
                ],
                subtitle:
                    'Tell us how you want to help — projects, funding, '
                    'diaspora partnerships, or simply staying in the loop.',
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel('Name *'),
                    _ApaTextField(controller: _nameController),
                    const SizedBox(height: 20),
                    const _FieldLabel('Email Address'),
                    _ApaTextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    const _FieldLabel("I'm reaching out about"),
                    _SubjectDropdown(
                      value: _subject,
                      options: _subjects,
                      onChanged: (v) {
                        if (v != null) setState(() => _subject = v);
                      },
                    ),
                    const SizedBox(height: 20),
                    const _FieldLabel('Message'),
                    _ApaTextField(
                      controller: _messageController,
                      maxLines: 6,
                      minHeight: 180,
                    ),
                    const SizedBox(height: 24),
                    ApaBlackPillButton(
                      label: 'SEND MESSAGE',
                      expanded: true,
                      fontSize: 15,
                      verticalPadding: 14,
                      horizontalPadding: 24,
                      onPressed: widget.onSendPressed,
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, _navBottomPad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'REACH US',
                      style: TextStyle(
                        color: ApaColors.black,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        height: 40 / 32,
                      ),
                    ),
                    const SizedBox(height: 24),
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
                    const SizedBox(height: 32),
                    Text.rich(
                      TextSpan(
                        style: const TextStyle(
                          color: ApaColors.nearBlack,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 24 / 16,
                          letterSpacing: 0.4,
                        ),
                        children: const [
                          TextSpan(
                            text:
                                'TOGETHER, WE CAN BUILD SAFER ROADS, BRIGHTER '
                                'COMMUNITIES, AND BETTER OPPORTUNITIES FOR ',
                          ),
                          TextSpan(
                            text: 'FUTURE GENERATIONS',
                            style: TextStyle(color: ApaColors.primaryRed),
                          ),
                          TextSpan(text: '.'),
                        ],
                      ),
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

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: ApaColors.gray700,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          height: 20 / 13,
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
      constraints: BoxConstraints(minHeight: minHeight),
      decoration: BoxDecoration(
        color: ApaColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ApaColors.gray200),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(
          color: ApaColors.nearBlack,
          fontSize: 15,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: ApaColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ApaColors.gray200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const ApaSvgIcon(
            assetPath: ApaAssets.icDropdown,
            size: 20,
            color: ApaColors.nearBlack,
          ),
          style: const TextStyle(
            color: ApaColors.nearBlack,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          items: options
              .map(
                (o) => DropdownMenuItem<String>(
                  value: o,
                  child: Text(o),
                ),
              )
              .toList(),
          onChanged: onChanged,
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
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: ApaColors.gray200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: ApaColors.gray500,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: ApaColors.nearBlack,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
