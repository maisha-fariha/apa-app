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
import '../../domain/transparency_page_content.dart';

/// Transparency Page — Figma frame `9:508`.
class TransparencyPage extends StatelessWidget {
  const TransparencyPage({
    super.key,
    this.scrollController,
    this.imageUrl,
  });

  final ScrollController? scrollController;
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
              ApaPageTemplates.transparency,
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
                      40.h,
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
      final content = _content(pagesController);
      if (content == null || !content.showHeader) {
        return const SizedBox.shrink();
      }

      return ApaHeroHeader(
        imageAsset: ApaAssets.transparencyHero,
        imageUrl: content.imageUrl ?? imageUrl,
        useAssetFallback: false,
        height: 540,
        badge: content.topTagLine,
        headline: _headlineSpans(content),
        subtitle: content.lastContent.isEmpty ? null : content.lastContent,
      );
    });
  }

  List<InlineSpan> _headlineSpans(TransparencyPageContent content) {
    final oneStyle = ApaFonts.inter(
      color: ApaColors.white,
      fontSize: 36.sp,
      fontWeight: FontWeight.w800,
      height: 40 / 36,
      letterSpacing: -0.5,
    );
    final twoStyle = ApaFonts.inter(
      color: ApaColors.primaryRedDeep,
      fontSize: 36.sp,
      fontWeight: FontWeight.w800,
      height: 40 / 36,
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

  Widget _buildBody(
    BuildContext context,
    PagesController? pagesController,
  ) {
    if (pagesController == null) return const SizedBox.shrink();

    return Obx(() {
      final content = _content(pagesController);
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
          if (content.hasFunding) ...[
            if (desktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (content.funding.hasRaised)
                    _RaisedBox(amount: content.funding.raisedLabel),
                  if (content.funding.hasRaised && content.funding.hasProgress)
                    SizedBox(width: 40.w),
                  if (content.funding.hasProgress)
                    Expanded(
                      child: _ProgressBlock(funding: content.funding),
                    ),
                ],
              )
            else ...[
              if (content.funding.hasRaised)
                _RaisedBox(amount: content.funding.raisedLabel),
              if (content.funding.hasRaised && content.funding.hasProgress)
                SizedBox(height: 24.h),
              if (content.funding.hasProgress)
                _ProgressBlock(funding: content.funding),
            ],
            SizedBox(height: 24.h),
            const ColoredBox(
              color: ApaColors.black,
              child: SizedBox(height: 1, width: double.infinity),
            ),
            SizedBox(height: 32.h),
          ],
          if (content.hasLedger) ...[
            Text(
              'PROJECT LEDGER',
              style: ApaFonts.inter(
                color: ApaColors.black,
                fontSize: 28.sp,
                fontWeight: FontWeight.w800,
                height: 34 / 28,
              ),
            ),
            SizedBox(height: 24.h),
            _LedgerTable(items: content.ledgerItems),
            SizedBox(height: 48.h),
          ],
          if (content.hasCommitments) ...[
            if (content.commitmentTitle.isNotEmpty)
              Text(
                content.commitmentTitle.toUpperCase(),
                style: ApaFonts.inter(
                  color: ApaColors.black,
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  height: 34 / 28,
                ),
              ),
            if (content.commitments.isNotEmpty) ...[
              SizedBox(height: 28.h),
              if (desktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < content.commitments.length; i++) ...[
                      if (i > 0) const SizedBox(width: 28),
                      Expanded(
                        child: _CommitmentBlock(
                          title: content.commitments[i].title,
                          body: content.commitments[i].body,
                        ),
                      ),
                    ],
                  ],
                )
              else ...[
                for (var i = 0; i < content.commitments.length; i++) ...[
                  if (i > 0) const _ThickSeparator(),
                  _CommitmentBlock(
                    title: content.commitments[i].title,
                    body: content.commitments[i].body,
                  ),
                ],
              ],
            ],
          ],
        ],
      );
    });
  }

  TransparencyPageContent? _content(PagesController pagesController) {
    pagesController.items.length;
    pagesController.pageDetailsById.length;

    final listPage = pagesController.pageForShell(ApaShellPage.transparency);
    if (listPage == null) return null;

    pagesController.loadPageDetails(listPage.id);
    final details = pagesController.detailsForPageId(listPage.id);
    if (details == null) return null;
    return TransparencyPageContent.fromPost(details);
  }
}

class _RaisedBox extends StatelessWidget {
  const _RaisedBox({required this.amount});

