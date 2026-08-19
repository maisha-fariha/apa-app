import '../../../data/models/post/post_model.dart';

class TransparencyLedgerItem {
  const TransparencyLedgerItem({
    required this.project,
    required this.community,
    required this.status,
    required this.committed,
    required this.highlightStatus,
  });

  final String project;
  final String community;
  final String status;
  final String committed;
  final bool highlightStatus;
}

class TransparencyCommitment {
  const TransparencyCommitment({required this.title, required this.body});

  final String title;
  final String body;
}

class TransparencyFunding {
  const TransparencyFunding({
    required this.raisedLabel,
    required this.progressValue,
    required this.progressCaption,
  });

  final String raisedLabel;
  final double progressValue;
  final String progressCaption;

  bool get hasRaised => raisedLabel.isNotEmpty;
  bool get hasProgress => progressCaption.isNotEmpty || progressValue > 0;
}

/// CMS content for Transparency, parsed from `get-post-details`.
class TransparencyPageContent {
  const TransparencyPageContent({
    required this.hideHeader,
    required this.topTagLine,
    required this.headingTextOne,
    required this.headingTextTwo,
    required this.lastContent,
    required this.imageUrl,
    required this.funding,
    required this.ledgerItems,
    required this.commitmentTitle,
    required this.commitments,
  });

  final bool hideHeader;
  final String topTagLine;
  final String headingTextOne;
  final String headingTextTwo;
  final String lastContent;
  final String? imageUrl;
  final TransparencyFunding funding;
  final List<TransparencyLedgerItem> ledgerItems;
  final String commitmentTitle;
  final List<TransparencyCommitment> commitments;

  bool get hasHeaderText =>
      topTagLine.isNotEmpty ||
      headingTextOne.isNotEmpty ||
      headingTextTwo.isNotEmpty ||
      lastContent.isNotEmpty;

  bool get showHeader => !hideHeader && (hasHeaderText || imageUrl != null);

  bool get hasFunding => funding.hasRaised || funding.hasProgress;

  bool get hasLedger => ledgerItems.isNotEmpty;

  bool get hasCommitments =>
      commitmentTitle.isNotEmpty || commitments.isNotEmpty;

  factory TransparencyPageContent.fromPost(PostItem page) {
    final acf = page.acfFields;
    final header = _asMap(acf['common_header']);
    final footer = _parseFooter(_asString(acf['footer']));

    return TransparencyPageContent(
      hideHeader: _asBool(header['hide_header']),
      topTagLine: _asString(header['top_tag_line']),
      headingTextOne: _asString(header['heading_text_one']),
      headingTextTwo: _asString(header['heading_text_two']),
      lastContent: _asString(header['last_content']),
      imageUrl: page.featuredImageUrl,
      funding: _funding(page.fundingProgress),
      ledgerItems: _ledgerItems(acf['related_project']),
      commitmentTitle: footer.title,
      commitments: footer.items,
    );
  }

  static TransparencyFunding _funding(Map<String, dynamic> json) {
    final raisedFormatted = _asString(json['raised_formatted']);
    final raisedAmount = _asNum(json['raised_amount']);
    final targetFormatted = _asString(json['target_formatted']);
    final percent = _asNum(json['percent_funded']);

    final raisedLabel = raisedFormatted.isNotEmpty
        ? _withDollar(raisedFormatted)
        : (raisedAmount == null ? '' : _formatMoney(raisedAmount));

    final percentText = percent == null ? '' : '${_prettyPercent(percent)}%';
    final targetText =
        targetFormatted.isNotEmpty ? _withDollar(targetFormatted) : '';

    final captionParts = <String>[
      if (percentText.isNotEmpty) '$percentText of goal',
      if (targetText.isNotEmpty) targetText,
    ];

    final progressValue = percent == null
        ? 0.0
        : (percent > 1 ? percent / 100 : percent).clamp(0, 1).toDouble();

    return TransparencyFunding(
      raisedLabel: raisedLabel,
      progressValue: progressValue,
      progressCaption: captionParts.join(' — '),
    );
  }

  static List<TransparencyLedgerItem> _ledgerItems(dynamic value) {
    if (value is! List) return const [];
    final items = <TransparencyLedgerItem>[];
    for (final entry in value) {
      if (entry is! Map) continue;
      final json = Map<String, dynamic>.from(entry);
      final acf = _asMap(json['acf_fields']);
      final title = _decode(_asString(json['title']));
      final community = _decode(_asString(acf['community']));
      final status = _decode(_asString(acf['status']));
      final committed = _formatMoney(acf['committed']);
      if (title.isEmpty && community.isEmpty && status.isEmpty && committed.isEmpty) {
        continue;
      }
      items.add(
        TransparencyLedgerItem(
          project: title,
          community: community,
          status: status.toUpperCase(),
          committed: committed,
          highlightStatus: status.toLowerCase().contains('progress'),
        ),
      );
    }
    return items;
  }

  static ({String title, List<TransparencyCommitment> items}) _parseFooter(
    String html,
  ) {
    if (html.trim().isEmpty) {
      return (title: '', items: const <TransparencyCommitment>[]);
    }

    final headingMatch = RegExp(
      r'<h2[^>]*>(.*?)</h2>',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(html);
    final title = _decode(_stripTags(headingMatch?.group(1) ?? ''));

    final articles = RegExp(
      r'<article[^>]*>(.*?)</article>',
      caseSensitive: false,
      dotAll: true,
    ).allMatches(html);

    final items = <TransparencyCommitment>[];
    for (final article in articles) {
      final bodyHtml = article.group(1) ?? '';
      final name = _decode(
        _stripTags(
          RegExp(
                r'<h3[^>]*>(.*?)</h3>',
                caseSensitive: false,
                dotAll: true,
              ).firstMatch(bodyHtml)?.group(1) ??
              '',
        ),
      );
      final body = _decode(
        _stripTags(
          RegExp(
                r'<p[^>]*>(.*?)</p>',
                caseSensitive: false,
                dotAll: true,
              ).firstMatch(bodyHtml)?.group(1) ??
              '',
        ),
      );
      if (name.isEmpty && body.isEmpty) continue;
      items.add(TransparencyCommitment(title: name, body: body));
    }

    return (title: title, items: items);
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

  static num? _asNum(dynamic value) {
    if (value is num) return value;
    if (value is String) {
      return num.tryParse(value.replaceAll(',', '').trim());
    }
    return null;
  }

  static String _prettyPercent(num percent) {
    if (percent == percent.roundToDouble()) return '${percent.round()}';
    return percent.toString();
  }

  static String _withDollar(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith(r'$')) return trimmed;
    return '\$$trimmed';
  }

  static String _formatMoney(dynamic value) {
    final raw = _asString(value);
    if (raw.isEmpty) return '';
    if (raw.startsWith(r'$')) return raw;
    final parsed = num.tryParse(raw.replaceAll(',', ''));
    if (parsed == null) return raw;
    final negative = parsed < 0;
    final abs = parsed.abs();
    final whole = abs.floor();
    final formatted = _withCommas(whole);
    return '${negative ? '-' : ''}\$$formatted';
  }

  static String _withCommas(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final remaining = digits.length - i;
      buffer.write(digits[i]);
      if (remaining > 1 && remaining % 3 == 1) buffer.write(',');
    }
    return buffer.toString();
  }

  static String _stripTags(String input) {
    return input.replaceAll(RegExp(r'<[^>]*>'), ' ');
  }

  static String _decode(String input) {
    return input
        .replaceAll('&amp;', '&')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&mdash;', '—')
        .replaceAll('&#8212;', '—')
        .replaceAll('&ndash;', '–')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
