import 'transaction_model.dart';

class TransactionDetailModel extends TransactionModel {
  final double? balanceAfter;
  final String? refId;
  final String? refType;
  final String? walletId;
  final String? projectId;
  final String? milestoneId;
  final String? companyId;
  final DateTime updatedAt;

  TransactionDetailModel({
    required super.id,
    required super.amount,
    required super.type,
    required super.direction,
    required super.description,
    required super.status,
    required super.createdAt,
    this.balanceAfter,
    this.refId,
    this.refType,
    this.walletId,
    this.projectId,
    this.milestoneId,
    this.companyId,
    required this.updatedAt,
  });

  factory TransactionDetailModel.fromJson(Map<String, dynamic> json) {
    return TransactionDetailModel(
      id: json['id'] ?? '',
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] ?? '',
      direction: json['direction'] ?? '',
      description: json['description'],
      status: json['status'] ?? '',
      balanceAfter: json['balanceAfter'] != null
          ? (json['balanceAfter'] as num).toDouble()
          : null,
      refId: json['refId'],
      refType: json['refType'],
      walletId: json['walletId'],
      projectId: json['projectId'],
      milestoneId: json['milestoneId'],
      companyId: json['companyId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}