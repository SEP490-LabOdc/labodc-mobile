// lib/main.dart
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

//  Core Config
import 'core/config/notifications/fcm_service.dart';
import 'core/get_it/get_it.dart';
import 'core/router/app_router.dart';
import 'core/config/networks/env.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/bloc/theme_bloc.dart';
import 'core/theme/bloc/theme_events.dart';
import 'core/theme/bloc/theme_state.dart';
import 'core/theme/domain/entity/theme_entity.dart';

//  Rung / Vibration
import 'core/services/vibration/vibration_cubit.dart';

//  Features
import 'features/auth/domain/use_cases/login_use_case.dart';
import 'features/auth/presentation/provider/auth_provider.dart';
import 'features/auth/presentation/utils/google_auth_service.dart';
import 'features/talent/presentation/cubit/talent_profile_cubit.dart'; // Import đúng Cubit

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Env.load();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await init();
  await GoogleAuthService.initialize(
    clientId: Env.googleAndroidClientId,
    serverClientId: Env.googleWebClientId,
  );

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
          BlocProvider(
            create: (context) => getIt<TalentProfileCubit>(
              param1: Provider.of<AuthProvider>(context, listen: false),
            ),
          ),
        ],
        child: const LabOdcApp(),
      ),
    ),
  );

  _bootstrapFcmNonBlocking();
}

/// Hàm khởi tạo FCM mà không chặn giao diện
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
        final isDarkMode = themeState.themeEntity?.themeType == ThemeType.dark;

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'LabODC',
          theme: AppTheme.getTheme(false),
          darkTheme: AppTheme.getTheme(true),
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('vi'),
          ],
          routerConfig: router,
        );
      },
    );
  }
}