// Lightweight HTML helpers for this project.
//
// We only support the subset of HTML that the APA API returns for:
// - bullet lists in `content` (expects `<li>...</li>` items)
// - simple footer markup (expects `<h2>` / `<p>` text)

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

