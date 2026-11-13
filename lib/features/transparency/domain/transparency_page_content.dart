import '../../../core/utils/html_utils.dart';
import '../../../data/models/post/paginated_posts.dart';
import '../../../data/models/post/post_item_extensions.dart';
import '../../../data/models/post/post_model.dart';

class TransparencyLedgerColumn {
  const TransparencyLedgerColumn({
    required this.heading,
    required this.fact,
    required this.display,
    required this.align,
    required this.textColor,
    required this.bgColor,
    required this.radius,
    required this.highlightValues,
    required this.highlightTextColor,
    required this.highlightBgColor,
  });

  final String heading;
  final String fact;
  final String display;
  final String align;
  final String textColor;
  final String bgColor;
  final double? radius;
  final List<String> highlightValues;
  final String highlightTextColor;
  final String highlightBgColor;

  bool get isBadge => display.toLowerCase() == 'badge';
  bool get isRight => align.toLowerCase() == 'right';

  factory TransparencyLedgerColumn.fromJson(Map<String, dynamic> json) {
    return TransparencyLedgerColumn(
      heading: _asString(json['heading']),
      fact: _asString(json['fact']),
      display: _asString(json['display']).isEmpty
          ? 'text'
          : _asString(json['display']),
      align: _asString(json['align']).isEmpty
          ? 'left'
          : _asString(json['align']),
      textColor: _asString(json['text_color']),
      bgColor: _asString(json['bg_color']),
      radius: _asDouble(json['radius']),
      highlightValues: _asStringList(json['hl_values']),
      highlightTextColor: _asString(json['hl_text_color']),
      highlightBgColor: _asString(json['hl_bg_color']),
    );
  }
}

class TransparencyLedgerCell {
  const TransparencyLedgerCell({
    required this.value,
    required this.display,
    required this.align,
    required this.textColor,
    required this.bgColor,
    required this.radius,
    required this.highlighted,
  });

  final String value;
  final String display;
  final String align;
  final String textColor;
  final String bgColor;
  final double? radius;
  final bool highlighted;

  bool get isBadge => display.toLowerCase() == 'badge';
  bool get isRight => align.toLowerCase() == 'right';
  bool get isEmpty => value.trim().isEmpty;

  factory TransparencyLedgerCell.fromJson(Map<String, dynamic> json) {
    return TransparencyLedgerCell(
      value: HtmlUtils.decodeEntities(_asString(json['value'])),
      display: _asString(json['display']).isEmpty
          ? 'text'
          : _asString(json['display']),
      align: _asString(json['align']).isEmpty
          ? 'left'
          : _asString(json['align']),
      textColor: _asString(json['text_color']),
      bgColor: _asString(json['bg_color']),
      radius: _asDouble(json['radius']),
      highlighted: _asBool(json['highlighted']),
    );
  }

  static TransparencyLedgerCell fromColumn(
    TransparencyLedgerColumn column,
    String value,
  ) {
    final trimmed = HtmlUtils.decodeEntities(value.trim());
    final highlighted = trimmed.isNotEmpty &&
        column.highlightValues.any(
          (v) => v.toLowerCase() == trimmed.toLowerCase(),
        );
    // Web badge defaults when not highlighted: ink on mist.
    final defaultText = column.isBadge ? '#0b0b0b' : '';
    final defaultBg = column.isBadge ? '#f1f2f6' : '';
    return TransparencyLedgerCell(
      value: trimmed,
      display: column.display,
      align: column.align,
      textColor: highlighted
          ? (column.highlightTextColor.isNotEmpty
              ? column.highlightTextColor
              : '#ffffff')
          : (column.textColor.isNotEmpty ? column.textColor : defaultText),
      bgColor: highlighted
          ? (column.highlightBgColor.isNotEmpty
              ? column.highlightBgColor
              : '#00209f')
          : (column.bgColor.isNotEmpty ? column.bgColor : defaultBg),
      radius: column.radius ?? (column.isBadge ? 999 : null),
      highlighted: highlighted,
    );
  }
}

class TransparencyLedgerItem {
  const TransparencyLedgerItem({
    required this.id,
    required this.project,
    required this.cells,
  });

  final int id;
  final String project;
  final List<TransparencyLedgerCell> cells;

