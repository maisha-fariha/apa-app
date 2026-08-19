// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_form_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ContactFormOptionImpl _$$ContactFormOptionImplFromJson(
  Map<String, dynamic> json,
) => _$ContactFormOptionImpl(
  label: json['label'] as String? ?? '',
  value: json['value'] as String? ?? '',
  isDefault: json['default'] == null ? false : boolFromJson(json['default']),
);

Map<String, dynamic> _$$ContactFormOptionImplToJson(
  _$ContactFormOptionImpl instance,
) => <String, dynamic>{
  'label': instance.label,
  'value': instance.value,
  'default': instance.isDefault,
};

_$ContactFormFieldImpl _$$ContactFormFieldImplFromJson(
  Map<String, dynamic> json,
) => _$ContactFormFieldImpl(
  id: json['id'] as String? ?? '',
  type: json['type'] as String? ?? 'text',
  label: json['label'] as String? ?? '',
  placeholder: json['placeholder'] as String? ?? '',
  required: json['required'] == null ? false : boolFromJson(json['required']),
  description: json['description'] as String? ?? '',
  options: json['options'] == null
      ? const []
      : contactFormOptionsFromJson(json['options']),
);

Map<String, dynamic> _$$ContactFormFieldImplToJson(
  _$ContactFormFieldImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'label': instance.label,
  'placeholder': instance.placeholder,
  'required': instance.required,
  'description': instance.description,
  'options': instance.options.map((e) => e.toJson()).toList(),
};

_$GetContactFormResponseImpl _$$GetContactFormResponseImplFromJson(
  Map<String, dynamic> json,
) => _$GetContactFormResponseImpl(
  success: json['success'] == null ? false : boolFromJson(json['success']),
  message: json['message'] as String? ?? '',
  fields:
      (json['fields'] as List<dynamic>?)
          ?.map((e) => ContactFormField.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$GetContactFormResponseImplToJson(
  _$GetContactFormResponseImpl instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'fields': instance.fields.map((e) => e.toJson()).toList(),
};

_$SubmitContactFormResponseImpl _$$SubmitContactFormResponseImplFromJson(
  Map<String, dynamic> json,
) => _$SubmitContactFormResponseImpl(
  success: json['success'] == null ? false : boolFromJson(json['success']),
  message: json['message'] as String? ?? '',
);

Map<String, dynamic> _$$SubmitContactFormResponseImplToJson(
  _$SubmitContactFormResponseImpl instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
};
