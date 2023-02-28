import 'package:json_annotation/json_annotation.dart';

part 'categoryHeading.g.dart';

@JsonSerializable()
class CategoryHeading extends Object {
  final int? id;
  final String? en;
  final String? np;
  final String? iconName;
  CategoryHeading({
    this.id,
    this.en,
    this.np,
    this.iconName,
  });

  factory CategoryHeading.fromJson(Map<String, dynamic> json) =>
      _$CategoryHeadingFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryHeadingToJson(this);
}
