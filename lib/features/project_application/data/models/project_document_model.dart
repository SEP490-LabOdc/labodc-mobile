class ProjectDocumentModel {
  final String id;
  final String projectId;
  final String documentName;
  final String documentUrl;
  final String documentType;
  final DateTime uploadedAt;

  ProjectDocumentModel({
    required this.id,
    required this.projectId,
    required this.documentName,
    required this.documentUrl,
    required this.documentType,
    required this.uploadedAt,
  });

  factory ProjectDocumentModel.fromJson(Map<String, dynamic> json) {
    return ProjectDocumentModel(
      id: json['id'] ?? '',
      projectId: json['projectId'] ?? '',
      documentName: json['documentName'] ?? 'Tài liệu không tên',
      documentUrl: json['documentUrl'] ?? '',
      documentType: json['documentType'] ?? 'FILE',
      uploadedAt: DateTime.tryParse(json['uploadedAt'] ?? '') ?? DateTime.now(),
    );
  }
}