import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/FakeAuthRemoteDataSource.dart';
import '../data_sources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  // final AuthRemoteDataSource remoteDataSource;
  //
  // AuthRepositoryImpl({required this.remoteDataSource});
  //
  // @override
  // Future<AuthEntity> login(String username, String password) {
  //   return remoteDataSource.login(username, password);
  // }

  final FakeAuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AuthEntity> login(String username, String password) {
    return remoteDataSource.login(username, password);
  }
}
