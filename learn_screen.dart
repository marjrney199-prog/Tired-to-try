import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/storage/local_storage.dart';
import '../data/seed_data.dart';
import '../models/lesson.dart';
import '../widgets/section_title.dart';
import '../widgets/surface_card.dart';
import 'lesson_screen.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  String _languageCode = 'en';
  String _level = 'A1';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = LocalStorage.enabledLanguageCodes.toSet();
    final languages = SeedData.languages.where((item) => enabled.contains(item.code)).toList();
    final availableLanguages = languages.isEmpty ? SeedData.languages : languages;
    if (!availableLanguages.any((item) => item.code == _languageCode)) {
      _languageCode = availableLanguages.first.code;
    }
    final language = SeedData.language(_languageCode);
    final lessons = <Lesson>[
      ...SeedData.lessonsFor(_languageCode, _level),
      ...LocalStorage.customLessons
          .where((item) => item['language_code'] == _languageCode && item['level'] == _level)
          .map((item) => Lesson(
                id: item['id'].toString(),
                languageCode: _languageCode,
                languageName: language.name,
                level: _level,
                title: item['title']?.toString() ?? 'Lição personalizada',
                description: item['description']?.toString().isNotEmpty == true
                    ? item['description'].toString()
                    : 'Lição local criada no painel administrativo.',
                durationMinutes: 3,
                questions: [ExerciseQuestion(
                  id: '${item['id']}_q1',
                  kind: ExerciseKind.fillBlank,
                  prompt: 'Traduza “${item['prompt']}” para ${language.name}.',
                  answer: item['answer'].toString(),
                )],
              )),
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle('Aprender', subtitle: 'Escolha um idioma, avance por níveis e pratique com exercícios.'),
            const SizedBox(height: 18),
            SurfaceCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.public_rounded, color: AppConstants.gold),
                  const SizedBox(width: 9),
                  Expanded(child: Text('Idioma de estudo', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
                  Text('${availableLanguages.length} idiomas', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ]),
                const SizedBox(height: 13),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableLanguages.map((item) => ChoiceChip(
                    selected: item.code == _languageCode,
                    onSelected: (_) => setState(() => _languageCode = item.code),
                    avatar: Text(item.flag),
                    label: Text(item.name),
                    selectedColor: AppConstants.gold.withValues(alpha: .25),
                  )).toList(),
                ),
                const SizedBox(height: 10),
                Text('Línguas africanas adicionais — Changana, Ronga, Macua, Sena, Ndau, Tsonga e Zulu — estão previstas na estrutura, mas ainda não têm conteúdo de tradução nesta versão.', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.4)),
              ]),
            ),
            const SizedBox(height: 19),
            const SectionTitle('Níveis de proficiência', subtitle: 'Percurso organizado do nível A1 ao C2.'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 9,
              runSpacing: 8,
              children: SeedData.levels.map((level) => ChoiceChip(
                selected: _level == level,
                label: Text(level),
                onSelected: (_) => setState(() => _level = level),
                selectedColor: AppConstants.navy,
                labelStyle: TextStyle(color: _level == level ? Colors.white : null, fontWeight: FontWeight.w700),
              )).toList(),
            ),
            const SizedBox(height: 14),
            SurfaceCard(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Container(width: 46, height: 46, decoration: BoxDecoration(color: AppConstants.gold.withValues(alpha: .18), borderRadius: BorderRadius.circular(14)), child: Center(child: Text(language.flag, style: const TextStyle(fontSize: 22)))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${language.name} · $_level', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)), Text('${language.nativeName} · ${lessons.length} lições neste nível', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant))])),
                const Icon(Icons.offline_bolt_rounded, color: AppConstants.gold),
              ]),
            ),
            const SizedBox(height: 18),
            ...lessons.asMap().entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _LessonCard(
                lesson: entry.value,
                index: entry.key + 1,
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => LessonScreen(lesson: entry.value))),
              ),
            )),
            const SizedBox(height: 5),
            Text('Inclui escolha múltipla, verdadeiro/falso, completar frases, correspondência e escuta com voz do dispositivo.', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.4)),
          ],
        ),
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({required this.lesson, required this.index, required this.onTap});
  final Lesson lesson;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: theme.dividerColor)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: AppConstants.navy.withValues(alpha: .08), borderRadius: BorderRadius.circular(14)), child: Center(child: Text('$index', style: const TextStyle(color: AppConstants.navy, fontWeight: FontWeight.w800, fontSize: 18)))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(lesson.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('${lesson.durationMinutes} min · ${lesson.questions.length} exercícios · avaliação', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ])),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ]),
        ),
      ),
    );
  }
}
