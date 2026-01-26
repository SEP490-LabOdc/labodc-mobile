class VietQRBank {
  final int id;
  final String name;
  final String code;
  final String bin;
  final String shortName;
  final String logo;
  final int transferSupported;
  final int lookupSupported;
  final String? swiftCode;

  VietQRBank({
    required this.id,
    required this.name,
    required this.code,
    required this.bin,
    required this.shortName,
    required this.logo,
    required this.transferSupported,
    required this.lookupSupported,
    this.swiftCode,
  });

  factory VietQRBank.fromJson(Map<String, dynamic> json) {
    return VietQRBank(
      id: json['id'] as int,
      name: json['name'] as String,
      code: json['code'] as String,
      bin: json['bin'] as String,
      shortName: json['shortName'] ?? json['short_name'] ?? '',
      logo: json['logo'] as String,
      transferSupported: json['transferSupported'] ?? json['isTransfer'] ?? 0,
      lookupSupported: json['lookupSupported'] ?? 0,
      swiftCode: json['swift_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'bin': bin,
      'shortName': shortName,
      'logo': logo,
      'transferSupported': transferSupported,
      'lookupSupported': lookupSupported,
      'swift_code': swiftCode,
    };
  }

  /// Check if bank supports transfer (for filtering)
  bool get supportsTransfer => transferSupported == 1;
}
