class BankInfoRequest {
  final String bankName; // PayOS bank code
  final String accountNumber;
  final String accountHolderName;

  const BankInfoRequest({
    required this.bankName,
    required this.accountNumber,
    required this.accountHolderName,
  });

  Map<String, dynamic> toJson() {
    return {
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountHolderName': accountHolderName,
    };
  }

  @override
  String toString() {
    return 'BankInfoRequest(bankName: $bankName, accountNumber: $accountNumber, accountHolderName: $accountHolderName)';
  }
}
