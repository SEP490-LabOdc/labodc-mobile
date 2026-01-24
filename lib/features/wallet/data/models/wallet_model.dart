import 'bank_info_model.dart';

class WalletModel {
  final String id;
  final double balance;
  final double heldBalance;
  final String currency;
  final String status;
  final List<BankInfoModel> bankInfos;

  WalletModel({
    required this.id,
    required this.balance,
    required this.heldBalance,
    required this.currency,
    required this.status,
    this.bankInfos = const [],
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] ?? '',
      balance: json['balance'] is int
          ? (json['balance'] as int).toDouble()
          : (json['balance'] as double? ?? 0.0),
      heldBalance: json['heldBalance'] is int
          ? (json['heldBalance'] as int).toDouble()
          : (json['heldBalance'] as double? ?? 0.0),
      currency: json['currency'] ?? 'VND',
      status: json['status'] ?? '',
      bankInfos:
          (json['bankInfos'] as List<dynamic>?)
              ?.map((e) => BankInfoModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  // Helper methods
  bool get hasBankInfo => bankInfos.isNotEmpty;
  BankInfoModel? get primaryBank => hasBankInfo ? bankInfos.first : null;
}
