import 'package:flutter/foundation.dart';

class MilestoneDetailModel {
  final String id;
  final String projectId;
  final String projectName;
  final String title;
  final double budget;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String status;

  final List<dynamic> talents;
  final List<dynamic> mentors;
  final List<dynamic> attachments;

  MilestoneDetailModel({
    required this.id,
    required this.projectId,
    required this.projectName,
    required this.title,
    required this.budget,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.talents,
    required this.mentors,
    required this.attachments,
  });

  factory MilestoneDetailModel.fromJson(Map<String, dynamic> json) {
    try {
      final data = json;

      return MilestoneDetailModel(
        id: data['id']?.toString() ?? '',
        projectId: data['projectId']?.toString() ?? '',
        projectName: data['projectName']?.toString() ?? '',
        title: data['title']?.toString() ?? '',
        budget: (data['budget'] ?? 0).toDouble(),
        description: data['description']?.toString() ?? '',
        startDate: DateTime.parse(data['startDate']),
        endDate: DateTime.parse(data['endDate']),
        status: data['status']?.toString() ?? 'UNKNOWN',
        talents: data['talents'] ?? [],
        mentors: data['mentors'] ?? [],
        attachments: data['attachments'] ?? [],
      );
    } catch (e) {
      debugPrint("❌ Error parsing MilestoneDetailModel: $e");
      rethrow;
    }
  }
}
