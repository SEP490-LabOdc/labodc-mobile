class UserProfileModel {
  final String id;
  final String email;
  final String phone;
  final String fullName;
  final DateTime? birthDate;
  final String avatarUrl;
  final String role;
  final String gender;
  final String address;
  final String? status;

  UserProfileModel({
    required this.id,
    required this.email,
    required this.phone,
    required this.fullName,
    required this.birthDate,
    required this.avatarUrl,
    required this.role,
    required this.gender,
    required this.address,
    this.status,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      birthDate: json['birthDate'] != null
          ? DateTime.tryParse(json['birthDate'] as String)
          : null,
      avatarUrl: json['avatarUrl'] as String? ?? '',
      role: json['role'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      address: json['address'] as String? ?? '',
      status: json['status']?.toString(),
    );
  }

  /// Dùng khi muốn gửi lên API update
  String get birthDateString {
    if (birthDate == null) return '';
    // yyyy-MM-dd
    return '${birthDate!.year.toString().padLeft(4, '0')}-'
        '${birthDate!.month.toString().padLeft(2, '0')}-'
        '${birthDate!.day.toString().padLeft(2, '0')}';
  }

  UserProfileModel copyWith({
    String? phone,
    String? fullName,
    DateTime? birthDate,
    String? avatarUrl,
    String? gender,
    String? address,
  }) {
    return UserProfileModel(
      id: id,
      email: email,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      birthDate: birthDate ?? this.birthDate,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      status: status,
    );
  }
}
