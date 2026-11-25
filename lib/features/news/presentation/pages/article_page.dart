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
import '../../../shell/presentation/models/apa_nav_item.dart';

/// Single news article — matches live web single-post template.
class ArticlePage extends StatefulWidget {
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
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
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
      if (widget.article.id > 0)
        controller.loadContentDetails(
          widget.article.id,
          postType: ApaApiConfig.postTypePost,
          force: true,
        ),
    ]);
  }

  PostItem _resolvedArticle(PagesController? controller) {
    final id = widget.article.id;
    if (controller != null && id > 0) {
      final detailed = controller.detailsForPageId(id);
      if (detailed != null) return detailed;
      final newsPosts =
          controller.resolvedPageForShell(ApaShellPage.news)?.newsPosts ??
              const <PostItem>[];
      for (final post in newsPosts) {
        if (post.id == id) return post;
      }
    }
    return widget.article;
  }

  List<PostItem> _resolvedMoreStories(
    PagesController? controller,
    PostItem article,
  ) {
    final related = article.relatedNewsPosts;
    if (related.isNotEmpty) {
      return related.where((post) => post.id != article.id).take(3).toList();
    }
    final newsPosts =
        controller?.resolvedPageForShell(ApaShellPage.news)?.newsPosts;
    final source = (newsPosts != null && newsPosts.isNotEmpty)
        ? newsPosts
        : widget.moreStories;
    return source.where((post) => post.id != article.id).take(3).toList();
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
            final article = _resolvedArticle(pagesController);
            final moreStories =
                _resolvedMoreStories(pagesController, article);
            final labels = pagesController?.newsLabelsFor(article) ??
                article.newsLabels;
            final donate = pagesController?.donateCtaFor(article) ??
                article.donateCta;
            return _buildScrollView(
              context,
              article: article,
              moreStories: moreStories,
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
    required PostItem article,
    required List<PostItem> moreStories,
    required ContentLabels labels,
    required DonateCta donate,
    required double top,
  }) {
    final imageUrl = article.featuredImageUrl;
    final header = article.commonHeader;
    // Web only paints hero copy from CMS `common_header`. Empty/null fields
    // leave the hero as image-only (no post title / category fallback).
    final badge = (header['top_tag_line']?.toString() ?? '').trim();
    final headingOne = (header['heading_text_one']?.toString() ?? '').trim();
    final headingTwo = (header['heading_text_two']?.toString() ?? '').trim();
    final subtitle = (header['last_content']?.toString() ?? '').trim();

    final category = article.categoryLabel.trim();
    final author = article.authorName.trim();
    final quote = article.featuredQuote;
    final quoteAuthor = article.featuredQuoteAuthor;
    final factRows = article.contentFactRows;
    final bodyBlocks = _parseArticleBody(article.content.trim());

    final backLabel = labels.backLabel.isNotEmpty
        ? labels.backLabel.toUpperCase()
        : 'BACK TO NEWS';
    final factsTitle = labels.factsTitle.isNotEmpty
        ? labels.factsTitle
        : 'Quick facts';
    final relatedTitle = labels.relatedTitle.isNotEmpty
        ? labels.relatedTitle.toUpperCase()
        : 'MORE STORIES';
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
                      ApaAssets.articleHero,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Image.asset(
                    ApaAssets.articleHero,
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
                        if (badge.isNotEmpty) ...[
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
                              badge.toUpperCase(),
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
                        ],
                        if (headingOne.isNotEmpty || headingTwo.isNotEmpty)
                          Text.rich(
                            TextSpan(
                              children: [
                                if (headingOne.isNotEmpty)
                                  TextSpan(
                                    text: headingTwo.isNotEmpty
                                        ? '${headingOne.toUpperCase()}\n'
                                        : headingOne.toUpperCase(),
                                    style: ApaFonts.inter(
                                      color: ApaColors.white,
                                      fontSize: 34.sp,
                                      fontWeight: FontWeight.w700,
                                      height: 1.02,
                                      letterSpacing: -0.85,
                                    ),
                                  ),
                                if (headingTwo.isNotEmpty)
                                  TextSpan(
                                    text: headingTwo.toUpperCase(),
                                    style: ApaFonts.inter(
                                      color: ApaColors.webRed,
                                      fontSize: 34.sp,
                                      fontWeight: FontWeight.w700,
                                      height: 1.02,
                                      letterSpacing: -0.85,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        if (subtitle.isNotEmpty) ...[
                          SizedBox(height: 16.h),
                          Text(
                            subtitle,
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
                    onTap: widget.onBackToNews ??
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
                            category: category,
                            dateLabel: _formatDate(article.date),
                            author: author,
                            blocks: bodyBlocks,
                            quote: quote,
                            quoteAuthor: quoteAuthor,
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
                    _EditorBody(
                      category: category,
                      dateLabel: _formatDate(article.date),
                      author: author,
                      blocks: bodyBlocks,
                      quote: quote,
                      quoteAuthor: quoteAuthor,
                    ),
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
                  if (moreStories.isNotEmpty) ...[
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
                    SizedBox(height: 26.h),
                    ...moreStories.map(
                      (item) => Padding(
                        padding: EdgeInsets.only(bottom: 32.h),
                        child: _MoreStoryCard(
                          post: item,
                          onTap: () => _openStory(context, item),
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

  void _openStory(BuildContext context, PostItem post) {
    final remaining = _resolvedMoreStories(_pagesController, post);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ArticlePage(
          article: post,
          moreStories: remaining,
          onDonatePressed: widget.onDonatePressed,
          onBackToNews: widget.onBackToNews,
        ),
      ),
    );
  }

  /// Web date: `August 17, 2026`.
  String _formatDate(String dateStr) {
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return dateStr;
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}

/// Ordered body blocks matching web `.editor-content`.
enum _BlockKind { paragraph, heading, bullets, numbered }

class _BodyBlock {
  const _BodyBlock.paragraph(this.text)
      : kind = _BlockKind.paragraph,
        items = const [];

  const _BodyBlock.heading(this.text)
      : kind = _BlockKind.heading,
        items = const [];

  const _BodyBlock.bullets(this.items)
      : kind = _BlockKind.bullets,
        text = '';

  const _BodyBlock.numbered(this.items)
      : kind = _BlockKind.numbered,
        text = '';

  final _BlockKind kind;
  final String text;
  final List<String> items;
}

List<_BodyBlock> _parseArticleBody(String raw) {
  if (raw.isEmpty) return const [];
  final html = raw.replaceAll('\r\n', '\n');
  final blocks = <_BodyBlock>[];
  final tagRe = RegExp(
    r'<(h2|ul|ol|p)(\s[^>]*)?>[\s\S]*?</\1>',
    caseSensitive: false,
  );

  var cursor = 0;
  for (final match in tagRe.allMatches(html)) {
    _appendPlainParagraphs(blocks, html.substring(cursor, match.start));
    final tag = (match.group(1) ?? '').toLowerCase();
    final full = match.group(0) ?? '';
    if (tag == 'h2') {
      final inner = RegExp(
        r'<h2[^>]*>([\s\S]*?)</h2>',
        caseSensitive: false,
      ).firstMatch(full)?.group(1);
      final text = HtmlUtils.stripHtmlToText(inner ?? '').trim();
      if (text.isNotEmpty) blocks.add(_BodyBlock.heading(text));
    } else if (tag == 'ul') {
      final items = HtmlUtils.bulletsFromHtml(full);
      if (items.isNotEmpty) blocks.add(_BodyBlock.bullets(items));
    } else if (tag == 'ol') {
      final items = HtmlUtils.bulletsFromHtml(full);
      if (items.isNotEmpty) blocks.add(_BodyBlock.numbered(items));
    } else if (tag == 'p') {
      final inner = RegExp(
        r'<p[^>]*>([\s\S]*?)</p>',
        caseSensitive: false,
      ).firstMatch(full)?.group(1);
      final text = HtmlUtils.stripHtmlToText(inner ?? '').trim();
      if (text.isNotEmpty) blocks.add(_BodyBlock.paragraph(text));
    }
    cursor = match.end;
  }
  _appendPlainParagraphs(blocks, html.substring(cursor));
  return blocks;
}

void _appendPlainParagraphs(List<_BodyBlock> blocks, String chunk) {
  final plain = chunk.trim();
  if (plain.isEmpty) return;
  // WP theme turns blank-line-separated prose into <p> blocks.
  for (final part in plain.split(RegExp(r'\n\s*\n'))) {
    final text = HtmlUtils.stripHtmlToText(part)
        .replaceAll(RegExp(r'[ \t]*\n[ \t]*'), ' ')
        .trim();
    if (text.isNotEmpty) blocks.add(_BodyBlock.paragraph(text));
  }
}

class _EditorBody extends StatelessWidget {
  const _EditorBody({
    required this.category,
    required this.dateLabel,
    required this.author,
    required this.blocks,
    this.quote,
    this.quoteAuthor,
  });

  final String category;
  final String dateLabel;
  final String author;
  final List<_BodyBlock> blocks;
  final String? quote;
  final String? quoteAuthor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (category.isNotEmpty || dateLabel.isNotEmpty || author.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12.w,
              runSpacing: 6.h,
              children: [
                if (category.isNotEmpty)
                  Text(
                    category.toUpperCase(),
                    style: ApaFonts.inter(
                      color: ApaColors.webRed,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.4,
                    ),
                  ),
                if (category.isNotEmpty &&
                    (dateLabel.isNotEmpty || author.isNotEmpty))
                  Text(
                    '·',
                    style: ApaFonts.inter(
                      color: ApaColors.factLabel,
                      fontSize: 14.sp,
                    ),
                  ),
                if (dateLabel.isNotEmpty)
                  Text(
                    dateLabel,
                    style: ApaFonts.inter(
                      color: ApaColors.factLabel,
                      fontSize: 14.sp,
                    ),
                  ),
                if (dateLabel.isNotEmpty && author.isNotEmpty)
                  Text(
                    '·',
                    style: ApaFonts.inter(
                      color: ApaColors.factLabel,
                      fontSize: 14.sp,
                    ),
                  ),
                if (author.isNotEmpty)
                  Text(
                    author,
                    style: ApaFonts.inter(
                      color: ApaColors.factLabel,
                      fontSize: 14.sp,
                    ),
                  ),
              ],
            ),
          ),
        ...blocks.map(_buildBlock),
        if (quote != null && quote!.trim().isNotEmpty)
          _FeaturedQuote(
            quote: quote!.trim(),
            author: quoteAuthor?.trim() ?? '',
          ),
      ],
    );
  }

  Widget _buildBlock(_BodyBlock block) {
    switch (block.kind) {
      case _BlockKind.paragraph:
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Text(
            block.text,
            style: ApaFonts.inter(
              color: ApaColors.webInk,
              fontSize: 16.sp,
              height: 1.65,
            ),
          ),
        );
      case _BlockKind.heading:
        return Padding(
          padding: EdgeInsets.only(top: 20.h, bottom: 12.h),
          child: Text(
            block.text,
            style: ApaFonts.inter(
              color: ApaColors.webInk,
              fontSize: 34.sp,
              fontWeight: FontWeight.w700,
              height: 1.15,
              letterSpacing: -0.5,
            ),
          ),
        );
      case _BlockKind.bullets:
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Column(
            children: block.items
                .map((item) => ApaEditorBulletItem(text: item))
                .toList(),
          ),
        );
      case _BlockKind.numbered:
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Column(
            children: block.items.asMap().entries.map((e) {
              return ApaNumberedItem(
                index: e.key + 1,
                text: e.value,
                indexColor: ApaColors.projectTypeNavy,
                textColor: ApaColors.webInk,
              );
            }).toList(),
          ),
        );
    }
  }
}

class _FeaturedQuote extends StatelessWidget {
  const _FeaturedQuote({required this.quote, required this.author});

  final String quote;
  final String author;

  @override
  Widget build(BuildContext context) {
    final display = quote.startsWith('“') || quote.startsWith('"')
        ? quote
        : '“$quote”';

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 16.h),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      decoration: const BoxDecoration(
        color: ApaColors.mist,
        border: Border(
          left: BorderSide(color: ApaColors.webRed, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            display,
            style: ApaFonts.inter(
              color: ApaColors.webInk,
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          if (author.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              '— ${author.toUpperCase()}',
              style: ApaFonts.inter(
                color: ApaColors.projectTypeNavy,
                fontSize: 13.6.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.08,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
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

class _MoreStoryCard extends StatelessWidget {
  const _MoreStoryCard({required this.post, this.onTap});

  final PostItem post;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final category = post.categoryLabel.trim();
    final excerpt = _plainExcerpt(post);
    final featured = post.featuredImageUrl?.trim() ?? '';
    final imageUrl =
        featured.isNotEmpty ? featured : ApaAssets.webNewsCardFallbackImage;

    return Material(
      color: ApaColors.white,
      elevation: 2,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(24.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: const Color(0xFFF3F4F6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 240,
                width: double.infinity,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    ApaAssets.newsFeatured,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (category.isNotEmpty)
                      Text(
                        category.toUpperCase(),
                        style: ApaFonts.inter(
                          color: ApaColors.webRed,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.08,
                          height: 1.2,
                        ),
                      ),
                    if (category.isNotEmpty) SizedBox(height: 12.h),
                    Text(
                      post.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: ApaFonts.inter(
                        color: ApaColors.webInk,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    if (excerpt.isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      Text(
                        excerpt,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: ApaFonts.inter(
                          color: ApaColors.factLabel,
                          fontSize: 15.sp,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _plainExcerpt(PostItem post) {
  final raw = post.excerpt.trim().isNotEmpty
      ? post.excerpt
      : (post.acfFields['card_content']?.toString() ?? post.content);
  return HtmlUtils.stripHtmlToText(raw).trim();
}
