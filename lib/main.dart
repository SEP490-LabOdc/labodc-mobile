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
import 'core/services/vibration/vibration_cubit.dart';

// Features
import 'core/theme/domain/entity/theme_entity.dart';
import 'features/auth/domain/use_cases/login_use_case.dart';
import 'features/auth/presentation/provider/auth_provider.dart';
import 'features/auth/presentation/utils/google_auth_service.dart';
import 'features/notification/presentation/widgets/websocket_manager.dart';
import 'features/talent/presentation/cubit/talent_profile_cubit.dart';
import 'features/notification/websocket/cubit/websocket_notification_cubit.dart';


final sl = GetIt.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Khởi tạo Firebase & Môi trường
  await Firebase.initializeApp();
  await Env.load();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // 2. Khởi tạo Dependency Injection (GetIt)
  await init();

  // 3. Khởi tạo Google Sign-In
  await GoogleAuthService.initialize(
    clientId: Env.googleAndroidClientId,
    serverClientId: Env.googleWebClientId,
  );

  // 4. Tạo AuthProvider thủ công để đưa vào MultiProvider
  final authProvider = AuthProvider(loginUseCase: getIt<LoginUseCase>());

  runApp(
    MultiProvider(
      providers: [
        // AuthProvider cần được khởi tạo sớm nhất để kiểm tra trạng thái đăng nhập
        ChangeNotifierProvider(create: (_) => authProvider),
      ],
      child: MultiBlocProvider(
        providers: [
          // Theme & Vibration Global Config
          BlocProvider(create: (_) => getIt<ThemeBloc>()..add(GetThemeEvent())),
          BlocProvider(create: (_) => VibrationCubit()..load()),

          // Talent Profile Cubit (phụ thuộc vào AuthProvider)
          BlocProvider(
            create: (context) => getIt<TalentProfileCubit>(
              param1: Provider.of<AuthProvider>(context, listen: false),
            ),
          ),

          // Notification Cubit Global
          // Cubit này sẽ sống trong suốt vòng đời của App
          BlocProvider(
            create: (context) => getIt<WebSocketNotificationCubit>(),
          ),
        ],
        // [QUAN TRỌNG] Bọc App trong WebSocketManager
        // Widget này sẽ lắng nghe AuthProvider và gọi connect/disconnect
        child: const WebSocketManager(
          child: LabOdcApp(),
        ),
      ),
    ),
  );

  _bootstrapFcmNonBlocking();
}

/// Khởi tạo FCM Service không chặn luồng chính (để App khởi động nhanh hơn)
void _bootstrapFcmNonBlocking() {
  Future.microtask(() async {
    try {
      await FirebaseMessaging.instance.setAutoInitEnabled(true);
    } catch (_) {}

    // Đợi frame đầu tiên render xong mới init FCM logic nặng
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
    // Lấy AuthProvider để truyền vào Router (cho logic Redirect)
    final authProvider = Provider.of<AuthProvider>(context);
    final router = AppRouter.createRouter(authProvider);

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.themeEntity?.themeType == ThemeType.dark;

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'LabODC',
          // Cấu hình Theme
          theme: AppTheme.getTheme(false),
          darkTheme: AppTheme.getTheme(true),
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

          // Cấu hình Localization
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('vi')],

          // Cấu hình Router (GoRouter)
          routerConfig: router,
        );
      },
    );
  }
}