import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gems_core/gems_core.dart';
import 'package:get/get.dart';

import '../../../../core/constants/apa_assets.dart';
import '../../../../core/constants/apa_shell_insets.dart';
import '../../../../core/theme/apa_colors.dart';
import '../../../../core/theme/apa_fonts.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/apa_shared_widgets.dart';
import '../controllers/contact_controller.dart';
import '../widgets/contact_dynamic_form.dart';

/// Contact Us Page — Figma frame `17:1286`.
class ContactPage extends StatelessWidget {
  const ContactPage({
    super.key,
    this.scrollController,
    this.onSendPressed,
    this.imageUrl,
  });

  final ScrollController? scrollController;
  final VoidCallback? onSendPressed;
  final String? imageUrl;

  ContactController? get _controller {
    if (!Get.isRegistered<ContactController>()) return null;
    return Get.find<ContactController>();
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
            if (controller == null) return;
            await controller.loadForm(force: true);
          },
          child: CustomScrollView(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
            SliverToBoxAdapter(
              child: ApaHeroHeader(
                imageAsset: ApaAssets.contactHero,
                imageUrl: imageUrl,
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
                            Expanded(
                              child: _buildFormColumn(context, controller),
                            ),
                            SizedBox(width: 48.w),
                            Expanded(child: _buildReachUs(context)),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFormColumn(context, controller),
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
      ),
    );
  }

  Widget _buildFormColumn(
    BuildContext context,
    ContactController? controller,
  ) {
    if (controller == null) {
      return const ContactFormMessage(
        text: 'The contact form is currently unavailable.',
      );
    }

    return Obx(() {
      controller.formEpoch.value;
      controller.schemaSignature;
      final loading = controller.isLoading.value;
      final submitting = controller.isSubmitting.value;
      final error = controller.errorMessage.value;

      if (loading && controller.items.isEmpty) {
        return const ContactFormLoading();
      }

      if (error.isNotEmpty && controller.items.isEmpty) {
        return ContactFormError(
          message: error,
          onRetry: () => controller.loadForm(force: true),
        );
      }

      return ContactDynamicForm(
        controller: controller,
        isSubmitting: submitting || loading,
        onSubmit: () => _submit(context, controller),
      );
    });
  }

  Future<void> _submit(
    BuildContext context,
    ContactController controller,
  ) async {
    final result = await controller.submit();
    if (!context.mounted) return;

    result.when(
      success: (message) {
        onSendPressed?.call();
        _showSnackBar(context, message: message, isError: false);
      },
      failure: (error) {
        if (error is ValidationError) return;
        _showSnackBar(context, message: error.message, isError: true);
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
