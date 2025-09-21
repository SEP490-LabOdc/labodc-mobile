import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/presentation/pages/admin_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/auth/presentation/provider/auth_provider.dart';
import '../../features/user/presentation/pages/user_page.dart';
import '../../features/auth/data/data_sources/splash_local_datasource.dart';
import '../../features/home/presentation/pages/post_detail_page.dart';

class AppRouter {
  static GoRouter createRouter(AuthProvider authProvider, SplashLocalDatasource splashLocalDatasource) {
    bool splashShown = false;

    return GoRouter(
      initialLocation: '/',
      refreshListenable: authProvider,
      routes: [
        GoRoute(
          path: '/',
          name: 'splash',
          builder: (context, state) => SplashPage(
            onFinish: () async {
              splashShown = true;
              context.go('/home');
            },
          ),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomePage(),
          routes: [
            GoRoute(
              path: 'user',
              name: 'user',
              builder: (context, state) => const UserPage(),
            ),
            GoRoute(
              path: 'admin',
              name: 'admin',
              builder: (context, state) => const AdminPage(),
            ),
            GoRoute(
              path: 'post_detail',
              name: 'post_detail',
              builder: (context, state) {
                final newsItem = state.extra as dynamic;
                return PostDetailPage(
                  id: newsItem.id,
                  title: newsItem.title,
                  body: newsItem.body,
                  userId: newsItem.userId,
                );
              },
            ),
          ],
        ),
      ],
      redirect: (context, state) {
        final loggedIn = authProvider.isAuthenticated;
        final loggingIn = state.uri.toString() == '/login';
        final publicRoutes = ['/', '/home','/register'];

        // Chỉ cho phép splash khi vừa mở app, sau đó chuyển sang home và không quay lại splash nữa
        if (state.matchedLocation == '/' && splashShown) {
          return '/home';
        }

        if (!loggedIn && !loggingIn && !publicRoutes.contains(state.uri.toString())) {
          return '/login';
        }

        if (loggedIn && loggingIn) return '/home';

        if (state.uri.toString().startsWith('/home/admin')) {
          if (!authProvider.hasRole('admin')) return '/home';
        }

        return null;
      },
    );
  }
}
