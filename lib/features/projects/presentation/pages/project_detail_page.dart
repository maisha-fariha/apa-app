import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constants/apa_assets.dart';
import '../../../../core/network/apa_api_config.dart';
import '../../../../core/theme/apa_colors.dart';
import '../../../../core/theme/apa_fonts.dart';
import '../../../../core/utils/html_utils.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/apa_shared_widgets.dart';
import '../../../../core/widgets/apa_svg_icon.dart';
import '../../../../data/models/post/content_detail_models.dart';
import '../../../../data/models/post/post_item_extensions.dart';
import '../../../../data/models/post/post_model.dart';
import '../../../shell/presentation/controllers/pages_controller.dart';

/// Single project detail — matches live web `single-projects`.
class ProjectDetailPage extends StatefulWidget {
  const ProjectDetailPage({
    super.key,
    required this.project,
    this.moreProjects = const [],
    this.onDonatePressed,
    this.onBackToProjects,
  });

  final PostItem project;
  final List<PostItem> moreProjects;
  final VoidCallback? onDonatePressed;
  final VoidCallback? onBackToProjects;

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  PagesController? get _pagesController {
    if (!Get.isRegistered<PagesController>()) return null;
    return Get.find<PagesController>();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshLatest();
    });
  }

  Future<void> _refreshLatest() async {
    final controller = _pagesController;
    if (controller == null) return;
    await Future.wait<void>([
      controller.loadGlobalSettings(),
      if (widget.project.id > 0)
        controller.loadContentDetails(
          widget.project.id,
          postType: ApaApiConfig.postTypeProjects,
          force: true,
        ),
    ]);
  }

  PostItem _resolvedProject(PagesController? controller) {
    final id = widget.project.id;
    if (controller != null && id > 0) {
      final detailed = controller.detailsForPageId(id);
      if (detailed != null) return detailed;
    }
    return widget.project;
  }

  List<PostItem> _resolvedMoreProjects(PostItem project) {
    final related = project.relatedProjects
        .where((item) => item.id != project.id)
        .take(3)
        .toList();
    if (related.isNotEmpty) return related;
    return widget.moreProjects
        .where((item) => item.id != project.id)
        .take(3)
        .toList();
  }

  /// Web prepends taxonomy Type when not already present in `project_details`.
  List<ContentFactRow> _factRows(PostItem project, ContentLabels labels) {
    final rows = List<ContentFactRow>.from(project.contentFactRows);
    final typeValue = (project.projectTypeLabel ?? '').trim();
    if (typeValue.isEmpty) return rows;

    final alreadyHasType = rows.any(
      (row) => row.label.trim().toLowerCase() == 'type',
    );
    if (alreadyHasType) return rows;

    final typeLabel =
        labels.typeLabel.trim().isNotEmpty ? labels.typeLabel.trim() : 'Type';
    return [
      ContentFactRow(label: typeLabel, text: typeValue),
      ...rows,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final pagesController = _pagesController;
    final top = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: ApaColors.white,
        body: RefreshIndicator(
          color: ApaColors.webRed,
          onRefresh: _refreshLatest,
          child: Obx(() {
            pagesController?.pageDetailsById.length;
            pagesController?.globalSettings.value;
            final project = _resolvedProject(pagesController);
            final more = _resolvedMoreProjects(project);
            final labels = pagesController?.projectLabelsFor(project) ??
                project.projectLabels;
            final donate =
                pagesController?.donateCtaFor(project) ?? project.donateCta;
            return _buildScrollView(
              context,
              project: project,
              moreProjects: more,
              labels: labels,
              donate: donate,
              top: top,
            );
          }),
        ),
      ),
    );
  }

  Widget _buildScrollView(
    BuildContext context, {
    required PostItem project,
    required List<PostItem> moreProjects,
    required ContentLabels labels,
    required DonateCta donate,
    required double top,
  }) {
    final imageUrl = project.featuredImageUrl;
    final typeLabel = project.projectTypeLabel ?? project.categoryLabel;
    final factRows = _factRows(project, labels);
    final rich = project.projectCardContent;
    final paragraphs = _extractParagraphs(
      project.content.trim().isNotEmpty
          ? project.content.trim()
          : (project.acfFields['card_content']?.toString() ?? ''),
    );
    final tagLine = project.tagLine ?? '';

    final backLabel = labels.backLabel.isNotEmpty
        ? labels.backLabel.toUpperCase()
        : 'BACK TO PROJECTS';
    final factsTitle = labels.factsTitle.isNotEmpty
        ? labels.factsTitle
        : 'Project quick facts';
    final relatedTitle = labels.relatedTitle.isNotEmpty
        ? labels.relatedTitle.toUpperCase()
        : 'MORE PROJECTS';
    final donateTitle = (donate.title.isNotEmpty
            ? donate.title
            : 'Help fund the next one.')
        .toUpperCase();
    final donateText = donate.text.isNotEmpty
        ? donate.text
        : 'Every gift goes straight to project funds, not overhead.';
    final donateButton = donate.buttonLabel.isNotEmpty
        ? donate.buttonLabel.toUpperCase()
        : 'DONATE';
    final logoUrl = _pagesController?.siteLogoUrl;
    final sidePad = R.isTabletLandscape(context) ? 48.0 : 22.w;
    final wide = MediaQuery.sizeOf(context).width >= 900;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            height: R.isTabletLandscape(context)
                ? (MediaQuery.sizeOf(context).height * 0.52)
                    .clamp(340.0, 520.0)
                : 420.h + top,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (imageUrl != null && imageUrl.isNotEmpty)
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      ApaAssets.projectsHero,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Image.asset(
                    ApaAssets.projectsHero,
                    fit: BoxFit.cover,
                  ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Color(0xCC000000),
                        Color(0x99000000),
                        Color(0xB3000000),
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(sidePad, 24.h, sidePad, 40.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: logoUrl != null && logoUrl.isNotEmpty
                              ? Image.network(
                                  logoUrl,
                                  width: 180.w,
                                  height: 67.5.h,
                                  fit: BoxFit.contain,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          Image.asset(
                                    ApaAssets.apaLogo,
                                    width: 180.w,
                                    height: 67.5.h,
                                    fit: BoxFit.contain,
                                  ),
                                )
                              : Image.asset(
                                  ApaAssets.apaLogo,
                                  width: 180.w,
                                  height: 67.5.h,
                                  fit: BoxFit.contain,
                                ),
                        ),
                        const Spacer(),
                        if (typeLabel.isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: ApaColors.locationYellowFill,
                              borderRadius: BorderRadius.circular(9999),
                              border: Border.all(
                                color: ApaColors.locationYellowBorder,
                              ),
                            ),
                            child: Text(
                              typeLabel.toUpperCase(),
                              style: ApaFonts.inter(
                                color: ApaColors.locationYellow,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.65,
                                height: 1.2,
                              ),
                            ),
                          ),
                        SizedBox(height: 16.h),
                        Text(
                          project.title.toUpperCase(),
                          style: ApaFonts.inter(
                            color: ApaColors.white,
                            fontSize: 34.sp,
                            fontWeight: FontWeight.w700,
                            height: 1.02,
                            letterSpacing: -0.85,
                          ),
                        ),
                        if (tagLine.isNotEmpty) ...[
                          SizedBox(height: 16.h),
                          Text(
                            tagLine,
                            style: ApaFonts.inter(
                              color: ApaColors.white80,
                              fontSize: 18.sp,
                              height: 1.55,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: ApaPageWidth(
            maxWidth: 1100,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                sidePad,
                56.h,
                sidePad,
                48.h + MediaQuery.paddingOf(context).bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: widget.onBackToProjects ??
                        () => Navigator.of(context).pop(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const ApaSvgIcon(
                          assetPath: ApaAssets.icBack,
                          size: 14,
                          color: ApaColors.webRed,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          backLabel,
                          style: ApaFonts.inter(
                            color: ApaColors.webRed,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),
                  if (wide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 11,
                          child: _EditorBody(
                            paragraphs: paragraphs,
                            rich: rich,
                          ),
                        ),
                        SizedBox(width: 56.w),
                        Expanded(
                          flex: 10,
                          child: _AsideColumn(
                            factsTitle: factsTitle,
                            factRows: factRows,
                            donateTitle: donateTitle,
                            donateText: donateText,
                            donateButton: donateButton,
                            onDonatePressed: widget.onDonatePressed,
                          ),
                        ),
                      ],
                    )
                  else ...[
                    _EditorBody(paragraphs: paragraphs, rich: rich),
                    SizedBox(height: 34.h),
                    _AsideColumn(
                      factsTitle: factsTitle,
                      factRows: factRows,
                      donateTitle: donateTitle,
                      donateText: donateText,
                      donateButton: donateButton,
                      onDonatePressed: widget.onDonatePressed,
                    ),
                  ],
                  if (moreProjects.isNotEmpty) ...[
                    SizedBox(height: 48.h),
                    Container(
                      height: 2,
                      color: ApaColors.webInk.withValues(alpha: 0.1),
                    ),
                    SizedBox(height: 40.h),
                    Text(
                      relatedTitle,
                      style: ApaFonts.inter(
                        color: ApaColors.webInk,
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                        letterSpacing: -0.48,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    ...moreProjects.map(
                      (item) => Padding(
                        padding: EdgeInsets.only(bottom: 24.h),
                        child: _MoreProjectCard(
                          project: item,
                          onTap: () => _openProject(context, item),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openProject(BuildContext context, PostItem project) {
    final remaining = _resolvedMoreProjects(project);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProjectDetailPage(
          project: project,
          moreProjects: remaining,
          onDonatePressed: widget.onDonatePressed,
          onBackToProjects: widget.onBackToProjects,
        ),
      ),
    );
  }

  /// Only real `<p>` blocks — never flatten lists into fake paragraphs.
  List<String> _extractParagraphs(String html) {
    if (html.isEmpty) return const [];
    final matches = RegExp(
      r'<p[^>]*>(.*?)</p>',
      caseSensitive: false,
      dotAll: true,
    ).allMatches(html);

    return matches
        .map((m) => HtmlUtils.stripHtmlToText(m.group(1) ?? '').trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }
}

class _EditorBody extends StatelessWidget {
  const _EditorBody({
    required this.paragraphs,
    required this.rich,
  });

  final List<String> paragraphs;
  final ProjectCardContent rich;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...paragraphs.map(
          (p) => Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: Text(
              p,
              style: ApaFonts.inter(
                color: ApaColors.webInk,
                fontSize: 15.5.sp,
                height: 1.55,
              ),
            ),
          ),
        ),
        if (rich.bullets.isNotEmpty)
          ...rich.bullets.map((b) => ApaEditorBulletItem(text: b)),
        if (rich.numbered.isNotEmpty) ...[
          if (rich.bullets.isNotEmpty) SizedBox(height: 4.h),
          ...rich.numbered.asMap().entries.map(
                (e) => ApaNumberedItem(
                  index: e.key + 1,
                  text: e.value,
                  indexColor: ApaColors.projectTypeNavy,
                  textColor: ApaColors.webInk,
                ),
              ),
        ],
        if (rich.callouts.isNotEmpty)
          ...rich.callouts.map((c) => ApaRedBorderCallout(text: c)),
      ],
    );
  }
}

class _AsideColumn extends StatelessWidget {
  const _AsideColumn({
    required this.factsTitle,
    required this.factRows,
    required this.donateTitle,
    required this.donateText,
    required this.donateButton,
    this.onDonatePressed,
  });

  final String factsTitle;
  final List<ContentFactRow> factRows;
  final String donateTitle;
  final String donateText;
  final String donateButton;
  final VoidCallback? onDonatePressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (factRows.isNotEmpty) ...[
          _QuickFactsCard(title: factsTitle, rows: factRows),
          SizedBox(height: 24.h),
        ],
        _DonateCtaCard(
          title: donateTitle,
          text: donateText,
          buttonLabel: donateButton,
          onPressed: onDonatePressed,
        ),
      ],
    );
  }
}

class _QuickFactsCard extends StatelessWidget {
  const _QuickFactsCard({required this.title, required this.rows});

  final String title;
  final List<ContentFactRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: ApaColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: ApaColors.factBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: ApaFonts.inter(
              color: ApaColors.webInk,
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
          SizedBox(height: 16.h),
          ...rows.asMap().entries.map((entry) {
            final row = entry.value;
            final isLast = entry.key == rows.length - 1;
            return Container(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : const Border(
                        bottom: BorderSide(color: ApaColors.factBorder),
                      ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(
                      row.label,
                      style: ApaFonts.inter(
                        color: ApaColors.factLabel,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Flexible(
                    child: Text(
                      row.text,
                      textAlign: TextAlign.right,
                      style: ApaFonts.inter(
                        color: ApaColors.webInk,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _DonateCtaCard extends StatelessWidget {
  const _DonateCtaCard({
    required this.title,
    required this.text,
    required this.buttonLabel,
    this.onPressed,
  });

  final String title;
  final String text;
  final String buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: ApaColors.webInk,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: ApaFonts.inter(
              color: ApaColors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              height: 1.15,
              letterSpacing: -0.24,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            text,
            style: ApaFonts.inter(
              color: ApaColors.mist,
              fontSize: 14.sp,
              height: 1.45,
            ),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            height: 60.h,
            child: Material(
              color: ApaColors.webInk,
              borderRadius: BorderRadius.circular(999),
              child: InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(999),
                child: Center(
                  child: Text(
                    buttonLabel,
                    style: ApaFonts.inter(
                      color: ApaColors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreProjectCard extends StatelessWidget {
  const _MoreProjectCard({
    required this.project,
    this.onTap,
  });

  final PostItem project;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: ApaColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: ApaColors.factBorder),
        ),
        child: Text(
          project.title,
          style: ApaFonts.inter(
            color: ApaColors.webInk,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}
