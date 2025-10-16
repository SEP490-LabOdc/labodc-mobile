// lib/features/talent/domain/repositories/talent_repository.dart

import '../entities/talent_entity.dart';

abstract class TalentRepository {
  Future<TalentEntity> getTalentProfile(String token, String userId);
}