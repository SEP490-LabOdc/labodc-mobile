// lib/core/get_it/get_it.dart
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Hiring Projects
import 'package:labodc_mobile/features/hiring_projects/presentation/cubit/related_projects_preview_cubit.dart';
import '../../features/hiring_projects/data/data_sources/project_remote_data_source.dart';
import '../../features/hiring_projects/data/repositories_impl/project_repository_impl.dart';
import '../../features/hiring_projects/domain/repositories/project_repository.dart';
import '../../features/hiring_projects/domain/use_cases/get_hiring_projects.dart';
import '../../features/hiring_projects/presentation/cubit/hiring_projects_cubit.dart';

// Project Application
import '../../features/project_application/data/data_sources/project_application_remote_data_source.dart';
import '../../features/project_application/data/repositories/project_application_repository_impl.dart';
import '../../features/project_application/domain/repositories/project_application_repository.dart';
import '../../features/project_application/domain/use_cases/apply_project_use_case.dart';
import '../../features/project_application/domain/use_cases/get_my_submitted_cvs_use_case.dart';
import '../../features/project_application/domain/use_cases/upload_cv_use_case.dart';
import '../../features/project_application/presentation/cubit/project_application_cubit.dart';

// Report Feature
import '../../features/report/data/data_sources/report_remote_data_source.dart';
import '../../features/report/data/repositories_imp/report_repository_impl.dart';
import '../../features/report/domain/repositories/report_repository.dart';
import '../../features/report/presentation/cubit/report_cubit.dart';

// User Profile
import '../../features/user_profile/data/datasources/user_profile_remote_data_source.dart';
import '../../features/user_profile/data/repositories/user_profile_repository_impl.dart';
import '../../features/user_profile/domain/repositories/user_profile_repository.dart';
import '../../features/user_profile/domain/use_cases/update_user_profile_use_case.dart';
import '../../features/user_profile/presentation/cubit/user_profile_cubit.dart';

// Auth
import '../../features/auth/data/token/auth_token_storage.dart';
import '../../features/auth/data/data_sources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories_impl/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/use_cases/login_use_case.dart';
import '../../features/auth/presentation/provider/auth_provider.dart';

// User
import '../../features/user/data/data_sources/user_remote_data_source.dart';
import '../../features/user/data/repositories_impl/user_repository_impl.dart';
import '../../features/user/domain/repositories/user_repository.dart';
import '../../features/user/domain/use_cases/get_user_profile.dart';

// Talent
import '../../features/talent/data/data_sources/talent_remote_data_source.dart';
import '../../features/talent/data/repositories_impl/talent_repository_impl.dart';
import '../../features/talent/domain/repositories/talent_repository.dart';
import '../../features/talent/domain/use_cases/get_talent_profile.dart';
import '../../features/talent/presentation/cubit/talent_profile_cubit.dart';

// Notification
import '../../features/notification/data/data_sources/notification_remote_data_source.dart';
import '../../features/notification/data/repositories_impl/notification_repository_impl.dart';
import '../../features/notification/domain/repositories/notification_repository.dart';
import '../../features/notification/domain/use_cases/get_notifications.dart';
import '../../features/notification/domain/use_cases/register_device_token_use_case.dart';

// Theme
import '../theme/bloc/theme_bloc.dart';
import '../theme/data/datasource/theme_local_datasource.dart';
import '../theme/data/repository/theme_repository_impl.dart';
import '../theme/domain/repository/theme_repository.dart';
import '../theme/domain/usecase/get_theme_use_case.dart';
import '../theme/domain/usecase/save_theme_use_case.dart';

// Websocket
import '../services/realtime/stomp_notification_service.dart';

final getIt = GetIt.instance;

