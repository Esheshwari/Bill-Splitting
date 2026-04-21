import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'providers/app_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'services/app_bootstrap.dart';

class SplitSmartBootstrap extends StatelessWidget {
  const SplitSmartBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppBootstrapResult>(
      future: AppBootstrapService.initialize(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: const SplashScreen(),
          );
        }

        final bootstrap = snapshot.data!;
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => AuthProvider(bootstrap.authService)..bootstrap(),
            ),
            ChangeNotifierProvider(
              create: (_) => AppProvider(bootstrap.repository)..bootstrap(),
            ),
          ],
          child: const SplitSmartApp(),
        );
      },
    );
  }
}

class SplitSmartApp extends StatelessWidget {
  const SplitSmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, AppProvider>(
      builder: (context, auth, app, _) {
        if (auth.user != null && app.currentUserId != auth.user!.id) {
          Future.microtask(() => app.bindUser(auth.user!.id));
        }
        return MaterialApp(
          title: 'SplitSmart',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: auth.themeMode,
          home: auth.isLoading
              ? const SplashScreen()
              : auth.isAuthenticated
                  ? const HomeScreen()
                  : const LoginScreen(),
        );
      },
    );
  }
}
