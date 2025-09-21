
import 'dart:convert';
import 'package:flutter/material.dart';

import '../../domain/entity/explore_models.dart';
import '../datasource/fake_explore_data.dart';



class ExploreService {
  // Map JSON keys to actual IconData
  final Map<String, IconData> _iconMap = {
    "Quản lý nhiệm vụ trực quan": Icons.task_alt,
    "Trao đổi trực tiếp với Mentor": Icons.chat_bubble_outline,
    "Theo dõi thu nhập minh bạch": Icons.monetization_on_outlined,
    "Ứng dụng Mobile cho Startup Fintech": Icons.phone_android,
    "Phân tích dữ liệu cho Web E-commerce": Icons.bar_chart,
    "Theo dõi tiến độ 24/7": Icons.timeline,
    "Phê duyệt & Phản hồi nhanh chóng": Icons.check_circle_outline,
    "Quản lý thanh toán đơn giản": Icons.credit_card
  };

  Future<ExploreData> loadExploreData() async {
    await Future.delayed(const Duration(seconds: 1));

    final data = jsonDecode(fakeExploreJsonData);

    final talentData = data['talentData'];
    final companyData = data['companyData'];

    final talentFeatures = (talentData['features'] as List)
        .map((f) => FeatureItem.fromJson(f, _iconMap[f['title']] ?? Icons.help))
        .toList();

    final projects = (talentData['projects'] as List)
        .map((p) => ProjectItem.fromJson(p, _iconMap[p['title']] ?? Icons.work))
        .toList();

    final companyFeatures = (companyData['features'] as List)
        .map((f) => FeatureItem.fromJson(f, _iconMap[f['title']] ?? Icons.help))
        .toList();

    final partners = (companyData['partners'] as List)
        .map((p) => PartnerItem.fromJson(p))
        .toList();

    return ExploreData(
      talentFeatures: talentFeatures,
      projects: projects,
      companyFeatures: companyFeatures,
      partners: partners,
    );
  }
}