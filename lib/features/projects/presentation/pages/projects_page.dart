import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../data/models/post/post_model.dart';
import '../../../../data/models/post/post_item_extensions.dart';
import '../../../../core/constants/apa_assets.dart';
import '../../../../core/constants/apa_shell_insets.dart';
import '../../../../core/theme/apa_colors.dart';
import '../../../../core/theme/apa_fonts.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/html_utils.dart';
import '../../../../core/widgets/apa_shared_widgets.dart';

/// Projects Page — Figma frame `6:203`.
class ProjectsPage extends StatelessWidget {
  const ProjectsPage({
    super.key,
    this.scrollController,
    this.page,
    this.onFundPressed,
    this.imageUrl,
  });

  final ScrollController? scrollController;
  final PostItem? page;
  final VoidCallback? onFundPressed;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final navBottomPad = ApaShellInsets.contentBottom(context);
    final commonHeader = page?.commonHeader ?? const <String, dynamic>{};
    final relatedProjects = page?.relatedProjects ?? const <PostItem>[];

    final badge = commonHeader['top_tag_line']?.toString() ?? '';
    final headingOne = (commonHeader['heading_text_one']?.toString() ?? '').trim();
    final headingTwo = (commonHeader['heading_text_two']?.toString() ?? '').trim();
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

    final sections = relatedProjects.take(3).toList(growable: false);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ColoredBox(
        color: ApaColors.white,
        child: CustomScrollView(
          controller: scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: ApaHeroHeader(
                imageAsset: ApaAssets.projectsHero,
                imageUrl: imageUrl,
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
                    R.isTabletLandscape(context) ? 48 : 24.w,
                    48.h,
                    R.isTabletLandscape(context) ? 48 : 24.w,
                    navBottomPad,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (R.isTabletLandscape(context) && sections.length >= 3)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _ProjectSection(
                                label: sections[0].projectTypeLabel ?? '',
                                title: sections[0].title,
                                body: sections[0].tagLine ?? '',
                                bullets: sections[0].contentBullets,
                              ),
                            ),
                            SizedBox(width: 28),
                            Expanded(
                              child: _ProjectSection(
                                label: sections[1].projectTypeLabel ?? '',
                                title: sections[1].title,
                                body: sections[1].tagLine ?? '',
                                bullets: sections[1].contentBullets,
                              ),
                            ),
                            SizedBox(width: 28),
                            Expanded(
                              child: _ProjectSection(
                                label: sections[2].projectTypeLabel ?? '',
                                title: sections[2].title,
                                body: sections[2].tagLine ?? '',
                                bullets: sections[2].contentBullets,
                              ),
                            ),
                          ],
                        )
                      else ...sections
                          .asMap()
                          .entries
                          .map((e) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _ProjectSection(
                                    label: e.value.projectTypeLabel ?? '',
                                    title: e.value.title,
                                    body: e.value.tagLine ?? '',
                                    bullets: e.value.contentBullets,
                                  ),
                                  if (e.key != sections.length - 1)
                                    const _BlackSeparator(),
                                ],
                              )),
                      const _BlackSeparator(),
                      _ProjectsFooterHtml(html: page?.footerHtml),
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
        ),
      ),
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
    required this.label,
    required this.title,
    required this.body,
    required this.bullets,
  });

  final String label;
  final String title;
  final String body;
  final List<String> bullets;

  @override
  Widget build(BuildContext context) {
    return Column(
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
