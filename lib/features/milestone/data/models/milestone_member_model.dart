class MilestoneMemberModel {
  final String milestoneMemberId;
  final String projectMemberId;
  final String userId;
  final String fullName;
  final String email;
  final String phone;
  final String avatarUrl;
  final bool isActive;
  final DateTime joinedAt;
  final DateTime? leftAt;
  final bool leader;

  MilestoneMemberModel({
    required this.milestoneMemberId,
    required this.projectMemberId,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.isActive,
    required this.joinedAt,
    this.leftAt,
    required this.leader,
  });

  factory MilestoneMemberModel.fromJson(Map<String, dynamic> json) {
    return MilestoneMemberModel(
      milestoneMemberId: json['milestoneMemberId'] ?? '',
      projectMemberId: json['projectMemberId'] ?? '',
      userId: json['userId'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      isActive: json['isActive'] ?? true,
      joinedAt: json['joinedAt'] != null
          ? DateTime.parse(json['joinedAt'])
          : DateTime.now(),
      leftAt: json['leftAt'] != null ? DateTime.parse(json['leftAt']) : null,
      leader: json['leader'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'milestoneMemberId': milestoneMemberId,
      'projectMemberId': projectMemberId,
      'userId': userId,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'isActive': isActive,
      'joinedAt': joinedAt.toIso8601String(),
      'leftAt': leftAt?.toIso8601String(),
      'leader': leader,
    };
  }
}
