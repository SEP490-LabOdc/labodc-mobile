class BankInfoEntity {
  final String bankName; // PayOS bank code: MB, OCB, etc.
  final String accountNumber;
  final String accountHolderName;

  const BankInfoEntity({
    required this.bankName,
    required this.accountNumber,
    required this.accountHolderName,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BankInfoEntity &&
          runtimeType == other.runtimeType &&
          bankName == other.bankName &&
          accountNumber == other.accountNumber &&
          accountHolderName == other.accountHolderName;

  @override
  int get hashCode =>
      bankName.hashCode ^ accountNumber.hashCode ^ accountHolderName.hashCode;

  @override
  String toString() {
    return 'BankInfoEntity(bankName: $bankName, accountNumber: $accountNumber, accountHolderName: $accountHolderName)';
  }
}