Future<void> init() async {

  // ------------------------
  // SharedPreferences
  // ------------------------
  final sharedPrefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPrefs);

  // ------------------------
  // Theme
  // ------------------------
  getIt.registerSingleton(ThemeLocalDatasource(sharedPreferences: getIt()));
  getIt.registerSingleton<ThemeRepository>(
    ThemeRepositoryImpl(themeLocalDatasource: getIt()),
  );
  getIt.registerSingleton(GetThemeUseCase(themeRepository: getIt()));
  getIt.registerSingleton(SaveThemeUseCase(themeRepository: getIt()));

  getIt.registerFactory(
        () => ThemeBloc(
      getThemeUseCase: getIt(),
      saveThemeUseCase: getIt(),
    ),
  );

  // ------------------------
  // Auth
  // ------------------------
  getIt.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSource());
  getIt.registerLazySingleton<AuthTokenStorage>(() => AuthTokenStorage());

  getIt.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      tokenStorage: getIt<AuthTokenStorage>(),
    ),
  );

  getIt.registerLazySingleton<LoginUseCase>(
        () => LoginUseCase(getIt<AuthRepository>()),
  );

  // ------------------------
  // User
  // ------------------------
  getIt.registerLazySingleton<UserRemoteDataSource>(() => UserRemoteDataSource());

  getIt.registerLazySingleton<UserRepository>(
        () => UserRepositoryImpl(remoteDataSource: getIt()),
  );

  getIt.registerLazySingleton<GetUserProfile>(
        () => GetUserProfile(getIt<UserRepository>()),
  );

  // ------------------------
  // Talent
  // ------------------------
  getIt.registerLazySingleton<TalentRemoteDataSource>(() => TalentRemoteDataSource());

  getIt.registerLazySingleton<TalentRepository>(
        () => TalentRepositoryImpl(remoteDataSource: getIt()),
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

  // ------------------------
  // Notification
  // ------------------------
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

  // ------------------------
  // Http Client
  // ------------------------
  getIt.registerLazySingleton<http.Client>(() => http.Client());

  // ------------------------
  // Hiring Projects
  // ------------------------
  getIt.registerLazySingleton<ProjectRemoteDataSource>(
        () => ProjectRemoteDataSourceImpl(
      getIt<http.Client>(),
      getIt<AuthRepository>(),
    ),
  );

  getIt.registerLazySingleton<ProjectRepository>(
        () => ProjectRepositoryImpl(getIt<ProjectRemoteDataSource>()),
  );

  getIt.registerLazySingleton<GetHiringProjects>(
        () => GetHiringProjects(getIt<ProjectRepository>()),
  );

  getIt.registerFactory<HiringProjectsCubit>(
        () => HiringProjectsCubit(getIt<GetHiringProjects>()),
  );

  getIt.registerFactory<RelatedProjectsPreviewCubit>(
        () => RelatedProjectsPreviewCubit(repository: getIt<ProjectRepository>()),
  );

  // ------------------------
  // Project Application
  // ------------------------
  getIt.registerLazySingleton<ProjectApplicationRemoteDataSource>(
        () => ProjectApplicationRemoteDataSourceImpl(
      client: getIt<http.Client>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );

  getIt.registerLazySingleton<ProjectApplicationRepository>(
        () => ProjectApplicationRepositoryImpl(remoteDataSource: getIt()),
  );

  getIt.registerLazySingleton<GetMySubmittedCvsUseCase>(
        () => GetMySubmittedCvsUseCase(repository: getIt()),
  );

  getIt.registerLazySingleton<ApplyProjectUseCase>(
        () => ApplyProjectUseCase(
      repository: getIt(),
      authRepository: getIt<AuthRepository>(),
    ),
  );

  getIt.registerLazySingleton<UploadCvUseCase>(
        () => UploadCvUseCase(repository: getIt()),
  );

  getIt.registerFactory<ProjectApplicationCubit>(
        () => ProjectApplicationCubit(
      getCvsUseCase: getIt(),
      applyProjectUseCase: getIt(),
      uploadCvUseCase: getIt(),
    ),
  );

  // ------------------------
  // User Profile
  // ------------------------
  getIt.registerLazySingleton<UserProfileRemoteDataSource>(
        () => UserProfileRemoteDataSourceImpl(
      client: getIt<http.Client>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );

  getIt.registerLazySingleton<UserProfileRepository>(
        () => UserProfileRepositoryImpl(remoteDataSource: getIt()),
  );

  getIt.registerLazySingleton<UpdateUserProfileUseCase>(
        () => UpdateUserProfileUseCase(getIt<UserProfileRepository>()),
  );

  getIt.registerFactory<UserProfileCubit>(
        () => UserProfileCubit(
      repository: getIt(),
      userId: getIt<AuthProvider>().userId,
    ),
  );

  // ======================================================
  // REPORT FEATURE
  // ======================================================

  // Data Source
  getIt.registerLazySingleton<ReportRemoteDataSource>(
        () => ReportRemoteDataSourceImpl(
      client: getIt<http.Client>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );

  // Repository
  getIt.registerLazySingleton<ReportRepository>(
        () => ReportRepositoryImpl(remote: getIt()),
  );

  // Cubit (ONLY registerFactoryParam)
  getIt.registerFactoryParam<ReportCubit, bool, void>(
        (isSent, _) => ReportCubit(
      repository: getIt<ReportRepository>(),
      isSent: isSent,
    ),
  );

  // ------------------------
  // WebSocket
  // ------------------------
  getIt.registerLazySingleton(() => StompNotificationService());
}
