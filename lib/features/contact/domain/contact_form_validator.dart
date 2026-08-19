import 'package:gems_core/gems_core.dart';

import '../../../data/models/contact/contact_form_model.dart';

class ContactFormValidator {
  const ContactFormValidator._();

  static Map<String, String> validate({
    required List<ContactFormField> fields,
    required Map<String, dynamic> values,
  }) {
    final errors = <String, String>{};
    for (final field in fields) {
      if (field.kind.isDisplayOnly || field.kind.isHidden) continue;
      final error = errorFor(field, values[field.id]);
      if (error != null) errors[field.id] = error;
    }
    return errors;
  }

  static String? errorFor(ContactFormField field, dynamic value) {
    final label = field.displayLabel;
    final kind = field.kind;

    if (kind == ContactFieldKind.checkbox) {
      if (field.required && _selectedValues(value).isEmpty) {
        return '$label is required';
      }
      return null;
    }

    final text = _asString(value);
    if (field.required && text.trim().isEmpty) {
      return '$label is required';
    }
    if (text.trim().isEmpty) return null;

    switch (kind) {
      case ContactFieldKind.email:
        return _ruleError(
          text.trim(),
          StringValidators.email(message: 'Enter a valid email address'),
        );
      case ContactFieldKind.phone:
        return _ruleError(
          text.trim(),
          StringValidators.phone(message: 'Enter a valid phone number'),
        );
      case ContactFieldKind.url:
        final uri = Uri.tryParse(text.trim());
        if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
          return 'Enter a valid URL';
        }
        return null;
      case ContactFieldKind.number:
        if (num.tryParse(text.trim()) == null) {
          return 'Enter a valid number';
        }
        return null;
      default:
        return null;
    }
  }

  static Map<String, dynamic> submitFields({
    required List<ContactFormField> fields,
    required Map<String, dynamic> values,
  }) {
    final payload = <String, dynamic>{};
    for (final field in fields) {
      if (field.kind.isDisplayOnly) continue;
      payload[field.id] = serializeValue(field, values[field.id]);
    }
    return payload;
  }

  static dynamic serializeValue(ContactFormField field, dynamic value) {
    switch (field.kind) {
      case ContactFieldKind.checkbox:
        final selected = _selectedValues(value);
        if (field.options.isEmpty) {
          return selected.isNotEmpty;
        }
        if (selected.length <= 1) {
          return selected.isEmpty ? '' : selected.first;
        }
        return selected;
      case ContactFieldKind.hidden:
      case ContactFieldKind.select:
      case ContactFieldKind.radio:
      case ContactFieldKind.text:
      case ContactFieldKind.email:
      case ContactFieldKind.phone:
      case ContactFieldKind.number:
      case ContactFieldKind.url:
      case ContactFieldKind.textarea:
      case ContactFieldKind.date:
        return _asString(value);
      case ContactFieldKind.html:
        return '';
    }
  }

  static String _asString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is bool) return value ? '1' : '';
    if (value is Iterable) {
      return value.map((item) => item.toString()).join(', ');
    }
    return value.toString();
  }

  static List<String> _selectedValues(dynamic value) {
    if (value == null) return const [];
    if (value is bool) return value ? const ['1'] : const [];
    if (value is Iterable) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    final text = value.toString().trim();
    if (text.isEmpty) return const [];
    return [text];
  }

  static String? _ruleError(String value, ValidationRule<String> rule) {
    return rule.validate(value);
  }
}
