import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/auth_remote_data_source.dart';
import '../token/auth_token_storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthTokenStorage tokenStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
  });

  @override
  Future<String?> getSavedToken() async {
    return await tokenStorage.getAccessToken();
  }



  @override
  Future<AuthEntity> login(String email, String password) async {
    final auth = await remoteDataSource.login(email, password);

    await tokenStorage.saveTokens(
      accessToken: auth.accessToken,
      refreshToken: auth.refreshToken,
      userId: auth.userId,
    );

    return auth;
  }

  @override
  Future<AuthEntity> loginWithGoogle(String googleToken) async {
    final auth = await remoteDataSource.loginWithGoogle(googleToken);

    await tokenStorage.saveTokens(
      accessToken: auth.accessToken,
      refreshToken: auth.refreshToken,
      userId: auth.userId,
    );

    return auth;
  }

  @override
  Future<AuthEntity> refreshToken(String refreshToken, String userId) async {
    final auth = await remoteDataSource.refreshToken(refreshToken, userId);

    await tokenStorage.saveTokens(
      accessToken: auth.accessToken,
      refreshToken: auth.refreshToken,
      userId: auth.userId,
    );

    return auth;
  }

  @override
  Future<void> logout() async {
    await tokenStorage.clear();
  }
}