  final String amount;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          constraints: BoxConstraints(minWidth: 280.w),
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
          decoration: BoxDecoration(
            color: ApaColors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: ApaColors.black, width: 2),
          ),
          child: Column(
            children: [
              Text(
                amount,
                maxLines: 1,
                style: ApaFonts.inter(
                  color: ApaColors.nearBlack,
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w800,
                  height: 32 / 28,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'RAISED TO DATE',
                maxLines: 1,
                softWrap: false,
                textAlign: TextAlign.center,
                style: ApaFonts.inter(
                  color: ApaColors.primaryRed,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressBlock extends StatelessWidget {
  const _ProgressBlock({required this.funding});

  final TransparencyFunding funding;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(9999),
          child: SizedBox(
            height: 14.h,
            child: LinearProgressIndicator(
              value: funding.progressValue,
              backgroundColor: ApaColors.gray100,
              color: ApaColors.navy,
            ),
          ),
        ),
        if (funding.progressCaption.isNotEmpty) ...[
          SizedBox(height: 12.h),
          Text(
            funding.progressCaption,
            style: ApaFonts.inter(
              color: ApaColors.gray700,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              height: 20 / 14,
            ),
          ),
        ],
      ],
    );
  }
}

class _ThickSeparator extends StatelessWidget {
  const _ThickSeparator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: const ColoredBox(
        color: ApaColors.gray200,
        child: SizedBox(height: 3, width: double.infinity),
      ),
    );
  }
}

class _CommitmentBlock extends StatelessWidget {
  const _CommitmentBlock({required this.title, required this.body});

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
              color: ApaColors.black,
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              height: 28 / 22,
            ),
          ),
        if (body.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Text(
            body,
            style: ApaFonts.inter(
              color: ApaColors.gray700,
              fontSize: 15.sp,
              height: 22 / 15,
            ),
          ),
        ],
      ],
    );
  }
}

class _LedgerTable extends StatelessWidget {
  const _LedgerTable({required this.items});

  final List<TransparencyLedgerItem> items;

  /// Comfortable width where 11/12sp table text fits without shrinking.
  static const double _comfortableWidth = 560;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / _comfortableWidth).clamp(0.72, 1.0);
        final gap = 8.0 * scale;

        final headerStyle = ApaFonts.inter(
          color: ApaColors.gray500,
          fontSize: 11.sp * scale,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.25 * scale,
        );
        final projectStyle = ApaFonts.inter(
          color: ApaColors.nearBlack,
          fontSize: 12.sp * scale,
          fontWeight: FontWeight.w600,
          height: 16 / 12,
        );
        final communityStyle = ApaFonts.inter(
          color: ApaColors.gray800,
          fontSize: 12.sp * scale,
          fontWeight: FontWeight.w600,
        );
        final committedStyle = ApaFonts.inter(
          color: ApaColors.nearBlack,
          fontSize: 12.sp * scale,
          fontWeight: FontWeight.w700,
        );

        Widget fitCell(
          String text,
          TextStyle style, {
          TextAlign align = TextAlign.left,
          EdgeInsetsGeometry? padding,
        }) {
          final alignment = align == TextAlign.right
              ? Alignment.centerRight
              : Alignment.centerLeft;
          return Padding(
            padding: padding ?? EdgeInsets.fromLTRB(0, 14.h, gap, 14.h),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: alignment,
              child: Text(
                text,
                style: style,
                maxLines: 1,
                softWrap: false,
                textAlign: align,
              ),
            ),
          );
        }

        return Table(
          columnWidths: const {
            0: FlexColumnWidth(2.8),
            1: FlexColumnWidth(1.7),
            2: FlexColumnWidth(2.3),
            3: FlexColumnWidth(1.6),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: ApaColors.black, width: 2),
                ),
              ),
              children: [
                fitCell(
                  'PROJECT',
                  headerStyle,
                  padding: EdgeInsets.fromLTRB(0, 0, gap, 12.h),
                ),
                fitCell(
                  'COMMUNITY',
                  headerStyle,
                  padding: EdgeInsets.fromLTRB(0, 0, gap, 12.h),
                ),
                fitCell(
                  'STATUS',
                  headerStyle,
                  padding: EdgeInsets.fromLTRB(0, 0, gap, 12.h),
                ),
                fitCell(
                  'COMMITTED',
                  headerStyle,
                  align: TextAlign.right,
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 12.h),
                ),
              ],
            ),
            for (final item in items)
              TableRow(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: ApaColors.gray200),
                  ),
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 14.h, gap, 14.h),
                    child: Text(
                      item.project,
                      style: projectStyle,
                      softWrap: true,
                    ),
                  ),
                  fitCell(item.community, communityStyle),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 10.h, gap, 10.h),
                    child: item.status.isEmpty
                        ? const SizedBox.shrink()
                        : FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: _StatusBadge(
                              status: item.status,
                              highlighted: item.highlightStatus,
                              fontSize: 10.sp * scale,
                              horizontalPadding: 8 * scale,
                            ),
                          ),
                  ),
                  fitCell(
                    item.committed,
                    committedStyle,
                    align: TextAlign.right,
                    padding: EdgeInsets.fromLTRB(0, 14.h, 0, 14.h),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
    required this.highlighted,
    required this.fontSize,
    required this.horizontalPadding,
  });

  final String status;
  final bool highlighted;
  final double fontSize;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color: highlighted ? ApaColors.navy : ApaColors.gray100,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        status,
        maxLines: 1,
        softWrap: false,
        style: ApaFonts.inter(
          color: highlighted ? ApaColors.white : ApaColors.nearBlack,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
