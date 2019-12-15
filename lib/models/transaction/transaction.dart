import 'package:json_annotation/json_annotation.dart';

part 'transaction.g.dart';

@JsonSerializable()
class Transaction extends Object {
  final int id;

  /// 0= Income , 1= Expense
  final int transactionType;
  final int categoryId;
  final String name;
  final String memo;
  final String amount;
  final int year;
  final int month;
  final String timestamp;

  Transaction({
    this.id,
    this.transactionType,
    this.categoryId,
    this.name,
    this.memo,
    this.amount,
    this.year,
    this.month,
    this.timestamp,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionToJson(this);
}
