class MilestoneWalletModel {
  final String id;
  final String ownerId;
  final String ownerType;
  final double balance;
  final double heldBalance;
  final String currency;
  final String status;
  final List<dynamic> bankInfos;

  MilestoneWalletModel({
    required this.id,
    required this.ownerId,
    required this.ownerType,
    required this.balance,
    required this.heldBalance,
    required this.currency,
    required this.status,
    this.bankInfos = const [],
  });

  factory MilestoneWalletModel.fromJson(Map<String, dynamic> json) {
    return MilestoneWalletModel(
      id: json['id'] ?? '',
      ownerId: json['ownerId'] ?? '',
      ownerType: json['ownerType'] ?? '',
      balance: json['balance'] is int
          ? (json['balance'] as int).toDouble()
          : (json['balance'] as double? ?? 0.0),
      heldBalance: json['heldBalance'] is int
          ? (json['heldBalance'] as int).toDouble()
          : (json['heldBalance'] as double? ?? 0.0),
      currency: json['currency'] ?? 'VND',
      status: json['status'] ?? '',
      bankInfos: json['bankInfos'] as List<dynamic>? ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'ownerType': ownerType,
      'balance': balance,
      'heldBalance': heldBalance,
      'currency': currency,
      'status': status,
      'bankInfos': bankInfos,
    };
  }
}
