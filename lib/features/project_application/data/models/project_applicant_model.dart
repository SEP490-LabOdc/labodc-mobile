class AiScanResultModel {
  final bool? isCv;
  final String? reason;
  final double? matchScore;
  final String? summary;
  final String? pros;
  final String? cons;

  const AiScanResultModel({
    this.isCv,
    this.reason,
    this.matchScore,
    this.summary,
    this.pros,
    this.cons,
  });

  factory AiScanResultModel.fromJson(Map<String, dynamic> json) {
    return AiScanResultModel(
      isCv: json['isCv'] as bool?,
      reason: json['reason'] as String?,
      matchScore: (json['matchScore'] as num?)?.toDouble(),
      summary: json['summary'] as String?,
      pros: json['pros'] as String?,
      cons: json['cons'] as String?,
    );
  }
}

class ProjectApplicantModel {
  final String id;
  final String userId;
  final String name;
  final String cvUrl;
  final String status;
  final DateTime appliedAt;
  final AiScanResultModel? aiScanResult;

  const ProjectApplicantModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.cvUrl,
    required this.status,
    required this.appliedAt,
    this.aiScanResult,
  });

  factory ProjectApplicantModel.fromJson(Map<String, dynamic> json) {
    return ProjectApplicantModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      cvUrl: json['cvUrl'] as String,
      status: json['status'] as String,
      appliedAt: DateTime.parse(json['appliedAt'] as String),
      aiScanResult: json['aiScanResult'] != null
          ? AiScanResultModel.fromJson(
        json['aiScanResult'] as Map<String, dynamic>,
      )
          : null,
    );
  }
}
