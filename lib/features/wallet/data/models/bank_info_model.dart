import '../../domain/entities/bank_info_entity.dart';

class BankInfoModel extends BankInfoEntity {
  const BankInfoModel({
    required super.bankName,
    required super.accountNumber,
    required super.accountHolderName,
  });

  factory BankInfoModel.fromJson(Map<String, dynamic> json) {
    return BankInfoModel(
      bankName: json['bankName'] as String? ?? '',
      accountNumber: json['accountNumber'] as String? ?? '',
      accountHolderName: json['accountHolderName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountHolderName': accountHolderName,
    };
  }

  BankInfoModel copyWith({
    String? bankName,
    String? accountNumber,
    String? accountHolderName,
  }) {
    return BankInfoModel(
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      accountHolderName: accountHolderName ?? this.accountHolderName,
    );
  }
}
