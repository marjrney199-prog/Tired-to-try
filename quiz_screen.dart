import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../data/seed_data.dart';
import '../models/lesson.dart';
import '../providers/auth_provider.dart';
import '../providers/progress_provider.dart';
import '../services/tts_service.dart';
import '../widgets/surface_card.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.lesson});
  final Lesson lesson;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _answerController = TextEditingController();
  int _index = 0;
  int _correctAnswers = 0;
  String _selected = '';
  bool _submitted = false;
  bool _wasCorrect = false;
  bool _finished = false;
  bool _saving = false;

  ExerciseQuestion get _question => widget.lesson.questions[_index];
  int get _score => (_correctAnswers * 100 / widget.lesson.questions.length).round();

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lesson = widget.lesson;
    return Scaffold(
      appBar: AppBar(title: Text('Exercício · ${lesson.level}'), actions: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17), child: Text('${_index + 1}/${lesson.questions.length}', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700))),
      ]),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _finished ? _resultView(context) : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LinearProgressIndicator(value: (_index + (_submitted ? 1 : 0)) / lesson.questions.length, minHeight: 7, borderRadius: BorderRadius.circular(10), color: AppConstants.gold),
                const SizedBox(height: 20),
                Text('${lesson.languageName} · ${lesson.title}', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 10),
                SurfaceCard(
                  padding: const EdgeInsets.all(22),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text(_question.prompt, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, height: 1.35))),
                      if (_question.kind == ExerciseKind.listening)
                        IconButton.filledTonal(
                          tooltip: 'Ouvir expressão',
                          onPressed: () => _speak(context),
                          icon: const Icon(Icons.volume_up_rounded),
                        ),
                    ]),
                    const SizedBox(height: 18),
                    _answerArea(context),
                    if (_submitted) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (_wasCorrect ? const Color(0xFF2E8B57) : const Color(0xFFB95050)).withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(children: [
                          Icon(_wasCorrect ? Icons.check_circle_outline : Icons.info_outline, color: _wasCorrect ? const Color(0xFF2E8B57) : const Color(0xFFB95050)),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_wasCorrect ? 'Correcto! Muito bem.' : 'Resposta: ${_question.answer}', style: const TextStyle(fontWeight: FontWeight.w600))),
                        ]),
                      ),
                    ],
                  ]),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _saving ? null : _submitOrContinue,
                  style: FilledButton.styleFrom(backgroundColor: AppConstants.navy, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(54)),
                  child: _saving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(_submitted ? (_index == lesson.questions.length - 1 ? 'Ver resultado' : 'Continuar') : 'Verificar resposta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _answerArea(BuildContext context) {
    switch (_question.kind) {
      case ExerciseKind.fillBlank:
        return TextField(
          controller: _answerController,
          enabled: !_submitted,
          textInputAction: TextInputAction.done,
          onChanged: (value) => _selected = value,
          onSubmitted: (_) => _submitOrContinue(),
          decoration: const InputDecoration(labelText: 'A sua resposta', prefixIcon: Icon(Icons.edit_outlined)),
        );
      case ExerciseKind.matching:
        return DropdownButtonFormField<String>(
          value: _selected.isEmpty ? null : _selected,
          decoration: const InputDecoration(labelText: 'Escolha a correspondência'),
          items: _question.choices.map((choice) => DropdownMenuItem(value: choice, child: Text(choice))).toList(),
          onChanged: _submitted ? null : (value) => setState(() => _selected = value ?? ''),
        );
      case ExerciseKind.multipleChoice:
      case ExerciseKind.trueFalse:
      case ExerciseKind.listening:
        return Wrap(
          spacing: 9,
          runSpacing: 9,
          children: _question.choices.map((choice) => ChoiceChip(
            selected: _selected == choice,
            label: Text(choice),
            onSelected: _submitted ? null : (_) => setState(() => _selected = choice),
            selectedColor: AppConstants.gold.withValues(alpha: .27),
            side: BorderSide(color: _selected == choice ? AppConstants.gold : Theme.of(context).dividerColor),
            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          )).toList(),
        );
    }
  }

  Future<void> _speak(BuildContext context) async {
    try {
      final language = SeedData.language(widget.lesson.languageCode);
      await context.read<TtsService>().speak(_question.spokenText ?? _question.answer, language.ttsLocale, rate: .42);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('A voz não está disponível neste dispositivo.')));
    }
  }

  Future<void> _submitOrContinue() async {
    if (_submitted) {
      if (_index < widget.lesson.questions.length - 1) {
        setState(() {
          _index++;
          _selected = '';
          _answerController.clear();
          _submitted = false;
          _wasCorrect = false;
        });
      } else {
        await _finishQuiz();
      }
      return;
    }
    final answer = _question.kind == ExerciseKind.fillBlank ? _answerController.text : _selected;
    if (answer.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Escolha ou escreva uma resposta antes de continuar.')));
      return;
    }
    final correct = answer.trim().toLowerCase() == _question.answer.trim().toLowerCase();
    setState(() {
      _submitted = true;
      _wasCorrect = correct;
      if (correct) _correctAnswers++;
    });
  }

  Future<void> _finishQuiz() async {
    setState(() => _saving = true);
    try {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        await context.read<ProgressProvider>().completeLesson(
          userId: user.id,
          lessonId: widget.lesson.id,
          language: widget.lesson.languageCode,
          level: widget.lesson.level,
          score: _score,
        );
      }
      if (mounted) setState(() { _saving = false; _finished = true; });
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível guardar o progresso: $error')));
    }
  }

  Widget _resultView(BuildContext context) {
    final theme = Theme.of(context);
    final passed = _score >= 70;
    return Center(
      child: SingleChildScrollView(
        child: SurfaceCard(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(passed ? Icons.emoji_events_rounded : Icons.auto_awesome_outlined, size: 58, color: AppConstants.gold),
            const SizedBox(height: 12),
            Text(passed ? 'Lição concluída!' : 'Boa tentativa!', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Pontuação: $_score%', style: theme.textTheme.titleLarge?.copyWith(color: AppConstants.navy, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(passed ? 'O seu progresso e XP foram guardados neste dispositivo.' : 'Reveja as respostas e volte a praticar quando quiser.', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 20),
            FilledButton.icon(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_rounded), label: const Text('Voltar à lição'), style: FilledButton.styleFrom(backgroundColor: AppConstants.navy, foregroundColor: Colors.white)),
          ]),
        ),
      ),
    );
  }
}
