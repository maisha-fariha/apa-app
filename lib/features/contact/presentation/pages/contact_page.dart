import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gems_core/gems_core.dart';
import 'package:get/get.dart';

import '../../../../core/constants/apa_assets.dart';
import '../../../../core/constants/apa_shell_insets.dart';
import '../../../../core/network/connectivity_controller.dart';
import '../../../../core/theme/apa_colors.dart';
import '../../../../core/theme/apa_fonts.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/apa_empty_retry.dart';
import '../../../../core/widgets/apa_shared_widgets.dart';
import '../../../shell/presentation/controllers/pages_controller.dart';
import '../../../shell/presentation/mapping/apa_page_templates.dart';
import '../../../shell/presentation/models/apa_nav_item.dart';
import '../../domain/contact_page_content.dart';
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

  ContactController? get _formController {
    if (!Get.isRegistered<ContactController>()) return null;
    return Get.find<ContactController>();
  }

  PagesController? get _pagesController {
    if (!Get.isRegistered<PagesController>()) return null;
    return Get.find<PagesController>();
  }

  @override
  Widget build(BuildContext context) {
    final navBottomPad = ApaShellInsets.contentBottom(context);
    final formController = _formController;
    final pagesController = _pagesController;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ColoredBox(
        color: ApaColors.white,
        child: RefreshIndicator(
          color: ApaColors.primaryRed,
          onRefresh: () async {
            await Future.wait([
              if (formController != null) formController.loadForm(force: true),
              if (pagesController != null)
                pagesController.loadDetailsForTemplate(
                  ApaPageTemplates.contact,
                  force: true,
                ),
            ]);
          },
          child: CustomScrollView(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(child: _buildHero(pagesController)),
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
                                child: _buildFormColumn(context, formController),
                              ),
                              SizedBox(width: 48.w),
                              Expanded(
                                child: _buildReachUs(pagesController),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFormColumn(context, formController),
                              SizedBox(height: 24.h),
                              _buildReachUs(pagesController),
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

  Widget _buildHero(PagesController? pagesController) {
    if (pagesController == null) return const SizedBox.shrink();

    return Obx(() {
      final content = _contactContent(pagesController);
      if (content == null || !content.showHeader) {
        return const SizedBox.shrink();
      }

      return ApaHeroHeader(
        imageAsset: ApaAssets.contactHero,
        imageUrl: content.imageUrl ?? imageUrl,
        useAssetFallback: false,
        height: 500,
        badge: content.topTagLine,
        headline: _headlineSpans(content),
        subtitle:
            content.lastContent.isEmpty ? null : content.lastContent,
      );
    });
  }

  List<InlineSpan> _headlineSpans(ContactPageContent content) {
    final oneStyle = ApaFonts.inter(
      color: ApaColors.white,
      fontSize: 40.sp,
      fontWeight: FontWeight.w800,
      height: 42 / 40,
      letterSpacing: -0.5,
    );
    final twoStyle = ApaFonts.inter(
      color: ApaColors.primaryRed,
      fontSize: 40.sp,
      fontWeight: FontWeight.w800,
      height: 42 / 40,
      letterSpacing: -0.5,
    );

    final one = content.headingTextOne;
    final two = content.headingTextTwo;
    return [
      if (one.isNotEmpty)
        TextSpan(
          text: two.isNotEmpty ? '${one.toUpperCase()}\n' : one.toUpperCase(),
          style: oneStyle,
        ),
      if (two.isNotEmpty)
        TextSpan(
          text: two.toUpperCase(),
          style: twoStyle,
        ),
    ];
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
      if (ConnectivityController.registered) {
        ConnectivityController.to.isOnline.value;
      }
      final loading = controller.isLoading.value;
      final submitting = controller.isSubmitting.value;
      final error = controller.errorMessage.value;

      if (loading && controller.items.isEmpty) {
        return const ContactFormLoading();
      }

      if (controller.items.isEmpty) {
        if (error.isNotEmpty) {
          return ContactFormError(
            message: error,
            onRetry: () => controller.loadForm(force: true),
          );
        }
        return ApaEmptyRetry.forConnectivity(
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

  Widget _buildReachUs(PagesController? pagesController) {
    if (pagesController == null) return const SizedBox.shrink();

    return Obx(() {
      final content = _contactContent(pagesController);
      if (content == null || !content.hasReachUs) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (content.infoRows.isNotEmpty) ...[
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
            for (final row in content.infoRows)
              _ContactRow(label: row.label, value: row.value),
          ],
          if (content.hasClosingText) ...[
            SizedBox(height: content.infoRows.isEmpty ? 0 : 32.h),
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
                  if (content.finalTextStart.isNotEmpty)
                    TextSpan(
                      text: content.finalTextEnd.isEmpty
                          ? content.finalTextStart
                          : '${content.finalTextStart} ',
                    ),
                  if (content.finalTextEnd.isNotEmpty)
                    TextSpan(
                      text: content.finalTextEnd,
                      style: ApaFonts.inter(
                        color: ApaColors.primaryRed,
                        fontSize: 16.sp,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      );
    });
  }

  ContactPageContent? _contactContent(PagesController pagesController) {
    pagesController.items.length;
    pagesController.pageDetailsById.length;

    final listPage = pagesController.pageForShell(ApaShellPage.contact);
    if (listPage == null) return null;

    pagesController.loadPageDetails(listPage.id);
    final details = pagesController.detailsForPageId(listPage.id);
    if (details == null) return null;
    return ContactPageContent.fromPost(details);
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
