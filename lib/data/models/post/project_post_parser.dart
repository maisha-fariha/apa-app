import 'post_model.dart';

/// Parses a Projects grid / related-project card, preserving root extras in ACF.
PostItem parseProjectCard(Map<String, dynamic> json) {
  final acf = Map<String, dynamic>.from(
    (json['acf_fields'] is Map)
        ? json['acf_fields'] as Map
        : <String, dynamic>{},
  );
  for (final key in const [
    'category',
    'quick_facts',
    'details',
    'project_details',
    'card_content',
    'tag_line',
  ]) {
    if (json.containsKey(key) && !acf.containsKey(key)) {
      acf[key] = json[key];
    }
  }
  json['acf_fields'] = acf;
  return PostItem.fromJson(json);
}
