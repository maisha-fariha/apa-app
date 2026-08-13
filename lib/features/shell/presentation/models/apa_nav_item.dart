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

enum ApaNavItem {
  home,
  projects,
  donation,
  transparency,
  more,
}

extension ApaNavItemX on ApaNavItem {
  String get label {
    switch (this) {
      case ApaNavItem.home:
        return 'HOME';
      case ApaNavItem.projects:
        return 'PROJECTS';
      case ApaNavItem.donation:
        return 'DONATION';
      case ApaNavItem.transparency:
        return 'TRANSPARENCY';
      case ApaNavItem.more:
        return 'MORE';
    }
  }

  bool get isCenterFab => this == ApaNavItem.donation;
}
