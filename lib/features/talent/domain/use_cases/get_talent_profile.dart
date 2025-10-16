// lib/features/talent/domain/use_cases/get_talent_profile.dart

import '../repositories/talent_repository.dart';
import '../entities/talent_entity.dart';

class GetTalentProfile {
  final TalentRepository repository;

  GetTalentProfile(this.repository);

  Future<TalentEntity> call(String token, String userId) async {
    return await repository.getTalentProfile(token, userId);
  }
}