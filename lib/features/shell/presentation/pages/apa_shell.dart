import 'package:flutter/material.dart';

import '../../../../core/utils/responsive.dart';
import '../../../contact/presentation/pages/contact_page.dart';
import '../../../donation/presentation/pages/donation_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../news/presentation/pages/article_page.dart';
import '../../../news/presentation/pages/news_page.dart';
import '../../../projects/presentation/pages/projects_page.dart';
import '../../../transparency/presentation/pages/transparency_page.dart';
import '../../../vision/presentation/pages/vision_page.dart';
import '../models/apa_nav_item.dart';
import '../widgets/apa_bottom_nav.dart';
import '../widgets/apa_desktop_nav.dart';
import '../widgets/apa_more_sheet.dart';

/// Root shell hosting APA screens with bottom / desktop navigation.
class ApaShell extends StatefulWidget {
  const ApaShell({
    super.key,
    this.onNavItemSelected,
  });

  final ValueChanged<ApaNavItem>? onNavItemSelected;

  @override
  State<ApaShell> createState() => _ApaShellState();
}

class _ApaShellState extends State<ApaShell> {
  ApaShellPage _page = ApaShellPage.home;

  final _homeScroll = ScrollController();
  final _projectsScroll = ScrollController();
  final _donationScroll = ScrollController();
  final _transparencyScroll = ScrollController();
  final _newsScroll = ScrollController();
  final _visionScroll = ScrollController();
  final _contactScroll = ScrollController();

  ApaNavItem get _navSelected {
    switch (_page) {
      case ApaShellPage.home:
        return ApaNavItem.home;
      case ApaShellPage.projects:
        return ApaNavItem.projects;
      case ApaShellPage.donation:
        return ApaNavItem.donation;
      case ApaShellPage.transparency:
        return ApaNavItem.transparency;
      case ApaShellPage.news:
      case ApaShellPage.vision:
      case ApaShellPage.contact:
        return ApaNavItem.more;
    }
  }

  @override
  void dispose() {
    _homeScroll.dispose();
    _projectsScroll.dispose();
    _donationScroll.dispose();
    _transparencyScroll.dispose();
    _newsScroll.dispose();
    _visionScroll.dispose();
    _contactScroll.dispose();
    super.dispose();
  }

  ScrollController? _scrollControllerFor(ApaShellPage page) {
    switch (page) {
      case ApaShellPage.home:
        return _homeScroll;
      case ApaShellPage.projects:
        return _projectsScroll;
      case ApaShellPage.donation:
        return _donationScroll;
      case ApaShellPage.transparency:
        return _transparencyScroll;
      case ApaShellPage.news:
        return _newsScroll;
      case ApaShellPage.vision:
        return _visionScroll;
      case ApaShellPage.contact:
        return _contactScroll;
    }
  }

  void _scrollToTop(ApaShellPage page) {
    final controller = _scrollControllerFor(page);
    if (controller == null) return;

    void jump() {
      if (controller.hasClients) {
        controller.jumpTo(0);
      }
    }

    jump();
    WidgetsBinding.instance.addPostFrameCallback((_) => jump());
  }

  void _go(ApaShellPage page) {
    setState(() => _page = page);
    _scrollToTop(page);
  }

  void _handleNav(ApaNavItem item) {
    widget.onNavItemSelected?.call(item);

    switch (item) {
      case ApaNavItem.home:
        _go(ApaShellPage.home);
      case ApaNavItem.projects:
        _go(ApaShellPage.projects);
      case ApaNavItem.donation:
        _go(ApaShellPage.donation);
      case ApaNavItem.transparency:
        _go(ApaShellPage.transparency);
      case ApaNavItem.more:
        _openMoreSheet();
    }
  }

  void _openMoreSheet() {
    ApaMoreSheet.show(
      context,
      onSelected: (destination) {
        switch (destination) {
          case ApaMoreDestination.news:
            _go(ApaShellPage.news);
          case ApaMoreDestination.vision:
            _go(ApaShellPage.vision);
          case ApaMoreDestination.contact:
            _go(ApaShellPage.contact);
        }
      },
    );
  }

  void _openArticle() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ArticlePage(
          onBackToNews: () {
            Navigator.of(context).pop();
            _scrollToTop(ApaShellPage.news);
          },
          onDonatePressed: () {
            Navigator.of(context).pop();
            _go(ApaShellPage.donation);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final desktop = R.isTabletLandscape(context);
    final pages = IndexedStack(
      index: _page.index,
      children: [
        HomePage(
          scrollController: _homeScroll,
          onDonatePressed: () => _go(ApaShellPage.donation),
        ),
        ProjectsPage(
          scrollController: _projectsScroll,
          onFundPressed: () => _go(ApaShellPage.donation),
        ),
        DonationPage(scrollController: _donationScroll),
        TransparencyPage(scrollController: _transparencyScroll),
        NewsPage(
          scrollController: _newsScroll,
          onReadMore: _openArticle,
        ),
        VisionPage(
          scrollController: _visionScroll,
          onLearnMore: () => _go(ApaShellPage.contact),
        ),
        ContactPage(scrollController: _contactScroll),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,
      body: pages,
      bottomNavigationBar: desktop
          ? ApaDesktopNav(
              selected: _navSelected,
              onItemSelected: _handleNav,
            )
          : ApaBottomNav(
              selected: _navSelected,
              onItemSelected: _handleNav,
            ),
    );
  }
}
