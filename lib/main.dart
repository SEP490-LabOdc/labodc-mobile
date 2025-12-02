// lib/main.dart
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';

// Core
import 'core/config/notifications/fcm_service.dart';
import 'core/get_it/get_it.dart';
import 'core/router/app_router.dart';
import 'core/config/networks/env.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/bloc/theme_bloc.dart';
import 'core/theme/bloc/theme_events.dart';
import 'core/theme/bloc/theme_state.dart';
import 'core/theme/domain/entity/theme_entity.dart';
import 'core/services/vibration/vibration_cubit.dart';
import 'core/services/realtime/stomp_notification_service.dart';

// Features
import 'features/auth/domain/use_cases/login_use_case.dart';
import 'features/auth/presentation/provider/auth_provider.dart';
import 'features/auth/presentation/utils/google_auth_service.dart';
import 'features/talent/presentation/cubit/talent_profile_cubit.dart';
import 'features/notification/websocket/cubit/websocket_notification_cubit.dart';
import 'features/notification/data/repositories_impl/notification_repository_impl.dart';
import 'features/notification/data/data_sources/notification_remote_data_source.dart';

final sl = GetIt.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Env.load();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await init();

  await GoogleAuthService.initialize(
    clientId: Env.googleAndroidClientId,
    serverClientId: Env.googleWebClientId,
  );

  // --- Register dependencies ------------------------------------------------
  // Register remote data source (adjust constructor to your actual implementation)
  if (!sl.isRegistered<NotificationRemoteDataSource>()) {
    sl.registerLazySingleton<NotificationRemoteDataSource>(() {
      // Replace with your actual implementation, e.g. NotificationRemoteDataSourceImpl(httpClient)
      return NotificationRemoteDataSource(); // <-- adjust if your class name differs
    });
  }

  // Register repository implementation
  if (!sl.isRegistered<NotificationRepositoryImpl>()) {
    sl.registerLazySingleton<NotificationRepositoryImpl>(() {
      return NotificationRepositoryImpl(remoteDataSource: sl());
    });
  }

  // Register realtime/stomp service
  if (!sl.isRegistered<StompNotificationService>()) {
    sl.registerLazySingleton<StompNotificationService>(() {
      return StompNotificationService(); // <-- adjust if constructor requires params
    });
  }

  // Register WebSocketNotificationCubit factory
  if (!sl.isRegistered<WebSocketNotificationCubit>()) {
    sl.registerFactory<WebSocketNotificationCubit>(() {
      final repo = sl<NotificationRepositoryImpl>();
      final stomp = sl<StompNotificationService>();
      // Provide a userId here if you can obtain it at startup, otherwise inject later
      const userId = ''; // <-- replace with actual user id retrieval
      return WebSocketNotificationCubit(repo, stomp, userId, sl<AuthProvider>());
    });
  }
  // -------------------------------------------------------------------------

  final authProvider = AuthProvider(loginUseCase: getIt<LoginUseCase>());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authProvider),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => getIt<ThemeBloc>()..add(GetThemeEvent())),
          BlocProvider(create: (_) => VibrationCubit()..load()),


          // 🧩 TalentProfileCubit có param => tạo bằng param
          BlocProvider(
            create: (context) => getIt<TalentProfileCubit>(
              param1: Provider.of<AuthProvider>(context, listen: false),
            ),

          ),


          // 🔔 WebSocketNotificationCubit khởi tạo tại đây
          BlocProvider(
            create: (context) {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              final user = auth.currentUser;
              if (user == null) {
                return WebSocketNotificationCubit(
                  getIt<NotificationRepositoryImpl>(),
                  getIt<StompNotificationService>(),
                  '',
                  auth,
                );
              }

              final cubit = WebSocketNotificationCubit(
                getIt<NotificationRepositoryImpl>(),
                getIt<StompNotificationService>(),
                user.userId,
                auth,
              );

              cubit.init(token: auth.accessToken);
              return cubit;
            },
          ),
        ],
        child: const LabOdcApp(),
      ),
    ),
  );

  _bootstrapFcmNonBlocking();
}

void _bootstrapFcmNonBlocking() {
  Future.microtask(() async {
    try {
      await FirebaseMessaging.instance.setAutoInitEnabled(true);
    } catch (_) {}
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await FcmService.init().timeout(const Duration(seconds: 12));
      } on TimeoutException {
        debugPrint('[FCM] ⚠️ init timeout');
      } catch (e, st) {
        debugPrint('[FCM] ❌ init error: $e\n$st');
      }
    });
  });
}

class LabOdcApp extends StatelessWidget {
  const LabOdcApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final router = AppRouter.createRouter(authProvider);

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.themeEntity?.themeType == ThemeType.dark;

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'LabODC',
          theme: AppTheme.getTheme(false),
          darkTheme: AppTheme.getTheme(true),
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('vi')],
          routerConfig: router,
        );
      },
    );
  }
}