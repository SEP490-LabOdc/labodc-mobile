// core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Thêm để dùng debugPrint
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
    debugPrint('AppRouter: Bắt đầu tạo GoRouter.');
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
          // ĐÃ SỬA: Không có logic điều hướng ở đây
          builder: (context, state) {
            return const SplashPage();
          },
        ),

        GoRoute(
          path: Routes.home,
          name: Routes.homeName,
          builder: (context, state) => const HomePage(),
        ),
        // ... (các routes khác giữ nguyên)

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
          builder: (context, state) => const TalentMainPage(),
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
      GoRouterState state,
      AuthProvider authProvider,
      ) {
    final currentPath = state.uri.toString();
    final isAuthenticated = authProvider.isAuthenticated;
    final role = authProvider.role;
    final targetRoute = getHomeRouteByRole(role);

    debugPrint('AppRouter Redirect: Đang ở $currentPath. isAuthenticated: $isAuthenticated, Role: $role, CheckComplete: ${authProvider.isInitialCheckComplete}');

    // SỬA LỖI QUAN TRỌNG: Router Guard cho Splash Page
    // Nếu đang ở Splash và AuthProvider chưa hoàn tất kiểm tra token, KHÔNG REDIRECT.
    if (currentPath == Routes.splash && !authProvider.isInitialCheckComplete) {
      debugPrint('AppRouter Redirect: Đang ở Splash và AuthProvider chưa xong. KHÔNG REDIRECT (Waiting for SplashPage).');
      return null;
    }

    // 1. Nếu chưa đăng nhập mà vào protected route
    if (!isAuthenticated && _isProtectedRoute(currentPath)) {
      debugPrint('AppRouter Redirect: Chưa ĐN và vào protected route. Redirect -> ${Routes.login}');
      return Routes.login;
    }

    // 2. Nếu đã login mà vẫn ở login page
    if (isAuthenticated && currentPath == Routes.login) {
      debugPrint('AppRouter Redirect: Đã ĐN và ở Login Page. Redirect -> $targetRoute');
      return targetRoute;
    }

    // 3. Nếu đã login mà vẫn ở home page (public)
    if (isAuthenticated && currentPath == Routes.home) {
      debugPrint('AppRouter Redirect: Đã ĐN và ở Home Page. Redirect -> $targetRoute');
      return targetRoute;
    }

    // 4. Nếu login nhưng không đúng role (Protected route check)
    if (isAuthenticated && _requiresRoleCheck(currentPath)) {
      if (!_hasRequiredRole(currentPath, role)) {
        debugPrint('AppRouter Redirect: ĐN nhưng role (${role}) không phù hợp với $currentPath. Redirect -> $targetRoute');
        return targetRoute;
      }
    }

    debugPrint('AppRouter Redirect: Không cần redirect. Ở lại $currentPath');
    return null; // Không cần redirect
  }

  /// Kiểm tra protected route
  static bool _isProtectedRoute(String path) {
    return !Routes.publicRoutes.any((route) => path.startsWith(route));
  }

  /// Route có cần check role?
  static bool _requiresRoleCheck(String path) {
    return path == Routes.user ||
        path == Routes.admin ||
        path == Routes.talent ||
        path == Routes.mentor ||
        path == Routes.company;
  }

  /// Kiểm tra quyền role
  static bool _hasRequiredRole(String path, String? userRole) {
    final role = userRole?.toLowerCase();

    switch (path) {
      case Routes.admin:
        return role == 'admin';
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

  /// Lấy home route theo role
  static String getHomeRouteByRole(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return Routes.admin;
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
  // ... (giữ nguyên)
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