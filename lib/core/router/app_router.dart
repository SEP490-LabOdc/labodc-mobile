import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

// Pages imports
import '../../features/admin/presentation/pages/lab_admin_main_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/company/presentation/pages/company_main_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/mentor/presentation/pages/mentor_main_page.dart';
import '../../features/talent/presentation/pages/talent_main_page.dart';
import '../../features/user/presentation/pages/user_page.dart';
import '../../common/presentation/pages/setting_page.dart';

// Providers
import '../../features/auth/presentation/provider/auth_provider.dart';

// Notification
import '../../features/notification/presentation/cubit/notification_cubit.dart';
import '../../features/notification/domain/use_cases/get_notifications.dart';
import '../../features/notification/domain/use_cases/register_device_token_use_case.dart';

// Constants
import 'route_constants.dart';

final sl = GetIt.instance;

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
  GlobalKey<NavigatorState>();

  static GoRouter createRouter(AuthProvider authProvider) {
    debugPrint('AppRouter: Bắt đầu tạo GoRouter.');

    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: Routes.splash,
      refreshListenable: authProvider,
      redirect: (context, state) => _handleRedirect(state, authProvider),
      routes: [
        // === PUBLIC ROUTES ===
        GoRoute(
          path: Routes.splash,
          name: Routes.splashName,
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: Routes.home,
          name: Routes.homeName,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: Routes.login,
          name: Routes.loginName,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: Routes.register,
          name: Routes.registerName,
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: Routes.setting,
          name: Routes.settingName,
          builder: (context, state) => const SettingPage(),
        ),

        // === PROTECTED ROUTES ===
        GoRoute(
          path: Routes.user,
          name: Routes.userName,
          builder: (context, state) {
            final user = authProvider.currentUser;
            if (user == null) return const LoginPage();

            return BlocProvider(
              create: (_) => NotificationCubit(
                getNotificationsUseCase: sl<GetNotificationsUseCase>(),
                registerDeviceTokenUseCase:
                sl<RegisterDeviceTokenUseCase>(),
                userId: user.userId,
                authToken: user.accessToken,
              ),
              child: const TalentMainPage(),
            );
          },
        ),

        // 🟩 LAB ADMIN (có BlocProvider)
        GoRoute(
          path: Routes.labAdmin,
          name: Routes.labAdminName,
          builder: (context, state) {
            final user = authProvider.currentUser;
            if (user == null) {
              debugPrint("⚠️ AuthProvider chưa có user, chuyển hướng về login.");
              return const LoginPage();
            }

            return BlocProvider(
              create: (_) => NotificationCubit(
                getNotificationsUseCase: sl<GetNotificationsUseCase>(),
                registerDeviceTokenUseCase:
                sl<RegisterDeviceTokenUseCase>(),
                userId: user.userId,
                authToken: user.accessToken,
              ),
              child: const LabAdminMainPage(),
            );
          },
        ),

        // 🟩 TALENT
        GoRoute(
          path: Routes.talent,
          name: Routes.talentName,
          builder: (context, state) {
            final user = authProvider.currentUser;
            if (user == null) return const LoginPage();

            return BlocProvider(
              create: (_) => NotificationCubit(
                getNotificationsUseCase: sl<GetNotificationsUseCase>(),
                registerDeviceTokenUseCase:
                sl<RegisterDeviceTokenUseCase>(),
                userId: user.userId,
                authToken: user.accessToken,
              ),
              child: const TalentMainPage(),
            );
          },
        ),

        // 🟩 MENTOR
        GoRoute(
          path: Routes.mentor,
          name: Routes.mentorName,
          builder: (context, state) {
            final user = authProvider.currentUser;
            if (user == null) return const LoginPage();

            return BlocProvider(
              create: (_) => NotificationCubit(
                getNotificationsUseCase: sl<GetNotificationsUseCase>(),
                registerDeviceTokenUseCase:
                sl<RegisterDeviceTokenUseCase>(),
                userId: user.userId,
                authToken: user.accessToken,
              ),
              child: const MentorMainPage(),
            );
          },
        ),

        // 🟩 COMPANY
        GoRoute(
          path: Routes.company,
          name: Routes.companyName,
          builder: (context, state) {
            final user = authProvider.currentUser;
            if (user == null) return const LoginPage();

            return BlocProvider(
              create: (_) => NotificationCubit(
                getNotificationsUseCase: sl<GetNotificationsUseCase>(),
                registerDeviceTokenUseCase:
                sl<RegisterDeviceTokenUseCase>(),
                userId: user.userId,
                authToken: user.accessToken,
              ),
              child: const CompanyMainPage(),
            );
          },
        ),
      ],
    );
  }

  // === PRIVATE METHODS ===

  static String? _handleRedirect(
      GoRouterState state,
      AuthProvider authProvider,
      ) {
    final currentPath = state.uri.toString();
    final isAuthenticated = authProvider.isAuthenticated;
    final role = authProvider.role;
    final targetHomeRoute = getHomeRouteByRole(role);

    debugPrint(
        'AppRouter Redirect: $currentPath | Auth: $isAuthenticated | Role: $role | Init: ${authProvider.isInitialCheckComplete}');

    if (currentPath == Routes.splash &&
        !authProvider.isInitialCheckComplete) {
      return null; // Chờ Splash load
    }

    // 1️⃣ Chưa login mà vào protected route
    if (!isAuthenticated && _isProtectedRoute(currentPath)) {
      return Routes.login;
    }

    // 2️⃣ Đã login nhưng vẫn ở login/home/register
    if (isAuthenticated &&
        (currentPath == Routes.login ||
            currentPath == Routes.home ||
            currentPath == Routes.register)) {
      return targetHomeRoute;
    }

    // 3️⃣ Đã login nhưng không đúng role
    if (isAuthenticated && _requiresRoleCheck(currentPath)) {
      if (!_hasRequiredRole(currentPath, role)) {
        return targetHomeRoute;
      }
    }

    return null;
  }

  static bool _isProtectedRoute(String path) {
    return !Routes.publicRoutes.any((route) => path.startsWith(route));
  }

  static bool _requiresRoleCheck(String path) {
    return path == Routes.user ||
        path == Routes.labAdmin ||
        path == Routes.talent ||
        path == Routes.mentor ||
        path == Routes.company;
  }

  static bool _hasRequiredRole(String path, String? userRole) {
    final role = userRole?.toLowerCase().replaceAll('-', '_');

    switch (path) {
      case Routes.labAdmin:
        return role == 'lab_admin';
      case Routes.talent:
        return role == 'talent';
      case Routes.mentor:
        return role == 'mentor';
      case Routes.company:
        return role == 'company';
      case Routes.user:
        return role == 'user' || role == null || role.isEmpty;
      default:
        return true;
    }
  }

  static String getHomeRouteByRole(String? role) {
    final normalizedRole = role?.toLowerCase().replaceAll('-', '_');

    switch (normalizedRole) {
      case 'lab_admin':
        return Routes.labAdmin;
      case 'talent':
        return Routes.talent;
      case 'mentor':
        return Routes.mentor;
      case 'company':
        return Routes.company;
      case 'user':
      default:
        return Routes.user;
    }
  }

  // === UTILITY METHODS ===
  static void goNamed(String name, {Map<String, String>? pathParameters}) {
    _rootNavigatorKey.currentContext?.goNamed(
      name,
      pathParameters: pathParameters ?? {},
    );
  }

  static void pushNamed(String name, {Map<String, String>? pathParameters}) {
    _rootNavigatorKey.currentContext?.pushNamed(
      name,
      pathParameters: pathParameters ?? {},
    );
  }

  static void pop() {
    _rootNavigatorKey.currentContext?.pop();
  }
}

// === EXTENSIONS ===
extension AppRouterExtension on BuildContext {
  void goToPostDetail(String postId) {
    goNamed(Routes.postDetailName, pathParameters: {'id': postId});
  }

  void goToLogin() {
    go(Routes.login);
  }

  void goToRoleBasedHome(String? role) {
    final route = AppRouter.getHomeRouteByRole(role);
    go(route);
  }
}
