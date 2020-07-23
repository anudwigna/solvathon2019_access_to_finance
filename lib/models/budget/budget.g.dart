// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Budget _$BudgetFromJson(Map<String, dynamic> json) {
  return Budget(
      month: json['month'] as int,
      total: json['total'] as String,
      spent: json['spent'] as String,
      categoryId: json['categoryId'] as int,
      year: json['year'] as int);
}

Map<String, dynamic> _$BudgetToJson(Budget instance) => <String, dynamic>{
      'month': instance.month,
      'total': instance.total,
      'spent': instance.spent,
      'categoryId': instance.categoryId,
      'year': instance.year
    };
