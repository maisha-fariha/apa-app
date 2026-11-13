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
import '../../domain/transparency_page_content.dart';

/// Transparency page — matches live web `page-transparency.php`.
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
          color: ApaColors.webRed,
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
                  maxWidth: 1100,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      R.isTabletLandscape(context) ? 48 : 22.w,
                      56.h,
                      R.isTabletLandscape(context) ? 48 : 22.w,
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
        height: 520,
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

  Widget _buildBody(
    BuildContext context,
    PagesController? pagesController,
  ) {
    if (pagesController == null) return const SizedBox.shrink();

    return Obx(() {
      if (ConnectivityController.registered) {
        ConnectivityController.to.isOnline.value;
      }
      pagesController.ledgerPage.value;
      pagesController.ledgerTotalPages.value;
      pagesController.loadingLedgerPage.value;
      // Track cached page rows so page 2+ updates after fetch.
      pagesController.ledgerPagesByNumber[pagesController.ledgerPage.value];

      final content = _content(pagesController);
      if (content == null) {
        final loadingList =
            pagesController.isLoading.value && pagesController.items.isEmpty;
        final loadingDetails = pagesController.isLoadingDetailsForTemplate(
          ApaPageTemplates.transparency,
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
            pagesController.isBlankForTemplate(ApaPageTemplates.transparency)) {
          return ApaEmptyRetry.forConnectivity(
            onRetry: () => pagesController.retryLoad(
              template: ApaPageTemplates.transparency,
            ),
          );
        }
        return const SizedBox.shrink();
      }

      final ledgerItems = pagesController.ledgerItemsForDisplay(
        pagesController.resolvedPageForShell(ApaShellPage.transparency),
      );
      final totalPages = pagesController.ledgerTotalPages.value;
      final currentPage = pagesController.ledgerPage.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (content.hasFunding) ...[
            if (content.funding.hasRaised)
              _RaisedBox(
                amount: content.funding.raisedLabel,
                caption: content.funding.raisedCaption,
              ),
            if (content.funding.hasProgress) ...[
              SizedBox(height: 18.h),
              _ProgressBlock(funding: content.funding),
            ],
            SizedBox(height: 40.h),
            Container(
              height: 2,
              color: ApaColors.webInk.withValues(alpha: 0.1),
            ),
            SizedBox(height: 40.h),
          ],
          if (content.hasLedger) ...[
            Text(
              content.ledgerTitle.toUpperCase(),
              style: ApaFonts.inter(
                color: ApaColors.webInk,
                fontSize: 32.sp,
                fontWeight: FontWeight.w700,
                height: 1.1,
                letterSpacing: -0.48,
              ),
            ),
            SizedBox(height: 24.h),
            _LedgerTable(
              projectHeading: content.projectColumnHeading,
              columns: content.ledgerColumns.isNotEmpty
                  ? content.ledgerColumns
                  : pagesController.ledgerColumns.toList(growable: false),
              items: ledgerItems,
            ),
            if (totalPages > 1) ...[
              SizedBox(height: 32.h),
              _LedgerPagination(
                currentPage: currentPage,
                totalPages: totalPages,
                loading: pagesController.loadingLedgerPage.value,
                onPageSelected: pagesController.goToLedgerPage,
              ),
            ],
            SizedBox(height: 48.h),
          ],
          if (content.hasCommitments) ...[
            if (content.commitmentTitle.isNotEmpty)
              Text(
                content.commitmentTitle.toUpperCase(),
                style: ApaFonts.inter(
                  color: ApaColors.webInk,
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  letterSpacing: -0.48,
                ),
              ),
            if (content.commitments.isNotEmpty) ...[
              SizedBox(height: 34.h),
              _CommitmentGrid(items: content.commitments),
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
  const _RaisedBox({required this.amount, required this.caption});

  final String amount;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: ApaColors.white,
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(color: ApaColors.webInk, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33636363),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                amount,
                maxLines: 1,
                style: ApaFonts.inter(
                  color: ApaColors.webInk,
                  fontSize: 34.sp,
                  fontWeight: FontWeight.w700,
                  height: 1,
                  letterSpacing: -0.68,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                caption.toUpperCase(),
                maxLines: 1,
                softWrap: false,
                textAlign: TextAlign.center,
                style: ApaFonts.inter(
                  color: ApaColors.webRed,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.05,
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
            height: 14,
            child: LinearProgressIndicator(
              value: funding.progressValue,
              backgroundColor: ApaColors.mist,
              color: ApaColors.projectTypeNavy,
            ),
          ),
        ),
        if (funding.progressCaption.isNotEmpty) ...[
          SizedBox(height: 16.h),
          Text(
            funding.progressCaption,
            style: ApaFonts.inter(
              color: ApaColors.factLabel,
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}

class _CommitmentGrid extends StatelessWidget {
  const _CommitmentGrid({required this.items});

  final List<TransparencyCommitment> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ApaColors.webInk,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 520;
          if (!wide) {
            return Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) const SizedBox(height: 2),
                  _CommitmentCard(item: items[i]),
                ],
              ],
            );
          }
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) const SizedBox(width: 2),
                  Expanded(child: _CommitmentCard(item: items[i])),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CommitmentCard extends StatelessWidget {
  const _CommitmentCard({required this.item});

  final TransparencyCommitment item;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: ApaColors.white,
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 26.h, 24.w, 28.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.title.isNotEmpty)
              Text(
                item.title,
                style: ApaFonts.inter(
                  color: ApaColors.webInk,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.22,
                  height: 1.2,
                ),
              ),
            if (item.body.isNotEmpty) ...[
              SizedBox(height: 6.h),
              Text(
                item.body,
                style: ApaFonts.inter(
                  color: ApaColors.factLabel,
                  fontSize: 16.sp,
                  height: 1.45,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LedgerTable extends StatelessWidget {
  const _LedgerTable({
    required this.projectHeading,
    required this.columns,
    required this.items,
  });

  final String projectHeading;
  final List<TransparencyLedgerColumn> columns;
  final List<TransparencyLedgerItem> items;

  /// Web `overflow-x-auto` — keep readable column mins, scroll on narrow screens.
  static const double _projectMin = 200;
  static const double _textMin = 112;
  static const double _badgeMin = 128;
  static const double _moneyMin = 104;

  double _columnMinWidth(TransparencyLedgerColumn col) {
    if (col.isBadge) return _badgeMin;
    if (col.isRight) return _moneyMin;
    return _textMin;
  }

  @override
  Widget build(BuildContext context) {
    final colCount = 1 + columns.length;
    final widths = <double>[
      _projectMin,
      for (final col in columns) _columnMinWidth(col),
    ];
    final tableWidth = widths.fold<double>(0, (sum, w) => sum + w);
    final viewport = MediaQuery.sizeOf(context).width;
    final sidePad = R.isTabletLandscape(context) ? 96.0 : 44.w;
    final available = (viewport - sidePad).clamp(0.0, double.infinity);
    final width = tableWidth < available ? available : tableWidth;

    // Stretch columns proportionally when there is extra room.
    final scale = width / tableWidth;
    final scaled = [for (final w in widths) w * scale];

    // Match web `.overflow-x-auto`: full-width when possible, else swipe horizontally.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      primary: false,
      physics: const BouncingScrollPhysics(),
      child: SizedBox(
        width: width,
        child: Table(
          columnWidths: {
            for (var i = 0; i < scaled.length; i++)
              i: FixedColumnWidth(scaled[i]),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              children: [
                _headerCell(projectHeading, alignRight: false),
                for (final col in columns)
                  _headerCell(col.heading, alignRight: col.isRight),
              ],
            ),
            for (final item in items)
              TableRow(
                children: [
                  _projectCell(item.project),
                  for (var i = 0; i < colCount - 1; i++)
                    _bodyCell(
                      i < item.cells.length
                          ? item.cells[i]
                          : const TransparencyLedgerCell(
                              value: '',
                              display: 'text',
                              align: 'left',
                              textColor: '',
                              bgColor: '',
                              radius: null,
                              highlighted: false,
                            ),
                      fallbackAlignRight:
                          i < columns.length ? columns[i].isRight : false,
                      fallbackIsBadge:
                          i < columns.length ? columns[i].isBadge : false,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _headerCell(String text, {required bool alignRight}) {
    return Container(
      padding: EdgeInsets.only(
        bottom: 12.h,
        right: alignRight ? 0 : 12.w,
        left: alignRight ? 12.w : 0,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: ApaColors.webInk, width: 3),
        ),
      ),
      child: Text(
        text.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: ApaFonts.inter(
          color: ApaColors.factLabel,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.44,
        ),
      ),
    );
  }

  Widget _projectCell(String text) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 15.h, 12.w, 15.h),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: ApaColors.factBorder),
        ),
      ),
      child: Text(
        text,
        style: ApaFonts.inter(
          color: ApaColors.webInk,
          fontSize: 15.5.sp,
          fontWeight: FontWeight.w600,
          height: 1.35,
        ),
      ),
    );
  }

  Widget _bodyCell(
    TransparencyLedgerCell cell, {
    required bool fallbackAlignRight,
    required bool fallbackIsBadge,
  }) {
    final right = cell.isRight || fallbackAlignRight;
    final asBadge = cell.isBadge || (fallbackIsBadge && !cell.isEmpty);
    return Container(
      padding: EdgeInsets.fromLTRB(
        right ? 12.w : 0,
        15.h,
        right ? 0 : 12.w,
        15.h,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: ApaColors.factBorder),
        ),
      ),
      child: Align(
        alignment: right ? Alignment.centerRight : Alignment.centerLeft,
        child: cell.isEmpty
            ? const SizedBox.shrink()
            : asBadge
                ? _LedgerBadge(cell: cell)
                : Text(
                    cell.value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: right ? TextAlign.right : TextAlign.left,
                    style: ApaFonts.inter(
                      color: ApaColors.webInk,
                      fontSize: 15.5.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
      ),
    );
  }
}

class _LedgerBadge extends StatelessWidget {
  const _LedgerBadge({required this.cell});

  final TransparencyLedgerCell cell;

  @override
  Widget build(BuildContext context) {
    final bg = _parseColor(
      cell.bgColor,
      fallback: cell.highlighted
          ? ApaColors.projectTypeNavy
          : ApaColors.mist,
    );
    final fg = _parseColor(
      cell.textColor,
      fallback: cell.highlighted ? ApaColors.white : ApaColors.webInk,
    );
    final radius = cell.radius ?? 999;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Text(
        cell.value.toUpperCase(),
        maxLines: 1,
        softWrap: false,
        style: ApaFonts.inter(
          color: fg,
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

Color _parseColor(String raw, {required Color fallback}) {
  final value = raw.trim();
  if (value.isEmpty) return fallback;
  var hex = value.replaceFirst('#', '');
  if (hex.length == 3) {
    hex = hex.split('').map((c) => '$c$c').join();
  }
  if (hex.length == 6) hex = 'FF$hex';
  final parsed = int.tryParse(hex, radix: 16);
  if (parsed == null) return fallback;
  return Color(parsed);
}

class _LedgerPagination extends StatelessWidget {
  const _LedgerPagination({
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
        children: [
          if (currentPage > 1) ...[
            _PagerButton(
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
            _PagerButton(
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
            _PagerButton(
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

class _PagerButton extends StatelessWidget {
  const _PagerButton({
    required this.label,
    required this.selected,
    required this.enabled,
    this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final filled = selected;
    return Material(
      color: filled ? ApaColors.webInk : Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: ApaColors.webInk, width: 2),
          ),
          child: Text(
            label,
            style: ApaFonts.inter(
              color: filled ? ApaColors.white : ApaColors.webInk,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
