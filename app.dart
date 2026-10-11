import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/app_user.dart';
import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/main_shell.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'theme/app_theme.dart';

class EAHubApp extends StatelessWidget {
  const EAHubApp({super.key});

  @override
  Widget build(BuildContext context) => Consumer<SettingsProvider>(
        builder: (context, settings, _) => MaterialApp(
          title: 'EA LANGUAGE HUB',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: settings.themeMode,
          home: const _AppGate(),
        ),
      );
}

class _AppGate extends StatelessWidget {
  const _AppGate();

  @override
  Widget build(BuildContext context) => Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (!auth.isReady) return const SplashScreen();
          final AppUser? user = auth.currentUser;
          if (user == null) return const WelcomeScreen();
          return MainShell(user: user);
        },
      );
}