  factory TransparencyLedgerItem.fromJson(
    Map<String, dynamic> json, {
    List<TransparencyLedgerColumn> columns = const [],
  }) {
    final title = HtmlUtils.decodeEntities(_asString(json['title']));
    final rawCells = json['cells'];
    if (rawCells is List && rawCells.isNotEmpty) {
      return TransparencyLedgerItem(
        id: _asInt(json['id']) ?? 0,
        project: title,
        cells: rawCells
            .whereType<Map>()
            .map(
              (c) => TransparencyLedgerCell.fromJson(
                Map<String, dynamic>.from(c),
              ),
            )
            .toList(),
      );
    }

    // Legacy `related_project` shape + column-driven rebuild.
    if (columns.isNotEmpty) {
      final acf = _asMap(json['acf_fields']);
      final facts = <String, String>{
        for (final col in columns)
          col.fact.toLowerCase(): _valueForFact(json, acf, col),
      };
      return TransparencyLedgerItem(
        id: _asInt(json['id']) ?? 0,
        project: title,
        cells: [
          for (final col in columns)
            TransparencyLedgerCell.fromColumn(
              col,
              facts[col.fact.toLowerCase()] ?? '',
            ),
        ],
      );
    }

    final acf = _asMap(json['acf_fields']);
    return TransparencyLedgerItem(
      id: _asInt(json['id']) ?? 0,
      project: title,
      cells: [
        TransparencyLedgerCell(
          value: HtmlUtils.decodeEntities(_asString(acf['community'])),
          display: 'text',
          align: 'left',
          textColor: '',
          bgColor: '',
          radius: null,
          highlighted: false,
        ),
        TransparencyLedgerCell(
          value: HtmlUtils.decodeEntities(_asString(acf['status'])),
          display: 'badge',
          align: 'left',
          textColor: '',
          bgColor: '',
          radius: 999,
          highlighted: _asString(acf['status']).toLowerCase().contains('progress') ||
              _asString(acf['status']).toLowerCase() == 'ongoing',
        ),
        TransparencyLedgerCell(
          value: _formatMoney(acf['committed']),
          display: 'text',
          align: 'right',
          textColor: '',
          bgColor: '',
          radius: null,
          highlighted: false,
        ),
      ],
    );
  }

  /// Builds a ledger row from a Projects CPT card + column settings.
  factory TransparencyLedgerItem.fromProject(
    PostItem project,
    List<TransparencyLedgerColumn> columns,
  ) {
    final facts = <String, String>{};
    for (final row in project.contentFactRows) {
      final key = row.label.trim().toLowerCase();
      if (key.isNotEmpty) {
        facts[key] = HtmlUtils.decodeEntities(row.text.trim());
      }
    }
    final quick = project.quickFacts;
    for (final entry in quick.entries) {
      facts.putIfAbsent(
        entry.key.toLowerCase(),
        () => HtmlUtils.decodeEntities(entry.value),
      );
    }
    // Root shortcuts returned on ledger / paginated payloads.
    for (final key in ['community', 'status', 'committed']) {
      final raw = project.acfFields[key];
      if (raw != null && raw.toString().trim().isNotEmpty) {
        facts.putIfAbsent(
          key,
          () => HtmlUtils.decodeEntities(raw.toString().trim()),
        );
      }
    }

    return TransparencyLedgerItem(
      id: project.id,
      project: HtmlUtils.decodeEntities(project.title),
      cells: [
        for (final col in columns)
          TransparencyLedgerCell.fromColumn(
            col,
            _lookupFact(facts, col),
          ),
      ],
    );
  }
}

class TransparencyCommitment {
  const TransparencyCommitment({required this.title, required this.body});

  final String title;
  final String body;
}

class TransparencyFunding {
  const TransparencyFunding({
    required this.raisedLabel,
    required this.raisedCaption,
    required this.progressValue,
    required this.progressCaption,
  });

  final String raisedLabel;
  final String raisedCaption;
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
    required this.ledgerTitle,
    required this.projectColumnHeading,
    required this.ledgerColumns,
    required this.ledgerItems,
    required this.pagination,
    required this.totalProjects,
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
  final String ledgerTitle;
  final String projectColumnHeading;
  final List<TransparencyLedgerColumn> ledgerColumns;
  final List<TransparencyLedgerItem> ledgerItems;
  final PageListPagination pagination;
  final int totalProjects;
  final String commitmentTitle;
  final List<TransparencyCommitment> commitments;

  bool get hasHeaderText =>
      topTagLine.isNotEmpty ||
      headingTextOne.isNotEmpty ||
      headingTextTwo.isNotEmpty ||
      lastContent.isNotEmpty;

  bool get showHeader => !hideHeader && (hasHeaderText || imageUrl != null);

  bool get hasFunding => funding.hasRaised || funding.hasProgress;

  bool get hasLedger => ledgerItems.isNotEmpty || ledgerColumns.isNotEmpty;

  bool get hasCommitments =>
      commitmentTitle.isNotEmpty || commitments.isNotEmpty;

