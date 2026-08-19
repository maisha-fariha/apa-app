// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FeaturedImageImpl _$$FeaturedImageImplFromJson(Map<String, dynamic> json) =>
    _$FeaturedImageImpl(
      id: json['id'] == null ? 0 : _intFromJson(json['id']),
      url: json['url'] as String? ?? '',
      alt: json['alt'] as String? ?? '',
    );

Map<String, dynamic> _$$FeaturedImageImplToJson(_$FeaturedImageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'alt': instance.alt,
    };

_$PostItemImpl _$$PostItemImplFromJson(Map<String, dynamic> json) =>
    _$PostItemImpl(
      id: json['id'] == null ? 0 : _intFromJson(json['id']),
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      type: json['type'] as String? ?? '',
      status: json['status'] as String? ?? '',
      date: json['date'] as String? ?? '',
      modified: json['modified'] as String? ?? '',
      template: json['template'] as String? ?? '',
      permalink: json['permalink'] as String? ?? '',
      featuredImage: json['featured_image'] == null
          ? const FeaturedImage()
          : _featuredImageFromJson(json['featured_image']),
      taxonomies: json['taxonomies'] == null
          ? const []
          : _dynamicListFromJson(json['taxonomies']),
      acfFields: json['acf_fields'] == null
          ? const {}
          : _acfFieldsFromJson(json['acf_fields']),
    );

Map<String, dynamic> _$$PostItemImplToJson(_$PostItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'slug': instance.slug,
      'type': instance.type,
      'status': instance.status,
      'date': instance.date,
      'modified': instance.modified,
      'template': instance.template,
      'permalink': instance.permalink,
      'featured_image': instance.featuredImage.toJson(),
      'taxonomies': instance.taxonomies,
      'acf_fields': instance.acfFields,
    };

_$GetAllPostsResponseImpl _$$GetAllPostsResponseImplFromJson(
  Map<String, dynamic> json,
) => _$GetAllPostsResponseImpl(
  success: json['success'] as bool? ?? false,
  count: json['count'] == null ? 0 : _intFromJson(json['count']),
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => PostItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$GetAllPostsResponseImplToJson(
  _$GetAllPostsResponseImpl instance,
) => <String, dynamic>{
  'success': instance.success,
  'count': instance.count,
  'items': instance.items.map((e) => e.toJson()).toList(),
};
