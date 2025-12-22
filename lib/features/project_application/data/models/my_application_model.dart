class MyApplicationModel {
  final String id;
  final String projectId;
  final String projectName;
  final String cvUrl;
  final String status;
  final DateTime appliedAt;
  final DateTime updatedAt;
  final String? reason;

  MyApplicationModel({
    required this.id,
    required this.projectId,
    required this.projectName,
    required this.cvUrl,
    required this.status,
    required this.appliedAt,
    required this.updatedAt,
    this.reason,
  });

  factory MyApplicationModel.fromJson(Map<String, dynamic> json) {
    return MyApplicationModel(
      id: json['id'] ?? '',
      projectId: json['projectId'] ?? '',
      projectName: json['projectName'] ?? 'Dự án không tên',
      cvUrl: json['cvUrl'] ?? '',
      status: json['status'] ?? 'PENDING',
      appliedAt: DateTime.parse(json['appliedAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      reason: json['reason'] ?? (json['status'] == 'REJECTED' ? "Hồ sơ chưa phù hợp với yêu cầu kỹ thuật của dự án." : null),
    );
  }
}