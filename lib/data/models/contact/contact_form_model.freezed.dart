// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contact_form_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ContactFormOption _$ContactFormOptionFromJson(Map<String, dynamic> json) {
  return _ContactFormOption.fromJson(json);
}

/// @nodoc
mixin _$ContactFormOption {
  String get label => throw _privateConstructorUsedError;
  String get value => throw _privateConstructorUsedError;
  @JsonKey(name: 'default', fromJson: boolFromJson)
  bool get isDefault => throw _privateConstructorUsedError;

  /// Serializes this ContactFormOption to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ContactFormOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ContactFormOptionCopyWith<ContactFormOption> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ContactFormOptionCopyWith<$Res> {
  factory $ContactFormOptionCopyWith(
    ContactFormOption value,
    $Res Function(ContactFormOption) then,
  ) = _$ContactFormOptionCopyWithImpl<$Res, ContactFormOption>;
  @useResult
  $Res call({
    String label,
    String value,
    @JsonKey(name: 'default', fromJson: boolFromJson) bool isDefault,
  });
}

/// @nodoc
class _$ContactFormOptionCopyWithImpl<$Res, $Val extends ContactFormOption>
    implements $ContactFormOptionCopyWith<$Res> {
  _$ContactFormOptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ContactFormOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? value = null,
    Object? isDefault = null,
  }) {
    return _then(
      _value.copyWith(
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            value: null == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as String,
            isDefault: null == isDefault
                ? _value.isDefault
                : isDefault // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ContactFormOptionImplCopyWith<$Res>
    implements $ContactFormOptionCopyWith<$Res> {
  factory _$$ContactFormOptionImplCopyWith(
    _$ContactFormOptionImpl value,
    $Res Function(_$ContactFormOptionImpl) then,
  ) = __$$ContactFormOptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String label,
    String value,
    @JsonKey(name: 'default', fromJson: boolFromJson) bool isDefault,
  });
}

/// @nodoc
class __$$ContactFormOptionImplCopyWithImpl<$Res>
    extends _$ContactFormOptionCopyWithImpl<$Res, _$ContactFormOptionImpl>
    implements _$$ContactFormOptionImplCopyWith<$Res> {
  __$$ContactFormOptionImplCopyWithImpl(
    _$ContactFormOptionImpl _value,
    $Res Function(_$ContactFormOptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ContactFormOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? value = null,
    Object? isDefault = null,
  }) {
    return _then(
      _$ContactFormOptionImpl(
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        value: null == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as String,
        isDefault: null == isDefault
            ? _value.isDefault
            : isDefault // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ContactFormOptionImpl extends _ContactFormOption {
  const _$ContactFormOptionImpl({
    this.label = '',
    this.value = '',
    @JsonKey(name: 'default', fromJson: boolFromJson) this.isDefault = false,
  }) : super._();

  factory _$ContactFormOptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ContactFormOptionImplFromJson(json);

  @override
  @JsonKey()
  final String label;
  @override
  @JsonKey()
  final String value;
  @override
  @JsonKey(name: 'default', fromJson: boolFromJson)
  final bool isDefault;

  @override
  String toString() {
    return 'ContactFormOption(label: $label, value: $value, isDefault: $isDefault)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ContactFormOptionImpl &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, label, value, isDefault);

  /// Create a copy of ContactFormOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ContactFormOptionImplCopyWith<_$ContactFormOptionImpl> get copyWith =>
      __$$ContactFormOptionImplCopyWithImpl<_$ContactFormOptionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ContactFormOptionImplToJson(this);
  }
}

abstract class _ContactFormOption extends ContactFormOption {
  const factory _ContactFormOption({
    final String label,
    final String value,
    @JsonKey(name: 'default', fromJson: boolFromJson) final bool isDefault,
  }) = _$ContactFormOptionImpl;
  const _ContactFormOption._() : super._();

  factory _ContactFormOption.fromJson(Map<String, dynamic> json) =
      _$ContactFormOptionImpl.fromJson;

  @override
  String get label;
  @override
  String get value;
  @override
  @JsonKey(name: 'default', fromJson: boolFromJson)
  bool get isDefault;

  /// Create a copy of ContactFormOption
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ContactFormOptionImplCopyWith<_$ContactFormOptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ContactFormField _$ContactFormFieldFromJson(Map<String, dynamic> json) {
  return _ContactFormField.fromJson(json);
}

/// @nodoc
mixin _$ContactFormField {
  String get id => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  String get placeholder => throw _privateConstructorUsedError;
  @JsonKey(fromJson: boolFromJson)
  bool get required => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  @JsonKey(fromJson: contactFormOptionsFromJson)
  List<ContactFormOption> get options => throw _privateConstructorUsedError;

  /// Serializes this ContactFormField to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ContactFormField
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ContactFormFieldCopyWith<ContactFormField> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ContactFormFieldCopyWith<$Res> {
  factory $ContactFormFieldCopyWith(
    ContactFormField value,
    $Res Function(ContactFormField) then,
  ) = _$ContactFormFieldCopyWithImpl<$Res, ContactFormField>;
  @useResult
  $Res call({
    String id,
    String type,
    String label,
    String placeholder,
    @JsonKey(fromJson: boolFromJson) bool required,
    String description,
    @JsonKey(fromJson: contactFormOptionsFromJson)
    List<ContactFormOption> options,
  });
}

/// @nodoc
class _$ContactFormFieldCopyWithImpl<$Res, $Val extends ContactFormField>
    implements $ContactFormFieldCopyWith<$Res> {
  _$ContactFormFieldCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ContactFormField
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? label = null,
    Object? placeholder = null,
    Object? required = null,
    Object? description = null,
    Object? options = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            placeholder: null == placeholder
                ? _value.placeholder
                : placeholder // ignore: cast_nullable_to_non_nullable
                      as String,
            required: null == required
                ? _value.required
                : required // ignore: cast_nullable_to_non_nullable
                      as bool,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            options: null == options
                ? _value.options
                : options // ignore: cast_nullable_to_non_nullable
                      as List<ContactFormOption>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ContactFormFieldImplCopyWith<$Res>
    implements $ContactFormFieldCopyWith<$Res> {
  factory _$$ContactFormFieldImplCopyWith(
    _$ContactFormFieldImpl value,
    $Res Function(_$ContactFormFieldImpl) then,
  ) = __$$ContactFormFieldImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String type,
    String label,
    String placeholder,
    @JsonKey(fromJson: boolFromJson) bool required,
    String description,
    @JsonKey(fromJson: contactFormOptionsFromJson)
    List<ContactFormOption> options,
  });
}

/// @nodoc
class __$$ContactFormFieldImplCopyWithImpl<$Res>
    extends _$ContactFormFieldCopyWithImpl<$Res, _$ContactFormFieldImpl>
    implements _$$ContactFormFieldImplCopyWith<$Res> {
  __$$ContactFormFieldImplCopyWithImpl(
    _$ContactFormFieldImpl _value,
    $Res Function(_$ContactFormFieldImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ContactFormField
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? label = null,
    Object? placeholder = null,
    Object? required = null,
    Object? description = null,
    Object? options = null,
  }) {
    return _then(
      _$ContactFormFieldImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        placeholder: null == placeholder
            ? _value.placeholder
            : placeholder // ignore: cast_nullable_to_non_nullable
                  as String,
        required: null == required
            ? _value.required
            : required // ignore: cast_nullable_to_non_nullable
                  as bool,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        options: null == options
            ? _value._options
            : options // ignore: cast_nullable_to_non_nullable
                  as List<ContactFormOption>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ContactFormFieldImpl extends _ContactFormField {
  const _$ContactFormFieldImpl({
    this.id = '',
    this.type = 'text',
    this.label = '',
    this.placeholder = '',
    @JsonKey(fromJson: boolFromJson) this.required = false,
    this.description = '',
    @JsonKey(fromJson: contactFormOptionsFromJson)
    final List<ContactFormOption> options = const [],
  }) : _options = options,
       super._();

  factory _$ContactFormFieldImpl.fromJson(Map<String, dynamic> json) =>
      _$$ContactFormFieldImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey()
  final String type;
  @override
  @JsonKey()
  final String label;
  @override
  @JsonKey()
  final String placeholder;
  @override
  @JsonKey(fromJson: boolFromJson)
  final bool required;
  @override
  @JsonKey()
  final String description;
  final List<ContactFormOption> _options;
  @override
  @JsonKey(fromJson: contactFormOptionsFromJson)
  List<ContactFormOption> get options {
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_options);
  }

  @override
  String toString() {
    return 'ContactFormField(id: $id, type: $type, label: $label, placeholder: $placeholder, required: $required, description: $description, options: $options)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ContactFormFieldImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.placeholder, placeholder) ||
                other.placeholder == placeholder) &&
            (identical(other.required, required) ||
                other.required == required) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._options, _options));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    type,
    label,
    placeholder,
    required,
    description,
    const DeepCollectionEquality().hash(_options),
  );

  /// Create a copy of ContactFormField
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ContactFormFieldImplCopyWith<_$ContactFormFieldImpl> get copyWith =>
      __$$ContactFormFieldImplCopyWithImpl<_$ContactFormFieldImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ContactFormFieldImplToJson(this);
  }
}

abstract class _ContactFormField extends ContactFormField {
  const factory _ContactFormField({
    final String id,
    final String type,
    final String label,
    final String placeholder,
    @JsonKey(fromJson: boolFromJson) final bool required,
    final String description,
    @JsonKey(fromJson: contactFormOptionsFromJson)
    final List<ContactFormOption> options,
  }) = _$ContactFormFieldImpl;
  const _ContactFormField._() : super._();

  factory _ContactFormField.fromJson(Map<String, dynamic> json) =
      _$ContactFormFieldImpl.fromJson;

  @override
  String get id;
  @override
  String get type;
  @override
  String get label;
  @override
  String get placeholder;
  @override
  @JsonKey(fromJson: boolFromJson)
  bool get required;
  @override
  String get description;
  @override
  @JsonKey(fromJson: contactFormOptionsFromJson)
  List<ContactFormOption> get options;

  /// Create a copy of ContactFormField
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ContactFormFieldImplCopyWith<_$ContactFormFieldImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GetContactFormResponse _$GetContactFormResponseFromJson(
  Map<String, dynamic> json,
) {
  return _GetContactFormResponse.fromJson(json);
}

/// @nodoc
mixin _$GetContactFormResponse {
  @JsonKey(fromJson: boolFromJson)
  bool get success => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  List<ContactFormField> get fields => throw _privateConstructorUsedError;

  /// Serializes this GetContactFormResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GetContactFormResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GetContactFormResponseCopyWith<GetContactFormResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetContactFormResponseCopyWith<$Res> {
  factory $GetContactFormResponseCopyWith(
    GetContactFormResponse value,
    $Res Function(GetContactFormResponse) then,
  ) = _$GetContactFormResponseCopyWithImpl<$Res, GetContactFormResponse>;
  @useResult
  $Res call({
    @JsonKey(fromJson: boolFromJson) bool success,
    String message,
    List<ContactFormField> fields,
  });
}

/// @nodoc
class _$GetContactFormResponseCopyWithImpl<
  $Res,
  $Val extends GetContactFormResponse
>
    implements $GetContactFormResponseCopyWith<$Res> {
  _$GetContactFormResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GetContactFormResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? fields = null,
  }) {
    return _then(
      _value.copyWith(
            success: null == success
                ? _value.success
                : success // ignore: cast_nullable_to_non_nullable
                      as bool,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            fields: null == fields
                ? _value.fields
                : fields // ignore: cast_nullable_to_non_nullable
                      as List<ContactFormField>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GetContactFormResponseImplCopyWith<$Res>
    implements $GetContactFormResponseCopyWith<$Res> {
  factory _$$GetContactFormResponseImplCopyWith(
    _$GetContactFormResponseImpl value,
    $Res Function(_$GetContactFormResponseImpl) then,
  ) = __$$GetContactFormResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(fromJson: boolFromJson) bool success,
    String message,
    List<ContactFormField> fields,
  });
}

/// @nodoc
class __$$GetContactFormResponseImplCopyWithImpl<$Res>
    extends
        _$GetContactFormResponseCopyWithImpl<$Res, _$GetContactFormResponseImpl>
    implements _$$GetContactFormResponseImplCopyWith<$Res> {
  __$$GetContactFormResponseImplCopyWithImpl(
    _$GetContactFormResponseImpl _value,
    $Res Function(_$GetContactFormResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GetContactFormResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? fields = null,
  }) {
    return _then(
      _$GetContactFormResponseImpl(
        success: null == success
            ? _value.success
            : success // ignore: cast_nullable_to_non_nullable
                  as bool,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        fields: null == fields
            ? _value._fields
            : fields // ignore: cast_nullable_to_non_nullable
                  as List<ContactFormField>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GetContactFormResponseImpl implements _GetContactFormResponse {
  const _$GetContactFormResponseImpl({
    @JsonKey(fromJson: boolFromJson) this.success = false,
    this.message = '',
    final List<ContactFormField> fields = const [],
  }) : _fields = fields;

  factory _$GetContactFormResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$GetContactFormResponseImplFromJson(json);

  @override
  @JsonKey(fromJson: boolFromJson)
  final bool success;
  @override
  @JsonKey()
  final String message;
  final List<ContactFormField> _fields;
  @override
  @JsonKey()
  List<ContactFormField> get fields {
    if (_fields is EqualUnmodifiableListView) return _fields;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_fields);
  }

  @override
  String toString() {
    return 'GetContactFormResponse(success: $success, message: $message, fields: $fields)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetContactFormResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other._fields, _fields));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    success,
    message,
    const DeepCollectionEquality().hash(_fields),
  );

  /// Create a copy of GetContactFormResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GetContactFormResponseImplCopyWith<_$GetContactFormResponseImpl>
  get copyWith =>
      __$$GetContactFormResponseImplCopyWithImpl<_$GetContactFormResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$GetContactFormResponseImplToJson(this);
  }
}

abstract class _GetContactFormResponse implements GetContactFormResponse {
  const factory _GetContactFormResponse({
    @JsonKey(fromJson: boolFromJson) final bool success,
    final String message,
    final List<ContactFormField> fields,
  }) = _$GetContactFormResponseImpl;

  factory _GetContactFormResponse.fromJson(Map<String, dynamic> json) =
      _$GetContactFormResponseImpl.fromJson;

  @override
  @JsonKey(fromJson: boolFromJson)
  bool get success;
  @override
  String get message;
  @override
  List<ContactFormField> get fields;

  /// Create a copy of GetContactFormResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GetContactFormResponseImplCopyWith<_$GetContactFormResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

SubmitContactFormResponse _$SubmitContactFormResponseFromJson(
  Map<String, dynamic> json,
) {
  return _SubmitContactFormResponse.fromJson(json);
}

/// @nodoc
mixin _$SubmitContactFormResponse {
  @JsonKey(fromJson: boolFromJson)
  bool get success => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;

  /// Serializes this SubmitContactFormResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubmitContactFormResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubmitContactFormResponseCopyWith<SubmitContactFormResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubmitContactFormResponseCopyWith<$Res> {
  factory $SubmitContactFormResponseCopyWith(
    SubmitContactFormResponse value,
    $Res Function(SubmitContactFormResponse) then,
  ) = _$SubmitContactFormResponseCopyWithImpl<$Res, SubmitContactFormResponse>;
  @useResult
  $Res call({@JsonKey(fromJson: boolFromJson) bool success, String message});
}

/// @nodoc
class _$SubmitContactFormResponseCopyWithImpl<
  $Res,
  $Val extends SubmitContactFormResponse
>
    implements $SubmitContactFormResponseCopyWith<$Res> {
  _$SubmitContactFormResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubmitContactFormResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? success = null, Object? message = null}) {
    return _then(
      _value.copyWith(
            success: null == success
                ? _value.success
                : success // ignore: cast_nullable_to_non_nullable
                      as bool,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubmitContactFormResponseImplCopyWith<$Res>
    implements $SubmitContactFormResponseCopyWith<$Res> {
  factory _$$SubmitContactFormResponseImplCopyWith(
    _$SubmitContactFormResponseImpl value,
    $Res Function(_$SubmitContactFormResponseImpl) then,
  ) = __$$SubmitContactFormResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@JsonKey(fromJson: boolFromJson) bool success, String message});
}

/// @nodoc
class __$$SubmitContactFormResponseImplCopyWithImpl<$Res>
    extends
        _$SubmitContactFormResponseCopyWithImpl<
          $Res,
          _$SubmitContactFormResponseImpl
        >
    implements _$$SubmitContactFormResponseImplCopyWith<$Res> {
  __$$SubmitContactFormResponseImplCopyWithImpl(
    _$SubmitContactFormResponseImpl _value,
    $Res Function(_$SubmitContactFormResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubmitContactFormResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? success = null, Object? message = null}) {
    return _then(
      _$SubmitContactFormResponseImpl(
        success: null == success
            ? _value.success
            : success // ignore: cast_nullable_to_non_nullable
                  as bool,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SubmitContactFormResponseImpl implements _SubmitContactFormResponse {
  const _$SubmitContactFormResponseImpl({
    @JsonKey(fromJson: boolFromJson) this.success = false,
    this.message = '',
  });

  factory _$SubmitContactFormResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubmitContactFormResponseImplFromJson(json);

  @override
  @JsonKey(fromJson: boolFromJson)
  final bool success;
  @override
  @JsonKey()
  final String message;

  @override
  String toString() {
    return 'SubmitContactFormResponse(success: $success, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubmitContactFormResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, success, message);

  /// Create a copy of SubmitContactFormResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubmitContactFormResponseImplCopyWith<_$SubmitContactFormResponseImpl>
  get copyWith =>
      __$$SubmitContactFormResponseImplCopyWithImpl<
        _$SubmitContactFormResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubmitContactFormResponseImplToJson(this);
  }
}

abstract class _SubmitContactFormResponse implements SubmitContactFormResponse {
  const factory _SubmitContactFormResponse({
    @JsonKey(fromJson: boolFromJson) final bool success,
    final String message,
  }) = _$SubmitContactFormResponseImpl;

  factory _SubmitContactFormResponse.fromJson(Map<String, dynamic> json) =
      _$SubmitContactFormResponseImpl.fromJson;

  @override
  @JsonKey(fromJson: boolFromJson)
  bool get success;
  @override
  String get message;

  /// Create a copy of SubmitContactFormResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubmitContactFormResponseImplCopyWith<_$SubmitContactFormResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}
