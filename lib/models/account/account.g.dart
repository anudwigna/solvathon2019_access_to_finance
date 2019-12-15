// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Account _$AccountFromJson(Map<String, dynamic> json) {
  return Account(
      name: json['name'] as String,
      balance: json['balance'] as String,
      type: json['type'] as int,
      transactionIds:
          (json['transactionIds'] as List)?.map((e) => e as int)?.toList());
}

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
      'name': instance.name,
      'balance': instance.balance,
      'type': instance.type,
      'transactionIds': instance.transactionIds
    };
