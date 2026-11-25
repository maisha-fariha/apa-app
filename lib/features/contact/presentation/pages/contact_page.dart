import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gems_core/gems_core.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

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

/// Contact Us — matches live web `page-contact.php`.
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
    // Web `.container`: 16px mobile, 30px ≥768. `.column-gap` / lg split at 1024.
    final width = MediaQuery.sizeOf(context).width;
    final sidePad = width >= 1280
        ? 80.0
        : width >= 768
            ? 30.0
            : 16.0;
    final wide = width >= 1024;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ColoredBox(
        color: ApaColors.white,
        child: RefreshIndicator(
          color: ApaColors.webRed,
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
              SliverToBoxAdapter(
                child: Obx(() {
                  pagesController?.pageDetailsById.length;
                  pagesController?.items.length;
                  final content = pagesController == null
                      ? null
                      : _contactContent(pagesController);
                  if (content == null || !content.showHeader) {
                    return const SizedBox.shrink();
                  }
                  return ApaHeroHeader(
                    imageAsset: ApaAssets.contactHero,
                    imageUrl: content.imageUrl ?? imageUrl,
                    useAssetFallback: false,
                    height: 520,
                    badge: content.topTagLine,
                    headline: _headlineSpans(content),
                    subtitle: content.lastContent.isEmpty
                        ? null
                        : content.lastContent,
                  );
                }),
              ),
              SliverToBoxAdapter(
                child: ApaPageWidth(
                  maxWidth: 1440,
                  child: Padding(
                    // Web `.sectionPadding`: 70px vertical on mobile.
                    padding: EdgeInsets.fromLTRB(
                      sidePad,
                      70.h,
                      sidePad,
                      navBottomPad,
                    ),
                    child: wide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 11,
                                child: _buildFormColumn(
                                  context,
                                  formController,
                                ),
                              ),
                              // Web `.column-gap` ≥1024: 60px
                              SizedBox(width: 60),
                              Expanded(
                                flex: 10,
                                child: _buildReachUs(pagesController),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFormColumn(context, formController),
                              // Web `.column-gap` mobile: 32px
                              SizedBox(height: 32.h),
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

  List<InlineSpan> _headlineSpans(ContactPageContent content) {
    final oneStyle = ApaFonts.inter(
      color: ApaColors.white,
      fontSize: 36.sp,
      fontWeight: FontWeight.w700,
      height: 1.02,
      letterSpacing: -0.9,
    );
    final twoStyle = ApaFonts.inter(
      color: ApaColors.webRed,
      fontSize: 36.sp,
      fontWeight: FontWeight.w700,
      height: 1.02,
      letterSpacing: -0.9,
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
        backgroundColor: isError ? ApaColors.webRed : ApaColors.webInk,
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
          Text(
            content.reachHeading.toUpperCase(),
            style: ApaFonts.inter(
              color: ApaColors.webInk,
              // Web h2: clamp(34px…) font-semibold uppercase leading-[1.1]
              fontSize: 34.sp,
              fontWeight: FontWeight.w600,
              height: 1.1,
              letterSpacing: -0.5,
            ),
          ),
          if (content.infoRows.isNotEmpty) ...[
            // Web h2 mb-3 (~12px) before list
            SizedBox(height: 12.h),
            for (var i = 0; i < content.infoRows.length; i++)
              _ContactRow(
                row: content.infoRows[i],
                showDivider: i < content.infoRows.length - 1,
              ),
          ],
          if (content.hasClosingText) ...[
            SizedBox(height: content.infoRows.isEmpty ? 0 : 28.h),
            Text.rich(
              TextSpan(
                style: ApaFonts.inter(
                  color: ApaColors.webInk,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
                children: [
                  if (content.finalTextStart.isNotEmpty)
                    TextSpan(
                      text: content.finalTextEnd.isEmpty
                          ? content.finalTextStart
                          : '${content.finalTextStart} ',
                      style: ApaFonts.inter(
                        color: ApaColors.webInk,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
                  if (content.finalTextEnd.isNotEmpty)
                    TextSpan(
                      // Web: sentence-case accent in --red
                      text: content.finalTextEnd,
                      style: ApaFonts.inter(
                        color: ApaColors.webRed,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
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
  const _ContactRow({
    required this.row,
    this.showDivider = true,
  });

  final ContactInfoRow row;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    // Web Reach Us: one line, left-aligned "Label value"
    // Links use --blue (#00209f) + underline (editor-content a).
    final uri = row.actionableUri;
    final isMap = row.type.toLowerCase() == 'map' &&
        (row.embedUrl.trim().isNotEmpty || (uri?.isNotEmpty ?? false));

    final labelStyle = ApaFonts.inter(
      color: ApaColors.factLabel,
      fontSize: 16.sp,
      fontWeight: FontWeight.w500,
      height: 1.4,
    );
    final valueStyle = ApaFonts.inter(
      color: ApaColors.webInk,
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      height: 1.4,
    );
    final linkStyle = ApaFonts.inter(
      color: ApaColors.webInk,
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      height: 1.4,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(
                bottom: BorderSide(color: ApaColors.factBorder),
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              if (row.label.isNotEmpty) ...[
                Text(row.label, style: labelStyle),
                if (row.value.isNotEmpty) SizedBox(width: 10.w),
              ],
              if (row.value.isNotEmpty)
                uri != null
                    ? InkWell(
                        onTap: () => _open(uri),
                        child: Text(row.value, style: linkStyle),
                      )
                    : Text(row.value, style: valueStyle),
            ],
          ),
          if (isMap) ...[
            SizedBox(height: 12.h),
            _MapPreview(
              embedUrl: row.embedUrl.trim().isNotEmpty
                  ? row.embedUrl.trim()
                  : uri!,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _open(String raw) async {
    final uri = Uri.tryParse(raw);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _MapPreview extends StatelessWidget {
  const _MapPreview({required this.embedUrl});

  final String embedUrl;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ApaColors.mist,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: () async {
          final uri = Uri.tryParse(embedUrl);
          if (uri == null) return;
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        },
        borderRadius: BorderRadius.circular(12.r),
        child: SizedBox(
          width: double.infinity,
          height: 160.h,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.map_outlined, color: ApaColors.webInk, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'Open map',
                  style: ApaFonts.inter(
                    color: ApaColors.webInk,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
