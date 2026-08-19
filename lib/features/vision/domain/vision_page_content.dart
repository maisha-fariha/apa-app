import '../../../data/models/post/post_model.dart';

class VisionValueItem {
  const VisionValueItem({
    required this.title,
    required this.content,
    this.iconId,
    this.iconUrl,
  });

  final String title;
  final String content;
  final int? iconId;
  final String? iconUrl;

  bool get hasText => title.isNotEmpty || content.isNotEmpty;
}

class VisionGoalItem {
  const VisionGoalItem({required this.heading, required this.subHeading});

  final String heading;
  final String subHeading;

  bool get hasText => heading.isNotEmpty || subHeading.isNotEmpty;
}

class VisionStatItem {
  const VisionStatItem({required this.heading, required this.subHeading});

  final String heading;
  final String subHeading;

  bool get hasText => heading.isNotEmpty || subHeading.isNotEmpty;
}

/// CMS content for Our Vision, parsed from `get-post-details` ACF fields.
class VisionPageContent {
  const VisionPageContent({
    required this.hideHeader,
    required this.topTagLine,
    required this.headingTextOne,
    required this.headingTextTwo,
    required this.lastContent,
    required this.imageUrl,
    required this.statementSubheading,
    required this.statementText,
    required this.coreValuesTitle,
    required this.coreValues,
    required this.futureGoalsTitle,
    required this.futureGoals,
    required this.stats,
    required this.joinMissionTitle,
    required this.joinMissionButtonText,
    required this.joinMissionButtonUrl,
  });

  final bool hideHeader;
  final String topTagLine;
  final String headingTextOne;
  final String headingTextTwo;
  final String lastContent;
  final String? imageUrl;
  final String statementSubheading;
  final String statementText;
  final String coreValuesTitle;
  final List<VisionValueItem> coreValues;
  final String futureGoalsTitle;
  final List<VisionGoalItem> futureGoals;
  final List<VisionStatItem> stats;
  final String joinMissionTitle;
  final String joinMissionButtonText;
  final String joinMissionButtonUrl;

  bool get hasHeaderText =>
      topTagLine.isNotEmpty ||
      headingTextOne.isNotEmpty ||
      headingTextTwo.isNotEmpty ||
      lastContent.isNotEmpty;

  bool get showHeader => !hideHeader && (hasHeaderText || imageUrl != null);

  bool get hasStatement =>
      statementSubheading.isNotEmpty || statementText.isNotEmpty;

  bool get hasCoreValues =>
      coreValuesTitle.isNotEmpty || coreValues.isNotEmpty;

  bool get hasGoals => futureGoalsTitle.isNotEmpty || futureGoals.isNotEmpty;

  bool get hasStats => stats.isNotEmpty;

  bool get hasJoinMission =>
      joinMissionTitle.isNotEmpty || joinMissionButtonText.isNotEmpty;

  factory VisionPageContent.fromPost(PostItem page) {
    final acf = page.acfFields;
    final header = _asMap(acf['common_header']);

    return VisionPageContent(
      hideHeader: _asBool(header['hide_header']),
      topTagLine: _asString(header['top_tag_line']),
      headingTextOne: _asString(header['heading_text_one']),
      headingTextTwo: _asString(header['heading_text_two']),
      lastContent: _asString(header['last_content']),
      imageUrl: page.featuredImageUrl,
      statementSubheading: _asString(acf['vision_statement_subheading']),
      statementText: _asString(acf['vision_statement_text']),
      coreValuesTitle: _asString(acf['core_values_title']),
      coreValues: _numberedMaps(acf, 'core_values_item_')
          .map(_valueItem)
          .where((item) => item.hasText)
          .toList(),
      futureGoalsTitle: _asString(acf['future_goals_title']),
      futureGoals: _numberedMaps(acf, 'future_goal_item_group_')
          .map(_goalItem)
          .where((item) => item.hasText)
          .toList(),
      stats: _numberedMaps(acf, 'success_statistics_group_')
          .map(_statItem)
          .where((item) => item.hasText)
          .toList(),
      joinMissionTitle: _asString(acf['join_mission_title']),
      joinMissionButtonText: _asString(acf['join_mission_button_text']),
      joinMissionButtonUrl: _asString(acf['join_mission_button_url']),
    );
  }

  static VisionValueItem _valueItem(Map<String, dynamic> json) {
    return VisionValueItem(
      title: _asString(json['title']),
      content: _asString(json['content']),
      iconId: _asMediaId(json['icon']),
      iconUrl: _asMediaUrl(json['icon']),
    );
  }

  static VisionGoalItem _goalItem(Map<String, dynamic> json) {
    return VisionGoalItem(
      heading: _asString(json['heading']),
      subHeading: _asString(json['sub_heading']),
    );
  }

  static VisionStatItem _statItem(Map<String, dynamic> json) {
    return VisionStatItem(
      heading: _asString(json['heading']),
      subHeading: _asString(json['sub_heading']),
    );
  }

  static List<Map<String, dynamic>> _numberedMaps(
    Map<String, dynamic> acf,
    String prefix,
  ) {
    final matches = <int, Map<String, dynamic>>{};
    for (final entry in acf.entries) {
      if (!entry.key.startsWith(prefix)) continue;
      final index = int.tryParse(entry.key.substring(prefix.length));
      if (index == null) continue;
      final map = _asMap(entry.value);
      if (map.isEmpty) continue;
      matches[index] = map;
    }
    final keys = matches.keys.toList()..sort();
    return [for (final key in keys) matches[key]!];
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  static String _asString(dynamic value) {
    if (value == null || value is bool) return '';
    return value.toString().trim();
  }

  static bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1' || normalized == 'yes';
    }
    return false;
  }

  static int? _asMediaId(dynamic value) {
    if (value is bool) return null;
    if (value is int) return value > 0 ? value : null;
    if (value is num) return value > 0 ? value.toInt() : null;
    if (value is String) {
      final parsed = int.tryParse(value.trim());
      return parsed != null && parsed > 0 ? parsed : null;
    }
    if (value is Map) {
      return _asMediaId(value['id'] ?? value['ID']);
    }
    return null;
  }

  static String? _asMediaUrl(dynamic value) {
    if (value is String &&
        (value.startsWith('http://') || value.startsWith('https://'))) {
      return value.trim();
    }
    if (value is Map) {
      final url = _asString(value['url'] ?? value['source_url']);
      return url.isEmpty ? null : url;
    }
    return null;
  }
}
