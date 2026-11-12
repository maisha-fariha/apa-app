import 'post_item_extensions.dart';
import 'post_model.dart';

final _titleSuffix = RegExp(r'\s+#\d+$');

/// Strips trailing ` #2`-style duplicate suffixes from a project title.
String normalizeProjectTitle(String title) {
  return title.trim().replaceFirst(_titleSuffix, '').trim();
}

bool _isTestProjectTitle(String title) {
  final normalized = normalizeProjectTitle(title).toLowerCase();
  return normalized.startsWith('exercitation') ||
      normalized == 'auto draft' ||
      normalized.startsWith('hello world');
}

/// Prefers original project cards over `#2` duplicates / lorem test posts,
/// matching the finished web Projects grid.
List<PostItem> preferCanonicalProjects(List<PostItem> projects) {
  final filtered = <PostItem>[
    for (final project in projects)
      if (!_isTestProjectTitle(project.title)) project,
  ];
  if (filtered.length <= 1) return filtered;

  final bestByKey = <String, PostItem>{};
  for (final project in filtered) {
    final key = normalizeProjectTitle(project.title).toLowerCase();
    if (key.isEmpty) continue;
    final existing = bestByKey[key];
    bestByKey[key] =
        existing == null ? project : _preferCanonical(existing, project);
  }

  final seen = <int>{};
  final result = <PostItem>[];
  for (final project in filtered) {
    final key = normalizeProjectTitle(project.title).toLowerCase();
    final chosen = bestByKey[key];
    if (chosen == null) continue;
    if (seen.add(chosen.id)) result.add(chosen);
  }
  return result;
}

PostItem _preferCanonical(PostItem a, PostItem b) {
  final aSuffix = _titleSuffix.hasMatch(a.title.trim());
  final bSuffix = _titleSuffix.hasMatch(b.title.trim());
  if (aSuffix != bSuffix) return aSuffix ? b : a;

  final aTag = (a.tagLine ?? '').isNotEmpty;
  final bTag = (b.tagLine ?? '').isNotEmpty;
  if (aTag != bTag) return aTag ? a : b;

  return a.id <= b.id ? a : b;
}
