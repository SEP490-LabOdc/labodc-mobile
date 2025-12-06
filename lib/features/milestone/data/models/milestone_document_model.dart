class MilestoneDocumentModel {
  final String id;
  final String fileName;
  final String fileUrl;
  final String s3Key;
  final DateTime uploadedAt;
  final String entityId;

  MilestoneDocumentModel({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.s3Key,
    required this.uploadedAt,
    required this.entityId,
  });

  factory MilestoneDocumentModel.fromJson(Map<String, dynamic> json) {
    return MilestoneDocumentModel(
      id: json['id'] ?? '',
      fileName: json['fileName'] ?? 'Tài liệu không tên',
      fileUrl: json['fileUrl'] ?? '',
      s3Key: json['s3Key'] ?? '',
      uploadedAt: DateTime.tryParse(json['uploadedAt'] ?? '') ?? DateTime.now(),
      entityId: json['entityId'] ?? '',
    );
  }

  // Helper để xác định loại file dựa trên đuôi mở rộng
  String get fileType {
    if (fileName.contains('.')) {
      return fileName.split('.').last.toUpperCase();
    }
    return 'FILE';
  }
}