// core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: Routes.splash,
      refreshListenable: authProvider,

      // Redirect logic - đơn giản và rõ ràng
      redirect: (context, state) => _handleRedirect(state, authProvider),

      routes: [
        // === PUBLIC ROUTES ===
        GoRoute(
          path: Routes.splash,
          name: Routes.splashName,
          builder: (context, state) => SplashPage(
            onFinish: () async => _navigateAfterSplash(context, authProvider),
          ),
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

  /// Xử lý redirect logic
  static String? _handleRedirect(GoRouterState state, AuthProvider authProvider) {
    final currentPath = state.uri.toString();
    final isAuthenticated = authProvider.isAuthenticated;

    // 1. Nếu chưa đăng nhập và truy cập protected route
    if (!isAuthenticated && _isProtectedRoute(currentPath)) {
      return Routes.login;
    }

    // 2. Nếu đã đăng nhập mà vẫn ở login page
    if (isAuthenticated && currentPath == Routes.login) {
      return _getHomeRouteByRole(authProvider.role);
    }

    // 3. Nếu đã đăng nhập mà vẫn ở home page (public) -> chuyển đến dashboard
    if (isAuthenticated && currentPath == Routes.home) {
      return _getHomeRouteByRole(authProvider.role);
    }

    // 4. Kiểm tra quyền truy cập role-based routes
    if (isAuthenticated && _requiresRoleCheck(currentPath)) {
      if (!_hasRequiredRole(currentPath, authProvider.role)) {
        return Routes.user; // 👈 Chuyển về user page thay vì home
      }
    }

    return null; // Không cần redirect
  }

  /// Kiểm tra xem route có phải là protected không
  static bool _isProtectedRoute(String path) {
    return !Routes.publicRoutes.any((route) => path.startsWith(route));
  }

  /// Kiểm tra xem route có cần check role không
  static bool _requiresRoleCheck(String path) {
    return path == Routes.admin ||
        path == Routes.talent ||
        path == Routes.mentor;
  }

  /// Kiểm tra user có role phù hợp không
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

  /// Lấy route phù hợp theo role sau khi login
  static String _getHomeRouteByRole(String? role) {
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
        return Routes.user; // 👈 Default cho user đã login nhưng không có role cụ thể
    }
  }

  /// Navigate sau khi splash finish
  static void _navigateAfterSplash(BuildContext context, AuthProvider authProvider) {
    if (authProvider.isAuthenticated) {
      // 👈 Đã login -> chuyển đến dashboard theo role
      final route = _getHomeRouteByRole(authProvider.role);
      context.go(route);
    } else {
      // 👈 Chưa login -> chuyển đến home page (public)
      context.go(Routes.home);
    }
  }

  // === UTILITY METHODS ===

  /// Navigate đến route với name
  static void goNamed(String name, {Map<String, String>? pathParameters}) {
    _rootNavigatorKey.currentContext?.goNamed(name, pathParameters: pathParameters ?? {});
  }

  /// Push route với name
  static void pushNamed(String name, {Map<String, String>? pathParameters}) {
    _rootNavigatorKey.currentContext?.pushNamed(name, pathParameters: pathParameters ?? {});
  }

  /// Go back
  static void pop() {
    _rootNavigatorKey.currentContext?.pop();
  }
}

// === EXTENSION METHODS ===
extension AppRouterExtension on BuildContext {
  /// Go to post detail
  void goToPostDetail(String postId) {
    goNamed(Routes.postDetailName, pathParameters: {'id': postId});
  }

  /// Go to login
  void goToLogin() {
    go(Routes.login);
  }

  /// Go to home based on role
  void goToRoleBasedHome(String? role) {
    final route = AppRouter._getHomeRouteByRole(role);
    go(route);
  }
}