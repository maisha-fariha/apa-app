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
import '../../../../core/widgets/apa_empty_retry.dart';
import '../../../../core/widgets/apa_shared_widgets.dart';
import '../../../shell/presentation/controllers/pages_controller.dart';
import '../../../shell/presentation/mapping/apa_page_templates.dart';
import '../../../shell/presentation/models/apa_nav_item.dart';
import '../../domain/vision_page_content.dart';

/// Our Vision — matches live web `page-vision.php`.
class VisionPage extends StatelessWidget {
  const VisionPage({
    super.key,
    this.scrollController,
    this.onLearnMore,
    this.imageUrl,
  });

  final ScrollController? scrollController;
  final VoidCallback? onLearnMore;
  final String? imageUrl;

  PagesController? get _pagesController {
    if (!Get.isRegistered<PagesController>()) return null;
    return Get.find<PagesController>();
  }

  @override
  Widget build(BuildContext context) {
    final navBottomPad = ApaShellInsets.contentBottom(context);
    final pagesController = _pagesController;
    final sidePad = R.isTabletLandscape(context) ? 48.0 : 22.w;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ColoredBox(
        color: ApaColors.white,
        child: RefreshIndicator(
          color: ApaColors.webRed,
          onRefresh: () async {
            await pagesController?.loadDetailsForTemplate(
              ApaPageTemplates.vision,
              force: true,
            );
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
                      : _visionContent(pagesController);
                  if (content == null || !content.showHeader) {
                    return const SizedBox.shrink();
                  }
                  return ApaHeroHeader(
                    imageAsset: ApaAssets.visionHero,
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
                  maxWidth: 1100,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      sidePad,
                      56.h,
                      sidePad,
                      navBottomPad,
                    ),
                    child: _buildBody(context, pagesController),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<InlineSpan> _headlineSpans(VisionPageContent content) {
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

  Widget _buildBody(BuildContext context, PagesController? pagesController) {
    if (pagesController == null) return const SizedBox.shrink();

    return Obx(() {
      if (ConnectivityController.registered) {
        ConnectivityController.to.isOnline.value;
      }
      final content = _visionContent(pagesController);
      if (content == null) {
        final loadingList =
            pagesController.isLoading.value && pagesController.items.isEmpty;
        final loadingDetails = pagesController.isLoadingDetailsForTemplate(
          ApaPageTemplates.vision,
        );
        if (loadingList || loadingDetails) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 48.h),
            child: const Center(
              child: CircularProgressIndicator(color: ApaColors.webRed),
            ),
          );
        }
        if (!ConnectivityController.currentlyOnline ||
            pagesController.isBlankForTemplate(ApaPageTemplates.vision)) {
          return ApaEmptyRetry.forConnectivity(
            onRetry: () => pagesController.retryLoad(
              template: ApaPageTemplates.vision,
            ),
          );
        }
        return const SizedBox.shrink();
      }

      final wide = MediaQuery.sizeOf(context).width >= 900;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (content.hasStatement) ...[
            if (content.statementSubheading.isNotEmpty)
              Text(
                content.statementSubheading.toUpperCase(),
                style: _sectionTitleStyle(fontWeight: FontWeight.w600),
              ),
            if (content.statementText.isNotEmpty) ...[
              SizedBox(height: 12.h),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Text(
                  content.statementText,
                  style: ApaFonts.inter(
                    color: ApaColors.webInk,
                    fontSize: 20.sp,
                    height: 1.55,
                  ),
                ),
              ),
            ],
            SizedBox(height: 40.h),
            _SectionRule(),
            SizedBox(height: 40.h),
          ],
          if (content.hasCoreValues) ...[
            if (content.coreValuesTitle.isNotEmpty)
              Text(
                content.coreValuesTitle.toUpperCase(),
                style: _sectionTitleStyle(),
              ),
            if (content.coreValues.isNotEmpty) ...[
              SizedBox(height: 34.h),
              _ValuesGrid(
                items: content.coreValues,
                resolveIconUrl: pagesController.mediaSourceUrl,
              ),
            ],
            SizedBox(height: 40.h),
            _SectionRule(),
            SizedBox(height: 40.h),
          ],
          if (content.hasGoals) ...[
            if (content.futureGoalsTitle.isNotEmpty)
              Text(
                content.futureGoalsTitle.toUpperCase(),
                style: _sectionTitleStyle(),
              ),
            if (content.futureGoals.isNotEmpty) ...[
              SizedBox(height: 26.h),
              _GoalsList(goals: content.futureGoals),
            ],
          ],
          if (content.hasStats) ...[
            SizedBox(height: 40.h),
            _StatsCard(stats: content.stats, wide: wide),
          ],
          if (content.hasJoinMission) ...[
            SizedBox(height: 40.h),
            _SectionRule(),
            SizedBox(height: 40.h),
            _JoinMissionRow(
              title: content.joinMissionTitle,
              buttonLabel: content.joinMissionButtonText,
              onPressed: onLearnMore,
            ),
          ],
        ],
      );
    });
  }

  TextStyle _sectionTitleStyle({FontWeight fontWeight = FontWeight.w700}) {
    return ApaFonts.inter(
      color: ApaColors.webInk,
      fontSize: 34.sp,
      fontWeight: fontWeight,
      height: 1.1,
      letterSpacing: -0.5,
    );
  }

  VisionPageContent? _visionContent(PagesController pagesController) {
    pagesController.items.length;
    pagesController.pageDetailsById.length;

    final listPage = pagesController.pageForShell(ApaShellPage.vision);
    if (listPage == null) return null;

    pagesController.loadPageDetails(listPage.id);
    final details = pagesController.detailsForPageId(listPage.id);
    if (details == null) return null;
    return VisionPageContent.fromPost(details);
  }
}

