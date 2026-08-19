import '../../../data/models/post/post_model.dart';

class ContactInfoRow {
  const ContactInfoRow({required this.label, required this.value});

  final String label;
  final String value;
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
      infoRows: _infoRows(info),
      finalTextStart: _asString(info['final_text_start']),
      finalTextEnd: _asString(info['final_text_end']),
    );
  }

  static List<ContactInfoRow> _infoRows(Map<String, dynamic> info) {
    final rows = <ContactInfoRow>[];
    for (final entry in info.entries) {
      if (entry.key.startsWith('final_text')) continue;
      final value = _asString(entry.value);
      if (value.isEmpty) continue;
      rows.add(
        ContactInfoRow(
          label: _labelFor(entry.key),
          value: value,
        ),
      );
    }
    return rows;
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

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  static String _asString(dynamic value) {
    if (value == null) return '';
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
}
