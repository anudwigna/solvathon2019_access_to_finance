// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transaction _$TransactionFromJson(Map<String, dynamic> json) {
  return Transaction(
      id: json['id'] as int,
      transactionType: json['transactionType'] as int,
      categoryId: json['categoryId'] as int,
      name: json['name'] as String,
      memo: json['memo'] as String,
      amount: json['amount'] as String,
      year: json['year'] as int,
      month: json['month'] as int,
      timestamp: json['timestamp'] as String);
}

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'transactionType': instance.transactionType,
      'categoryId': instance.categoryId,
      'name': instance.name,
      'memo': instance.memo,
      'amount': instance.amount,
      'year': instance.year,
      'month': instance.month,
      'timestamp': instance.timestamp
    };
