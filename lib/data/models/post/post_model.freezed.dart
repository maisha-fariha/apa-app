// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FeaturedImage _$FeaturedImageFromJson(Map<String, dynamic> json) {
  return _FeaturedImage.fromJson(json);
}

/// @nodoc
mixin _$FeaturedImage {
  @JsonKey(fromJson: _intFromJson)
  int get id => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  String get alt => throw _privateConstructorUsedError;

  /// Serializes this FeaturedImage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FeaturedImage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeaturedImageCopyWith<FeaturedImage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeaturedImageCopyWith<$Res> {
  factory $FeaturedImageCopyWith(
    FeaturedImage value,
    $Res Function(FeaturedImage) then,
  ) = _$FeaturedImageCopyWithImpl<$Res, FeaturedImage>;
  @useResult
  $Res call({@JsonKey(fromJson: _intFromJson) int id, String url, String alt});
}

/// @nodoc
class _$FeaturedImageCopyWithImpl<$Res, $Val extends FeaturedImage>
    implements $FeaturedImageCopyWith<$Res> {
  _$FeaturedImageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeaturedImage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? url = null, Object? alt = null}) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            url: null == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String,
            alt: null == alt
                ? _value.alt
                : alt // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FeaturedImageImplCopyWith<$Res>
    implements $FeaturedImageCopyWith<$Res> {
  factory _$$FeaturedImageImplCopyWith(
    _$FeaturedImageImpl value,
    $Res Function(_$FeaturedImageImpl) then,
  ) = __$$FeaturedImageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@JsonKey(fromJson: _intFromJson) int id, String url, String alt});
}

