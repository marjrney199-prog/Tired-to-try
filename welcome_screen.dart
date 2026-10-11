import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_logo.dart';
import '../widgets/surface_card.dart';
import 'auth_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: dark
                ? const [Color(0xFF121212), Color(0xFF0A2342)]
                : const [Color(0xFFFFFFFF), Color(0xFFEAF0F8)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppLogo(width: width < 440 ? width * .76 : 360, dark: dark),
                    const SizedBox(height: 20),
                    Text(
                      'O conhecimento abre portas.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Aprenda idiomas, pratique conversas e consulte ferramentas úteis — mesmo sem internet.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.5),
                    ),
                    const SizedBox(height: 28),
                    SurfaceCard(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FilledButton.icon(
                            onPressed: () => _openAuth(context, AuthMode.login),
                            icon: const Icon(Icons.login_rounded),
                            label: const Text('Entrar'),
                            style: FilledButton.styleFrom(backgroundColor: AppConstants.navy, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(52)),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () => _openAuth(context, AuthMode.register),
                            icon: const Icon(Icons.person_add_alt_1_rounded),
                            label: const Text('Criar conta local'),
                            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52), side: const BorderSide(color: AppConstants.gold, width: 1.4)),
                          ),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: () => _continueOffline(context),
                            icon: const Icon(Icons.wifi_off_rounded),
                            label: const Text('Continuar Offline'),
                            style: TextButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            'Conta, progresso e conteúdos ficam neste dispositivo. Sem subscrições e sem serviços de IA.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_outline_rounded, size: 15, color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text('Armazenamento local · privacidade por concepção', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openAuth(BuildContext context, AuthMode mode) => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => AuthScreen(initialMode: mode)),
      );

  Future<void> _continueOffline(BuildContext context) async {
    try {
      await context.read<AuthProvider>().continueOffline();
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível iniciar o perfil offline: $error')));
    }
  }
}
