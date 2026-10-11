import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/database/app_database.dart';
import 'core/storage/local_storage.dart';
import 'providers/auth_provider.dart';
import 'providers/progress_provider.dart';
import 'providers/settings_provider.dart';
import 'repositories/progress_repository.dart';
import 'repositories/user_repository.dart';
import 'services/auth_service.dart';
import 'services/speech_service.dart';
import 'services/translation_service.dart';
import 'services/tts_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Hive.initFlutter().timeout(const Duration(seconds: 8));
    await LocalStorage.initialize().timeout(const Duration(seconds: 8));
    await AppDatabase.instance.initialize().timeout(const Duration(seconds: 8));

    final database = AppDatabase.instance;
    runApp(
      MultiProvider(
        providers: [
          Provider<AppDatabase>.value(value: database),
          Provider<TranslationService>.value(value: const TranslationService()),
          Provider<TtsService>(create: (_) => TtsService()),
          Provider<SpeechService>(create: (_) => SpeechService()),
          ChangeNotifierProvider(create: (_) => SettingsProvider()..load()),
          ChangeNotifierProvider(
            create: (_) => AuthProvider(AuthService(UserRepository(database)))..restore(),
          ),
          ChangeNotifierProvider(
            create: (_) => ProgressProvider(ProgressRepository(database)),
          ),
        ],
        child: const EAHubApp(),
      ),
    );
  } catch (error) {
    runApp(_StartupFailureApp(error: error));
  }
}

class _StartupFailureApp extends StatelessWidget {
  const _StartupFailureApp({required this.error});
  final Object error;

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A2342))),
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.storage_rounded, size: 48, color: Color(0xFFD4AF37)),
                  const SizedBox(height: 14),
                  const Text('Não foi possível iniciar o armazenamento local.', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(error.toString(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 18),
                  FilledButton.icon(onPressed: () async { await main(); }, icon: const Icon(Icons.refresh_rounded), label: const Text('Tentar novamente')),
                ]),
              ),
            ),
          ),
        ),
      );
}
