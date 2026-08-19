import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gems_data_layer/gems_data_layer.dart';

part 'post_model.freezed.dart';
part 'post_model.g.dart';

// ignore_for_file: invalid_annotation_target

@freezed
class FeaturedImage with _$FeaturedImage {
  const factory FeaturedImage({
    @JsonKey(fromJson: _intFromJson) @Default(0) int id,
    @Default('') String url,
    @Default('') String alt,
  }) = _FeaturedImage;

  factory FeaturedImage.fromJson(Map<String, dynamic> json) =>
      _$FeaturedImageFromJson(json);
}

@freezed
class PostItem with _$PostItem implements BaseModel {
  const PostItem._();

  const factory PostItem({
    @JsonKey(fromJson: _intFromJson) @Default(0) int id,
    @Default('') String title,
    @Default('') String slug,
    @Default('') String type,
    @Default('') String status,
    @Default('') String date,
    @Default('') String modified,
    @Default('') String template,
    @Default('') String permalink,
    @JsonKey(name: 'featured_image', fromJson: _featuredImageFromJson)
    @Default(FeaturedImage())
    FeaturedImage featuredImage,
    @JsonKey(fromJson: _dynamicListFromJson) @Default([]) List<dynamic> taxonomies,
    @JsonKey(name: 'acf_fields', fromJson: _acfFieldsFromJson)
    @Default({})
    Map<String, dynamic> acfFields,
  }) = _PostItem;

  factory PostItem.fromJson(Map<String, dynamic> json) =>
      _$PostItemFromJson(json);

  String get normalizedTemplate {
    var value = template.trim().toLowerCase();
    if (value.contains('/')) {
      value = value.split('/').last;
    }
    if (value.contains(r'\')) {
      value = value.split(r'\').last;
    }
    return value;
  }

  String? get featuredImageUrl {
    final value = featuredImage.url.trim();
    return value.isEmpty ? null : value;
  }
}

@freezed
class GetAllPostsResponse with _$GetAllPostsResponse {
  const factory GetAllPostsResponse({
    @Default(false) bool success,
    @JsonKey(fromJson: _intFromJson) @Default(0) int count,
    @Default([]) List<PostItem> items,
  }) = _GetAllPostsResponse;

  factory GetAllPostsResponse.fromJson(Map<String, dynamic> json) =>
      _$GetAllPostsResponseFromJson(json);
}

int _intFromJson(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

FeaturedImage _featuredImageFromJson(dynamic value) {
  if (value is Map<String, dynamic>) {
    return FeaturedImage.fromJson(value);
  }
  if (value is Map) {
    return FeaturedImage.fromJson(Map<String, dynamic>.from(value));
  }
  return const FeaturedImage();
}

List<dynamic> _dynamicListFromJson(dynamic value) {
  if (value is List) return List<dynamic>.from(value);
  if (value == null) return const [];
  return [value];
}

Map<String, dynamic> _acfFieldsFromJson(dynamic value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return {};
}
