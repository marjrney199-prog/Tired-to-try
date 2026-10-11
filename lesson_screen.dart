import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../models/lesson.dart';
import '../widgets/surface_card.dart';
import 'quiz_screen.dart';

class LessonScreen extends StatelessWidget {
  const LessonScreen({super.key, required this.lesson});
  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('${lesson.languageName} · ${lesson.level}')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 780),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(colors: [AppConstants.navy, Color(0xFF173E6B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: AppConstants.gold.withValues(alpha: .22), borderRadius: BorderRadius.circular(20)), child: Text('NÍVEL ${lesson.level}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1))),
                  const SizedBox(height: 16),
                  Text(lesson.title, style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(lesson.description, style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white.withValues(alpha: .86), height: 1.5)),
                  const SizedBox(height: 16),
                  Row(children: [const Icon(Icons.schedule_rounded, color: AppConstants.gold, size: 18), const SizedBox(width: 6), Text('${lesson.durationMinutes} minutos', style: const TextStyle(color: Colors.white)), const SizedBox(width: 18), const Icon(Icons.quiz_outlined, color: AppConstants.gold, size: 18), const SizedBox(width: 6), Text('${lesson.questions.length} exercícios', style: const TextStyle(color: Colors.white))]),
                ]),
              ),
              const SizedBox(height: 22),
              Text('Nesta lição', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              SurfaceCard(child: Column(children: const [
                _FeatureRow(icon: Icons.check_circle_outline, title: 'Exercícios interactivos', subtitle: 'Escolha, complete, ligue e responda.'),
                Divider(height: 22),
                _FeatureRow(icon: Icons.volume_up_outlined, title: 'Escuta com texto para voz', subtitle: 'Usa as vozes disponíveis no dispositivo.'),
                Divider(height: 22),
                _FeatureRow(icon: Icons.insights_outlined, title: 'Progresso guardado', subtitle: 'Pontuação e XP são armazenados localmente.'),
              ])),
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => QuizScreen(lesson: lesson))),
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Iniciar exercícios'),
                style: FilledButton.styleFrom(backgroundColor: AppConstants.navy, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(54)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, color: AppConstants.gold),
    const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 3),
      Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
    ])),
  ]);
}
