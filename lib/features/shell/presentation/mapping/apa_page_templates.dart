import '../models/apa_nav_item.dart';
import '../widgets/apa_more_sheet.dart';

/// WordPress `template` values used as the unique page identifier.
abstract final class ApaPageTemplates {
  static const String home = 'front-page.php';
  static const String projects = 'page-project.php';
  static const String news = 'page-news.php';
  static const String donation = 'page-donation.php';
  static const String contact = 'page-contact.php';
  static const String transparency = 'page-transparency.php';
  static const String vision = 'page-vision.php';

  static String normalize(String template) {
    var value = template.trim().toLowerCase();
    if (value.contains('/')) {
      value = value.split('/').last;
    }
    if (value.contains(r'\')) {
      value = value.split(r'\').last;
    }
    return value;
  }

  static ApaShellPage? toShellPage(String template) {
    switch (normalize(template)) {
      case home:
        return ApaShellPage.home;
      case projects:
        return ApaShellPage.projects;
      case donation:
        return ApaShellPage.donation;
      case transparency:
        return ApaShellPage.transparency;
      case news:
        return ApaShellPage.news;
      case vision:
        return ApaShellPage.vision;
      case contact:
        return ApaShellPage.contact;
      default:
        return null;
    }
  }

  static String? forNavItem(ApaNavItem item) {
    switch (item) {
      case ApaNavItem.home:
        return home;
      case ApaNavItem.projects:
        return projects;
      case ApaNavItem.donation:
        return donation;
      case ApaNavItem.transparency:
        return transparency;
      case ApaNavItem.more:
        return null;
    }
  }

  static String forMoreDestination(ApaMoreDestination destination) {
    switch (destination) {
      case ApaMoreDestination.news:
        return news;
      case ApaMoreDestination.vision:
        return vision;
      case ApaMoreDestination.contact:
        return contact;
    }
  }

  static String forShellPage(ApaShellPage page) {
    switch (page) {
      case ApaShellPage.home:
        return home;
      case ApaShellPage.projects:
        return projects;
      case ApaShellPage.donation:
        return donation;
      case ApaShellPage.transparency:
        return transparency;
      case ApaShellPage.news:
        return news;
      case ApaShellPage.vision:
        return vision;
      case ApaShellPage.contact:
        return contact;
    }
  }
}