  factory TransparencyPageContent.fromPost(PostItem page) {
    final acf = page.acfFields;
    final header = _asMap(acf['common_header']);
    final fundingSummary = _asMap(acf['funding_summary']);
    final projectLedger = _asMap(acf['project_ledger']);
    final commitment = _asMap(acf['commitment']);

    final columns = _ledgerColumns(acf['ledger_columns'], projectLedger);
    final ledgerItems = _ledgerItems(
      acf['ledger'] ?? acf['related_project'],
      columns,
    );

    final pagination = page.listPagination;
    final totalRaw = acf['total_projects'];
    final totalProjects = totalRaw is int
        ? totalRaw
        : int.tryParse(totalRaw?.toString() ?? '') ??
            (pagination.totalPages > 0 && pagination.perPage > 0
                ? pagination.totalPages * pagination.perPage
                : ledgerItems.length);

    final commitments = _commitments(commitment, acf['footer']);

    return TransparencyPageContent(
      hideHeader: _asBool(header['hide_header']),
      topTagLine: _asString(header['top_tag_line']),
      headingTextOne: _asString(header['heading_text_one']),
      headingTextTwo: _asString(header['heading_text_two']),
      lastContent: _asString(header['last_content']),
      imageUrl: page.featuredImageUrl,
      funding: _funding(page.fundingProgress, fundingSummary),
      ledgerTitle: () {
        final title = _asString(projectLedger['title']);
        if (title.isNotEmpty) return title;
        final hasRows = (acf['ledger'] is List && (acf['ledger'] as List).isNotEmpty) ||
            (acf['related_project'] is List &&
                (acf['related_project'] as List).isNotEmpty) ||
            columns.isNotEmpty;
        return hasRows ? 'Project ledger' : '';
      }(),
      projectColumnHeading: _asString(projectLedger['col_project']).isNotEmpty
          ? _asString(projectLedger['col_project'])
          : 'Project',
      ledgerColumns: columns,
      ledgerItems: ledgerItems,
      pagination: pagination,
      totalProjects: totalProjects,
      commitmentTitle: commitments.title,
      commitments: commitments.items,
    );
  }

  static TransparencyFunding _funding(
    Map<String, dynamic> json,
    Map<String, dynamic> summary,
  ) {
    final raisedFormatted = _asString(json['raised_formatted']);
    final raisedAmount = _asNum(json['raised_amount']);
    final targetFormatted = _asString(json['target_formatted']);
    final percent = _asNum(json['percent_funded']);

    final raisedLabel = raisedFormatted.isNotEmpty
        ? _withDollar(raisedFormatted)
        : (raisedAmount == null ? '' : _formatMoney(raisedAmount));

    final raisedCaption = _asString(summary['raised_label']).isNotEmpty
        ? _asString(summary['raised_label'])
        : 'Raised to date';

    final goalLabel = _asString(summary['goal_label']).isNotEmpty
        ? _asString(summary['goal_label'])
        : 'Phase one goal';
    final fundedLabel = _asString(summary['funded_label']).isNotEmpty
        ? _asString(summary['funded_label'])
        : 'funded';

    final percentText = percent == null ? '' : _prettyPercent(percent);
    final targetText =
        targetFormatted.isNotEmpty ? _withDollar(targetFormatted) : '';

    final captionParts = <String>[];
    if (targetText.isNotEmpty) {
      captionParts.add('$goalLabel: $targetText');
    }
    if (percentText.isNotEmpty) {
      captionParts.add('$percentText% $fundedLabel');
    }

    final progressValue = percent == null
        ? 0.0
        : (percent > 1 ? percent / 100 : percent).clamp(0, 1).toDouble();

    return TransparencyFunding(
      raisedLabel: raisedLabel,
      raisedCaption: raisedCaption,
      progressValue: progressValue,
      progressCaption: captionParts.join(' · '),
    );
  }

