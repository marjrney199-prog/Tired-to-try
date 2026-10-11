import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/constants/app_constants.dart';
import '../core/database/app_database.dart';
import '../core/storage/local_storage.dart';
import '../data/seed_data.dart';
import '../models/app_user.dart';
import '../providers/auth_provider.dart';
import '../widgets/section_title.dart';
import '../widgets/surface_card.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _tab = 0;
  bool _loading = true;
  List<Map<String, dynamic>> _users = const [];
  List<String> _enabledLanguages = const [];
  int _historyCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final database = context.read<AppDatabase>();
      final users = await database.allUsers();
      final historyCount = await database.historyCount();
      if (!mounted) return;
      setState(() {
        _users = users;
        _historyCount = historyCount;
        _enabledLanguages = LocalStorage.enabledLanguageCodes;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível carregar as estatísticas locais: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Painel administrativo local')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1040),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppConstants.gold.withValues(alpha: .14), borderRadius: BorderRadius.circular(14)),
                child: Text('Este painel administra apenas os dados locais deste dispositivo; não existe servidor de utilizadores nem sincronização central.', style: theme.textTheme.bodySmall?.copyWith(height: 1.4)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text('Resumo'), icon: Icon(Icons.insights_outlined)),
                  ButtonSegment(value: 1, label: Text('Utilizadores'), icon: Icon(Icons.people_outline_rounded)),
                  ButtonSegment(value: 2, label: Text('Conteúdo'), icon: Icon(Icons.library_books_outlined)),
                ],
                selected: {_tab},
                onSelectionChanged: (selection) => setState(() => _tab = selection.first),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(child: _loading ? const Center(child: CircularProgressIndicator()) : _buildTab(context)),
          ]),
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context) => switch (_tab) {
        0 => _summaryView(context),
        1 => _usersView(context),
        _ => _contentView(context),
      };

  Widget _summaryView(BuildContext context) {
    final theme = Theme.of(context);
    final customCount = LocalStorage.customLessons.length;
    final totalLessons = SeedData.languages.length * SeedData.levels.length * 3 + customCount;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SectionTitle('Visão geral', subtitle: 'Estatísticas agregadas apenas para esta instalação.'),
        const SizedBox(height: 14),
        LayoutBuilder(builder: (context, constraints) {
          final columns = constraints.maxWidth > 680 ? 4 : 2;
          final width = (constraints.maxWidth - (columns - 1) * 10) / columns;
          return Wrap(spacing: 10, runSpacing: 10, children: [
            SizedBox(width: width, child: _AdminStat('Utilizadores', '${_users.length}', Icons.people_outline_rounded)),
            SizedBox(width: width, child: _AdminStat('Idiomas activos', '${_enabledLanguages.length}', Icons.language_rounded)),
            SizedBox(width: width, child: _AdminStat('Lições locais', '$totalLessons', Icons.menu_book_outlined)),
            SizedBox(width: width, child: _AdminStat('Traduções', '$_historyCount', Icons.translate_rounded)),
          ]);
        }),
        const SizedBox(height: 20),
        SectionTitle('Conteúdo preparado', subtitle: '${SeedData.languages.length} idiomas × ${SeedData.levels.length} níveis × 3 lições + lições locais.'),
        const SizedBox(height: 10),
        SurfaceCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${SeedData.languages.length * SeedData.levels.length} combinações de idioma e nível', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('Cada lição de demonstração contém exercícios, teste, avaliação de pontuação e gravação local de progresso. O conteúdo de tradução é um vocabulário inicial, não um tradutor automático geral.', style: theme.textTheme.bodySmall?.copyWith(height: 1.45, color: theme.colorScheme.onSurfaceVariant)),
        ])),
        const SizedBox(height: 20),
        FilledButton.tonalIcon(onPressed: _shareReport, icon: const Icon(Icons.ios_share_rounded), label: const Text('Partilhar relatório local em JSON')),
      ],
    );
  }

  Widget _usersView(BuildContext context) => RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SectionTitle('Gestão de utilizadores', subtitle: 'Contas locais registadas neste dispositivo.'),
            const SizedBox(height: 12),
            if (_users.isEmpty) const SurfaceCard(child: Text('Ainda não existem utilizadores locais.')),
            ..._users.map((row) {
              final active = (row['is_active'] ?? 1) == 1 || row['is_active'] == true;
              final id = row['id']?.toString() ?? '';
              final currentId = context.read<AuthProvider>().currentUser?.id;
              final isCurrent = id == currentId;
              final user = AppUser.fromMap(row);
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Theme.of(context).dividerColor)),
                child: SwitchListTile(
                  secondary: CircleAvatar(backgroundColor: AppConstants.navy.withValues(alpha: .1), child: Text(user.name.isEmpty ? '?' : user.name[0].toUpperCase(), style: const TextStyle(color: AppConstants.navy, fontWeight: FontWeight.w700))),
                  title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(user.isGuest ? 'Perfil offline' : user.email),
                  value: active,
                  onChanged: isCurrent ? null : (value) => _setUserActive(id, value),
                ),
              );
            }),
            const SizedBox(height: 6),
            Text('Não é possível desactivar a conta actualmente em utilização. O controlo não constitui segurança de servidor.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      );

  Widget _contentView(BuildContext context) {
    final theme = Theme.of(context);
    final customLessons = LocalStorage.customLessons;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SectionTitle('Gestão de idiomas', subtitle: 'Activar ou ocultar idiomas no catálogo de aprendizagem.'),
        const SizedBox(height: 10),
        SurfaceCard(child: Column(children: SeedData.languages.map((language) => SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: Text(language.flag, style: const TextStyle(fontSize: 20)),
          title: Text(language.name),
          subtitle: Text(language.nativeName),
          value: _enabledLanguages.contains(language.code),
          onChanged: (value) => _toggleLanguage(language.code, value),
        )).toList())),
        const SizedBox(height: 18),
        SectionTitle('Gestão de lições', subtitle: '${SeedData.languages.length * SeedData.levels.length * 3} lições de catálogo · ${customLessons.length} lição(ões) adicional(is).', action: FilledButton.tonalIcon(onPressed: _addLesson, icon: const Icon(Icons.add_rounded), label: const Text('Nova lição'))),
        const SizedBox(height: 10),
        if (customLessons.isEmpty) SurfaceCard(child: Text('As lições base são fornecidas offline. Pode acrescentar lições locais de vocabulário.', style: theme.textTheme.bodyMedium)),
        ...customLessons.map((lesson) {
          final language = SeedData.language(lesson['language_code']?.toString() ?? 'en');
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.edit_note_rounded, color: AppConstants.gold),
              title: Text(lesson['title']?.toString() ?? 'Lição personalizada'),
              subtitle: Text('${language.name} · ${lesson['level']} · ${lesson['prompt'] ?? ''} → ${lesson['answer'] ?? ''}'),
            ),
          );
        }),
      ],
    );
  }

  Future<void> _setUserActive(String id, bool active) async {
    await context.read<AppDatabase>().setUserActive(id, active);
    await _load();
  }

  Future<void> _toggleLanguage(String code, bool enabled) async {
    final next = [..._enabledLanguages];
    if (enabled && !next.contains(code)) next.add(code);
    if (!enabled) next.remove(code);
    if (next.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mantenha pelo menos um idioma activo.')));
      return;
    }
    await LocalStorage.setEnabledLanguageCodes(next);
    if (mounted) setState(() => _enabledLanguages = next);
  }

  Future<void> _addLesson() async {
    final title = TextEditingController();
    final prompt = TextEditingController();
    final answer = TextEditingController();
    final description = TextEditingController();
    String languageCode = _enabledLanguages.isEmpty ? 'en' : _enabledLanguages.first;
    String level = 'A1';
    final lesson = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(builder: (context, setDialogState) => AlertDialog(
        title: const Text('Nova lição local'),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: title, decoration: const InputDecoration(labelText: 'Título')),
            const SizedBox(height: 9),
            DropdownButtonFormField<String>(value: languageCode, decoration: const InputDecoration(labelText: 'Idioma'), items: SeedData.languages.map((item) => DropdownMenuItem(value: item.code, child: Text(item.name))).toList(), onChanged: (value) => setDialogState(() => languageCode = value ?? languageCode)),
            const SizedBox(height: 9),
            DropdownButtonFormField<String>(value: level, decoration: const InputDecoration(labelText: 'Nível'), items: SeedData.levels.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(), onChanged: (value) => setDialogState(() => level = value ?? level)),
            const SizedBox(height: 9),
            TextField(controller: prompt, decoration: const InputDecoration(labelText: 'Palavra / frase de origem')),
            const SizedBox(height: 9),
            TextField(controller: answer, decoration: const InputDecoration(labelText: 'Resposta correcta')),
            const SizedBox(height: 9),
            TextField(controller: description, maxLines: 2, decoration: const InputDecoration(labelText: 'Nota / descrição (opcional)')),
          ])),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
          FilledButton(onPressed: () {
            if (title.text.trim().isEmpty || prompt.text.trim().isEmpty || answer.text.trim().isEmpty) return;
            Navigator.pop(dialogContext, {
              'id': 'custom_${DateTime.now().microsecondsSinceEpoch}',
              'title': title.text.trim(),
              'language_code': languageCode,
              'level': level,
              'prompt': prompt.text.trim(),
              'answer': answer.text.trim(),
              'description': description.text.trim(),
            });
          }, child: const Text('Guardar')),
        ],
      )),
    );
    title.dispose();
    prompt.dispose();
    answer.dispose();
    description.dispose();
    if (lesson == null) return;
    await LocalStorage.saveCustomLesson(lesson);
    if (mounted) setState(() {});
  }

  Future<void> _shareReport() async {
    final report = {
      'product': 'EA LANGUAGE HUB',
      'generated_at': DateTime.now().toIso8601String(),
      'local_only': true,
      'users': _users.length,
      'active_languages': _enabledLanguages,
      'seed_lessons': SeedData.languages.length * SeedData.levels.length * 3,
      'custom_lessons': LocalStorage.customLessons.length,
      'translation_records': _historyCount,
    };
    await Share.share(const JsonEncoder.withIndent('  ').convert(report), subject: 'Relatório local EA LANGUAGE HUB');
  }
}

class _AdminStat extends StatelessWidget {
  const _AdminStat(this.title, this.value, this.icon);
  final String title;
  final String value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => SurfaceCard(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: AppConstants.gold), const SizedBox(height: 10), Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)), Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant))]));
}
