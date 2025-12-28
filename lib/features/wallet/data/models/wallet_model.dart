class WalletModel {
  final String id;
  final double balance;
  final double heldBalance;
  final String currency;
  final String status;

  WalletModel({
    required this.id,
    required this.balance,
    required this.heldBalance,
    required this.currency,
    required this.status,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] ?? '',
      balance: json['balance'] ?? 0,
      heldBalance: json['heldBalance'] ?? 0,
      currency: json['currency'] ?? 'VND',
      status: json['status'] ?? '',
    );
  }
}