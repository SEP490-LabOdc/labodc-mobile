// lib/features/company/data/models/company_project_model.dart
class CompanyProjectModel {
  final String id;
  final String title;
  final String description;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final double budget;
  final List<String> skills;

  CompanyProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.budget,
    required this.skills,
  });

  factory CompanyProjectModel.fromJson(Map<String, dynamic> json) {
    return CompanyProjectModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : DateTime.now(),
      budget: double.tryParse(json['budget']?.toString() ?? '0') ?? 0,
      skills: (json['skills'] as List?)
          ?.map((s) => s['name'].toString())
          .toList() ?? [],
    );
  }
}