import 'package:flutter/material.dart';

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
import '../widgets/apa_more_sheet.dart';

/// Internal shell page state (includes More destinations).
enum ApaShellPage {
  home,
  projects,
  donation,
  transparency,
  news,
  vision,
  contact,
}

/// Root shell hosting APA screens with bottom navigation.
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

  void _go(ApaShellPage page) {
    setState(() => _page = page);
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
          onBackToNews: () => Navigator.of(context).pop(),
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
    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,
      body: IndexedStack(
        index: _page.index,
        children: [
          HomePage(onDonatePressed: () => _go(ApaShellPage.donation)),
          ProjectsPage(onFundPressed: () => _go(ApaShellPage.donation)),
          const DonationPage(),
          const TransparencyPage(),
          NewsPage(onReadMore: _openArticle),
          VisionPage(onLearnMore: () => _go(ApaShellPage.contact)),
          const ContactPage(),
        ],
      ),
      bottomNavigationBar: ApaBottomNav(
        selected: _navSelected,
        onItemSelected: _handleNav,
      ),
    );
  }
}
