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
import '../../../../core/widgets/apa_svg_icon.dart';
import '../../../../data/models/post/content_detail_models.dart';
import '../../../../data/models/post/post_item_extensions.dart';
import '../../../../data/models/post/post_model.dart';
import '../../../shell/presentation/controllers/pages_controller.dart';

/// Single project detail — uses `get-post-details?post_type=projects`.
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

  @override
  Widget build(BuildContext context) {
    final pagesController = _pagesController;
    final top = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: ApaColors.white,
        body: RefreshIndicator(
          color: ApaColors.primaryRed,
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
    final factRows = project.contentFactRows;
    final contentHtml = project.content.trim().isNotEmpty
        ? project.content.trim()
        : (project.acfFields['card_content']?.toString() ?? '');
    final bullets = HtmlUtils.bulletsFromHtml(contentHtml);
    final paragraphs = _extractParagraphs(contentHtml);
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
    final donateTitle =
        donate.title.isNotEmpty ? donate.title : 'Help fund the next one.';
    final donateText = donate.text.isNotEmpty
        ? donate.text
        : 'Every gift goes straight to project funds, not overhead.';
    final donateButton = donate.buttonLabel.isNotEmpty
        ? '${donate.buttonLabel.toUpperCase()} →'
        : 'DONATE →';
    final logoUrl = _pagesController?.siteLogoUrl;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            height: R.isTabletLandscape(context)
                ? (MediaQuery.sizeOf(context).height * 0.52)
                    .clamp(340.0, 460.0)
                : 520.h + top,
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
                ColoredBox(color: Colors.black.withValues(alpha: 0.7)),
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      R.isTabletLandscape(context) ? 48 : 24.w,
                      24.h,
                      R.isTabletLandscape(context) ? 48 : 24.w,
                      40.h,
                    ),
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
                                  errorBuilder: (context, error, stackTrace) => Image.asset(
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
                              horizontal: 13.w,
                              vertical: 7.h,
                            ),
                            decoration: BoxDecoration(
                              color: ApaColors.locationYellowFill,
                              borderRadius: BorderRadius.circular(9999),
                              border: Border.all(color: ApaColors.white20),
                            ),
                            child: Text(
                              typeLabel.toUpperCase(),
                              style: ApaFonts.inter(
                                color: ApaColors.locationYellow,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        SizedBox(height: 16.h),
                        Text(
                          project.title,
                          style: ApaFonts.inter(
                            color: ApaColors.white,
                            fontSize: 34.sp,
                            fontWeight: FontWeight.w800,
                            height: 40 / 34,
                            letterSpacing: -0.5,
                          ),
                        ),
                        if (tagLine.isNotEmpty) ...[
                          SizedBox(height: 12.h),
                          Text(
                            tagLine,
                            style: ApaFonts.inter(
                              color: ApaColors.white80,
                              fontSize: 15.sp,
                              height: 22 / 15,
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
            maxWidth: 760,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                R.isTabletLandscape(context) ? 48 : 24.w,
                40.h,
                R.isTabletLandscape(context) ? 48 : 24.w,
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
                          size: 16,
                          color: ApaColors.primaryRed,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          backLabel,
                          style: ApaFonts.inter(
                            color: ApaColors.primaryRed,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 28.h),
                  ...paragraphs.map(
                    (p) => Padding(
                      padding: EdgeInsets.only(bottom: 20.h),
                      child: Text(
                        p,
                        style: ApaFonts.inter(
                          color: ApaColors.gray700,
                          fontSize: 16.sp,
                          height: 24 / 16,
                        ),
                      ),
                    ),
                  ),
                  if (bullets.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    ...bullets.map(
                      (b) => Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '•  ',
                              style: ApaFonts.inter(
                                color: ApaColors.black,
                                fontSize: 15.sp,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                b,
                                style: ApaFonts.inter(
                                  color: ApaColors.gray700,
                                  fontSize: 15.sp,
                                  height: 22.5 / 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (factRows.isNotEmpty) ...[
                    SizedBox(height: 32.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: ApaColors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: ApaColors.gray200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            factsTitle,
                            style: ApaFonts.inter(
                              color: ApaColors.black,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          ...factRows.map(
                            (row) => Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 120.w,
                                    child: Text(
                                      row.label,
                                      style: ApaFonts.inter(
                                        color: ApaColors.gray500,
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      row.text,
                                      style: ApaFonts.inter(
                                        color: ApaColors.black,
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 32.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 32.w,
                      vertical: 36.h,
                    ),
                    decoration: BoxDecoration(
                      color: ApaColors.black,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      children: [
                        Text(
                          donateTitle,
                          textAlign: TextAlign.center,
                          style: ApaFonts.inter(
                            color: ApaColors.white,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w800,
                            height: 30 / 24,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          donateText,
                          textAlign: TextAlign.center,
                          style: ApaFonts.inter(
                            color: ApaColors.white80,
                            fontSize: 14.sp,
                            height: 20 / 14,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: widget.onDonatePressed,
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              child: Text(
                                donateButton,
                                style: ApaFonts.inter(
                                  color: ApaColors.primaryRed,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (moreProjects.isNotEmpty) ...[
                    SizedBox(height: 48.h),
                    Text(
                      relatedTitle,
                      style: ApaFonts.inter(
                        color: ApaColors.black,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 24.h),
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

  List<String> _extractParagraphs(String html) {
    if (html.isEmpty) return const [];
    final matches = RegExp(
      r'<p[^>]*>(.*?)</p>',
      caseSensitive: false,
      dotAll: true,
    ).allMatches(html);

    if (matches.isEmpty) {
      final stripped = HtmlUtils.stripHtmlToText(html).trim();
      return stripped.isEmpty ? const [] : [stripped];
    }

    return matches
        .map((m) => HtmlUtils.stripHtmlToText(m.group(1) ?? '').trim())
        .where((s) => s.isNotEmpty)
        .toList();
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
    final imageUrl = project.featuredImageUrl;
    final type = project.projectTypeLabel ?? project.categoryLabel;
    final body = project.tagLine ??
        HtmlUtils.stripHtmlToText(project.excerpt).trim();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: ApaColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: ApaColors.gray200),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 348 / 200,
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        ApaAssets.projectsHero,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      ApaAssets.projectsHero,
                      fit: BoxFit.cover,
                    ),
            ),
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (type.isNotEmpty)
                    Text(
                      type.toUpperCase(),
                      style: ApaFonts.inter(
                        color: ApaColors.navy,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  if (type.isNotEmpty) SizedBox(height: 8.h),
                  Text(
                    project.title,
                    style: ApaFonts.inter(
                      color: ApaColors.black,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      height: 26 / 20,
                    ),
                  ),
                  if (body.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Text(
                      body,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: ApaFonts.inter(
                        color: ApaColors.gray600,
                        fontSize: 14.sp,
                        height: 20 / 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
