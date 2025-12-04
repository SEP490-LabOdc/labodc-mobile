class ReportItemModel {
  final String id;
  final String projectId;
  final String projectName;
  final String reporterId;
  final String reporterName;
  final String reporterEmail;
  final String reporterAvatar;
  final String recipientId;
  final String reportType;
  final String status;
  final String content;
  final List<String> attachmentsUrl;
  final DateTime reportingDate;
  final DateTime createdAt;
  final String? feedback;
  final String milestoneId;
  final String milestoneTitle;

  ReportItemModel({
    required this.id,
    required this.projectId,
    required this.projectName,
    required this.reporterId,
    required this.reporterName,
    required this.reporterEmail,
    required this.reporterAvatar,
    required this.recipientId,
    required this.reportType,
    required this.status,
    required this.content,
    required this.attachmentsUrl,
    required this.reportingDate,
    required this.createdAt,
    required this.feedback,
    required this.milestoneId,
    required this.milestoneTitle,
  });

  factory ReportItemModel.fromJson(Map<String, dynamic> json) {
    return ReportItemModel(
      id: json["id"] ?? "",
      projectId: json["projectId"] ?? "",
      projectName: json["projectName"] ?? "",
      reporterId: json["reporterId"] ?? "",
      reporterName: json["reporterName"] ?? "",
      reporterEmail: json["reporterEmail"] ?? "",
      reporterAvatar: json["reporterAvatar"] ?? "",
      recipientId: json["recipientId"] ?? "",
      reportType: json["reportType"] ?? "",
      status: json["status"] ?? "",
      content: json["content"] ?? "",
      attachmentsUrl: List<String>.from(json["attachmentsUrl"] ?? []),
      reportingDate: DateTime.parse(json["reportingDate"]),
      createdAt: DateTime.parse(json["createdAt"]),
      feedback: json["feedback"],
      milestoneId: json["milestoneId"] ?? "",
      milestoneTitle: json["milestoneTitle"] ?? "",
    );
  }
}
