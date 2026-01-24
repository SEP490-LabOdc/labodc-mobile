import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
import 'core/services/widget/notification_widget_service.dart';

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

  // 1. Khởi tạo Dependency Injection (GetIt) - Cần thiết cho app
  await init();

  // 2. Load môi trường - Nhanh, đọc từ file
  await Env.load();

  // 3. Firebase initialization - KHÔNG cần thiết ngay lập tức
  String? initialRoute;
  _deferFirebaseInit();

  // 4. Widget Service - Kiểm tra nhanh, init sau
  initialRoute = await _quickCheckWidgetRoute();

  // 5. Tạo AuthProvider thủ công để đưa vào MultiProvider
  final authProvider = AuthProvider(loginUseCase: getIt<LoginUseCase>());

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => authProvider)],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => getIt<ThemeBloc>()..add(GetThemeEvent())),
          BlocProvider(create: (_) => getIt<VibrationCubit>()..load()),
          BlocProvider(
            create: (context) => getIt<TalentProfileCubit>(
              param1: Provider.of<AuthProvider>(context, listen: false),
            ),
          ),
          BlocProvider(
            create: (context) => getIt<WebSocketNotificationCubit>(),
          ),
        ],
        child: WebSocketManager(child: LabOdcApp(initialRoute: initialRoute)),
      ),
    ),
  );

  // 6. Google Sign-In - Chỉ init khi cần
  _deferGoogleSignInInit();
}

/// Firebase initialization - Chạy sau khi frame đầu tiên render
void _deferFirebaseInit() {
  Future.microtask(() async {
    try {
      // Đợi frame đầu tiên render
      await Future.delayed(const Duration(milliseconds: 100));

      debugPrint('🔥 [Firebase] Starting initialization...');
      await Firebase.initializeApp();
      debugPrint('🔥 [Firebase] ✓ Initialized');

      // Set background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Disable auto-init để tránh Google Play Services handshake chậm
      await FirebaseMessaging.instance.setAutoInitEnabled(false);

      // FCM init sau thêm 2 giây nữa
      _bootstrapFcmNonBlocking();
    } catch (e, st) {
      debugPrint('🔥 [Firebase] ❌ Init failed: $e\n$st');
    }
  });
}

/// Google Sign-In - Chỉ init khi thực sự cần
void _deferGoogleSignInInit() {
  Future.microtask(() async {
    try {
      // Đợi thêm 2 giây sau khi app đã render
      await Future.delayed(const Duration(seconds: 2));

      debugPrint('🔐 [GoogleAuth] Starting initialization...');
      await GoogleAuthService.initialize(
        clientId: Env.googleAndroidClientId,
        serverClientId: Env.googleWebClientId,
      );
      debugPrint('🔐 [GoogleAuth] ✓ Initialized');
    } catch (e, st) {
      debugPrint('🔐 [GoogleAuth] ❌ Init failed: $e\n$st');
      // Không crash app nếu Google Sign-In fail
    }
  });
}

/// Quick widget route check - Chỉ kiểm tra nhanh, init đầy đủ sau
Future<String?> _quickCheckWidgetRoute() async {
  try {
    // Kiểm tra nhanh xem có được mở từ widget không
    final widgetUri = await NotificationWidgetService.getWidgetUri().timeout(
      const Duration(milliseconds: 200),
    );

    if (widgetUri != null && widgetUri.host == 'notifications') {
      debugPrint('🔗 App opened from widget');
      // Init widget service đầy đủ ở background
      _deferWidgetServiceInit();
      return '/notifications';
    }
  } catch (e) {
    debugPrint('⚠️ Widget check timeout/failed: $e');
  }

  // Init widget service ở background
  _deferWidgetServiceInit();
  return null;
}

/// Defer Widget Service full initialization
void _deferWidgetServiceInit() {
  Future.microtask(() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      await NotificationWidgetService.initialize();
      debugPrint('🎨 [Widget] ✓ Initialized');
    } catch (e) {
      debugPrint('🎨 [Widget] ❌ Init failed: $e');
    }
  });
}

/// Khởi tạo FCM Service không chặn luồng chính (để App khởi động nhanh hơn)
void _bootstrapFcmNonBlocking() {
  Future.microtask(() async {
    // Đợi thêm 3 giây sau khi app render
    await Future.delayed(const Duration(seconds: 3));

    try {
      debugPrint('📬 [FCM] Starting service initialization...');
      await FcmService.init().timeout(const Duration(seconds: 10));
      debugPrint('📬 [FCM] ✓ Service initialized');
    } on TimeoutException {
      debugPrint('📬 [FCM] ⚠️ Init timeout - will retry later');
      // Retry sau 10 giây
      Future.delayed(const Duration(seconds: 10), () {
        FcmService.init()
            .timeout(const Duration(seconds: 10))
            .catchError((_) {});
      });
    } catch (e, st) {
      debugPrint('📬 [FCM] ❌ Init error: $e\n$st');
    }
  });
}

class LabOdcApp extends StatefulWidget {
  final String? initialRoute;

  const LabOdcApp({super.key, this.initialRoute});

  @override
  State<LabOdcApp> createState() => _LabOdcAppState();
}

class _LabOdcAppState extends State<LabOdcApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // ✅ Khởi tạo router MỘT LẦN DUY NHẤT khi app bắt đầu
    // Sử dụng context.read để lấy AuthProvider mà không "lắng nghe" sự thay đổi sau này
    final authProvider = context.read<AuthProvider>();
    _router = AppRouter.createRouter(authProvider);

    // Navigate to initial route if app was opened from widget
    if (widget.initialRoute != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _router.go(widget.initialRoute!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Chỉ lắng nghe Theme để đổi màu giao diện, không khởi tạo lại Router
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

          routerConfig: _router,
        );
      },
    );
  }
}
