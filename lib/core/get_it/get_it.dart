// lib/core/get_it/get_it.dart
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Core Theme
import '../../features/auth/data/token/auth_token_storage.dart';
import '../../features/hiring_projects/data/data_sources/project_remote_data_source.dart';
import '../../features/hiring_projects/data/repositories_impl/project_repository_impl.dart';
import '../../features/hiring_projects/domain/repositories/project_repository.dart';
import '../../features/hiring_projects/domain/use_cases/get_hiring_projects.dart';
import '../../features/hiring_projects/presentation/cubit/hiring_projects_cubit.dart';
import '../services/realtime/stomp_notification_service.dart';
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

// Notification Feature
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
// Token Storage
  getIt.registerLazySingleton<AuthTokenStorage>(() => AuthTokenStorage());

// Auth Repository
  getIt.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      tokenStorage: getIt<AuthTokenStorage>(),
    ),
  );

  getIt.registerLazySingleton<LoginUseCase>(
        () => LoginUseCase(getIt<AuthRepository>()),
  );

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

  // 🧠 TalentProfileCubit có param authProvider, nên dùng registerFactoryParam
  getIt.registerFactoryParam<TalentProfileCubit, AuthProvider, void>(
        (authProvider, _) => TalentProfileCubit(
      getTalentProfile: getIt<GetTalentProfile>(),
      authProvider: authProvider,
    ),
  );

  // --- Notification ---
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

// ======================================================
// COMPANY FEATURE (Hiring Projects)
// ======================================================

// 1. Http Client (Dùng chung toàn app)
  getIt.registerLazySingleton<http.Client>(() => http.Client());

// 2. ProjectRemoteDataSource
  getIt.registerLazySingleton<ProjectRemoteDataSource>(
        () => ProjectRemoteDataSourceImpl(
      getIt<http.Client>(),
      getIt<AuthRepository>(),
    ),
  );

// 3. ProjectRepository
  getIt.registerLazySingleton<ProjectRepository>(
        () => ProjectRepositoryImpl(
      getIt<ProjectRemoteDataSource>(),
    ),
  );

// 4. UseCase
  getIt.registerLazySingleton<GetHiringProjects>(
        () => GetHiringProjects(
      getIt<ProjectRepository>(),
    ),
  );

// 5. Cubit
  getIt.registerFactory<HiringProjectsCubit>(
        () => HiringProjectsCubit(
      getIt<GetHiringProjects>(),
    ),
  );




  // 🧩 WebSocket / STOMP Service
  getIt.registerLazySingleton(() => StompNotificationService());
}