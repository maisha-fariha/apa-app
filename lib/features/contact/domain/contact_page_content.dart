import '../../../data/models/post/post_model.dart';

class ContactInfoRow {
  const ContactInfoRow({
    required this.label,
    required this.value,
    this.type = 'text',
    this.link = '',
    this.isLink = false,
    this.embedUrl = '',
  });

  final String label;
  final String value;
  final String type;
  final String link;
  final bool isLink;
  final String embedUrl;

  bool get hasText =>
      label.isNotEmpty || value.isNotEmpty || embedUrl.isNotEmpty;

  String? get actionableUri {
    final direct = link.trim();
    if (direct.isNotEmpty) return direct;
    final embed = embedUrl.trim();
    if (embed.isNotEmpty) return embed;
    final v = value.trim();
    if (v.isEmpty) return null;
    switch (type.toLowerCase()) {
      case 'email':
        return 'mailto:$v';
      case 'phone':
        final digits = v.replaceAll(RegExp(r'[^\d+]'), '');
        return digits.isEmpty ? null : 'tel:$digits';
      case 'whatsapp':
        final digits = v.replaceAll(RegExp(r'\D'), '');
        return digits.isEmpty ? null : 'https://wa.me/$digits';
      default:
        return null;
    }
  }
}

/// CMS content for Contact Us, parsed from `get-post-details` ACF fields.
class ContactPageContent {
  const ContactPageContent({
    required this.hideHeader,
    required this.topTagLine,
    required this.headingTextOne,
    required this.headingTextTwo,
    required this.lastContent,
    required this.imageUrl,
    required this.reachTitle,
    required this.infoRows,
    required this.finalTextStart,
    required this.finalTextEnd,
  });

  final bool hideHeader;
  final String topTagLine;
  final String headingTextOne;
  final String headingTextTwo;
  final String lastContent;
  final String? imageUrl;
  final String reachTitle;
  final List<ContactInfoRow> infoRows;
  final String finalTextStart;
  final String finalTextEnd;

  bool get hasHeaderText =>
      topTagLine.isNotEmpty ||
      headingTextOne.isNotEmpty ||
      headingTextTwo.isNotEmpty ||
      lastContent.isNotEmpty;

  bool get showHeader => !hideHeader && (hasHeaderText || imageUrl != null);

  bool get hasClosingText =>
      finalTextStart.isNotEmpty || finalTextEnd.isNotEmpty;

  bool get hasReachUs => infoRows.isNotEmpty || hasClosingText;

  String get reachHeading =>
      reachTitle.isNotEmpty ? reachTitle : 'Reach us';

  factory ContactPageContent.fromPost(PostItem page) {
    final acf = page.acfFields;
    final header = _asMap(acf['common_header']);
    final info = _asMap(acf['contact_information']);

    return ContactPageContent(
      hideHeader: _asBool(header['hide_header']),
      topTagLine: _asString(header['top_tag_line']),
      headingTextOne: _asString(header['heading_text_one']),
      headingTextTwo: _asString(header['heading_text_two']),
      lastContent: _asString(header['last_content']),
      imageUrl: page.featuredImageUrl,
      reachTitle: _firstNonEmpty([
        _asString(info['top_text_lebel']), // CMS typo on live site
        _asString(info['top_text_label']),
        _asString(info['title']),
      ]),
      infoRows: _infoRows(acf, info),
      finalTextStart: _asString(info['final_text_start']),
      finalTextEnd: _asString(info['final_text_end']),
    );
  }

  static List<ContactInfoRow> _infoRows(
    Map<String, dynamic> acf,
    Map<String, dynamic> info,
  ) {
    // Prefer enriched root `contact_items` (links already resolved by API).
    final fromRoot = _asList(acf['contact_items'])
        .map(_rowFromMap)
        .where((row) => row.hasText)
        .toList();
    if (fromRoot.isNotEmpty) return fromRoot;

    // Nested ACF `contact_information.items`.
    final fromItems = _asList(info['items'])
        .map(_rowFromMap)
        .where((row) => row.hasText)
        .toList();
    if (fromItems.isNotEmpty) return fromItems;

    // Legacy flat keys.
    final rows = <ContactInfoRow>[];
    for (final entry in info.entries) {
      if (entry.key.startsWith('final_text')) continue;
      if (entry.key.startsWith('top_text')) continue;
      if (entry.key == 'items' || entry.key == 'title') continue;
      final value = _asString(entry.value);
      if (value.isEmpty) continue;
      rows.add(
        ContactInfoRow(
          label: _labelFor(entry.key),
          value: value,
          type: _typeForLegacyKey(entry.key),
        ),
      );
    }
    return rows;
  }

  static ContactInfoRow _rowFromMap(Map<String, dynamic> json) {
    final type = _asString(json['type']).isEmpty
        ? 'text'
        : _asString(json['type']);
    final link = _asString(json['link']);
    final isLink = json['is_link'] == true ||
        json['is_link'] == 1 ||
        json['is_link'] == '1' ||
        link.isNotEmpty;
    return ContactInfoRow(
      label: _asString(json['label']),
      value: _asString(json['value']),
      type: type,
      link: link,
      isLink: isLink,
      embedUrl: _asString(json['embed_url']),
    );
  }

  static const _labels = {
    'email': 'Email',
    'phone': 'Phone',
    'the_field_office': 'Field office',
    'diaspora_relations': 'Diaspora relations',
  };

  static String _labelFor(String key) {
    final known = _labels[key];
    if (known != null) return known;
    return key
        .split('_')
        .where((part) => part.isNotEmpty)
        .map(
          (part) => '${part[0].toUpperCase()}${part.substring(1)}',
        )
        .join(' ');
  }

  static String _typeForLegacyKey(String key) {
    switch (key) {
      case 'email':
      case 'diaspora_relations':
        return 'email';
      case 'phone':
        return 'phone';
      default:
        return 'text';
    }
  }

  static List<Map<String, dynamic>> _asList(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  static String _asString(dynamic value) {
    if (value == null || value is bool) return '';
    return value.toString().trim();
  }

  static String _firstNonEmpty(List<String> values) {
    for (final value in values) {
      if (value.isNotEmpty) return value;
    }
    return '';
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
}
