import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/get_it/get_it.dart';
import 'core/router/app_router.dart';
import 'core/config/networks/env.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/bloc/theme_bloc.dart';
import 'core/theme/bloc/theme_events.dart';
import 'core/theme/bloc/theme_state.dart';
import 'core/theme/domain/entity/theme_entity.dart';

import 'features/auth/domain/use_cases/login_use_case.dart';
import 'features/auth/presentation/provider/auth_provider.dart';
import 'features/user/domain/use_cases/get_user_profile.dart';
import 'features/user/presentation/provider/user_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment config
  await Env.load();

  // Initialize dependency injection
  await init(useFakeAuth: true);

  runApp(
    BlocProvider(
      create: (_) => getIt<ThemeBloc>()..add(GetThemeEvent()),
      child: const LabOdcApp(),
    ),
  );
}

class LabOdcApp extends StatelessWidget {
  const LabOdcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(loginUseCase: getIt<LoginUseCase>()),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProvider(getUserProfile: getIt<GetUserProfile>()),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
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

                routerConfig: AppRouter.createRouter(authProvider),
              );
            },
          );
        },
      ),
    );
  }
}