class _SectionRule extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      width: double.infinity,
      color: ApaColors.webInk.withValues(alpha: 0.1),
    );
  }
}

class _ValuesGrid extends StatelessWidget {
  const _ValuesGrid({
    required this.items,
    required this.resolveIconUrl,
  });

  final List<VisionValueItem> items;
  final Future<String?> Function(int id) resolveIconUrl;

  @override
  Widget build(BuildContext context) {
    // Web: `grid-cols-[repeat(auto-fit,minmax(240px,1fr))] gap-0.5 bg-ink`
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        var columns = (width / 240).floor().clamp(1, items.length);
        if (items.length <= 2) columns = items.length.clamp(1, columns);
        if (width < 500) columns = 1;

        final rows = <List<VisionValueItem>>[];
        for (var i = 0; i < items.length; i += columns) {
          rows.add(
            items.sublist(
              i,
              i + columns > items.length ? items.length : i + columns,
            ),
          );
        }

        return ColoredBox(
          color: ApaColors.webInk,
          child: Column(
            children: [
              for (var r = 0; r < rows.length; r++) ...[
                if (r > 0) const SizedBox(height: 2),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var c = 0; c < columns; c++) ...[
                        if (c > 0) const SizedBox(width: 2),
                        Expanded(
                          child: c < rows[r].length
                              ? _ValueCard(
                                  item: rows[r][c],
                                  resolveIconUrl: resolveIconUrl,
                                )
                              : const ColoredBox(color: ApaColors.white),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ValueCard extends StatelessWidget {
  const _ValueCard({
    required this.item,
    required this.resolveIconUrl,
  });

  final VisionValueItem item;
  final Future<String?> Function(int id) resolveIconUrl;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: ApaColors.white,
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 26.h, 24.w, 28.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ValueIcon(
              iconId: item.iconId,
              iconUrl: item.iconUrl,
              resolveIconUrl: resolveIconUrl,
            ),
            SizedBox(height: 10.h),
            if (item.title.isNotEmpty)
              Text(
                item.title,
                style: ApaFonts.inter(
                  color: ApaColors.webInk,
                  fontSize: 27.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                  letterSpacing: -0.27,
                ),
              ),
            if (item.content.isNotEmpty) ...[
              SizedBox(height: 6.h),
              Text(
                item.content,
                style: ApaFonts.inter(
                  color: ApaColors.factLabel,
                  fontSize: 16.sp,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ValueIcon extends StatelessWidget {
  const _ValueIcon({
    required this.resolveIconUrl,
    this.iconId,
    this.iconUrl,
  });

  final int? iconId;
  final String? iconUrl;
  final Future<String?> Function(int id) resolveIconUrl;

  static const _size = 40.0;

  @override
  Widget build(BuildContext context) {
    final directUrl = iconUrl?.trim();
    if (directUrl != null && directUrl.isNotEmpty) {
      return _networkIcon(directUrl);
    }

    final id = iconId;
    if (id == null || id <= 0) return const SizedBox(height: _size);

    return FutureBuilder<String?>(
      future: resolveIconUrl(id),
      builder: (context, snapshot) {
        final url = snapshot.data?.trim();
        if (url == null || url.isEmpty) {
          return const SizedBox(height: _size);
        }
        return _networkIcon(url);
      },
    );
  }

  Widget _networkIcon(String url) {
    return Image.network(
      url,
      width: _size,
      height: _size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          const SizedBox(width: _size, height: _size),
    );
  }
}

class _GoalsList extends StatelessWidget {
  const _GoalsList({required this.goals});

  final List<VisionGoalItem> goals;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final goal in goals)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: ApaColors.factBorder),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (goal.heading.isNotEmpty)
                  Text(
                    goal.heading,
                    style: ApaFonts.inter(
                      color: ApaColors.webInk,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                if (goal.subHeading.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    goal.subHeading,
                    style: ApaFonts.inter(
                      color: ApaColors.factLabel,
                      fontSize: 16.sp,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.stats, required this.wide});

  final List<VisionStatItem> stats;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final columns = wide && stats.length >= 4 ? 4 : 2;
    final rows = <List<VisionStatItem>>[];
    for (var i = 0; i < stats.length; i += columns) {
      rows.add(
        stats.sublist(
          i,
          i + columns > stats.length ? stats.length : i + columns,
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 24.w,
        vertical: wide ? 56.h : 48.h,
      ),
      decoration: BoxDecoration(
        color: ApaColors.webInk,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        children: [
          for (var r = 0; r < rows.length; r++) ...[
            if (r > 0) SizedBox(height: 40.h),
            Row(
              children: [
                for (final stat in rows[r])
                  Expanded(
                    child: _StatCell(
                      value: stat.heading,
                      label: stat.subHeading,
                    ),
                  ),
                for (var i = rows[r].length; i < columns; i++)
                  const Expanded(child: SizedBox.shrink()),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: ApaFonts.inter(
            color: ApaColors.white,
            fontSize: 40.sp,
            fontWeight: FontWeight.w700,
            height: 1,
            letterSpacing: -0.8,
          ),
        ),
        if (label.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: ApaFonts.inter(
              color: ApaColors.mist,
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              height: 1.3,
            ),
          ),
        ],
      ],
    );
  }
}

class _JoinMissionRow extends StatelessWidget {
  const _JoinMissionRow({
    required this.title,
    required this.buttonLabel,
    this.onPressed,
  });

  final String title;
  final String buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final button = buttonLabel.isNotEmpty
        ? ApaBlackPillButton(
            label: buttonLabel.toUpperCase(),
            onPressed: onPressed,
            fontSize: 18,
            horizontalPadding: 35,
            verticalPadding: 16,
          )
        : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final stack = constraints.maxWidth < 520;
        if (stack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title.isNotEmpty)
                Text(
                  title.toUpperCase(),
                  style: ApaFonts.inter(
                    color: ApaColors.webInk,
                    fontSize: 34.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                ),
              if (button != null) ...[
                SizedBox(height: 24.h),
                button,
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (title.isNotEmpty)
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: ApaFonts.inter(
                    color: ApaColors.webInk,
                    fontSize: 34.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                ),
              )
            else
              const Spacer(),
            if (button != null) ...[
              SizedBox(width: 24.w),
              button,
            ],
          ],
        );
      },
    );
  }
}
