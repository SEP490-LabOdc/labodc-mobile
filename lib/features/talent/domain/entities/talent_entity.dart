// lib/features/talent/domain/entities/talent_entity.dart


class TalentEntity {
  final String id;
  final String email;
  final String phone;
  final String fullName;
  final DateTime birthDate;
  final String avatarUrl;
  final String role;
  final String gender;

  const TalentEntity({
    required this.id,
    required this.email,
    required this.phone,
    required this.fullName,
    required this.birthDate,
    required this.avatarUrl,
    required this.role,
    required this.gender,
  });
}