/// @nodoc
class __$$FeaturedImageImplCopyWithImpl<$Res>
    extends _$FeaturedImageCopyWithImpl<$Res, _$FeaturedImageImpl>
    implements _$$FeaturedImageImplCopyWith<$Res> {
  __$$FeaturedImageImplCopyWithImpl(
    _$FeaturedImageImpl _value,
    $Res Function(_$FeaturedImageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FeaturedImage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? url = null, Object? alt = null}) {
    return _then(
      _$FeaturedImageImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        url: null == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String,
        alt: null == alt
            ? _value.alt
            : alt // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FeaturedImageImpl implements _FeaturedImage {
  const _$FeaturedImageImpl({
    @JsonKey(fromJson: _intFromJson) this.id = 0,
    this.url = '',
    this.alt = '',
  });

  factory _$FeaturedImageImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeaturedImageImplFromJson(json);

  @override
  @JsonKey(fromJson: _intFromJson)
  final int id;
  @override
  @JsonKey()
  final String url;
  @override
  @JsonKey()
  final String alt;

  @override
  String toString() {
    return 'FeaturedImage(id: $id, url: $url, alt: $alt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeaturedImageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.alt, alt) || other.alt == alt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, url, alt);

  /// Create a copy of FeaturedImage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeaturedImageImplCopyWith<_$FeaturedImageImpl> get copyWith =>
      __$$FeaturedImageImplCopyWithImpl<_$FeaturedImageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FeaturedImageImplToJson(this);
  }
}

abstract class _FeaturedImage implements FeaturedImage {
  const factory _FeaturedImage({
    @JsonKey(fromJson: _intFromJson) final int id,
    final String url,
    final String alt,
  }) = _$FeaturedImageImpl;

  factory _FeaturedImage.fromJson(Map<String, dynamic> json) =
      _$FeaturedImageImpl.fromJson;

  @override
  @JsonKey(fromJson: _intFromJson)
  int get id;
  @override
  String get url;
  @override
  String get alt;

  /// Create a copy of FeaturedImage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeaturedImageImplCopyWith<_$FeaturedImageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PostItem _$PostItemFromJson(Map<String, dynamic> json) {
  return _PostItem.fromJson(json);
}

/// @nodoc
mixin _$PostItem {
  @JsonKey(fromJson: _intFromJson)
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get slug => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get date => throw _privateConstructorUsedError;
  String get modified => throw _privateConstructorUsedError;
  String get template => throw _privateConstructorUsedError;
  String get permalink => throw _privateConstructorUsedError;
  @JsonKey(name: 'featured_image', fromJson: _featuredImageFromJson)
  FeaturedImage get featuredImage => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _dynamicListFromJson)
  List<dynamic> get taxonomies => throw _privateConstructorUsedError;
  @JsonKey(name: 'acf_fields', fromJson: _acfFieldsFromJson)
  Map<String, dynamic> get acfFields => throw _privateConstructorUsedError;
  @JsonKey(name: 'funding_progress', fromJson: _acfFieldsFromJson)
  Map<String, dynamic> get fundingProgress =>
      throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String get excerpt => throw _privateConstructorUsedError;

  /// Serializes this PostItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PostItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PostItemCopyWith<PostItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PostItemCopyWith<$Res> {
  factory $PostItemCopyWith(PostItem value, $Res Function(PostItem) then) =
      _$PostItemCopyWithImpl<$Res, PostItem>;
  @useResult
  $Res call({
    @JsonKey(fromJson: _intFromJson) int id,
    String title,
    String slug,
    String type,
    String status,
    String date,
    String modified,
    String template,
    String permalink,
    @JsonKey(name: 'featured_image', fromJson: _featuredImageFromJson)
    FeaturedImage featuredImage,
    @JsonKey(fromJson: _dynamicListFromJson) List<dynamic> taxonomies,
    @JsonKey(name: 'acf_fields', fromJson: _acfFieldsFromJson)
    Map<String, dynamic> acfFields,
    @JsonKey(name: 'funding_progress', fromJson: _acfFieldsFromJson)
    Map<String, dynamic> fundingProgress,
    String content,
    String excerpt,
  });

  $FeaturedImageCopyWith<$Res> get featuredImage;
}

/// @nodoc
class _$PostItemCopyWithImpl<$Res, $Val extends PostItem>
    implements $PostItemCopyWith<$Res> {
  _$PostItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PostItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? slug = null,
    Object? type = null,
    Object? status = null,
    Object? date = null,
    Object? modified = null,
    Object? template = null,
    Object? permalink = null,
    Object? featuredImage = null,
    Object? taxonomies = null,
    Object? acfFields = null,
    Object? fundingProgress = null,
    Object? content = null,
    Object? excerpt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            slug: null == slug
                ? _value.slug
                : slug // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String,
            modified: null == modified
                ? _value.modified
                : modified // ignore: cast_nullable_to_non_nullable
                      as String,
            template: null == template
                ? _value.template
                : template // ignore: cast_nullable_to_non_nullable
                      as String,
            permalink: null == permalink
                ? _value.permalink
                : permalink // ignore: cast_nullable_to_non_nullable
                      as String,
            featuredImage: null == featuredImage
                ? _value.featuredImage
                : featuredImage // ignore: cast_nullable_to_non_nullable
                      as FeaturedImage,
            taxonomies: null == taxonomies
                ? _value.taxonomies
                : taxonomies // ignore: cast_nullable_to_non_nullable
                      as List<dynamic>,
            acfFields: null == acfFields
                ? _value.acfFields
                : acfFields // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            fundingProgress: null == fundingProgress
                ? _value.fundingProgress
                : fundingProgress // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            excerpt: null == excerpt
                ? _value.excerpt
                : excerpt // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }

  /// Create a copy of PostItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FeaturedImageCopyWith<$Res> get featuredImage {
    return $FeaturedImageCopyWith<$Res>(_value.featuredImage, (value) {
      return _then(_value.copyWith(featuredImage: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PostItemImplCopyWith<$Res>
    implements $PostItemCopyWith<$Res> {
  factory _$$PostItemImplCopyWith(
    _$PostItemImpl value,
    $Res Function(_$PostItemImpl) then,
  ) = __$$PostItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(fromJson: _intFromJson) int id,
    String title,
    String slug,
    String type,
    String status,
    String date,
    String modified,
    String template,
    String permalink,
    @JsonKey(name: 'featured_image', fromJson: _featuredImageFromJson)
    FeaturedImage featuredImage,
    @JsonKey(fromJson: _dynamicListFromJson) List<dynamic> taxonomies,
    @JsonKey(name: 'acf_fields', fromJson: _acfFieldsFromJson)
    Map<String, dynamic> acfFields,
    @JsonKey(name: 'funding_progress', fromJson: _acfFieldsFromJson)
    Map<String, dynamic> fundingProgress,
    String content,
    String excerpt,
  });

  @override
  $FeaturedImageCopyWith<$Res> get featuredImage;
}

/// @nodoc
class __$$PostItemImplCopyWithImpl<$Res>
    extends _$PostItemCopyWithImpl<$Res, _$PostItemImpl>
    implements _$$PostItemImplCopyWith<$Res> {
  __$$PostItemImplCopyWithImpl(
    _$PostItemImpl _value,
    $Res Function(_$PostItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PostItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? slug = null,
    Object? type = null,
    Object? status = null,
    Object? date = null,
    Object? modified = null,
    Object? template = null,
    Object? permalink = null,
    Object? featuredImage = null,
    Object? taxonomies = null,
    Object? acfFields = null,
    Object? fundingProgress = null,
    Object? content = null,
    Object? excerpt = null,
  }) {
    return _then(
      _$PostItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        slug: null == slug
            ? _value.slug
            : slug // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String,
        modified: null == modified
            ? _value.modified
            : modified // ignore: cast_nullable_to_non_nullable
                  as String,
        template: null == template
            ? _value.template
            : template // ignore: cast_nullable_to_non_nullable
                  as String,
        permalink: null == permalink
            ? _value.permalink
            : permalink // ignore: cast_nullable_to_non_nullable
                  as String,
        featuredImage: null == featuredImage
            ? _value.featuredImage
            : featuredImage // ignore: cast_nullable_to_non_nullable
                  as FeaturedImage,
        taxonomies: null == taxonomies
            ? _value._taxonomies
            : taxonomies // ignore: cast_nullable_to_non_nullable
                  as List<dynamic>,
        acfFields: null == acfFields
            ? _value._acfFields
            : acfFields // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        fundingProgress: null == fundingProgress
            ? _value._fundingProgress
            : fundingProgress // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        excerpt: null == excerpt
            ? _value.excerpt
            : excerpt // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PostItemImpl extends _PostItem {
  const _$PostItemImpl({
    @JsonKey(fromJson: _intFromJson) this.id = 0,
    this.title = '',
    this.slug = '',
    this.type = '',
    this.status = '',
    this.date = '',
    this.modified = '',
    this.template = '',
    this.permalink = '',
    @JsonKey(name: 'featured_image', fromJson: _featuredImageFromJson)
    this.featuredImage = const FeaturedImage(),
    @JsonKey(fromJson: _dynamicListFromJson)
    final List<dynamic> taxonomies = const [],
    @JsonKey(name: 'acf_fields', fromJson: _acfFieldsFromJson)
    final Map<String, dynamic> acfFields = const {},
    @JsonKey(name: 'funding_progress', fromJson: _acfFieldsFromJson)
    final Map<String, dynamic> fundingProgress = const {},
    this.content = '',
    this.excerpt = '',
  }) : _taxonomies = taxonomies,
       _acfFields = acfFields,
       _fundingProgress = fundingProgress,
       super._();

  factory _$PostItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$PostItemImplFromJson(json);

  @override
  @JsonKey(fromJson: _intFromJson)
  final int id;
  @override
  @JsonKey()
  final String title;
  @override
  @JsonKey()
  final String slug;
  @override
  @JsonKey()
  final String type;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey()
  final String date;
  @override
  @JsonKey()
  final String modified;
  @override
  @JsonKey()
  final String template;
  @override
  @JsonKey()
  final String permalink;
  @override
  @JsonKey(name: 'featured_image', fromJson: _featuredImageFromJson)
  final FeaturedImage featuredImage;
  final List<dynamic> _taxonomies;
  @override
  @JsonKey(fromJson: _dynamicListFromJson)
  List<dynamic> get taxonomies {
    if (_taxonomies is EqualUnmodifiableListView) return _taxonomies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_taxonomies);
  }

  final Map<String, dynamic> _acfFields;
  @override
  @JsonKey(name: 'acf_fields', fromJson: _acfFieldsFromJson)
  Map<String, dynamic> get acfFields {
    if (_acfFields is EqualUnmodifiableMapView) return _acfFields;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_acfFields);
  }

  final Map<String, dynamic> _fundingProgress;
  @override
  @JsonKey(name: 'funding_progress', fromJson: _acfFieldsFromJson)
  Map<String, dynamic> get fundingProgress {
    if (_fundingProgress is EqualUnmodifiableMapView) return _fundingProgress;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_fundingProgress);
  }

  @override
  @JsonKey()
  final String content;
  @override
  @JsonKey()
  final String excerpt;

  @override
  String toString() {
    return 'PostItem(id: $id, title: $title, slug: $slug, type: $type, status: $status, date: $date, modified: $modified, template: $template, permalink: $permalink, featuredImage: $featuredImage, taxonomies: $taxonomies, acfFields: $acfFields, fundingProgress: $fundingProgress, content: $content, excerpt: $excerpt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PostItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.modified, modified) ||
                other.modified == modified) &&
            (identical(other.template, template) ||
                other.template == template) &&
            (identical(other.permalink, permalink) ||
                other.permalink == permalink) &&
            (identical(other.featuredImage, featuredImage) ||
                other.featuredImage == featuredImage) &&
            const DeepCollectionEquality().equals(
              other._taxonomies,
              _taxonomies,
            ) &&
            const DeepCollectionEquality().equals(
              other._acfFields,
              _acfFields,
            ) &&
            const DeepCollectionEquality().equals(
              other._fundingProgress,
              _fundingProgress,
            ) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.excerpt, excerpt) || other.excerpt == excerpt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    slug,
    type,
    status,
    date,
    modified,
    template,
    permalink,
    featuredImage,
    const DeepCollectionEquality().hash(_taxonomies),
    const DeepCollectionEquality().hash(_acfFields),
    const DeepCollectionEquality().hash(_fundingProgress),
    content,
    excerpt,
  );

  /// Create a copy of PostItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PostItemImplCopyWith<_$PostItemImpl> get copyWith =>
      __$$PostItemImplCopyWithImpl<_$PostItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PostItemImplToJson(this);
  }
}

