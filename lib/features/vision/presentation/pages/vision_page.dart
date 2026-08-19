import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constants/apa_assets.dart';
import '../../../../core/constants/apa_shell_insets.dart';
import '../../../../core/theme/apa_colors.dart';
import '../../../../core/theme/apa_fonts.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/apa_shared_widgets.dart';
import '../../../shell/presentation/controllers/pages_controller.dart';
import '../../../shell/presentation/mapping/apa_page_templates.dart';
import '../../../shell/presentation/models/apa_nav_item.dart';
import '../../domain/vision_page_content.dart';

/// Our Vision Page — Figma frame `16:1107`.
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ColoredBox(
        color: ApaColors.white,
        child: RefreshIndicator(
          color: ApaColors.primaryRed,
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
              SliverToBoxAdapter(child: _buildHero(pagesController)),
              SliverToBoxAdapter(
                child: ApaPageWidth(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      R.isTabletLandscape(context) ? 48 : 24.w,
                      48.h,
                      R.isTabletLandscape(context) ? 48 : 24.w,
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

  Widget _buildHero(PagesController? pagesController) {
    if (pagesController == null) return const SizedBox.shrink();

    return Obx(() {
      final content = _visionContent(pagesController);
      if (content == null || !content.showHeader) {
        return const SizedBox.shrink();
      }

      return ApaHeroHeader(
        imageAsset: ApaAssets.visionHero,
        imageUrl: content.imageUrl ?? imageUrl,
        useAssetFallback: false,
        height: 505,
        badge: content.topTagLine,
        headline: _headlineSpans(content),
        subtitle: content.lastContent.isEmpty ? null : content.lastContent,
      );
    });
  }

  List<InlineSpan> _headlineSpans(VisionPageContent content) {
    final oneStyle = ApaFonts.inter(
      color: ApaColors.white,
      fontSize: 34.sp,
      fontWeight: FontWeight.w800,
      height: 40 / 34,
      letterSpacing: -0.5,
    );
    final twoStyle = ApaFonts.inter(
      color: ApaColors.primaryRed,
      fontSize: 34.sp,
      fontWeight: FontWeight.w800,
      height: 40 / 34,
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

  Widget _buildBody(BuildContext context, PagesController? pagesController) {
    if (pagesController == null) return const SizedBox.shrink();

    return Obx(() {
      final content = _visionContent(pagesController);
      if (content == null) {
        if (pagesController.isLoading.value && pagesController.items.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 48.h),
            child: const Center(
              child: CircularProgressIndicator(color: ApaColors.primaryRed),
            ),
          );
        }
        return const SizedBox.shrink();
      }

      final desktop = R.isTabletLandscape(context);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (content.hasStatement) ...[
            if (content.statementSubheading.isNotEmpty)
              Text(
                content.statementSubheading.toUpperCase(),
                style: ApaFonts.inter(
                  color: ApaColors.black,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  height: 28 / 22,
                ),
              ),
            if (content.statementText.isNotEmpty) ...[
              SizedBox(height: 14.h),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Text(
                  content.statementText,
                  style: ApaFonts.inter(
                    color: ApaColors.gray700,
                    fontSize: 16.sp,
                    height: 24 / 16,
                  ),
                ),
              ),
            ],
            SizedBox(height: 24.h),
            const ColoredBox(
              color: ApaColors.black,
              child: SizedBox(height: 1, width: double.infinity),
            ),
            SizedBox(height: 28.h),
          ],
          if (content.hasCoreValues) ...[
            if (content.coreValuesTitle.isNotEmpty)
              Text(
                content.coreValuesTitle.toUpperCase(),
                style: ApaFonts.inter(
                  color: ApaColors.black,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  height: 28 / 22,
                ),
              ),
            if (content.coreValues.isNotEmpty) ...[
              SizedBox(height: 28.h),
              _ValuesLayout(
                items: content.coreValues,
                desktop: desktop,
                resolveIconUrl: pagesController.mediaSourceUrl,
              ),
            ],
            SizedBox(height: 40.h),
          ],
          if (desktop && (content.hasGoals || content.hasStats))
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (content.hasGoals)
                  Expanded(child: _GoalsColumn(content: content)),
                if (content.hasGoals && content.hasStats) SizedBox(width: 40.w),
                if (content.hasStats)
                  Expanded(child: _StatsCard(stats: content.stats)),
              ],
            )
          else ...[
            if (content.hasGoals) _GoalsColumn(content: content),
            if (content.hasGoals && content.hasStats) SizedBox(height: 32.h),
            if (content.hasStats) _StatsCard(stats: content.stats),
          ],
          if (content.hasJoinMission) ...[
            SizedBox(height: 48.h),
            if (content.joinMissionTitle.isNotEmpty)
              Text(
                content.joinMissionTitle.toUpperCase(),
                style: ApaFonts.inter(
                  color: ApaColors.black,
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  height: 34 / 28,
                ),
              ),
            if (content.joinMissionButtonText.isNotEmpty) ...[
              SizedBox(height: 24.h),
              ApaBlackPillButton(
                label: content.joinMissionButtonText,
                onPressed: onLearnMore,
                fontSize: 16,
                horizontalPadding: 40,
                verticalPadding: 18,
              ),
            ],
          ],
        ],
      );
    });
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

