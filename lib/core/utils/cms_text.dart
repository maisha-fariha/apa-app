/// Detects unfinished ACF placeholder copy (e.g. "Heading Text One").
bool isCmsPlaceholder(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return true;
  switch (text.toLowerCase()) {
    case 'heading text one':
    case 'heading text two':
    case 'top tag line':
    case 'last content goes here':
    case 'last content':
      return true;
    default:
      return false;
  }
}

/// Returns [value] when it is real CMS copy; otherwise [fallback].
String cmsOr(dynamic value, String fallback) {
  final text = value?.toString().trim() ?? '';
  if (isCmsPlaceholder(text)) return fallback;
  return text;
}