abstract class _PostItem extends PostItem {
  const factory _PostItem({
    @JsonKey(fromJson: _intFromJson) final int id,
    final String title,
    final String slug,
    final String type,
    final String status,
    final String date,
    final String modified,
    final String template,
    final String permalink,
    @JsonKey(name: 'featured_image', fromJson: _featuredImageFromJson)
    final FeaturedImage featuredImage,
    @JsonKey(fromJson: _dynamicListFromJson) final List<dynamic> taxonomies,
    @JsonKey(name: 'acf_fields', fromJson: _acfFieldsFromJson)
    final Map<String, dynamic> acfFields,
    @JsonKey(name: 'funding_progress', fromJson: _acfFieldsFromJson)
    final Map<String, dynamic> fundingProgress,
    final String content,
    final String excerpt,
  }) = _$PostItemImpl;
  const _PostItem._() : super._();

  factory _PostItem.fromJson(Map<String, dynamic> json) =
      _$PostItemImpl.fromJson;

  @override
  @JsonKey(fromJson: _intFromJson)
  int get id;
  @override
  String get title;
  @override
  String get slug;
  @override
  String get type;
  @override
  String get status;
  @override
  String get date;
  @override
  String get modified;
  @override
  String get template;
  @override
  String get permalink;
  @override
  @JsonKey(name: 'featured_image', fromJson: _featuredImageFromJson)
  FeaturedImage get featuredImage;
  @override
  @JsonKey(fromJson: _dynamicListFromJson)
  List<dynamic> get taxonomies;
  @override
  @JsonKey(name: 'acf_fields', fromJson: _acfFieldsFromJson)
  Map<String, dynamic> get acfFields;
  @override
  @JsonKey(name: 'funding_progress', fromJson: _acfFieldsFromJson)
  Map<String, dynamic> get fundingProgress;
  @override
  String get content;
  @override
  String get excerpt;

