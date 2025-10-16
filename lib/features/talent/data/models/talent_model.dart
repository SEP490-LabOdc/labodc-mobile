// lib/features/talent/data/models/talent_model.dart

import '../../domain/entities/talent_entity.dart';

class TalentModel extends TalentEntity {
  const TalentModel({
    required super.id,
    required super.email,
    required super.phone,
    required super.fullName,
    required super.birthDate,
    required super.avatarUrl,
    required super.role,
    required super.gender,
  });

  factory TalentModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;

    return TalentModel(
      id: data['id'] as String,
      email: data['email'] as String,
      phone: data['phone'] as String,
      fullName: data['fullName'] as String,
      avatarUrl: data['avatarUrl'] as String,
      role: data['role'] as String,
      gender: data['gender'] as String,
      birthDate: DateTime.parse(data['birthDate'] as String),
    );
  }
}