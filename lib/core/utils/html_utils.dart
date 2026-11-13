// Lightweight HTML helpers for this project.
//
// We only support the subset of HTML that the APA API returns for:
// - bullet lists in `content` (expects `<li>...</li>` items)
// - project card blocks: `ul` / `ol` / `blockquote`
// - simple footer markup (expects `<h2>` / `<p>` text)

/// Structured Projects card body from ACF `card_content`.
class ProjectCardContent {
  const ProjectCardContent({
    required this.bullets,
    required this.numbered,
    required this.callouts,
  });

  final List<String> bullets;
  final List<String> numbered;
  final List<String> callouts;

  static const empty = ProjectCardContent(
    bullets: [],
    numbered: [],
    callouts: [],
  );

  bool get isEmpty =>
      bullets.isEmpty && numbered.isEmpty && callouts.isEmpty;
}

class HtmlUtils {
  /// Decodes common HTML entities (named + numeric).
  ///
  /// Supported entities: &amp; &lt; &gt; &quot; &#39;
  /// Also supports numeric: `&#123;` and hex: `&#x1F600;`.
  static String decodeEntities(String input) {
    var value = input;

    value = value
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', '\'')
        .replaceAll('&nbsp;', ' ');

    // Decode decimal numeric entities: &#123;
    value = value.replaceAllMapped(
      RegExp(r'&#(\d+);'),
      (m) {
        final codePoint = int.tryParse(m.group(1) ?? '');
        if (codePoint == null) return m.group(0) ?? '';
        return String.fromCharCode(codePoint);
      },
    );

    // Decode hex numeric entities: &#x1F600;
    value = value.replaceAllMapped(
      RegExp(r'&#x([0-9a-fA-F]+);'),
      (m) {
        final hex = m.group(1);
        final codePoint = hex == null ? null : int.tryParse(hex, radix: 16);
        if (codePoint == null) return m.group(0) ?? '';
        return String.fromCharCode(codePoint);
      },
    );

    return value;
  }

  /// Extracts plain bullet strings from HTML like:
  /// `<ul><li>Item 1</li><li>Item 2</li></ul>`
  ///
  /// Prefer [projectCardContentFromHtml] when `<ol>` / `<blockquote>` matter.
  static List<String> bulletsFromHtml(String html) {
    if (html.trim().isEmpty) return const [];

    final matches = RegExp(
      r'<li[^>]*>(.*?)</li>',
      caseSensitive: false,
      dotAll: true,
    ).allMatches(html);

    final out = <String>[];
    for (final match in matches) {
      var inner = match.group(1) ?? '';
      inner = inner.replaceAll('\n', ' ');
      inner = _stripTags(inner).trim();
      inner = decodeEntities(inner);
      if (inner.isNotEmpty) out.add(inner);
    }

    return out;
  }

  /// Parses Projects `card_content` the way the web theme does:
  /// disc bullets (`ul`), numbered items (`ol`), red-border callouts (`blockquote`).
  static ProjectCardContent projectCardContentFromHtml(String html) {
    final value = html.trim();
    if (value.isEmpty) return ProjectCardContent.empty;

    return ProjectCardContent(
      bullets: _listItemsInside(value, 'ul'),
      numbered: _listItemsInside(value, 'ol'),
      callouts: _blockquoteTexts(value),
    );
  }

  static List<String> _listItemsInside(String html, String tag) {
    final out = <String>[];
    final blocks = RegExp(
      '<$tag[^>]*>(.*?)</$tag>',
      caseSensitive: false,
      dotAll: true,
    ).allMatches(html);
    for (final block in blocks) {
      out.addAll(bulletsFromHtml(block.group(1) ?? ''));
    }
    return out;
  }

  static List<String> _blockquoteTexts(String html) {
    final out = <String>[];
    for (final match in RegExp(
      r'<blockquote[^>]*>(.*?)</blockquote>',
      caseSensitive: false,
      dotAll: true,
    ).allMatches(html)) {
      final inner = match.group(1) ?? '';
      final paragraphs = RegExp(
        r'<p[^>]*>(.*?)</p>',
        caseSensitive: false,
        dotAll: true,
      ).allMatches(inner);
      if (paragraphs.isNotEmpty) {
        for (final p in paragraphs) {
          final text = stripHtmlToText(p.group(1) ?? '').trim();
          if (text.isNotEmpty) out.add(text);
        }
      } else {
        final text = stripHtmlToText(inner).trim();
        if (text.isNotEmpty) out.add(text);
      }
    }
    return out;
  }

  static String _stripTags(String html) {
    // Remove any remaining tags.
    final withoutTags = html.replaceAll(
      RegExp(r'<[^>]+>'),
      '',
    );
    return withoutTags;
  }

  /// Strips tags and decodes entities (best-effort).
  static String stripHtmlToText(String html) {
    final withoutTags = _stripTags(html);
    return decodeEntities(withoutTags);
  }

  /// Best-effort extraction of `<h2>..</h2>` and `<p>..</p>` blocks.
  ///
  /// Returns an ordered list like: `[{type: 'h2', text: '...'}, ...]`.
  static List<Map<String, String>> extractHeaderAndParagraphs(String html) {
    final value = html.trim();
    if (value.isEmpty) return const [];

    final blocks = <Map<String, String>>[];

    // h2
    for (final m in RegExp(
      r'<h2[^>]*>(.*?)</h2>',
      caseSensitive: false,
      dotAll: true,
    ).allMatches(value)) {
      final inner = m.group(1) ?? '';
      final text = stripHtmlToText(inner).trim();
      if (text.isNotEmpty) {
        blocks.add({'type': 'h2', 'text': text});
      }
    }

    // p
    for (final m in RegExp(
      r'<p[^>]*>(.*?)</p>',
      caseSensitive: false,
      dotAll: true,
    ).allMatches(value)) {
      final inner = m.group(1) ?? '';
      final text = stripHtmlToText(inner).trim();
      if (text.isNotEmpty) {
        blocks.add({'type': 'p', 'text': text});
      }
    }

    return blocks;
  }
}

