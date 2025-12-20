class MilestoneDisbursementModel {
  final String disbursementId;
  final String milestoneId;
  final double totalAmount;
  final double systemFee;
  final double mentorAmount;
  final double talentAmount;
  final String status;
  final DateTime updatedAt;

  MilestoneDisbursementModel({
    required this.disbursementId,
    required this.milestoneId,
    required this.totalAmount,
    required this.systemFee,
    required this.mentorAmount,
    required this.talentAmount,
    required this.status,
    required this.updatedAt,
  });

  factory MilestoneDisbursementModel.fromJson(Map<String, dynamic> json) {
    return MilestoneDisbursementModel(
      disbursementId: json['disbursementId'] ?? '',
      milestoneId: json['milestoneId'] ?? '',
      totalAmount: (json['totalAmount'] as num).toDouble(),
      systemFee: (json['systemFee'] as num).toDouble(),
      mentorAmount: (json['mentorAmount'] as num).toDouble(),
      talentAmount: (json['talentAmount'] as num).toDouble(),
      status: json['status'] ?? '',
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}