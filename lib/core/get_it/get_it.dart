// lib/core/get_it/get_it.dart
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core Theme
import '../theme/bloc/theme_bloc.dart';
import '../theme/data/datasource/theme_local_datasource.dart';
import '../theme/data/repository/theme_repository_impl.dart';
import '../theme/domain/repository/theme_repository.dart';
import '../theme/domain/usecase/get_theme_use_case.dart';
import '../theme/domain/usecase/save_theme_use_case.dart';

// Auth Feature
import '../../features/auth/data/data_sources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories_impl/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/use_cases/login_use_case.dart';
import '../../features/auth/presentation/provider/auth_provider.dart';

// User Feature
import '../../features/user/data/data_sources/user_remote_data_source.dart';
import '../../features/user/data/repositories_impl/user_repository_impl.dart';
import '../../features/user/domain/repositories/user_repository.dart';
import '../../features/user/domain/use_cases/get_user_profile.dart';

// Talent Feature
import '../../features/talent/data/data_sources/talent_remote_data_source.dart';
import '../../features/talent/data/repositories_impl/talent_repository_impl.dart';
import '../../features/talent/domain/repositories/talent_repository.dart';
import '../../features/talent/domain/use_cases/get_talent_profile.dart';
import '../../features/talent/presentation/cubit/talent_profile_cubit.dart';

// 🟩 Notification Feature
import '../../features/notification/data/data_sources/notification_remote_data_source.dart';
import '../../features/notification/data/repositories_impl/notification_repository_impl.dart';
import '../../features/notification/domain/repositories/notification_repository.dart';
import '../../features/notification/domain/use_cases/get_notifications.dart';
import '../../features/notification/domain/use_cases/register_device_token_use_case.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // --- SharedPreferences ---
  final sharedPrefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPrefs);

  // --- Theme ---
  getIt.registerSingleton(ThemeLocalDatasource(sharedPreferences: getIt()));
  getIt.registerSingleton<ThemeRepository>(
    ThemeRepositoryImpl(themeLocalDatasource: getIt()),
  );
  getIt.registerSingleton(GetThemeUseCase(themeRepository: getIt()));
  getIt.registerSingleton(SaveThemeUseCase(themeRepository: getIt()));
  getIt.registerFactory(
        () => ThemeBloc(getThemeUseCase: getIt(), saveThemeUseCase: getIt()),
  );

  // --- Auth ---
  getIt.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSource(),
  );
  getIt.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(remoteDataSource: getIt<AuthRemoteDataSource>()),
  );
  getIt.registerLazySingleton<LoginUseCase>(
        () => LoginUseCase(getIt<AuthRepository>()),
  );
  // AuthProvider không cần register vì được tạo trong main.dart

  // --- User ---
  getIt.registerLazySingleton<UserRemoteDataSource>(
        () => UserRemoteDataSource(),
  );
  getIt.registerLazySingleton<UserRepository>(
        () => UserRepositoryImpl(remoteDataSource: getIt()),
  );
  getIt.registerLazySingleton<GetUserProfile>(
        () => GetUserProfile(getIt<UserRepository>()),
  );

  // --- Talent ---
  getIt.registerLazySingleton<TalentRemoteDataSource>(
        () => TalentRemoteDataSource(),
  );
  getIt.registerLazySingleton<TalentRepository>(
        () => TalentRepositoryImpl(remoteDataSource: getIt<TalentRemoteDataSource>()),
  );
  getIt.registerLazySingleton<GetTalentProfile>(
        () => GetTalentProfile(getIt<TalentRepository>()),
  );
  getIt.registerFactoryParam<TalentProfileCubit, AuthProvider, void>(
        (authProvider, _) => TalentProfileCubit(
      getTalentProfile: getIt<GetTalentProfile>(),
      authProvider: authProvider,
    ),
  );

  // 🟩 --- Notification ---
  getIt.registerLazySingleton<NotificationRemoteDataSource>(
        () => NotificationRemoteDataSource(),
  );
  getIt.registerLazySingleton<NotificationRepository>(
        () => NotificationRepositoryImpl(remoteDataSource: getIt()),
  );
  getIt.registerLazySingleton<GetNotificationsUseCase>(
        () => GetNotificationsUseCase(getIt<NotificationRepository>()),
  );
  getIt.registerLazySingleton<RegisterDeviceTokenUseCase>(
        () => RegisterDeviceTokenUseCase(getIt<NotificationRepository>()),
  );
}
