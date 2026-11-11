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
import '../../../../core/utils/html_utils.dart';
import '../../../../core/widgets/apa_empty_retry.dart';
import '../../../../core/widgets/apa_shared_widgets.dart';
import '../../../../data/models/post/post_model.dart';
import '../../../../data/models/post/post_item_extensions.dart';
import '../../../shell/presentation/controllers/pages_controller.dart';
import '../../../shell/presentation/mapping/apa_page_templates.dart';
import '../../../shell/presentation/models/apa_nav_item.dart';

/// Projects Page — Figma frame `6:203`.
class ProjectsPage extends StatelessWidget {
  const ProjectsPage({
    super.key,
    this.scrollController,
    this.page,
    this.onFundPressed,
    this.onProjectPressed,
    this.imageUrl,
  });

  final ScrollController? scrollController;
  final PostItem? page;
  final VoidCallback? onFundPressed;
  final ValueChanged<PostItem>? onProjectPressed;
  final String? imageUrl;

  PagesController? get _pagesController {
    if (!Get.isRegistered<PagesController>()) return null;
    return Get.find<PagesController>();
  }

  @override
  Widget build(BuildContext context) {
    final navBottomPad = ApaShellInsets.contentBottom(context);
    final pagesController = _pagesController;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ColoredBox(
        color: ApaColors.white,
        child: RefreshIndicator(
          color: ApaColors.primaryRed,
          onRefresh: () async {
            await pagesController?.loadDetailsForTemplate(
              ApaPageTemplates.projects,
              force: true,
            );
          },
          child: Obx(() {
            pagesController?.items.length;
            pagesController?.pageDetailsById.length;
            pagesController?.extraProjects.length;
            pagesController?.projectsHasMore.value;
            pagesController?.loadingMoreProjects.value;
            pagesController?.isLoading.value;
            if (ConnectivityController.registered) {
              ConnectivityController.to.isOnline.value;
            }

            final blank = pagesController?.isBlankForTemplate(
                  ApaPageTemplates.projects,
                ) ??
                true;
            final loading = pagesController != null &&
                ((pagesController.isLoading.value &&
                        pagesController.items.isEmpty) ||
                    pagesController.isLoadingDetailsForTemplate(
                      ApaPageTemplates.projects,
                    ));

            if (loading) {
              return const ColoredBox(
                color: ApaColors.white,
                child: Center(
                  child: CircularProgressIndicator(color: ApaColors.primaryRed),
                ),
              );
            }

            if (blank) {
              return ColoredBox(
                color: ApaColors.white,
                child: ListView(
                  controller: scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    20.w,
                    48.h,
                    20.w,
                    navBottomPad,
                  ),
                  children: [
                    ApaEmptyRetry.forConnectivity(
                      onRetry: () => pagesController?.retryLoad(
                        template: ApaPageTemplates.projects,
                      ),
                    ),
                  ],
                ),
              );
            }

            final current =
                pagesController?.resolvedPageForShell(ApaShellPage.projects) ??
                    page;
            final projects = pagesController?.projectsForDisplay(current) ??
                current?.relatedProjects ??
                const <PostItem>[];
            return _buildScrollView(
              context,
              current,
              projects,
              navBottomPad,
              hasMore: pagesController?.projectsHasMore.value ?? false,
              loadingMore: pagesController?.loadingMoreProjects.value ?? false,
              onLoadMore: pagesController == null
                  ? null
                  : () => pagesController.loadMoreProjects(),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildScrollView(
    BuildContext context,
    PostItem? current,
    List<PostItem> projects,
    double navBottomPad, {
    required bool hasMore,
    required bool loadingMore,
    required VoidCallback? onLoadMore,
  }) {
    final commonHeader = current?.commonHeader ?? const <String, dynamic>{};

    final badge = commonHeader['top_tag_line']?.toString() ?? '';
    final headingOne =
        (commonHeader['heading_text_one']?.toString() ?? '').trim();
    final headingTwo =
        (commonHeader['heading_text_two']?.toString() ?? '').trim();
    final subtitle = commonHeader['last_content']?.toString();

    final headline = <InlineSpan>[];
    if (headingOne.isNotEmpty) {
      headline.add(
        TextSpan(
          text: '${headingOne.toUpperCase()}\n',
          style: ApaFonts.inter(
            color: ApaColors.white,
            fontSize: 36.sp,
            fontWeight: FontWeight.w800,
            height: 40 / 36,
            letterSpacing: -0.5,
          ),
        ),
      );
    }
    if (headingTwo.isNotEmpty) {
      headline.add(
        TextSpan(
          text: headingTwo.toUpperCase(),
          style: ApaFonts.inter(
            color: ApaColors.primaryRed,
            fontSize: 36.sp,
            fontWeight: FontWeight.w800,
            height: 40 / 36,
            letterSpacing: -0.5,
          ),
        ),
      );
    }

    final heroImage = current?.featuredImageUrl ?? imageUrl;
    final isLandscape = R.isTabletLandscape(context);
    // Landscape hero row stays 3-up; extra projects stack below (no layout break).
    final rowProjects =
        isLandscape ? projects.take(3).toList(growable: false) : projects;
    final overflowProjects =
        isLandscape && projects.length > 3 ? projects.sublist(3) : const <PostItem>[];

    return CustomScrollView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        SliverToBoxAdapter(
          child: ApaHeroHeader(
            imageAsset: ApaAssets.projectsHero,
            imageUrl: heroImage,
            useAssetFallback: false,
            height: 520,
            overlayOpacity: 0.7,
            logoWidth: 180,
            logoHeight: 67.5,
            badge: badge,
            headline: headline,
            subtitle: subtitle,
          ),
        ),
        SliverToBoxAdapter(
          child: ApaPageWidth(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isLandscape ? 48 : 24.w,
                48.h,
                isLandscape ? 48 : 24.w,
                navBottomPad,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isLandscape && rowProjects.length >= 3)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < 3; i++) ...[
                          if (i > 0) const SizedBox(width: 28),
                          Expanded(
                            child: _ProjectSection(
                              project: rowProjects[i],
                              onTap: onProjectPressed == null
                                  ? null
                                  : () => onProjectPressed!(rowProjects[i]),
                            ),
                          ),
                        ],
                      ],
                    )
                  else
                    ...rowProjects.asMap().entries.map(
                          (e) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _ProjectSection(
                                project: e.value,
                                onTap: onProjectPressed == null
                                    ? null
                                    : () => onProjectPressed!(e.value),
                              ),
                              if (e.key != rowProjects.length - 1)
                                const _BlackSeparator(),
                            ],
                          ),
                        ),
                  for (final project in overflowProjects) ...[
                    const _BlackSeparator(),
                    _ProjectSection(
                      project: project,
                      onTap: onProjectPressed == null
                          ? null
                          : () => onProjectPressed!(project),
                    ),
                  ],
                  if (hasMore) ...[
                    SizedBox(height: 28.h),
                    Center(
                      child: loadingMore
                          ? const SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                color: ApaColors.primaryRed,
                                strokeWidth: 2.5,
                              ),
                            )
                          : ApaBlackPillButton(
                              label: 'LOAD MORE',
                              onPressed: onLoadMore,
                            ),
                    ),
                  ],
                  const _BlackSeparator(),
                  _ProjectsFooterHtml(html: current?.footerHtml),
                  SizedBox(height: 28.h),
                  Center(
                    child: ApaBlackPillButton(
                      label: 'FUND A PROJECT',
                      onPressed: onFundPressed,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BlackSeparator extends StatelessWidget {
  const _BlackSeparator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: const ColoredBox(
        color: ApaColors.black,
        child: SizedBox(height: 1, width: double.infinity),
      ),
    );
  }
}

class _ProjectSection extends StatelessWidget {
  const _ProjectSection({
    required this.project,
    this.onTap,
  });

