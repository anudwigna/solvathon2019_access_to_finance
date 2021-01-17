import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

@JsonSerializable()
class Category {
  int id;
  String en;
  String np;
  String iconName;
  int categoryHeadingId;

  Category({this.id, this.en, this.np, this.iconName, this.categoryHeadingId});

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}
