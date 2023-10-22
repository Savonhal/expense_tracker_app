// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Expense _$ExpenseFromJson(Map<String, dynamic> json) => Expense(
      json['name'] as String,
      (json['amount'] as num).toDouble(),
    );

Map<String, dynamic> _$ExpenseToJson(Expense instance) => <String, dynamic>{
      'name': instance.name,
      'amount': instance.amount,
    };

ExpenseList _$ExpenseListFromJson(Map<String, dynamic> json) => ExpenseList(
      json['categoryName'] as String,
    )..list = (json['list'] as List<dynamic>)
        .map((e) => Expense.fromJson(e as Map<String, dynamic>))
        .toList();

Map<String, dynamic> _$ExpenseListToJson(ExpenseList instance) =>
    <String, dynamic>{
      'categoryName': instance.categoryName,
      'list': instance.list,
    };
