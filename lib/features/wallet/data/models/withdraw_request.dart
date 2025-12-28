class WithdrawRequest {
  final double amount;
  final String bankName;
  final String accountNumber;
  final String accountName;

  WithdrawRequest({
    required this.amount,
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
  });

  Map<String, dynamic> toJson() {
    return {
      "amount": amount,
      "bankName": bankName,
      "accountNumber": accountNumber,
      "accountName": accountName,
    };
  }
}