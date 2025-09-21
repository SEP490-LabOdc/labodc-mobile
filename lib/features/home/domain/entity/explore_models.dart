import 'package:flutter/material.dart';

class FeatureItem {
  final IconData icon;
  final String title;
  final String description;

  FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  factory FeatureItem.fromJson(Map<String, dynamic> json, IconData icon) {
    return FeatureItem(
      icon: icon,
      title: json['title'],
      description: json['description'],
    );
  }
}

// Model cho một dự án nổi bật
class ProjectItem {
  final IconData icon;
  final String title;
  final List<String> skills;

  ProjectItem({
    required this.icon,
    required this.title,
    required this.skills,
  });

  factory ProjectItem.fromJson(Map<String, dynamic> json, IconData icon) {
    return ProjectItem(
      icon: icon,
      title: json['title'],
      skills: List<String>.from(json['skills']),
    );
  }
}

// Model cho một đối tác
class PartnerItem {
  final String name;
  final String logoUrl;

  PartnerItem({required this.name, required this.logoUrl});

  factory PartnerItem.fromJson(Map<String, dynamic> json) {
    return PartnerItem(
      name: json['name'],
      logoUrl: json['logoUrl'],
    );
  }
}

// Model tổng hợp cho toàn bộ dữ liệu của trang Khám phá
class ExploreData {
  final List<FeatureItem> talentFeatures;
  final List<ProjectItem> projects;
  final List<FeatureItem> companyFeatures;
  final List<PartnerItem> partners;

  ExploreData({
    required this.talentFeatures,
    required this.projects,
    required this.companyFeatures,
    required this.partners,
  });
}