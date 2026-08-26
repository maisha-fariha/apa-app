/// Returns true when [value] is non-empty and consists only of digits.
bool isNumericOnlyInput(String value) {
  final trimmed = value.trim();
  return trimmed.isNotEmpty && RegExp(r'^\d+$').hasMatch(trimmed);
}
