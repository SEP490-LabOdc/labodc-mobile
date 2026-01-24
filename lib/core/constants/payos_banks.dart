class PayOSBank {
  final String code;
  final String fullName;
  final String logo; // URL or asset path

  const PayOSBank({
    required this.code,
    required this.fullName,
    required this.logo,
  });
}

/// PayOS supported banks for Vietnam
class PayOSBanks {
  static const List<PayOSBank> supported = [
    PayOSBank(
      code: 'MB',
      fullName: 'Ngân hàng Quân đội (MB Bank)',
      logo: '🏦', // Temporary emoji, replace with actual logo URL/asset
    ),
    PayOSBank(code: 'OCB', fullName: 'Ngân hàng Phương Đông (OCB)', logo: '🏦'),
    PayOSBank(
      code: 'KienlongBank',
      fullName: 'Ngân hàng Kiên Long (KienlongBank)',
      logo: '🏦',
    ),
    PayOSBank(code: 'ACB', fullName: 'Ngân hàng Á Châu (ACB)', logo: '🏦'),
    PayOSBank(
      code: 'BIDV',
      fullName: 'Ngân hàng Đầu tư và Phát triển Việt Nam (BIDV)',
      logo: '🏦',
    ),
  ];

  /// Get bank by code
  static PayOSBank? getByCode(String code) {
    try {
      return supported.firstWhere((bank) => bank.code == code);
    } catch (e) {
      return null;
    }
  }

  /// Get bank full name by code
  static String getFullName(String code) {
    return getByCode(code)?.fullName ?? code;
  }
}
