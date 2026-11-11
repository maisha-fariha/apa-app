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
import '../../../../data/models/post/post_model.dart';
import '../../../../data/models/post/post_item_extensions.dart';
import '../../../shell/presentation/controllers/pages_controller.dart';
import '../../../shell/presentation/mapping/apa_page_templates.dart';
import '../../../shell/presentation/models/apa_nav_item.dart';

/// News Page — Figma frame `13:738`.
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
          color: ApaColors.primaryRed,
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
            pagesController?.newsSearchQuery.value;
            pagesController?.newsSearchResults.length;
            pagesController?.newsSearchHasMore.value;
            pagesController?.searchingNews.value;
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
                  child: CircularProgressIndicator(color: ApaColors.primaryRed),
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
            final searching = pagesController?.isNewsSearchActive ?? false;
            final otherPosts = pagesController?.newsStoriesForDisplay(current) ??
                current?.nonFeaturedPosts ??
                const <PostItem>[];
            final hasMore = searching
                ? (pagesController?.newsSearchHasMore.value ?? false)
                : (pagesController?.newsHasMore.value ?? false);
            return _buildScrollView(
              context,
              current,
              otherPosts,
              navBottomPad,
              searching: searching,
              searchingBusy: pagesController?.searchingNews.value ?? false,
              hasMore: hasMore,
              loadingMore: pagesController?.loadingMoreNews.value ?? false,
              onLoadMore: pagesController == null
                  ? null
                  : () => pagesController.loadMoreNews(),
              onSearch: pagesController == null
                  ? null
                  : (query) => pagesController.searchNews(query),
              onClearSearch: pagesController == null
                  ? null
                  : () => pagesController.clearNewsSearch(),
              searchQuery: pagesController?.newsSearchQuery.value ?? '',
            );
          }),
        ),
      ),
    );
  }

  Widget _buildScrollView(
    BuildContext context,
    PostItem? current,
    List<PostItem> otherPosts,
    double navBottomPad, {
    required bool searching,
    required bool searchingBusy,
    required bool hasMore,
    required bool loadingMore,
    required VoidCallback? onLoadMore,
    required ValueChanged<String>? onSearch,
    required VoidCallback? onClearSearch,
    required String searchQuery,
  }) {
    final commonHeader = current?.commonHeader ?? const <String, dynamic>{};

    final badge =
        commonHeader['top_tag_line']?.toString() ?? '';
    final headingOne =
        (commonHeader['heading_text_one']?.toString() ?? '').trim();
    final headingTwo =
        (commonHeader['heading_text_two']?.toString() ?? '').trim();
    final subtitle = commonHeader['last_content']?.toString();

    final headline = <InlineSpan>[];
    if (headingOne.isNotEmpty) {
      headline.add(
        TextSpan(
          text: '${headingOne.toUpperCase()} ',
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
            color: ApaColors.primaryRedAlt,
            fontSize: 36.sp,
            fontWeight: FontWeight.w800,
            height: 40 / 36,
            letterSpacing: -0.5,
          ),
        ),
      );
    }

    final featured = searching ? null : current?.featuredPost;
    final heroImage = current?.featuredImageUrl ?? imageUrl;

    return CustomScrollView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
            SliverToBoxAdapter(
              child: ApaHeroHeader(
                imageAsset: ApaAssets.newsHero,
                imageUrl: heroImage,
                useAssetFallback: false,
                height: 480,
                badge: badge,
                headline: headline,
                subtitle: subtitle,
              ),
            ),
            SliverToBoxAdapter(
              child: ApaPageWidth(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    R.isTabletLandscape(context) ? 48 : 20.w,
                    40.h,
                    R.isTabletLandscape(context) ? 48 : 20.w,
                    navBottomPad,
                  ),
                  child: Column(
                    children: [
                      _NewsSearchField(
                        initialQuery: searchQuery,
                        busy: searchingBusy,
                        onSearch: onSearch,
                        onClear: onClearSearch,
                      ),
                      SizedBox(height: 24.h),
                      if (searchingBusy)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 48),
                          child: CircularProgressIndicator(
                            color: ApaColors.primaryRed,
                          ),
                        )
                      else if (searching && otherPosts.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 48.h),
                          child: Text(
                            'No stories matched “$searchQuery”.',
                            textAlign: TextAlign.center,
                            style: ApaFonts.inter(
                              color: ApaColors.gray600,
                              fontSize: 15.sp,
                              height: 22 / 15,
                            ),
                          ),
                        )
                      else
                        R.isTabletLandscape(context)
                            ? _buildLandscape(
                                context,
                                featured: featured,
                                otherPosts: otherPosts,
                              )
                            : _buildPortrait(
                                context,
                                featured: featured,
                                otherPosts: otherPosts,
                              ),
                      if (hasMore && !searchingBusy) ...[
                        SizedBox(height: 32.h),
                        Center(
                          child: loadingMore
                              ? const SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(
                                    color: ApaColors.primaryRed,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : ApaBlackPillButton(
                                  label: 'LOAD MORE',
                                  onPressed: onLoadMore,
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

  Widget _buildLandscape(
    BuildContext context, {
    PostItem? featured,
    required List<PostItem> otherPosts,
  }) {
    final cards = <Widget>[];

    if (featured != null) {
      cards.add(
        Expanded(
          child: _NewsCard(
            post: featured,
            showReadMore: true,
            onReadMore: () => onReadMore?.call(featured),
          ),
        ),
      );
    }

    if (otherPosts.isNotEmpty) {
      if (cards.isNotEmpty) cards.add(SizedBox(width: 24.w));
      cards.add(
        Expanded(
          child: _NewsCard(
            post: otherPosts.first,
            onReadMore: () => onReadMore?.call(otherPosts.first),
          ),
        ),
      );
    }

    final remaining = otherPosts.length > 1 ? otherPosts.sublist(1) : <PostItem>[];

    return Column(
      children: [
        if (cards.isNotEmpty)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: cards,
          ),
        ...remaining.map((post) => Padding(
              padding: EdgeInsets.only(top: 32.h),
              child: _NewsCard(
                post: post,
                onReadMore: () => onReadMore?.call(post),
              ),
            )),
      ],
    );
  }

  Widget _buildPortrait(
    BuildContext context, {
    PostItem? featured,
    required List<PostItem> otherPosts,
  }) {
    return Column(
      children: [
        if (featured != null)
          _NewsCard(
            post: featured,
            showReadMore: true,
            onReadMore: () => onReadMore?.call(featured),
          ),
        ...otherPosts.map((post) => Padding(
              padding: EdgeInsets.only(top: 32.h),
              child: _NewsCard(
                post: post,
                onReadMore: () => onReadMore?.call(post),
              ),
            )),
      ],
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({
    required this.post,
    this.showReadMore = false,
    this.onReadMore,
  });

  final PostItem post;
  final bool showReadMore;
  final VoidCallback? onReadMore;

  @override
  Widget build(BuildContext context) {
    final imageUrl = post.featuredImageUrl;
    final category = post.categoryLabel.toUpperCase();
    final title = post.title;
    final description = post.excerpt.isNotEmpty ? post.excerpt : post.content;
    final plainDescription = description.replaceAll(RegExp(r'<[^>]+>'), '').trim();

    return GestureDetector(
      onTap: onReadMore,
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
            aspectRatio: 348 / 261,
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) =>
                        Image.asset(
                      ApaAssets.newsFeatured,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  )
                : Image.asset(
                    ApaAssets.newsFeatured,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
          ),
          Padding(
            padding: EdgeInsets.all(24.w),
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
                      height: 16 / 12,
                    ),
                  ),
                if (category.isNotEmpty) SizedBox(height: 12.h),
                Text(
                  title,
                  style: ApaFonts.inter(
                    color: ApaColors.black,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                    height: 30 / 24,
                  ),
                ),
                if (plainDescription.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  Text(
                    plainDescription,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: ApaFonts.inter(
                      color: ApaColors.gray600,
                      fontSize: 15.sp,
                      height: 22 / 15,
                    ),
                  ),
                ],
                if (showReadMore) ...[
                  SizedBox(height: 20.h),
                  ApaBlackPillButton(
                    label: 'READ MORE',
                    fontSize: 14,
                    horizontalPadding: 40,
                    verticalPadding: 14,
                    onPressed: onReadMore,
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

class _NewsSearchField extends StatefulWidget {
  const _NewsSearchField({
    required this.initialQuery,
    required this.busy,
    required this.onSearch,
    required this.onClear,
  });

  final String initialQuery;
  final bool busy;
  final ValueChanged<String>? onSearch;
  final VoidCallback? onClear;

  @override
  State<_NewsSearchField> createState() => _NewsSearchFieldState();
}

class _NewsSearchFieldState extends State<_NewsSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void didUpdateWidget(covariant _NewsSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialQuery != oldWidget.initialQuery &&
        widget.initialQuery != _controller.text) {
      _controller.text = widget.initialQuery;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final query = _controller.text.trim();
    if (query.isEmpty) {
      widget.onClear?.call();
      return;
    }
    widget.onSearch?.call(query);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => _submit(),
      style: ApaFonts.inter(
        color: ApaColors.black,
        fontSize: 15.sp,
      ),
      decoration: InputDecoration(
        hintText: 'Search stories',
        hintStyle: ApaFonts.inter(
          color: ApaColors.gray500,
          fontSize: 15.sp,
        ),
        filled: true,
        fillColor: ApaColors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: ApaColors.gray200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: ApaColors.black, width: 1.4),
        ),
        prefixIcon: Icon(
          Icons.search,
          color: ApaColors.gray500,
          size: 22.sp,
        ),
        suffixIcon: widget.busy
            ? Padding(
                padding: EdgeInsets.all(12.w),
                child: const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: ApaColors.primaryRed,
                  ),
                ),
              )
            : (_controller.text.trim().isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _controller.clear();
                      setState(() {});
                      widget.onClear?.call();
                    },
                    icon: Icon(
                      Icons.close,
                      color: ApaColors.gray500,
                      size: 20.sp,
                    ),
                  )
                : IconButton(
                    onPressed: _submit,
                    icon: Icon(
                      Icons.arrow_forward,
                      color: ApaColors.black,
                      size: 20.sp,
                    ),
                  )),
      ),
      onChanged: (_) => setState(() {}),
    );
  }
}
