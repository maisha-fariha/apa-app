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
import '../../../../data/models/post/content_detail_models.dart';
import '../../../../data/models/post/post_model.dart';
import '../../../../data/models/post/post_item_extensions.dart';
import '../../../shell/presentation/controllers/pages_controller.dart';
import '../../../shell/presentation/mapping/apa_page_templates.dart';
import '../../../shell/presentation/models/apa_nav_item.dart';

/// Projects Page — matches live web `page-project.php`.
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
            pagesController?.projectsCatalog.length;
            pagesController?.projectsCatalogLoaded.value;
            pagesController?.projectsPage.value;
            pagesController?.projectsTotalPages.value;
            pagesController?.loadingProjectsPage.value;
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
              currentPage: pagesController?.projectsPage.value ?? 1,
              totalPages: pagesController?.projectsTotalPages.value ?? 1,
              loadingPage:
                  pagesController?.loadingProjectsPage.value ?? false,
              onPageSelected: pagesController == null
                  ? null
                  : (pageNumber) async {
                      await pagesController.goToProjectsPage(pageNumber);
                      final controller = scrollController;
                      if (controller != null && controller.hasClients) {
                        await controller.animateTo(
                          0,
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOut,
                        );
                      }
                    },
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
    required int currentPage,
    required int totalPages,
    required bool loadingPage,
    required ValueChanged<int>? onPageSelected,
  }) {
    final commonHeader = current?.commonHeader ?? const <String, dynamic>{};

    // Live web shows CMS values as-is (including placeholder "Heading Text One").
    final badge = (commonHeader['top_tag_line']?.toString() ?? '').trim();
    final headingOne =
        (commonHeader['heading_text_one']?.toString() ?? '').trim();
    final headingTwo =
        (commonHeader['heading_text_two']?.toString() ?? '').trim();
    final subtitle = (commonHeader['last_content']?.toString() ?? '').trim();

    // Web: `Heading Text One<br><span class="block text-(--red)">Heading Text Two</span>`
    final headline = <InlineSpan>[];
    if (headingOne.isNotEmpty) {
      headline.add(
        TextSpan(
          text: headingTwo.isNotEmpty
              ? '${headingOne.toUpperCase()}\n'
              : headingOne.toUpperCase(),
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
            color: ApaColors.webRed,
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
            // Web keeps the hero subcopy on one flowing paragraph under the H1.
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
                  if (totalPages > 1) ...[
                    // Web: `mt-8` above Projects pagination.
                    SizedBox(height: 32),
                    _ProjectsNumberedPagination(
                      currentPage: currentPage,
                      totalPages: totalPages,
                      loading: loadingPage,
                      onPageSelected: onPageSelected,
                    ),
                  ],
                  const _BlackSeparator(),
                  _ProjectsFooterBlock(
                    footer: current?.pageFooter ?? PageFooterSection.empty,
                    legacyHtml: current?.footerHtml,
                    fundLabel: () {
                      final title = current?.pageFooter.buttonTitle.trim() ?? '';
                      if (title.isNotEmpty) return title.toUpperCase();
                      return 'FUND A PROJECT';
                    }(),
                    onFundPressed: onFundPressed,
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

/// Live web pager (`nav.mt-8.flex...gap-2`): square `h-10 min-w-10`
/// buttons with `border-2 border-[#0b0b0b]`, active filled, `← 1 2 3 →`.
class _ProjectsNumberedPagination extends StatelessWidget {
  const _ProjectsNumberedPagination({
    required this.currentPage,
    required this.totalPages,
    required this.loading,
    required this.onPageSelected,
  });

  final int currentPage;
  final int totalPages;
  final bool loading;
  final ValueChanged<int>? onPageSelected;

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    final canPrev = currentPage > 1 && !loading;
    final canNext = currentPage < totalPages && !loading;

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (currentPage > 1) ...[
            _PaginationSquareButton(
              label: '←',
              selected: false,
              enabled: canPrev,
              onTap:
                  canPrev ? () => onPageSelected?.call(currentPage - 1) : null,
            ),
            const SizedBox(width: 8),
          ],
          for (var page = 1; page <= totalPages; page++) ...[
            if (page > 1) const SizedBox(width: 8),
            _PaginationSquareButton(
              label: '$page',
              selected: page == currentPage,
              enabled: !loading,
              onTap: (!loading && page != currentPage)
                  ? () => onPageSelected?.call(page)
                  : null,
            ),
          ],
          if (currentPage < totalPages) ...[
            const SizedBox(width: 8),
            _PaginationSquareButton(
              label: '→',
              selected: false,
              enabled: canNext,
              onTap:
                  canNext ? () => onPageSelected?.call(currentPage + 1) : null,
            ),
          ],
        ],
      ),
    );
  }
}

class _PaginationSquareButton extends StatefulWidget {
  const _PaginationSquareButton({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  State<_PaginationSquareButton> createState() =>
      _PaginationSquareButtonState();
}

class _PaginationSquareButtonState extends State<_PaginationSquareButton> {
  /// Web `border-[#0b0b0b]` / `bg-[#0b0b0b]`.
  static const Color _ink = Color(0xFF0B0B0B);

  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final filled = widget.selected || _hovered;
    return MouseRegion(
      onEnter: (_) {
        if (widget.enabled && !widget.selected) {
          setState(() => _hovered = true);
        }
      },
      onExit: (_) {
        if (_hovered) setState(() => _hovered = false);
      },
      child: GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: filled ? _ink : Colors.transparent,
            border: Border.all(color: _ink, width: 2),
          ),
          child: Text(
            widget.label,
            style: ApaFonts.inter(
              color: filled ? ApaColors.white : _ink,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
        ),
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
    final label = (project.projectTypeLabel ?? '').trim();
    // Live web keeps `#2` suffixes in titles.
    final title = project.title.trim();
    final body = (project.tagLine ?? '').trim();
    final rich = project.projectCardContent;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label.toUpperCase(),
            style: ApaFonts.inter(
              color: ApaColors.projectTypeNavy,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.68,
              height: 16 / 12,
            ),
          ),
          SizedBox(height: 10.h),
        ],
        Text(
          title,
          style: ApaFonts.inter(
            color: ApaColors.black,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            height: 1.1,
            letterSpacing: -0.2,
          ),
        ),
        if (body.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Text(
            body,
            style: ApaFonts.inter(
              color: const Color(0xFF5A5C66),
              fontSize: 15.sp,
              height: 22.5 / 15,
            ),
          ),
        ],
        if (rich.bullets.isNotEmpty) ...[
          SizedBox(height: 12.h),
          ...rich.bullets.map((b) => ApaBulletItem(text: b)),
        ],
        if (rich.numbered.isNotEmpty) ...[
          SizedBox(height: rich.bullets.isEmpty ? 12.h : 4.h),
          ...rich.numbered.asMap().entries.map(
                (e) => ApaNumberedItem(index: e.key + 1, text: e.value),
              ),
        ],
        if (rich.callouts.isNotEmpty) ...[
          ...rich.callouts.map((c) => ApaRedBorderCallout(text: c)),
        ],
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

class _ProjectsFooterBlock extends StatelessWidget {
  const _ProjectsFooterBlock({
    required this.footer,
    required this.fundLabel,
    this.legacyHtml,
    this.onFundPressed,
  });

  final PageFooterSection footer;
  final String? legacyHtml;
  final String fundLabel;
  final VoidCallback? onFundPressed;

  @override
  Widget build(BuildContext context) {
    final hasStructured =
        footer.title.isNotEmpty || footer.content.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasStructured)
          _ProjectsFooterSection(footer: footer)
        else if (legacyHtml != null && legacyHtml!.trim().isNotEmpty)
          _ProjectsFooterHtml(html: legacyHtml),
        SizedBox(height: 28.h),
        Center(
          child: ApaBlackPillButton(
            label: fundLabel,
            onPressed: onFundPressed,
          ),
        ),
      ],
    );
  }
}

class _ProjectsFooterSection extends StatelessWidget {
  const _ProjectsFooterSection({required this.footer});

  final PageFooterSection footer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (footer.title.isNotEmpty)
          Text(
            footer.title.toUpperCase(),
            style: ApaFonts.inter(
              color: ApaColors.black,
              fontSize: 36.sp,
              fontWeight: FontWeight.w800,
              height: 40 / 36,
              letterSpacing: -0.5,
            ),
          ),
        if (footer.content.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: footer.title.isEmpty ? 0 : 16.h),
            child: Text(
              footer.content,
              style: ApaFonts.inter(
                color: ApaColors.gray700,
                fontSize: 16.sp,
                height: 24 / 16,
              ),
            ),
          ),
      ],
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
