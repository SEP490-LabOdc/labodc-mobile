import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Giữ lại nếu cần dùng cho các Bloc khác
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:labodc_mobile/features/company/presentation/pages/company_detail_page.dart';
import 'package:labodc_mobile/features/project_fund/presentation/pages/project_fund_page.dart';

// Pages imports
import '../../features/admin/presentation/pages/lab_admin_main_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/company/presentation/pages/company_main_page.dart';
import '../../features/mentor/presentation/pages/mentor_main_page.dart';
import '../../features/milestone/presentation/pages/milestone_detail_page.dart';
import '../../features/notification/presentation/pages/notification_page.dart';
import '../../features/project_fund/presentation/cubit/project_fund_cubit.dart';
import '../../features/talent/presentation/pages/talent_main_page.dart';
import '../../features/user/presentation/pages/user_page.dart';
import '../../common/presentation/pages/setting_page.dart';
import '../../features/hiring_projects/presentation/pages/project_detail_page.dart';
import '../../features/project_application/presentation/pages/my_project_detail_page.dart';

// Providers
import '../../features/auth/presentation/provider/auth_provider.dart';

// Constants
import '../../features/user_profile/data/models/user_profile_model.dart';
import '../../features/user_profile/presentation/pages/edit_profile_page.dart';
import '../../wallet/presentation/pages/transaction_history_page.dart';
import '../get_it/get_it.dart';
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

        // 🟩 USER (Sửa lại: Trả về UserPage thay vì TalentMainPage)
        GoRoute(
          path: Routes.user,
          name: Routes.userName,
          builder: (context, state) {
            final user = authProvider.currentUser;
            if (user == null) return const LoginPage();
            return const TalentMainPage();
          },
        ),

        // 🟩 LAB ADMIN
        GoRoute(
          path: Routes.labAdmin,
          name: Routes.labAdminName,
          builder: (context, state) {
            final user = authProvider.currentUser;
            if (user == null) return const LoginPage();
            return const LabAdminMainPage();
          },
        ),

        // 🟩 TALENT
        GoRoute(
          path: Routes.talent,
          name: Routes.talentName,
          builder: (context, state) {
            final user = authProvider.currentUser;
            if (user == null) return const LoginPage();
            return const TalentMainPage();
          },
        ),

        // 🟩 MENTOR
        GoRoute(
          path: Routes.mentor,
          name: Routes.mentorName,
          builder: (context, state) {
            final user = authProvider.currentUser;
            if (user == null) return const LoginPage();
            return const MentorMainPage();
          },
        ),

        // 🟩 COMPANY
        GoRoute(
          path: Routes.company,
          name: Routes.companyName,
          builder: (context, state) {
            final user = authProvider.currentUser;
            if (user == null) return const LoginPage();
            return const CompanyMainPage();
          },
        ),

        // === DETAIL PAGES ===
        GoRoute(
          path: Routes.projectDetail,
          name: Routes.projectDetailName,
          builder: (context, state) {
            final id = state.pathParameters['id'];
            if (id == null) return const SizedBox.shrink();
            return ProjectDetailPage(projectId: id);
          },
        ),
        GoRoute(
          path: Routes.myProjectDetail,
          name: Routes.myProjectDetailName,
          builder: (context, state) {
            final id = state.pathParameters['id'];
            if (id == null) return const SizedBox.shrink();
            return MyProjectDetailPage(projectId: id);
          },
        ),
        GoRoute(
          path: Routes.milestoneDetail,
          name: Routes.milestoneDetailName,
          builder: (context, state) {
            final id = state.pathParameters['id'];
            if (id == null) return const SizedBox.shrink();
            return MilestoneDetailPage(milestoneId: id);
          },
        ),
        GoRoute(
          path: Routes.editProfile,
          builder: (context, state) {
            final user = state.extra as UserProfileModel;
            return EditProfilePage(user: user);
          },
        ),

        // 🟩 NOTIFICATIONS
        GoRoute(
          path: Routes.notifications,
          name: Routes.notificationsName,
          builder: (context, state) {
            final user = authProvider.currentUser;
            if (user == null) return const LoginPage();
            // Đã có WebSocketNotificationCubit global, không cần BlocProvider ở đây
            return const NotificationPage();
          },
        ),

        GoRoute(
          path: Routes.projectFund,
          name: Routes.projectFundName,
          builder: (context, state) {
            final user = authProvider.currentUser;
            if (user == null) return const LoginPage();

            return BlocProvider<ProjectFundCubit>(
              create: (_) => getIt<ProjectFundCubit>(),
              child: const ProjectFundPage(),
            );
          },
        ),
        GoRoute(
          path: Routes.transactionHistory,
          name: Routes.transactionHistoryName,
          builder: (context, state) {
            return TransactionHistoryPage();
          },
        ),

        GoRoute(
          path: Routes.companyDetail,
          name: Routes.companyDetailName,
          builder: (context, state) {
            final id = state.pathParameters['id'];
            if (id == null) return const SizedBox.shrink();
            return CompanyDetailPage(companyId: id);
          },
        ),
      ],
    );
  }

  // === PRIVATE METHODS (Giữ nguyên) ===

  static String? _handleRedirect(GoRouterState state, AuthProvider authProvider) {
    final currentPath = state.uri.toString();
    final isAuthenticated = authProvider.isAuthenticated;
    final isInitialCheckComplete = authProvider.isInitialCheckComplete;
    final role = authProvider.currentUser?.role;
    final targetHomeRoute = getHomeRouteByRole(role);

    // 1. Nếu chưa kiểm tra xong trạng thái ban đầu (đang ở Splash), không redirect
    if (currentPath == Routes.splash && !isInitialCheckComplete) {
      return null;
    }

    // 2. Nếu CHƯA đăng nhập
    if (!isAuthenticated) {
      // Nếu đang ở các trang công khai (Login, Register, Splash), cho phép ở lại
      if (currentPath == Routes.login || currentPath == Routes.register || currentPath == Routes.splash) {
        return null;
      }
      // Nếu cố vào trang bảo mật, bắt quay về Login
      if (_isProtectedRoute(currentPath)) {
        return Routes.login;
      }
    }

    // 3. Nếu ĐÃ đăng nhập mà vẫn ở trang Login/Register/Splash
    if (isAuthenticated && (currentPath == Routes.login || currentPath == Routes.register || currentPath == Routes.splash)) {
      return targetHomeRoute;
    }

    // 4. Kiểm tra quyền truy cập Role (giữ nguyên logic của bạn)
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
        return Routes.talent;
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