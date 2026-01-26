import 'disbursement_leader_model.dart';

class MilestoneDisbursementModel {
  final String milestoneId;
  final double totalAmount;
  final double systemFee;
  final String status;
  final DisbursementLeaderModel? mentorLeader;
  final DisbursementLeaderModel? talentLeader;

  MilestoneDisbursementModel({
    required this.milestoneId,
    required this.totalAmount,
    required this.systemFee,
    required this.status,
    this.mentorLeader,
    this.talentLeader,
  });

  factory MilestoneDisbursementModel.fromJson(Map<String, dynamic> json) {
    try {
      return MilestoneDisbursementModel(
        milestoneId: json['milestoneId'] ?? '',
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
        systemFee: (json['systemFee'] as num?)?.toDouble() ?? 0.0,
        status: json['status'] ?? '',
        mentorLeader: json['mentorLeader'] != null
            ? DisbursementLeaderModel.fromJson(json['mentorLeader'])
            : null,
        talentLeader: json['talentLeader'] != null
            ? DisbursementLeaderModel.fromJson(json['talentLeader'])
            : null,
      );
    } catch (e) {
      throw Exception(
        'Error parsing MilestoneDisbursementModel: $e, json: $json',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'milestoneId': milestoneId,
      'totalAmount': totalAmount,
      'systemFee': systemFee,
      'status': status,
      'mentorLeader': mentorLeader?.toJson(),
      'talentLeader': talentLeader?.toJson(),
    };
  }
}
