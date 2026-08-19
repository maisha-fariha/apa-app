import 'post_model.dart';
import '../../../core/utils/html_utils.dart';

extension PostItemProjectsX on PostItem {
  Map<String, dynamic> get commonHeader {
    final raw = acfFields['common_header'];
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return const {};
  }

  List<PostItem> get relatedProjects {
    final raw = acfFields['related_projects'];
    if (raw is! List) return const [];

    return raw
        .whereType<Map>()
        .map((item) => PostItem.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  String? get footerHtml {
    final raw = acfFields['footer'];
    if (raw is String && raw.trim().isNotEmpty) {
      return raw.trim();
    }
    return null;
  }

  String? get tagLine {
    final raw = acfFields['tag_line'];
    if (raw is String && raw.trim().isNotEmpty) {
      return raw.trim();
    }
    return null;
  }

  String? get projectTypeLabel {
    for (final entry in taxonomies) {
      if (entry is! Map) continue;
      final map = Map<String, dynamic>.from(entry);
      final projectType = map['project_type'];
      if (projectType is! Map) continue;

      final terms = projectType['terms'];
      if (terms is! List || terms.isEmpty) continue;

      final first = terms.first;
      if (first is! Map) continue;

      final name = first['name'];
      if (name is String && name.trim().isNotEmpty) {
        return HtmlUtils.decodeEntities(name.trim());
      }
    }
    return null;
  }

  List<String> get contentBullets => HtmlUtils.bulletsFromHtml(content);
}
