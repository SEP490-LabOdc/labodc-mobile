// lib/features/auth/data/repositories_impl/auth_repository_impl.dart
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AuthEntity> login(String email, String password) {
    return remoteDataSource.login(email, password);
  }

  @override
  Future<AuthEntity> refreshToken(String refreshToken, String userId) async {
    final authModel = await remoteDataSource.refreshToken(refreshToken, userId);
    return authModel;
  }
}