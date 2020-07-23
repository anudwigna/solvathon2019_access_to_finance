import 'package:json_annotation/json_annotation.dart';

part 'budget.g.dart';

@JsonSerializable()
class Budget extends Object {
  final int month;
  final String total;
  final String spent;
  final int categoryId;
  final int year;

  Budget({this.month, this.total, this.spent, this.categoryId, this.year});

  factory Budget.fromJson(Map<String, dynamic> json) => _$BudgetFromJson(json);
  Map<String, dynamic> toJson() => _$BudgetToJson(this);
}
