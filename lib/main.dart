import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/get_it/get_it.dart';
import 'core/router/app_router.dart';
import 'core/config/networks/env.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/bloc/theme_bloc.dart';
import 'core/theme/bloc/theme_events.dart';
import 'core/theme/bloc/theme_state.dart';
import 'core/theme/domain/entity/theme_entity.dart';

import 'features/auth/data/data_sources/auth_remote_data_source.dart';
import 'features/auth/data/data_sources/splash_local_datasource.dart';
import 'features/auth/data/repositories_impl/auth_repository_impl.dart';
import 'features/auth/domain/use_cases/login_use_case.dart';
import 'features/auth/presentation/provider/auth_provider.dart';

import 'features/user/data/data_sources/user_remote_data_source.dart';
import 'features/user/data/repositories_impl/user_repository_impl.dart';
import 'features/user/domain/use_cases/get_user_profile.dart';
import 'features/user/presentation/provider/user_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load config môi trường
  await Env.load();

  // Init dependency injection (get_it)
  await init();

  // SharedPreferences để dùng cho Splash
  final sharedPreferences = await SharedPreferences.getInstance();
  final splashLocalDatasource =
  SplashLocalDatasource(sharedPreferences: sharedPreferences);

  runApp(
    BlocProvider(
      create: (_) => getIt<ThemeBloc>()..add(GetThemeEvent()),
      child: LabOdcApp(splashLocalDatasource: splashLocalDatasource),
    ),
  );
}

class LabOdcApp extends StatelessWidget {
  final SplashLocalDatasource splashLocalDatasource;
  const LabOdcApp({super.key, required this.splashLocalDatasource});

  @override
  Widget build(BuildContext context) {
    final authProvider = AuthProvider(loginUseCase: getIt<LoginUseCase>());

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider(
          create: (_) => UserProvider(getUserProfile: getIt<GetUserProfile>()),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          final isDark = state.themeEntity?.themeType == ThemeType.dark;
          final router =
          AppRouter.createRouter(authProvider, splashLocalDatasource);

          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'LabODC',
            routerConfig: router,
            theme: AppTheme.getTheme(false),
            darkTheme: AppTheme.getTheme(true),
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('vi'),
            ],
          );
        },
      ),
    );
  }
}
