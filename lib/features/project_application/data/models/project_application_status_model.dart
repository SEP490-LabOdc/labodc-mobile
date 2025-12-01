class ProjectApplicationStatusModel {
  final String? projectApplicationId;
  final bool canApply;
  final String fileLink;
  final String fileName;
  final String status;
  final DateTime? submittedAt;

  ProjectApplicationStatusModel({
    required this.projectApplicationId,
    required this.canApply,
    required this.fileLink,
    required this.fileName,
    required this.status,
    required this.submittedAt,
  });

  factory ProjectApplicationStatusModel.fromJson(Map<String, dynamic> json) {
    return ProjectApplicationStatusModel(
      projectApplicationId: json['projectApplicationId'] as String?,
      canApply: json['canApply'] as bool? ?? true,
      fileLink: json['fileLink'] as String? ?? '',
      fileName: json['fileName'] as String? ?? '',
      status: json['status'] as String? ?? '',
      submittedAt: json['submittedAt'] != null
          ? DateTime.tryParse(json['submittedAt'] as String)
          : null,
    );
  }
}
