/// Shared CMS label / CTA shapes from Global Settings and single-item details.
class ContentLabels {
  const ContentLabels({
    required this.backLabel,
    required this.factsTitle,
    required this.relatedTitle,
    this.categoryLabel = '',
    this.typeLabel = '',
  });

  final String backLabel;
  final String factsTitle;
  final String relatedTitle;
  final String categoryLabel;
  final String typeLabel;

  static const empty = ContentLabels(
    backLabel: '',
    factsTitle: '',
    relatedTitle: '',
  );

  factory ContentLabels.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return empty;
    return ContentLabels(
      backLabel: _string(json['back_label']),
      factsTitle: _string(json['facts_title']),
      relatedTitle: _string(json['related_title']),
      categoryLabel: _string(json['category_label']),
      typeLabel: _string(json['type_label']),
    );
  }

  bool get isEmpty =>
      backLabel.isEmpty && factsTitle.isEmpty && relatedTitle.isEmpty;
}

class DonateCta {
  const DonateCta({
    required this.title,
    required this.text,
    required this.buttonLabel,
  });

  final String title;
  final String text;
  final String buttonLabel;

  static const empty = DonateCta(title: '', text: '', buttonLabel: '');

  factory DonateCta.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return empty;
    return DonateCta(
      title: _string(json['title']),
      text: _string(json['text']),
      buttonLabel: _string(json['button_label']),
    );
  }

  bool get isEmpty => title.isEmpty && text.isEmpty && buttonLabel.isEmpty;
}

class ContentFactRow {
  const ContentFactRow({required this.label, required this.text});

  final String label;
  final String text;

  factory ContentFactRow.fromJson(Map<String, dynamic> json) {
    return ContentFactRow(
      label: _string(json['label']),
      text: _string(json['text']),
    );
  }
}

/// ACF `footer` block used by Projects (`page-project.php`) and similar pages.
class PageFooterSection {
  const PageFooterSection({
    required this.title,
    required this.content,
    required this.buttonTitle,
    this.buttonLink = '',
  });

  final String title;
  final String content;
  final String buttonTitle;
  final String buttonLink;

  static const empty = PageFooterSection(
    title: '',
    content: '',
    buttonTitle: '',
  );

  factory PageFooterSection.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return empty;
    return PageFooterSection(
      title: _string(json['title']),
      content: _string(json['content']),
      buttonTitle: _string(json['button_title']),
      buttonLink: _string(json['button_link']),
    );
  }

  bool get isEmpty =>
      title.isEmpty && content.isEmpty && buttonTitle.isEmpty;
}

String _string(dynamic value) {
  if (value == null) return '';
  return value.toString().trim();
}
