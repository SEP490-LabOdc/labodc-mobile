import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Core Services
import '../storage/storage_service.dart';
import '../cache/cache_manager.dart';
import '../services/vibration/vibration_cubit.dart';
import '../services/vibration/vibration_prefs.dart';

// Hiring Projects
import 'package:labodc_mobile/features/hiring_projects/presentation/cubit/related_projects_preview_cubit.dart';
import '../../features/company/domain/use_cases/get_company_detail_use_case.dart';
import '../../features/company/presentation/cubit/company_detail_cubit.dart';
import '../../features/company/presentation/cubit/company_projects_cubit.dart';
import '../../features/hiring_projects/data/data_sources/project_local_data_source.dart';
import '../../features/hiring_projects/data/data_sources/project_remote_data_source.dart';
import '../../features/hiring_projects/data/repositories_impl/project_repository_impl.dart';
import '../../features/hiring_projects/domain/repositories/project_repository.dart';
import '../../features/hiring_projects/domain/use_cases/get_hiring_projects.dart';
import '../../features/hiring_projects/domain/use_cases/search_projects.dart';
import '../../features/hiring_projects/presentation/cubit/bookmark_projects_cubit.dart';
import '../../features/hiring_projects/presentation/cubit/hiring_projects_cubit.dart';
import '../../features/hiring_projects/presentation/cubit/search_projects_cubit.dart';

// Project Application
import '../../features/milestone/data/data_sources/milestone_remote_data_source.dart';
// Lưu ý: Kiểm tra lại import này nếu có xung đột tên với ProjectRepositoryImpl của Hiring Projects
import '../../features/milestone/data/repositories/project_repository_impl.dart'
    as milestone_repo;
import '../../features/milestone/domain/repositories/milestone_repository.dart';
import '../../features/milestone/presentation/cubit/disbursement_cubit.dart';
import '../../features/milestone/presentation/cubit/milestone_cubit.dart';
import '../../features/milestone/presentation/cubit/milestone_detail_cubit.dart';
import '../../features/milestone/presentation/cubit/milestone_documents_cubit.dart';
import '../../features/project_application/data/data_sources/project_application_remote_data_source.dart';
import '../../features/project_application/data/repositories/project_application_repository_impl.dart';
import '../../features/project_application/domain/repositories/project_application_repository.dart';
import '../../features/project_application/domain/use_cases/apply_project_use_case.dart';
import '../../features/project_application/domain/use_cases/get_my_submitted_cvs_use_case.dart';
import '../../features/project_application/domain/use_cases/upload_cv_use_case.dart';
import '../../features/project_application/presentation/cubit/my_applications_cubit.dart';
import '../../features/project_application/presentation/cubit/project_application_cubit.dart';

// Report Feature
import '../../features/project_application/presentation/cubit/project_documents_cubit.dart';
import '../../features/project_fund/presentation/cubit/milestone_detail_cubit.dart'
    as fund_milestone;
import '../../features/project_fund/presentation/cubit/project_fund_cubit.dart';
import '../../features/report/data/data_sources/report_remote_data_source.dart';
import '../../features/report/data/repositories_imp/report_repository_impl.dart';
import '../../features/report/domain/repositories/report_repository.dart';
import '../../features/report/presentation/cubit/milestone_reports_state.dart';
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

// Notification Imports
import '../../features/notification/data/data_sources/notification_remote_data_source.dart';
import '../../features/notification/data/repositories_impl/notification_repository_impl.dart';
import '../../features/notification/domain/repositories/notification_repository.dart';
import '../../features/notification/domain/use_cases/get_notifications.dart';
import '../../features/notification/domain/use_cases/register_device_token_use_case.dart';
import '../../features/notification/websocket/cubit/websocket_notification_cubit.dart';

// Theme & Wallet

