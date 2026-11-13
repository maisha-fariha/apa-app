import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constants/apa_assets.dart';
import '../../../../core/constants/apa_shell_insets.dart';
import '../../../../core/network/connectivity_controller.dart';
import '../../../../core/theme/apa_colors.dart';
import '../../../../core/theme/apa_fonts.dart';
import '../../../../core/utils/html_utils.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/apa_empty_retry.dart';
import '../../../../core/widgets/apa_shared_widgets.dart';
import '../../../../data/models/post/post_item_extensions.dart';
import '../../../../data/models/post/post_model.dart';
import '../../../shell/presentation/controllers/pages_controller.dart';
import '../../../shell/presentation/mapping/apa_page_templates.dart';
import '../../../shell/presentation/models/apa_nav_item.dart';
import '../../domain/news_page_content.dart';

/// News listing — matches live web `page-news.php`.
class NewsPage extends StatelessWidget {
  const NewsPage({
    super.key,
    this.scrollController,
    this.onReadMore,
    this.imageUrl,
    this.page,
  });

  final ScrollController? scrollController;
  final ValueChanged<PostItem>? onReadMore;
  final String? imageUrl;
  final PostItem? page;

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
              ApaPageTemplates.news,
              force: true,
            );
          },
          child: Obx(() {
            pagesController?.items.length;
            pagesController?.pageDetailsById.length;
            pagesController?.extraNewsPosts.length;
            pagesController?.newsHasMore.value;
            pagesController?.loadingMoreNews.value;
            pagesController?.isLoading.value;
            if (ConnectivityController.registered) {
              ConnectivityController.to.isOnline.value;
            }

            final blank = pagesController?.isBlankForTemplate(
                  ApaPageTemplates.news,
                ) ??
                true;
            final loading = pagesController != null &&
                ((pagesController.isLoading.value &&
                        pagesController.items.isEmpty) ||
                    pagesController.isLoadingDetailsForTemplate(
                      ApaPageTemplates.news,
                    ));

            if (loading) {
              return const ColoredBox(
                color: ApaColors.white,
                child: Center(
                  child: CircularProgressIndicator(color: ApaColors.webRed),
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
                        template: ApaPageTemplates.news,
                      ),
                    ),
                  ],
                ),
              );
            }

            final current =
                pagesController?.resolvedPageForShell(ApaShellPage.news) ??
                    page;
            final content = current == null
                ? null
                : NewsPageContent.fromPost(current);
            final otherPosts =
                pagesController?.newsStoriesForDisplay(current) ??
                    current?.nonFeaturedPosts ??
                    const <PostItem>[];
            final hasMore = pagesController?.newsHasMore.value ?? false;
            final loadingMore =
                pagesController?.loadingMoreNews.value ?? false;

            return _NewsScrollView(
              scrollController: scrollController,
              current: current,
              content: content,
              featured: current?.featuredPost,
              otherPosts: otherPosts,
              navBottomPad: navBottomPad,
              heroImageFallback: imageUrl,
              hasMore: hasMore,
              loadingMore: loadingMore,
              onLoadMore: pagesController == null
                  ? null
                  : () => pagesController.loadMoreNews(),
              onReadMore: onReadMore,
            );
          }),
        ),
      ),
    );
  }
}

class _NewsScrollView extends StatelessWidget {
  const _NewsScrollView({
    required this.scrollController,
    required this.current,
    required this.content,
    required this.featured,
    required this.otherPosts,
    required this.navBottomPad,
    required this.heroImageFallback,
    required this.hasMore,
    required this.loadingMore,
    required this.onLoadMore,
    required this.onReadMore,
  });

  final ScrollController? scrollController;
  final PostItem? current;
  final NewsPageContent? content;
  final PostItem? featured;
  final List<PostItem> otherPosts;
  final double navBottomPad;
  final String? heroImageFallback;
  final bool hasMore;
  final bool loadingMore;
  final VoidCallback? onLoadMore;
  final ValueChanged<PostItem>? onReadMore;

