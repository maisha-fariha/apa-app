import 'package:freezed_annotation/freezed_annotation.dart';

part 'contact_form_model.freezed.dart';
part 'contact_form_model.g.dart';

// ignore_for_file: invalid_annotation_target

enum ContactFieldKind {
  text,
  email,
  phone,
  number,
  url,
  textarea,
  select,
  radio,
  checkbox,
  date,
  hidden,
  html;

  static ContactFieldKind fromType(String type) {
    switch (type.trim().toLowerCase()) {
      case 'email':
        return ContactFieldKind.email;
      case 'phone':
      case 'tel':
      case 'telephone':
        return ContactFieldKind.phone;
      case 'number':
      case 'numeric':
        return ContactFieldKind.number;
      case 'url':
      case 'website':
        return ContactFieldKind.url;
      case 'textarea':
      case 'message':
        return ContactFieldKind.textarea;
      case 'select':
      case 'dropdown':
      case 'selectdropdown':
        return ContactFieldKind.select;
      case 'radio':
      case 'radios':
        return ContactFieldKind.radio;
      case 'checkbox':
      case 'checkboxes':
      case 'consent':
      case 'gdpr':
      case 'acceptance':
        return ContactFieldKind.checkbox;
      case 'date':
      case 'datepicker':
        return ContactFieldKind.date;
      case 'hidden':
        return ContactFieldKind.hidden;
      case 'html':
      case 'section':
      case 'heading':
      case 'separator':
        return ContactFieldKind.html;
      case 'name':
      case 'text':
      case 'input':
      case 'textfield':
      default:
        return ContactFieldKind.text;
    }
  }

  bool get usesTextInput => switch (this) {
        ContactFieldKind.text ||
        ContactFieldKind.email ||
        ContactFieldKind.phone ||
        ContactFieldKind.number ||
        ContactFieldKind.url ||
        ContactFieldKind.textarea ||
        ContactFieldKind.date =>
          true,
        _ => false,
      };

  bool get isDisplayOnly => this == ContactFieldKind.html;

  bool get isHidden => this == ContactFieldKind.hidden;
}

@freezed
class ContactFormOption with _$ContactFormOption {
  const ContactFormOption._();

  const factory ContactFormOption({
    @Default('') String label,
    @Default('') String value,
    @JsonKey(name: 'default', fromJson: boolFromJson) @Default(false) bool isDefault,
  }) = _ContactFormOption;

  factory ContactFormOption.fromJson(Map<String, dynamic> json) =>
      _$ContactFormOptionFromJson(json);

  String get submitValue {
    final resolved = value.trim().isEmpty ? label : value;
    return resolved;
  }

  String get displayLabel {
    final resolved = label.trim().isEmpty ? value : label;
    return resolved;
  }
}

@freezed
class ContactFormField with _$ContactFormField {
  const ContactFormField._();

  const factory ContactFormField({
    @Default('') String id,
    @Default('text') String type,
    @Default('') String label,
    @Default('') String placeholder,
    @JsonKey(fromJson: boolFromJson) @Default(false) bool required,
    @Default('') String description,
    @JsonKey(fromJson: contactFormOptionsFromJson)
    @Default([])
    List<ContactFormOption> options,
  }) = _ContactFormField;

  factory ContactFormField.fromJson(Map<String, dynamic> json) =>
      _$ContactFormFieldFromJson(json);

  ContactFieldKind get kind => ContactFieldKind.fromType(type);

  /// True for CF7/API name fields (type `name` or common name labels).
  bool get isNameField {
    final normalizedType = type.trim().toLowerCase();
    if (normalizedType == 'name') return true;
    final normalizedLabel = displayLabel.trim().toLowerCase();
    return normalizedLabel == 'name' ||
        normalizedLabel == 'your name' ||
        normalizedLabel == 'full name' ||
        normalizedLabel == 'your full name';
  }

  String get displayLabel {
    final value = label.trim();
    return value.isEmpty ? id : value;
  }

  String? get defaultOptionValue {
    for (final option in options) {
      if (option.isDefault) {
        final value = option.submitValue;
        if (value.isNotEmpty) return value;
      }
    }
    return null;
  }

  List<String> get defaultCheckboxValues {
    return options
        .where((option) => option.isDefault && option.submitValue.isNotEmpty)
        .map((option) => option.submitValue)
        .toList();
  }
}

@freezed
class GetContactFormResponse with _$GetContactFormResponse {
  const factory GetContactFormResponse({
    @JsonKey(fromJson: boolFromJson) @Default(false) bool success,
    @Default('') String message,
    @Default([]) List<ContactFormField> fields,
  }) = _GetContactFormResponse;

  factory GetContactFormResponse.fromJson(Map<String, dynamic> json) =>
      _$GetContactFormResponseFromJson(json);
}

@freezed
class SubmitContactFormResponse with _$SubmitContactFormResponse {
  const factory SubmitContactFormResponse({
    @JsonKey(fromJson: boolFromJson) @Default(false) bool success,
    @Default('') String message,
  }) = _SubmitContactFormResponse;

  factory SubmitContactFormResponse.fromJson(Map<String, dynamic> json) =>
      _$SubmitContactFormResponseFromJson(json);
}

bool boolFromJson(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'true' ||
        normalized == '1' ||
        normalized == 'yes' ||
        normalized == 'required';
  }
  return false;
}

List<ContactFormOption> contactFormOptionsFromJson(dynamic value) {
  if (value == null) return const [];
  if (value is List) {
    return value.map(_optionFromDynamic).whereType<ContactFormOption>().toList();
  }
  if (value is Map) {
    return value.entries.map((entry) {
      return ContactFormOption(
        value: entry.key.toString(),
        label: entry.value?.toString() ?? entry.key.toString(),
      );
    }).toList();
  }
  return const [];
}

ContactFormOption? _optionFromDynamic(dynamic value) {
  if (value is Map) {
    return ContactFormOption.fromJson(Map<String, dynamic>.from(value));
  }
  if (value is String) {
    final text = value.trim();
    if (text.isEmpty) return null;
    return ContactFormOption(label: text, value: text);
  }
  if (value == null) return null;
  final text = value.toString();
  if (text.isEmpty) return null;
  return ContactFormOption(label: text, value: text);
}
