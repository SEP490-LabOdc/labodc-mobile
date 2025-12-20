import 'dart:convert';

class TransactionModel {
  final String id;
  final double amount;
  final String type;
  final String direction;
  final String? description;
  final String status;
  final String? refType;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.direction,
    this.description,
    required this.status,
    this.refType,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      amount: json['amount'] ?? 0,
      type: json['type'] ?? '',
      direction: json['direction'] ?? '',
      description: json['description'],
      status: json['status'] ?? '',
      refType: json['refType'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  static List<TransactionModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((item) => TransactionModel.fromJson(item)).toList();
  }
}