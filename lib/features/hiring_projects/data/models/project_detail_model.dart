// lib/features/hiring_projects/data/models/project_detail_model.dart

import 'project_model.dart';

class ProjectDetailModel {
  final String id;
  final String companyId;
  final String title;
  final String description;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final double? budget;
  final List<SkillModel> skills;
  final List<dynamic> mentors;
  // Các trường bổ sung từ JSON
  final String? companyName;
  final String? currentMilestoneName;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProjectDetailModel({
    required this.id,
    required this.companyId,
    required this.title,
    required this.description,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.budget,
    required this.skills,
    required this.mentors,
    this.companyName,
    this.currentMilestoneName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProjectDetailModel.fromJson(Map<String, dynamic> json) {
    return ProjectDetailModel(
      id: json['id'] ?? '',
      companyId: json['companyId'] ?? '',
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? '',
      status: json['status'] ?? 'UNKNOWN',
      startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate'] ?? '') ?? DateTime.now(),
      budget: (json['budget'] as num?)?.toDouble(),
      skills: (json['skills'] as List?)?.map((e) => SkillModel.fromJson(e)).toList() ?? [],
      mentors: json['mentors'] ?? [],
      // Parse các trường mới
      companyName: json['companyName'],
      currentMilestoneName: json['currentMilestoneName'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}