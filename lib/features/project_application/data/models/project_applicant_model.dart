class ProjectApplicantModel {
  final String id;
  final String userId;
  final String name;
  final String cvUrl;
  final String status;
  final DateTime appliedAt;
  final AiScanResult? aiScanResult;

  ProjectApplicantModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.cvUrl,
    required this.status,
    required this.appliedAt,
    required this.aiScanResult,
  });

  factory ProjectApplicantModel.fromJson(Map<String, dynamic> json) {
    return ProjectApplicantModel(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      cvUrl: json['cvUrl'],
      status: json['status'],
      appliedAt: DateTime.parse(json['appliedAt']),
      aiScanResult: json['aiScanResult'] != null
          ? AiScanResult.fromJson(json['aiScanResult'])
          : null,
    );
  }
}

class AiScanResult {
  final bool? isCv;
  final String? reason;
  final double? matchScore;
  final String? summary;
  final List<String>? pros;
  final List<String>? cons;

  AiScanResult({
    this.isCv,
    this.reason,
    this.matchScore,
    this.summary,
    this.pros,
    this.cons,
  });

  factory AiScanResult.fromJson(Map<String, dynamic> json) {
    return AiScanResult(
      isCv: json['isCv'],
      reason: json['reason'],
      matchScore: (json['matchScore'] as num?)?.toDouble(),
      summary: json['summary'],

      pros: json['pros'] != null
          ? List<String>.from(json['pros'])
          : null,

      cons: json['cons'] != null
          ? List<String>.from(json['cons'])
          : null,
    );
  }
}
