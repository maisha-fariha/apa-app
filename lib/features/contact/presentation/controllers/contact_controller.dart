import 'package:flutter/widgets.dart';
import 'package:gems_core/gems_core.dart';
import 'package:gems_data_layer/gems_data_layer.dart';
import 'package:get/get.dart';

import '../../../../data/models/contact/contact_form_model.dart';
import '../../../../data/repositories/contact_repository.dart';
import '../../domain/contact_form_validator.dart';

class ContactController extends BaseListController<ContactFormField> {
  ContactController({required this.repository});

  final ContactRepository repository;

  final RxBool isSubmitting = false.obs;
  final RxInt formEpoch = 0.obs;
  final RxMap<String, String> fieldErrors = <String, String>{}.obs;
  final RxMap<String, dynamic> values = <String, dynamic>{}.obs;

  final Map<String, TextEditingController> _textControllers = {};

  @override
  void onInit() {
    super.onInit();
    loadForm();
  }

  @override
  Future<void> loadItems() => loadForm();

  Future<void> loadForm({bool force = false}) async {
    if (isLoading.value) return;
    if (!force && items.isNotEmpty) return;

    setLoading(true);
    errorMessage.value = '';
    try {
      final result = await repository.getForm();
      result.when(
        success: (fields) {
          items
            ..clear()
            ..addAll(fields);
          _resetValues(fields);
        },
        failure: (error) {
          items.clear();
          _disposeTextControllers();
          values.clear();
          fieldErrors.clear();
          setError(error.message);
        },
      );
    } finally {
      setLoading(false);
    }
  }

  TextEditingController textControllerFor(ContactFormField field) {
    return _textControllers.putIfAbsent(field.id, () {
      final controller = TextEditingController(
        text: _asString(values[field.id]),
      );
      controller.addListener(() {
        values[field.id] = controller.text;
        _clearFieldError(field.id);
      });
      return controller;
    });
  }

  void setValue(String fieldId, dynamic value) {
    values[fieldId] = value;
    _clearFieldError(fieldId);
    _touch();
  }

  void toggleCheckbox(ContactFormField field, String optionValue) {
    final selected = List<String>.from(
      (values[field.id] as List?)?.map((item) => item.toString()) ??
          const <String>[],
    );
    if (selected.contains(optionValue)) {
      selected.remove(optionValue);
    } else {
      selected.add(optionValue);
    }
    setValue(field.id, selected);
  }

  bool isCheckboxSelected(ContactFormField field, String optionValue) {
    final value = values[field.id];
    if (value is bool) return value;
    if (value is Iterable) {
      return value.map((item) => item.toString()).contains(optionValue);
    }
    return value?.toString() == optionValue;
  }

  Future<Result<String>> submit() async {
    if (isSubmitting.value || isLoading.value || items.isEmpty) {
      return Result.failure(
        const ValidationError(message: 'The contact form is not ready yet.'),
      );
    }

    final errors = ContactFormValidator.validate(
      fields: items,
      values: values,
    );
    fieldErrors
      ..clear()
      ..addAll(errors);
    _touch();
    if (errors.isNotEmpty) {
      return Result.failure(
        ValidationError(
          message: errors.values.first,
          fieldErrors: {
            for (final entry in errors.entries) entry.key: [entry.value],
          },
        ),
      );
    }

    isSubmitting.value = true;
    try {
      final payload = ContactFormValidator.submitFields(
        fields: items,
        values: values,
      );
      final result = await repository.submitForm(payload);
      result.onSuccess((_) => _resetValues(items));
      return result;
    } finally {
      isSubmitting.value = false;
    }
  }

  void _resetValues(List<ContactFormField> fields) {
    fieldErrors.clear();
    values.clear();
    _syncTextControllers(fields);
    for (final field in fields) {
      values[field.id] = _defaultValue(field);
      if (field.kind.usesTextInput) {
        final controller = _textControllers[field.id];
        final text = _asString(values[field.id]);
        if (controller != null && controller.text != text) {
          controller.text = text;
        }
      }
    }
    _touch();
  }

  dynamic _defaultValue(ContactFormField field) {
    switch (field.kind) {
      case ContactFieldKind.select:
      case ContactFieldKind.radio:
        return field.defaultOptionValue ?? '';
      case ContactFieldKind.checkbox:
        if (field.options.isEmpty) return false;
        return field.defaultCheckboxValues;
      case ContactFieldKind.hidden:
        return field.defaultOptionValue ?? '';
      default:
        return '';
    }
  }

  void _syncTextControllers(List<ContactFormField> fields) {
    final keep = fields
        .where((field) => field.kind.usesTextInput)
        .map((field) => field.id)
        .toSet();
    for (final id in _textControllers.keys.toList()) {
      if (!keep.contains(id)) {
        _textControllers.remove(id)?.dispose();
      }
    }
    for (final field in fields.where((field) => field.kind.usesTextInput)) {
      textControllerFor(field);
    }
  }

  void _clearFieldError(String fieldId) {
    if (fieldErrors.containsKey(fieldId)) {
      fieldErrors.remove(fieldId);
      _touch();
    }
  }

  void _touch() => formEpoch.value++;

  String _asString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  void _disposeTextControllers() {
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    _textControllers.clear();
  }

  @override
  void onClose() {
    _disposeTextControllers();
    isSubmitting.close();
    formEpoch.close();
    fieldErrors.close();
    values.close();
    super.onClose();
  }
}
