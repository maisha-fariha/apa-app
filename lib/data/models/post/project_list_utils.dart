import 'post_model.dart';

final _titleSuffix = RegExp(r'\s+#\d+$');

/// Strips trailing ` #2`-style duplicate suffixes from a project title.
String normalizeProjectTitle(String title) {
  return title.trim().replaceFirst(_titleSuffix, '').trim();
}

/// Live web Projects grid order: API order unchanged (same as
/// `?project_page=N` — includes `#2` copies and test posts).
List<PostItem> projectsForWebGrid(List<PostItem> projects) {
  return List<PostItem>.unmodifiable(projects);
}
