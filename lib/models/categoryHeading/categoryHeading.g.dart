// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categoryHeading.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryHeading _$CategoryHeadingFromJson(Map<String, dynamic> json) {
  return CategoryHeading(
      id: json['id'] as int,
      en: json['en'] as String,
      np: json['np'] as String,
      iconName: json['iconName'] as String);
}

Map<String, dynamic> _$CategoryHeadingToJson(CategoryHeading instance) =>
    <String, dynamic>{
      'id': instance.id,
      'en': instance.en,
      'np': instance.np,
      'iconName': instance.iconName
    };