  bool _maybeLoadMore(ScrollNotification notification) {
    if (!hasMore || loadingMore || onLoadMore == null) return false;
    final metrics = notification.metrics;
    if (metrics.extentAfter < 280) {
      onLoadMore!();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final labels = content;
    final badge = labels?.topTagLine ?? '';
    final headingOne = (labels?.headingTextOne ?? '').trim();
    final headingTwo = (labels?.headingTextTwo ?? '').trim();
    final subtitle = labels?.lastContent;
    final readMoreLabel = labels?.readMoreLabel ?? 'Read More';
    final loadingLabel = labels?.loadingLabel ?? 'Loading more stories...';
    final endMessage = labels?.endMessage ??
        'You’ve reached the end of our latest news.';
    final emptyTitle = labels?.emptyTitle ?? 'No news articles found';
    final emptyMessage = labels?.emptyMessage ??
        'We are actively preparing new updates and stories from Haiti. Please check back soon.';

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
            fontWeight: FontWeight.w700,
            height: 1.02,
            letterSpacing: -0.9,
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
            fontWeight: FontWeight.w700,
            height: 1.02,
            letterSpacing: -0.9,
          ),
        ),
      );
    }

    final heroImage = labels?.imageUrl ??
        current?.featuredImageUrl ??
        heroImageFallback;
    final showHeader = labels?.showHeader ?? true;
    final hasAnyStory = featured != null || otherPosts.isNotEmpty;
    final wide = MediaQuery.sizeOf(context).width >= 700;

    return NotificationListener<ScrollNotification>(
      onNotification: _maybeLoadMore,
      child: CustomScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          if (showHeader)
            SliverToBoxAdapter(
              child: ApaHeroHeader(
                imageAsset: ApaAssets.newsHero,
                imageUrl: heroImage,
                useAssetFallback: false,
                height: 520,
                badge: badge,
                headline: headline,
                subtitle: (subtitle == null || subtitle.isEmpty)
                    ? null
                    : subtitle,
              ),
            ),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!hasAnyStory)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 48.h),
                        child: Column(
                          children: [
                            Text(
                              emptyTitle,
                              textAlign: TextAlign.center,
                              style: ApaFonts.inter(
                                color: ApaColors.webInk,
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              emptyMessage,
                              textAlign: TextAlign.center,
                              style: ApaFonts.inter(
                                color: ApaColors.factLabel,
                                fontSize: 15.sp,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      if (featured != null) ...[
                        _FeaturedNewsCard(
                          post: featured!,
                          readMoreLabel: readMoreLabel,
                          sideBySide: wide,
                          onTap: () => onReadMore?.call(featured!),
                        ),
                        SizedBox(height: 32.h),
                      ],
                      _NewsCardsGrid(
                        posts: otherPosts,
                        onReadMore: onReadMore,
                      ),
                      SizedBox(height: 24.h),
                      if (loadingMore)
                        _NewsFooterStatus(
                          label: loadingLabel,
                          showSpinner: true,
                        )
                      else if (!hasMore)
                        _NewsFooterStatus(
                          label: endMessage,
                          showSpinner: false,
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsFooterStatus extends StatelessWidget {
  const _NewsFooterStatus({
    required this.label,
    required this.showSpinner,
  });

  final String label;
  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showSpinner) ...[
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: ApaColors.webRed,
              ),
            ),
            SizedBox(width: 12.w),
          ],
          Flexible(
            child: Text(
              label.toUpperCase(),
              textAlign: TextAlign.center,
              style: ApaFonts.inter(
                color: ApaColors.factLabel,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsCardsGrid extends StatelessWidget {
  const _NewsCardsGrid({
    required this.posts,
    required this.onReadMore,
  });

  final List<PostItem> posts;
  final ValueChanged<PostItem>? onReadMore;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 900
            ? 3
            : width >= 560
                ? 2
                : 1;
        final gap = 32.0;

        if (crossAxisCount == 1) {
          return Column(
            children: [
              for (var i = 0; i < posts.length; i++) ...[
                if (i > 0) SizedBox(height: gap),
                _NewsCard(
                  post: posts[i],
                  onTap: () => onReadMore?.call(posts[i]),
                ),
              ],
            ],
          );
        }

        final rows = <Widget>[];
        for (var i = 0; i < posts.length; i += crossAxisCount) {
          final slice = posts.sublist(
            i,
            (i + crossAxisCount).clamp(0, posts.length),
          );
          rows.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var j = 0; j < crossAxisCount; j++) ...[
                    if (j > 0) SizedBox(width: gap),
                    Expanded(
                      child: j < slice.length
                          ? _NewsCard(
                              post: slice[j],
                              onTap: () => onReadMore?.call(slice[j]),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
            ),
          );
          if (i + crossAxisCount < posts.length) {
            rows.add(SizedBox(height: gap));
          }
        }
        return Column(children: rows);
      },
    );
  }
}

class _FeaturedNewsCard extends StatelessWidget {
  const _FeaturedNewsCard({
    required this.post,
    required this.readMoreLabel,
    required this.sideBySide,
    this.onTap,
  });

  final PostItem post;
  final String readMoreLabel;
  final bool sideBySide;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final category = post.categoryLabel.trim();
    final excerpt = _plainExcerpt(post);

    final image = SizedBox(
      height: sideBySide ? null : 280.h,
      width: double.infinity,
      child: _NewsCardImage(post: post),
    );

    final text = Padding(
      padding: EdgeInsets.all(sideBySide ? 40.w : 32.w),
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
          if (category.isNotEmpty) SizedBox(height: 14.h),
          Text(
            post.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: ApaFonts.inter(
              color: ApaColors.webInk,
              fontSize: sideBySide ? 28.sp : 24.sp,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          if (excerpt.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Text(
              excerpt,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: ApaFonts.inter(
                color: ApaColors.factLabel,
                fontSize: 16.sp,
                height: 1.45,
              ),
            ),
          ],
          SizedBox(height: 32.h),
          ApaBlackPillButton(
            label: readMoreLabel,
            fontSize: 16,
            horizontalPadding: 35,
            verticalPadding: 16,
            onPressed: onTap,
          ),
        ],
      ),
    );

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
          child: sideBySide
              ? SizedBox(
                  height: 320,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: image),
                      Expanded(child: text),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      // top corners already clipped by parent
                      child: image,
                    ),
                    text,
                  ],
                ),
        ),
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({
    required this.post,
    this.onTap,
  });

  final PostItem post;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final category = post.categoryLabel.trim();
    final excerpt = _plainExcerpt(post);

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
                child: _NewsCardImage(post: post),
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

/// Resolves card art the way the web theme does: featured image, else theme
/// `projects-2.webp` placeholder (used for posts like "Hello world!").
class _NewsCardImage extends StatelessWidget {
  const _NewsCardImage({required this.post});

  final PostItem post;

  @override
  Widget build(BuildContext context) {
    final featured = post.featuredImageUrl?.trim() ?? '';
    final url =
        featured.isNotEmpty ? featured : ApaAssets.webNewsCardFallbackImage;

    return Image.network(
      url,
      key: ValueKey<String>('news-img-${post.id}-$url'),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) => Image.asset(
        ApaAssets.newsFeatured,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}