class _ValuesLayout extends StatelessWidget {
  const _ValuesLayout({
    required this.items,
    required this.desktop,
    required this.resolveIconUrl,
  });

  final List<VisionValueItem> items;
  final bool desktop;
  final Future<String?> Function(int id) resolveIconUrl;

  @override
  Widget build(BuildContext context) {
    if (!desktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const _ValueDivider(),
            _ValueBlock(item: items[i], resolveIconUrl: resolveIconUrl),
          ],
        ],
      );
    }

    final perRow = items.length == 4 ? 2 : 3;
    final rows = <List<VisionValueItem>>[];
    for (var i = 0; i < items.length; i += perRow) {
      rows.add(
        items.sublist(
          i,
          i + perRow > items.length ? items.length : i + perRow,
        ),
      );
    }

    return Column(
      children: [
        for (var r = 0; r < rows.length; r++) ...[
          if (r > 0) SizedBox(height: 32.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var c = 0; c < rows[r].length; c++) ...[
                if (c > 0) const SizedBox(width: 32),
                Expanded(
                  child: _ValueBlock(
                    item: rows[r][c],
                    resolveIconUrl: resolveIconUrl,
                  ),
                ),
              ],
              for (var c = rows[r].length; c < perRow; c++)
                const Expanded(child: SizedBox.shrink()),
            ],
          ),
        ],
      ],
    );
  }
}

class _ValueDivider extends StatelessWidget {
  const _ValueDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: const ColoredBox(
        color: ApaColors.gray200,
        child: SizedBox(height: 1, width: double.infinity),
      ),
    );
  }
}

class _ValueBlock extends StatelessWidget {
  const _ValueBlock({
    required this.item,
    required this.resolveIconUrl,
  });

  final VisionValueItem item;
  final Future<String?> Function(int id) resolveIconUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
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
              color: ApaColors.black,
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              height: 28 / 22,
            ),
          ),
        if (item.content.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Text(
            item.content,
            style: ApaFonts.inter(
              color: ApaColors.gray700,
              fontSize: 16.sp,
              height: 24 / 16,
            ),
          ),
        ],
      ],
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

  static const _size = 26.0;

  @override
  Widget build(BuildContext context) {
    final directUrl = iconUrl?.trim();
    if (directUrl != null && directUrl.isNotEmpty) {
      return _networkIcon(directUrl);
    }

    final id = iconId;
    if (id == null || id <= 0) return SizedBox(height: _size.h);

    return FutureBuilder<String?>(
      future: resolveIconUrl(id),
      builder: (context, snapshot) {
        final url = snapshot.data?.trim();
        if (url == null || url.isEmpty) {
          return SizedBox(height: _size.h);
        }
        return _networkIcon(url);
      },
    );
  }

  Widget _networkIcon(String url) {
    final size = _size.w;
    return Image.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => SizedBox(
        width: size,
        height: size,
      ),
    );
  }
}

class _GoalDivider extends StatelessWidget {
  const _GoalDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: const ColoredBox(
        color: ApaColors.gray200,
        child: SizedBox(height: 1, width: double.infinity),
      ),
    );
  }
}

class _GoalsColumn extends StatelessWidget {
  const _GoalsColumn({required this.content});

  final VisionPageContent content;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (content.futureGoalsTitle.isNotEmpty)
          Text(
            content.futureGoalsTitle.toUpperCase(),
            style: ApaFonts.inter(
              color: ApaColors.black,
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              height: 28 / 22,
            ),
          ),
        if (content.futureGoals.isNotEmpty) ...[
          SizedBox(height: 24.h),
          for (var i = 0; i < content.futureGoals.length; i++) ...[
            if (i > 0) const _GoalDivider(),
            _GoalRow(
              title: content.futureGoals[i].heading,
              body: content.futureGoals[i].subHeading,
            ),
          ],
        ],
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.stats});

  final List<VisionStatItem> stats;

  @override
  Widget build(BuildContext context) {
    final rows = <List<VisionStatItem>>[];
    for (var i = 0; i < stats.length; i += 2) {
      rows.add(
        stats.sublist(i, i + 2 > stats.length ? stats.length : i + 2),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 32.w,
        vertical: 40.h,
      ),
      decoration: BoxDecoration(
        color: ApaColors.black,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          for (var r = 0; r < rows.length; r++) ...[
            if (r > 0) SizedBox(height: 32.h),
            Row(
              children: [
                for (final stat in rows[r])
                  Expanded(
                    child: _StatCell(
                      value: stat.heading,
                      label: stat.subHeading,
                    ),
                  ),
                if (rows[r].length == 1) const Expanded(child: SizedBox.shrink()),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Text(
            title,
            style: ApaFonts.inter(
              color: ApaColors.nearBlack,
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              height: 22 / 16,
            ),
          ),
        if (body.isNotEmpty) ...[
          SizedBox(height: 4.h),
          Text(
            body,
            style: ApaFonts.inter(
              color: ApaColors.gray600,
              fontSize: 14.sp,
              height: 20 / 14,
            ),
          ),
        ],
      ],
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
          style: ApaFonts.inter(
            color: ApaColors.white,
            fontSize: 32.sp,
            fontWeight: FontWeight.w800,
            height: 40 / 32,
          ),
        ),
        if (label.isNotEmpty) ...[
          SizedBox(height: 4.h),
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: ApaFonts.inter(
              color: ApaColors.white60,
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ],
      ],
    );
  }
}