  final PostItem project;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final label = project.projectTypeLabel ?? '';
    final title = project.title;
    final body = project.tagLine ?? '';
    final bullets = project.contentBullets;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ApaSectionLabel(label),
        SizedBox(height: 8.h),
        Text(
          title,
          style: ApaFonts.inter(
            color: ApaColors.black,
            fontSize: 28.sp,
            fontWeight: FontWeight.w800,
            height: 32 / 28,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          body,
          style: ApaFonts.inter(
            color: ApaColors.gray700,
            fontSize: 15.sp,
            height: 22.5 / 15,
          ),
        ),
        SizedBox(height: 12.h),
        ...bullets.map((b) => ApaBulletItem(text: b)),
      ],
    );

    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: content,
    );
  }
}

class _ProjectsFooterHtml extends StatelessWidget {
  const _ProjectsFooterHtml({required this.html});

  final String? html;

  @override
  Widget build(BuildContext context) {
    if (html == null || html!.trim().isEmpty) return const SizedBox.shrink();

    final blocks = HtmlUtils.extractHeaderAndParagraphs(html!);
    if (blocks.isEmpty) {
      return Text(
        HtmlUtils.stripHtmlToText(html!),
        style: ApaFonts.inter(
          color: ApaColors.gray700,
          fontSize: 16.sp,
          height: 24 / 16,
        ),
      );
    }

    // Render in the order we encounter `<h2>` / `<p>` blocks.
    final children = <Widget>[];
    for (final block in blocks) {
      final type = block['type'];
      final text = (block['text'] ?? '').trim();
      if (text.isEmpty) continue;

      if (type == 'h2') {
        children.add(
          Text(
            text.toUpperCase(),
            style: ApaFonts.inter(
              color: ApaColors.black,
              fontSize: 36.sp,
              fontWeight: FontWeight.w800,
              height: 40 / 36,
              letterSpacing: -0.5,
            ),
          ),
        );
      } else if (type == 'p') {
        children.add(
          Padding(
            padding: EdgeInsets.only(top: children.isEmpty ? 0 : 16.h),
            child: Text(
              text,
              style: ApaFonts.inter(
                color: ApaColors.gray700,
                fontSize: 16.sp,
                height: 24 / 16,
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
