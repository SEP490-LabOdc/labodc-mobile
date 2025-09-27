// core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:labodc_mobile/common/presentation/pages/setting_page.dart';

// Pages imports
import '../../features/admin/presentation/pages/admin_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/company/presentation/pages/company_main_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/mentor/presentation/pages/mentor_main_page.dart';
import '../../features/talent/presentation/pages/talent_main_page.dart';
import '../../features/user/presentation/pages/user_page.dart';

// Providers
import '../../features/auth/presentation/provider/auth_provider.dart';

// Constants
import 'route_constants.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
  GlobalKey<NavigatorState>();

  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: Routes.splash,
      refreshListenable: authProvider,

      // Redirect logic
      redirect: (context, state) => _handleRedirect(state, authProvider),

      routes: [
        // === PUBLIC ROUTES ===
        GoRoute(
          path: Routes.splash,
          name: Routes.splashName,
          builder: (context, state) {
            final authProvider = context.read<AuthProvider>();
            return SplashPage(
              onFinish: () async {
                if (authProvider.isAuthenticated) {
                  final route = AppRouter.getHomeRouteByRole(authProvider.role);
                  context.go(route);
                } else {
                  context.go(Routes.home);
                }
              },
            );
          },
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
          builder: (context, state) => const UserPage(),
        ),
        GoRoute(
          path: Routes.admin,
          name: Routes.adminName,
          builder: (context, state) => const AdminPage(),
        ),
        GoRoute(
          path: Routes.talent,
          name: Routes.talentName,
          builder: (context, state) => const TalentMainPage(),
        ),
        GoRoute(
          path: Routes.mentor,
          name: Routes.mentorName,
          builder: (context, state) => const MentorMainPage(),
        ),
        GoRoute(
          path: Routes.company,
          name: Routes.companyName,
          builder: (context, state) => const CompanyMainPage(),
        ),
      ],
    );
  }

  // === PRIVATE METHODS ===

  /// Redirect logic
  static String? _handleRedirect(
      GoRouterState state, AuthProvider authProvider) {
    final currentPath = state.uri.toString();
    final isAuthenticated = authProvider.isAuthenticated;

    // 1. Nếu chưa đăng nhập mà vào protected route
    if (!isAuthenticated && _isProtectedRoute(currentPath)) {
      return Routes.login;
    }

    // 2. Nếu đã login mà vẫn ở login page
    if (isAuthenticated && currentPath == Routes.login) {
      return getHomeRouteByRole(authProvider.role);
    }

    // 3. Nếu đã login mà vẫn ở home page (public) → về dashboard theo role
    if (isAuthenticated && currentPath == Routes.home) {
      return getHomeRouteByRole(authProvider.role);
    }

    // 4. Nếu login nhưng không đúng role
    if (isAuthenticated && _requiresRoleCheck(currentPath)) {
      if (!_hasRequiredRole(currentPath, authProvider.role)) {
        return Routes.user;
      }
    }

    return null; // Không cần redirect
  }

  /// Kiểm tra protected route
  static bool _isProtectedRoute(String path) {
    return !Routes.publicRoutes.any((route) => path.startsWith(route));
  }

  /// Route có cần check role?
  static bool _requiresRoleCheck(String path) {
    return path == Routes.admin ||
        path == Routes.talent ||
        path == Routes.mentor ||
        path == Routes.company;
  }

  /// Kiểm tra quyền role
  static bool _hasRequiredRole(String path, String? userRole) {
    switch (path) {
      case Routes.admin:
        return userRole == 'admin';
      case Routes.talent:
        return userRole == 'talent';
      case Routes.mentor:
        return userRole == 'mentor';
      case Routes.company:
        return userRole == 'company';
      default:
        return true;
    }
  }

  /// Lấy home route theo role
  static String getHomeRouteByRole(String? role) {
    switch (role) {
      case 'admin':
        return Routes.admin;
      case 'talent':
        return Routes.talent;
      case 'mentor':
        return Routes.mentor;
      case 'company':
        return Routes.company;
      default:
        return Routes.user;
    }
  }

  /// Navigate sau khi splash xong
  static void _navigateAfterSplash(
      BuildContext context, AuthProvider authProvider) {
    if (authProvider.isAuthenticated) {
      final route = getHomeRouteByRole(authProvider.role);
      context.go(route);
    } else {
      context.go(Routes.home);
    }
  }

  // === UTILITY METHODS ===

  static void goNamed(String name,
      {Map<String, String>? pathParameters}) {
    _rootNavigatorKey.currentContext
        ?.goNamed(name, pathParameters: pathParameters ?? {});
  }

  static void pushNamed(String name,
      {Map<String, String>? pathParameters}) {
    _rootNavigatorKey.currentContext
        ?.pushNamed(name, pathParameters: pathParameters ?? {});
  }

  static void pop() {
    _rootNavigatorKey.currentContext?.pop();
  }
}

// === EXTENSION METHODS ===
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