  /// Create a copy of PostItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PostItemImplCopyWith<_$PostItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GetAllPostsResponse _$GetAllPostsResponseFromJson(Map<String, dynamic> json) {
  return _GetAllPostsResponse.fromJson(json);
}

/// @nodoc
mixin _$GetAllPostsResponse {
  bool get success => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _intFromJson)
  int get count => throw _privateConstructorUsedError;
  List<PostItem> get items => throw _privateConstructorUsedError;

  /// Serializes this GetAllPostsResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GetAllPostsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GetAllPostsResponseCopyWith<GetAllPostsResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetAllPostsResponseCopyWith<$Res> {
  factory $GetAllPostsResponseCopyWith(
    GetAllPostsResponse value,
    $Res Function(GetAllPostsResponse) then,
  ) = _$GetAllPostsResponseCopyWithImpl<$Res, GetAllPostsResponse>;
  @useResult
  $Res call({
    bool success,
    @JsonKey(fromJson: _intFromJson) int count,
    List<PostItem> items,
  });
}

/// @nodoc
class _$GetAllPostsResponseCopyWithImpl<$Res, $Val extends GetAllPostsResponse>
    implements $GetAllPostsResponseCopyWith<$Res> {
  _$GetAllPostsResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GetAllPostsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? count = null,
    Object? items = null,
  }) {
    return _then(
      _value.copyWith(
            success: null == success
                ? _value.success
                : success // ignore: cast_nullable_to_non_nullable
                      as bool,
            count: null == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                      as int,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<PostItem>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GetAllPostsResponseImplCopyWith<$Res>
    implements $GetAllPostsResponseCopyWith<$Res> {
  factory _$$GetAllPostsResponseImplCopyWith(
    _$GetAllPostsResponseImpl value,
    $Res Function(_$GetAllPostsResponseImpl) then,
  ) = __$$GetAllPostsResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool success,
    @JsonKey(fromJson: _intFromJson) int count,
    List<PostItem> items,
  });
}

/// @nodoc
class __$$GetAllPostsResponseImplCopyWithImpl<$Res>
    extends _$GetAllPostsResponseCopyWithImpl<$Res, _$GetAllPostsResponseImpl>
    implements _$$GetAllPostsResponseImplCopyWith<$Res> {
  __$$GetAllPostsResponseImplCopyWithImpl(
    _$GetAllPostsResponseImpl _value,
    $Res Function(_$GetAllPostsResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GetAllPostsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? count = null,
    Object? items = null,
  }) {
    return _then(
      _$GetAllPostsResponseImpl(
        success: null == success
            ? _value.success
            : success // ignore: cast_nullable_to_non_nullable
                  as bool,
        count: null == count
            ? _value.count
            : count // ignore: cast_nullable_to_non_nullable
                  as int,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<PostItem>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GetAllPostsResponseImpl implements _GetAllPostsResponse {
  const _$GetAllPostsResponseImpl({
    this.success = false,
    @JsonKey(fromJson: _intFromJson) this.count = 0,
    final List<PostItem> items = const [],
  }) : _items = items;

  factory _$GetAllPostsResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$GetAllPostsResponseImplFromJson(json);

  @override
  @JsonKey()
  final bool success;
  @override
  @JsonKey(fromJson: _intFromJson)
  final int count;
  final List<PostItem> _items;
  @override
  @JsonKey()
  List<PostItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'GetAllPostsResponse(success: $success, count: $count, items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetAllPostsResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.count, count) || other.count == count) &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    success,
    count,
    const DeepCollectionEquality().hash(_items),
  );

  /// Create a copy of GetAllPostsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GetAllPostsResponseImplCopyWith<_$GetAllPostsResponseImpl> get copyWith =>
      __$$GetAllPostsResponseImplCopyWithImpl<_$GetAllPostsResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$GetAllPostsResponseImplToJson(this);
  }
}

abstract class _GetAllPostsResponse implements GetAllPostsResponse {
  const factory _GetAllPostsResponse({
    final bool success,
    @JsonKey(fromJson: _intFromJson) final int count,
    final List<PostItem> items,
  }) = _$GetAllPostsResponseImpl;

  factory _GetAllPostsResponse.fromJson(Map<String, dynamic> json) =
      _$GetAllPostsResponseImpl.fromJson;

  @override
  bool get success;
  @override
  @JsonKey(fromJson: _intFromJson)
  int get count;
  @override
  List<PostItem> get items;

  /// Create a copy of GetAllPostsResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GetAllPostsResponseImplCopyWith<_$GetAllPostsResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