  static List<TransparencyLedgerColumn> _ledgerColumns(
    dynamic rootColumns,
    Map<String, dynamic> projectLedger,
  ) {
    final raw = rootColumns is List
        ? rootColumns
        : (projectLedger['columns'] is List
            ? projectLedger['columns'] as List
            : const []);
    return raw
        .whereType<Map>()
        .map(
          (item) => TransparencyLedgerColumn.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .where((c) => c.heading.isNotEmpty || c.fact.isNotEmpty)
        .toList();
  }

  static List<TransparencyLedgerItem> _ledgerItems(
    dynamic value,
    List<TransparencyLedgerColumn> columns,
  ) {
    if (value is! List) return const [];
    final items = <TransparencyLedgerItem>[];
    for (final entry in value) {
      if (entry is! Map) continue;
      final item = TransparencyLedgerItem.fromJson(
        Map<String, dynamic>.from(entry),
        columns: columns,
      );
      if (item.project.isEmpty &&
          item.cells.every((c) => c.value.isEmpty)) {
        continue;
      }
      items.add(item);
    }
    return items;
  }

  static ({String title, List<TransparencyCommitment> items}) _commitments(
    Map<String, dynamic> commitment,
    dynamic footer,
  ) {
    final title = _asString(commitment['title']);
    final rawItems = commitment['items'];
    if (rawItems is List && rawItems.isNotEmpty) {
      final items = <TransparencyCommitment>[];
      for (final entry in rawItems) {
        if (entry is! Map) continue;
        final map = Map<String, dynamic>.from(entry);
        final heading = HtmlUtils.decodeEntities(
          _asString(map['heading'] ?? map['title']),
        );
        final body = HtmlUtils.decodeEntities(
          _asString(map['content'] ?? map['body']),
        );
        if (heading.isEmpty && body.isEmpty) continue;
        items.add(TransparencyCommitment(title: heading, body: body));
      }
      return (title: title, items: items);
    }

    return _parseFooterHtml(_asString(footer));
  }

  static ({String title, List<TransparencyCommitment> items}) _parseFooterHtml(
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
    final title = HtmlUtils.decodeEntities(
      HtmlUtils.stripHtmlToText(headingMatch?.group(1) ?? ''),
    );

    final articles = RegExp(
      r'<article[^>]*>(.*?)</article>',
      caseSensitive: false,
      dotAll: true,
    ).allMatches(html);

    final items = <TransparencyCommitment>[];
    for (final article in articles) {
      final bodyHtml = article.group(1) ?? '';
      final name = HtmlUtils.decodeEntities(
        HtmlUtils.stripHtmlToText(
          RegExp(
                r'<h3[^>]*>(.*?)</h3>',
                caseSensitive: false,
                dotAll: true,
              ).firstMatch(bodyHtml)?.group(1) ??
              '',
        ),
      );
      final body = HtmlUtils.decodeEntities(
        HtmlUtils.stripHtmlToText(
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
}

String _lookupFact(
  Map<String, String> facts,
  TransparencyLedgerColumn col,
) {
  final keys = [
    col.fact.toLowerCase(),
    col.heading.toLowerCase(),
    col.fact.toLowerCase().replaceAll(' ', '_'),
    col.heading.toLowerCase().replaceAll(' ', '_'),
  ];
  for (final key in keys) {
    final value = facts[key];
    if (value != null && value.isNotEmpty) return value;
  }
  // "New" / "New Test" style facts on project_details.
  for (final entry in facts.entries) {
    if (entry.key == col.fact.toLowerCase() ||
        entry.key == col.heading.toLowerCase()) {
      return entry.value;
    }
  }
  return '';
}

String _valueForFact(
  Map<String, dynamic> json,
  Map<String, dynamic> acf,
  TransparencyLedgerColumn col,
) {
  final factKey = col.fact.toLowerCase();
  final headingKey = col.heading.toLowerCase();
  for (final key in [factKey, headingKey, 'community', 'status', 'committed']) {
    if (json[key] != null && json[key].toString().trim().isNotEmpty) {
      final raw = json[key].toString().trim();
      if (key == 'committed') return _formatMoney(raw);
      return raw;
    }
    if (acf[key] != null && acf[key].toString().trim().isNotEmpty) {
      final raw = acf[key].toString().trim();
      if (key == 'committed') return _formatMoney(raw);
      return raw;
    }
  }
  return '';
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return {};
}

String _asString(dynamic value) {
  if (value == null || value is bool) return '';
  return value.toString().trim();
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }
  return false;
}

num? _asNum(dynamic value) {
  if (value is num) return value;
  if (value is String) {
    return num.tryParse(value.replaceAll(',', '').trim());
  }
  return null;
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

double? _asDouble(dynamic value) {
  if (value == null || value == '') return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim());
  return null;
}

List<String> _asStringList(dynamic value) {
  if (value is List) {
    return value
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
  if (value is String && value.trim().isNotEmpty) {
    return value
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
  return const [];
}

String _prettyPercent(num percent) {
  if (percent == percent.roundToDouble()) return '${percent.round()}';
  return percent.toString();
}

String _withDollar(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return '';
  if (trimmed.startsWith(r'$')) return trimmed;
  return '\$$trimmed';
}

String _formatMoney(dynamic value) {
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

String _withCommas(int value) {
  final digits = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final remaining = digits.length - i;
    buffer.write(digits[i]);
    if (remaining > 1 && remaining % 3 == 1) buffer.write(',');
  }
  return buffer.toString();
}
