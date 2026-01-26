class DisbursementLeaderModel {
  final String userId;
  final String fullName;
  final String email;
  final String avatarUrl;
  final String roleInProject;
  final double amount;
  final bool leader;

  DisbursementLeaderModel({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.avatarUrl,
    required this.roleInProject,
    required this.amount,
    required this.leader,
  });

  factory DisbursementLeaderModel.fromJson(Map<String, dynamic> json) {
    try {
      return DisbursementLeaderModel(
        userId: json['userId'] ?? '',
        fullName: json['fullName'] ?? '',
        email: json['email'] ?? '',
        avatarUrl: json['avatarUrl'] ?? '',
        roleInProject: json['roleInProject'] ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        leader: json['leader'] ?? false,
      );
    } catch (e) {
      throw Exception('Error parsing DisbursementLeaderModel: $e, json: $json');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fullName': fullName,
      'email': email,
      'avatarUrl': avatarUrl,
      'roleInProject': roleInProject,
      'amount': amount,
      'leader': leader,
    };
  }
}
