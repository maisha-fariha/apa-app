import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/apa_assets.dart';
import '../../../../core/theme/apa_colors.dart';
import '../../../../core/theme/apa_fonts.dart';
import '../../../../core/utils/html_utils.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/apa_svg_icon.dart';
import '../../../../data/models/post/post_model.dart';
import '../../../../data/models/post/post_item_extensions.dart';

/// Article / Read More page — Figma frame `14:811`.
///
/// Pushed route (no bottom nav).
class ArticlePage extends StatelessWidget {
  const ArticlePage({
    super.key,
    required this.article,
    this.moreStories = const [],
    this.onDonatePressed,
    this.onBackToNews,
  });

  final PostItem article;
  final List<PostItem> moreStories;
  final VoidCallback? onDonatePressed;
  final VoidCallback? onBackToNews;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final imageUrl = article.featuredImageUrl;
    final category = article.categoryLabel;
    final location = article.location ?? '';
    final author = article.authorName;
    final quote = article.featuredQuote;
    final quoteAuthor = article.featuredQuoteAuthor;
    final facts = article.quickFacts;
    final contentHtml = article.content.trim();
    final bullets = HtmlUtils.bulletsFromHtml(contentHtml);
    final paragraphs = _extractParagraphs(contentHtml);

    final metaParts = <String>[
      if (category.isNotEmpty) category.toUpperCase(),
      if (article.date.isNotEmpty) _formatDate(article.date),
      if (location.isNotEmpty) location.toUpperCase(),
    ];
    final metaLine = metaParts.join('  ·  ');

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: ApaColors.white,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Hero
            SliverToBoxAdapter(
              child: SizedBox(
                height: R.isTabletLandscape(context)
                    ? (MediaQuery.sizeOf(context).height * 0.52)
                        .clamp(340.0, 460.0)
                    : 620.h + top,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (imageUrl != null && imageUrl.isNotEmpty)
                      Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset(
                          ApaAssets.articleHero,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Image.asset(
                        ApaAssets.articleHero,
                        fit: BoxFit.cover,
                      ),
                    ColoredBox(
                      color: Colors.black.withValues(alpha: 0.7),
                    ),
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          R.isTabletLandscape(context) ? 48 : 24.w,
                          24.h,
                          R.isTabletLandscape(context) ? 48 : 24.w,
                          40.h,
                        ),
                        child: ApaPageWidth(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Image.asset(
                                  ApaAssets.apaLogo,
                                  width: 180.w,
                                  height: 67.5.h,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const Spacer(),
                              if (category.isNotEmpty)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 13.w,
                                    vertical: 7.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ApaColors.locationYellowFill,
                                    borderRadius: BorderRadius.circular(9999),
                                    border:
                                        Border.all(color: ApaColors.white20),
                                  ),
                                  child: Text(
                                    category.toUpperCase(),
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
                                article.title,
                                style: ApaFonts.inter(
                                  color: ApaColors.white,
                                  fontSize: 34.sp,
                                  fontWeight: FontWeight.w800,
                                  height: 40 / 34,
                                  letterSpacing: -0.5,
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
            ),

            // Body
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
                      // Back button
                      InkWell(
                        onTap: onBackToNews ??
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
                              'BACK TO NEWS',
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
                      SizedBox(height: 20.h),

                      // Meta line
                      if (metaLine.isNotEmpty)
                        Text(
                          metaLine,
                          style: ApaFonts.inter(
                            color: ApaColors.gray500,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      if (author.isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        Text(
                          'By $author',
                          style: ApaFonts.inter(
                            color: ApaColors.gray600,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                      SizedBox(height: 28.h),

                      // Content paragraphs
                      ...paragraphs.map((p) => Padding(
                            padding: EdgeInsets.only(bottom: 20.h),
                            child: _BodyText(p),
                          )),

                      // Bullets if present
                      if (bullets.isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        ...bullets.map((b) => _DotItem(b)),
                      ],

                      // Featured quote
                      if (quote != null && quote.isNotEmpty) ...[
                        SizedBox(height: 24.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ColoredBox(
                              color: ApaColors.primaryRed,
                              child: SizedBox(width: 3.w, height: 100.h),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '"$quote"',
                                    style: ApaFonts.inter(
                                      color: ApaColors.gray800,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FontStyle.italic,
                                      height: 26 / 18,
                                    ),
                                  ),
                                  if (quoteAuthor != null &&
                                      quoteAuthor.isNotEmpty) ...[
                                    SizedBox(height: 8.h),
                                    Text(
                                      '— $quoteAuthor',
                                      style: ApaFonts.inter(
                                        color: ApaColors.gray500,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Quick facts
                      if (facts.isNotEmpty) ...[
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
                                'Project quick facts',
                                style: ApaFonts.inter(
                                  color: ApaColors.black,
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 20.h),
                              ...facts.entries.map(
                                (e) => _FactRow(
                                  label: _humanizeKey(e.key),
                                  value: e.value,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Donate CTA
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
                              'Help fund the next stretch',
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
                              'Every gift moves phase one forward in Sud.',
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
                                onTap: onDonatePressed,
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(vertical: 8.h),
                                  child: Text(
                                    'DONATE →',
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

                      // More stories
                      if (moreStories.isNotEmpty) ...[
                        SizedBox(height: 48.h),
                        Text(
                          'MORE STORIES',
                          style: ApaFonts.inter(
                            color: ApaColors.black,
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        ...moreStories.map(
                          (post) => Padding(
                            padding: EdgeInsets.only(bottom: 24.h),
                            child: _MoreStoryCard(
                              post: post,
                              onTap: () => _openStory(context, post),
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
        ),
      ),
    );
  }

  void _openStory(BuildContext context, PostItem post) {
    final remaining = moreStories.where((p) => p.id != post.id).toList();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ArticlePage(
          article: post,
          moreStories: remaining,
          onDonatePressed: onDonatePressed,
          onBackToNews: onBackToNews,
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

  String _formatDate(String dateStr) {
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return dateStr;
    const months = [
      'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
      'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER',
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }

  String _humanizeKey(String key) {
    return key
        .replaceAll('_', ' ')
        .replaceFirst(RegExp(r'^.'), key[0].toUpperCase());
  }
}

class _MoreStoryCard extends StatelessWidget {
  const _MoreStoryCard({required this.post, this.onTap});

  final PostItem post;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final imageUrl = post.featuredImageUrl;
    final category = post.categoryLabel.toUpperCase();
    final excerpt = post.excerpt.isNotEmpty
        ? post.excerpt
        : HtmlUtils.stripHtmlToText(post.content).trim();

    return GestureDetector(
      onTap: onTap,
      child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: ApaColors.gray200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 340 / 256,
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) =>
                        Image.asset(
                      ApaAssets.newsCommunity,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  )
                : Image.asset(
                    ApaAssets.newsCommunity,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(32.w, 28.h, 32.w, 28.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (category.isNotEmpty)
                  Text(
                    category,
                    style: ApaFonts.inter(
                      color: ApaColors.navy,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                if (category.isNotEmpty) SizedBox(height: 12.h),
                Text(
                  post.title,
                  style: ApaFonts.inter(
                    color: ApaColors.black,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    height: 26 / 20,
                  ),
                ),
                if (excerpt.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Text(
                    excerpt,
                    maxLines: 2,
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

class _BodyText extends StatelessWidget {
  const _BodyText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: ApaFonts.inter(
        color: ApaColors.gray800,
        fontSize: 16.sp,
        height: 26 / 16,
      ),
    );
  }
}

class _DotItem extends StatelessWidget {
  const _DotItem(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 8.h),
            width: 8.w,
            height: 8.w,
            decoration: const BoxDecoration(
              color: ApaColors.navy,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: ApaFonts.inter(
                color: ApaColors.gray800,
                fontSize: 15.sp,
                height: 22 / 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Text(
            label,
            style: ApaFonts.inter(
              color: ApaColors.gray500,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: ApaFonts.inter(
              color: ApaColors.nearBlack,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