import '../../features/wallet/data/data_sources/transaction_remote_data_source.dart';
import '../../features/wallet/data/repositories/transaction_repository.dart';
import '../../features/wallet/data/repositories/wallet_repository.dart';
import '../../features/wallet/data/repositories_impl/transaction_repository_impl.dart';
import '../../features/wallet/data/repositories_impl/wallet_repository_impl.dart';
import '../../features/wallet/presentation/bloc/transaction_history_cubit.dart';
import '../../features/wallet/presentation/bloc/wallet_cubit.dart';
import '../theme/bloc/theme_bloc.dart';
import '../theme/data/datasource/theme_local_datasource.dart';
import '../theme/data/repository/theme_repository_impl.dart';
import '../theme/domain/repository/theme_repository.dart';
import '../theme/domain/usecase/get_theme_use_case.dart';
import '../theme/domain/usecase/save_theme_use_case.dart';

// Websocket Service
import '../services/realtime/stomp_notification_service.dart';

// Company
import '../../features/company/data/data_sources/company_remote_data_source.dart';
import '../../features/company/data/repositories_impl/company_repository_impl.dart';
import '../../features/company/domain/repositories/company_repository.dart';
import '../../features/company/domain/use_cases/get_active_companies_use_case.dart';
import '../../features/company/presentation/cubit/company_cubit.dart';
import '../../features/company/domain/use_cases/search_companies.dart';
import '../../features/company/presentation/cubit/search_companies_cubit.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // ---------------------------------------------------------------------------
  // 1. External & Core (SharedPreferences, Http, Storage, Cache)
  // ---------------------------------------------------------------------------
  final sharedPrefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPrefs);
  getIt.registerLazySingleton<http.Client>(() => http.Client());

  // Register Storage Service (type-safe wrapper for SharedPreferences)
  getIt.registerLazySingleton(() => StorageService(getIt<SharedPreferences>()));

  // Register Cache Managers for different data types
  getIt.registerLazySingleton(() => CacheManager<List<dynamic>>(maxSize: 50));
  getIt.registerLazySingleton(
    () => CacheManager<Map<String, dynamic>>(maxSize: 100),
  );

  // ---------------------------------------------------------------------------
  // 2. Auth
  // ---------------------------------------------------------------------------
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(),
  );
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

  // ---------------------------------------------------------------------------
  // 3. Hiring Projects (Đã gộp - Không đăng ký trùng lặp)
  // ---------------------------------------------------------------------------
  getIt.registerLazySingleton<ProjectLocalDataSource>(
    () => ProjectLocalDataSourceImpl(),
  );

  getIt.registerLazySingleton<ProjectRemoteDataSource>(
    () => ProjectRemoteDataSourceImpl(
      getIt<http.Client>(),
      getIt<AuthRepository>(),
    ),
  );

  getIt.registerLazySingleton<ProjectRepository>(
    () => ProjectRepositoryImpl(
      getIt<ProjectRemoteDataSource>(),
      getIt<ProjectLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton<GetHiringProjects>(
    () => GetHiringProjects(getIt<ProjectRepository>()),
  );

  getIt.registerLazySingleton<SearchProjects>(
    () => SearchProjects(getIt<ProjectRepository>()),
  );

  getIt.registerFactory<HiringProjectsCubit>(
    () => HiringProjectsCubit(getIt<GetHiringProjects>()),
  );

  getIt.registerFactory<SearchProjectsCubit>(
    () => SearchProjectsCubit(getIt<SearchProjects>()),
  );

  getIt.registerFactory<RelatedProjectsPreviewCubit>(
    () => RelatedProjectsPreviewCubit(repository: getIt<ProjectRepository>()),
  );

  getIt.registerFactory<BookmarkProjectsCubit>(
    () => BookmarkProjectsCubit(getIt<ProjectRepository>()),
  );

  // ---------------------------------------------------------------------------
  // 4. Notification & Websocket
  // ---------------------------------------------------------------------------
  getIt.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSource(),
  );
  getIt.registerLazySingleton<NotificationRepositoryImpl>(
    () => NotificationRepositoryImpl(remoteDataSource: getIt()),
  );
  getIt.registerLazySingleton<NotificationRepository>(
    () => getIt<NotificationRepositoryImpl>(),
  );
  getIt.registerLazySingleton<StompNotificationService>(
    () => StompNotificationService(),
  );
  getIt.registerLazySingleton<WebSocketNotificationCubit>(
    () => WebSocketNotificationCubit(
      getIt<NotificationRepositoryImpl>(),
      getIt<StompNotificationService>(),
    ),
  );
  getIt.registerLazySingleton<GetNotificationsUseCase>(
    () => GetNotificationsUseCase(getIt<NotificationRepository>()),
  );
  getIt.registerLazySingleton<RegisterDeviceTokenUseCase>(
    () => RegisterDeviceTokenUseCase(getIt<NotificationRepository>()),
  );

  // ---------------------------------------------------------------------------
  // 5. Theme
  // ---------------------------------------------------------------------------
  getIt.registerSingleton(ThemeLocalDatasource(sharedPreferences: getIt()));
  getIt.registerSingleton<ThemeRepository>(
    ThemeRepositoryImpl(themeLocalDatasource: getIt()),
  );
  getIt.registerSingleton(GetThemeUseCase(themeRepository: getIt()));
  getIt.registerSingleton(SaveThemeUseCase(themeRepository: getIt()));
  getIt.registerFactory(
    () => ThemeBloc(getThemeUseCase: getIt(), saveThemeUseCase: getIt()),
  );

  // Vibration Services
  getIt.registerLazySingleton(() => VibrationPrefs(getIt<StorageService>()));
  getIt.registerFactory(() => VibrationCubit(getIt<VibrationPrefs>()));

  // ---------------------------------------------------------------------------
  // 6. User & User Profile
  // ---------------------------------------------------------------------------
  getIt.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSource(),
  );
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(remoteDataSource: getIt()),
  );
  getIt.registerLazySingleton<GetUserProfile>(
    () => GetUserProfile(getIt<UserRepository>()),
  );

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

  // ---------------------------------------------------------------------------
  // 7. Talent
  // ---------------------------------------------------------------------------
  getIt.registerLazySingleton<TalentRemoteDataSource>(
    () => TalentRemoteDataSource(),
  );
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

  // ---------------------------------------------------------------------------
  // 8. Project Application
  // ---------------------------------------------------------------------------
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
  getIt.registerFactoryParam<ProjectDocumentsCubit, String, void>(
    (projectId, _) =>
        ProjectDocumentsCubit(getIt<ProjectApplicationRepository>()),
  );
  getIt.registerFactory<MyApplicationsCubit>(
    () =>
        MyApplicationsCubit(repository: getIt<ProjectApplicationRepository>()),
  );

  // ---------------------------------------------------------------------------
  // 9. Report
  // ---------------------------------------------------------------------------
  getIt.registerLazySingleton<ReportRemoteDataSource>(
    () => ReportRemoteDataSourceImpl(
      client: getIt<http.Client>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );
  getIt.registerLazySingleton<ReportRepository>(
    () => ReportRepositoryImpl(remote: getIt()),
  );
  getIt.registerFactoryParam<ReportCubit, bool, void>(
    (isSent, _) =>
        ReportCubit(repository: getIt<ReportRepository>(), isSent: isSent),
  );

  // ---------------------------------------------------------------------------
  // 10. Milestone
  // ---------------------------------------------------------------------------
  getIt.registerLazySingleton<MilestoneRemoteDataSource>(
    () =>
        MilestoneRemoteDataSourceImpl(client: getIt(), authRepository: getIt()),
  );
  getIt.registerLazySingleton<MilestoneRepository>(
    () => milestone_repo.MilestoneRepositoryImpl(remoteDataSource: getIt()),
  );
  getIt.registerFactory<MilestoneCubit>(
    () => MilestoneCubit(getIt<MilestoneRepository>()),
  );
  getIt.registerFactoryParam<MilestoneReportsCubit, String, void>(
    (milestoneId, _) => MilestoneReportsCubit(getIt<ReportRepository>()),
  );
  getIt.registerFactory<MilestoneDetailCubit>(
    () => MilestoneDetailCubit(getIt<MilestoneRepository>()),
  );
  getIt.registerFactoryParam<MilestoneDocumentsCubit, String, void>(
    (milestoneId, _) => MilestoneDocumentsCubit(getIt<MilestoneRepository>()),
  );
  getIt.registerFactory(
    () => DisbursementCubit(repository: getIt<MilestoneRepository>()),
  );

  // ---------------------------------------------------------------------------
  // 11. Project Fund Management
  // ---------------------------------------------------------------------------
  getIt.registerFactory<ProjectFundCubit>(
    () => ProjectFundCubit(
      projectApplicationRepository: getIt<ProjectApplicationRepository>(),
      milestoneRepository: getIt<MilestoneRepository>(),
    ),
  );

  // Register milestone detail cubit for project fund feature
  getIt.registerFactory<fund_milestone.MilestoneDetailCubit>(
    () => fund_milestone.MilestoneDetailCubit(
      milestoneRepository: getIt<MilestoneRepository>(),
    ),
  );

  // ---------------------------------------------------------------------------
  // 12. Company
  // ---------------------------------------------------------------------------
  getIt.registerLazySingleton<CompanyRemoteDataSource>(
    () => CompanyRemoteDataSourceImpl(
      getIt<http.Client>(),
      getIt<AuthRepository>(),
    ),
  );
  getIt.registerLazySingleton<CompanyRepository>(
    () => CompanyRepositoryImpl(getIt<CompanyRemoteDataSource>()),
  );
  getIt.registerLazySingleton<GetActiveCompaniesUseCase>(
    () => GetActiveCompaniesUseCase(getIt<CompanyRepository>()),
  );
  getIt.registerLazySingleton<SearchCompanies>(
    () => SearchCompanies(getIt<CompanyRepository>()),
  );
  getIt.registerFactory<CompanyCubit>(
    () => CompanyCubit(
      getActiveCompaniesUseCase: getIt<GetActiveCompaniesUseCase>(),
    ),
  );
  getIt.registerFactory<SearchCompaniesCubit>(
    () => SearchCompaniesCubit(getIt<SearchCompanies>()),
  );
  getIt.registerLazySingleton<GetCompanyDetailUseCase>(
    () => GetCompanyDetailUseCase(getIt<CompanyRepository>()),
  );
  getIt.registerFactory<CompanyDetailCubit>(
    () => CompanyDetailCubit(
      getCompanyDetailUseCase: getIt<GetCompanyDetailUseCase>(),
    ),
  );
  getIt.registerFactory(
    () => CompanyProjectsCubit(repository: getIt<CompanyRepository>()),
  );

  // ---------------------------------------------------------------------------
  // 13. Transaction & Wallet
  // ---------------------------------------------------------------------------
  getIt.registerLazySingleton<TransactionRemoteDataSource>(
    () => TransactionRemoteDataSource(),
  );
  getIt.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(
      remoteDataSource: getIt<TransactionRemoteDataSource>(),
      tokenStorage: getIt<AuthTokenStorage>(),
    ),
  );
  getIt.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(
      remoteDataSource: getIt<TransactionRemoteDataSource>(),
      tokenStorage: getIt<AuthTokenStorage>(),
    ),
  );
  getIt.registerFactory<TransactionHistoryCubit>(
    () => TransactionHistoryCubit(getIt<TransactionRepository>()),
  );
  getIt.registerFactory<WalletCubit>(
    () => WalletCubit(getIt<WalletRepository>()),
  );
}
