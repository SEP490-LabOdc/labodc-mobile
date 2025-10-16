// lib/features/talent/data/repositories_impl/talent_repository_impl.dart

import '../../domain/entities/talent_entity.dart';
import '../../domain/repositories/talent_repository.dart';
import '../data_sources/talent_remote_data_source.dart';

class TalentRepositoryImpl implements TalentRepository {
  final TalentRemoteDataSource remoteDataSource;

  TalentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<TalentEntity> getTalentProfile(String token, String userId) {
    return remoteDataSource.getTalentProfile(token, userId);
  }
}