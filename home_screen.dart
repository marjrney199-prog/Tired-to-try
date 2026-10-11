import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../models/app_user.dart';
import '../providers/progress_provider.dart';
import '../widgets/section_title.dart';
import '../widgets/surface_card.dart';
import 'conversation_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.user, required this.onNavigate});

  final AppUser user;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Bom dia' : hour < 18 ? 'Boa tarde' : 'Boa noite';
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$greeting, ${user.name.split(' ').first}', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 5),
            Text('Um pequeno passo por dia faz a diferença.', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 22),
            _HeroCard(onLearn: () => onNavigate(1), onTranslate: () => onNavigate(2)),
            const SizedBox(height: 22),
            Consumer<ProgressProvider>(
              builder: (context, progress, _) => LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth > 720 ? 4 : 2;
                  final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(width: width, child: _StatCard(icon: Icons.bolt_rounded, label: 'XP', value: '${progress.totalXp}', tint: AppConstants.gold)),
                      SizedBox(width: width, child: _StatCard(icon: Icons.check_circle_outline_rounded, label: 'Lições', value: '${progress.completedLessons}', tint: const Color(0xFF37A377))),
                      SizedBox(width: width, child: _StatCard(icon: Icons.local_fire_department_outlined, label: 'Sequência', value: '${progress.streak} dia(s)', tint: const Color(0xFFE57C38))),
                      SizedBox(width: width, child: _StatCard(icon: Icons.emoji_events_outlined, label: 'Ranking local', value: progress.rank == 0 ? '—' : '#${progress.rank}', tint: const Color(0xFF4C78B8))),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Consumer<ProgressProvider>(
              builder: (context, progress, _) => SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.flag_outlined, color: AppConstants.gold),
                        const SizedBox(width: 10),
                        Expanded(child: Text('Meta de hoje', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
                        Text(progress.completedToday > 0 ? 'Concluída' : '1 lição', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(value: progress.dailyGoalProgress, minHeight: 9, color: AppConstants.gold, backgroundColor: theme.dividerColor.withValues(alpha: .45)),
                    ),
                    const SizedBox(height: 8),
                    Text('${progress.completedToday} de 1 lição concluída hoje', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 26),
            SectionTitle('Explorar', subtitle: 'Continue a aprender ao seu ritmo.'),
            const SizedBox(height: 12),
            LayoutBuilder(builder: (context, constraints) {
              final columns = constraints.maxWidth > 720 ? 3 : 1;
              final width = columns == 1 ? constraints.maxWidth : (constraints.maxWidth - 24) / 3;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(width: width, child: _ActionCard(icon: Icons.school_rounded, title: 'Aprender', subtitle: '9 idiomas · níveis A1–C2', color: AppConstants.navy, onTap: () => onNavigate(1))),
                  SizedBox(width: width, child: _ActionCard(icon: Icons.translate_rounded, title: 'Tradutor offline', subtitle: 'Texto, voz, imagem e ficheiros', color: const Color(0xFF367A9A), onTap: () => onNavigate(2))),
                  SizedBox(width: width, child: _ActionCard(icon: Icons.menu_book_rounded, title: 'Dicionário', subtitle: 'Pesquisa rápida e favoritos', color: const Color(0xFF896B20), onTap: () => onNavigate(3))),
                ],
              );
            }),
            const SizedBox(height: 24),
            SectionTitle('Pratique a conversação', subtitle: 'Diálogos pré-programados, sem IA.', action: TextButton(onPressed: () => _openConversations(context), child: const Text('Ver cenários'))),
            const SizedBox(height: 10),
            SizedBox(
              height: 104,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: ConversationScreen.scenarios.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final scenario = ConversationScreen.scenarios[index];
                  return SizedBox(
                    width: 170,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _openConversations(context, scenarioIndex: index),
                      child: SurfaceCard(
                        padding: const EdgeInsets.all(14),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Icon(scenario.icon, color: AppConstants.gold),
                          const Spacer(),
                          Text(scenario.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                        ]),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            Text('Disponível offline · progresso guardado localmente', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  void _openConversations(BuildContext context, {int? scenarioIndex}) => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => ConversationScreen(initialScenarioIndex: scenarioIndex)),
      );
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onLearn, required this.onTranslate});
  final VoidCallback onLearn;
  final VoidCallback onTranslate;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(colors: [AppConstants.navy, Color(0xFF173E6B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: LayoutBuilder(builder: (context, constraints) {
          final stacked = constraints.maxWidth < 540;
          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: .12), borderRadius: BorderRadius.circular(20)),
                child: const Text('A SUA ESCOLA DE IDIOMAS OFFLINE', style: TextStyle(color: Colors.white, fontSize: 10, letterSpacing: .9, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 14),
              Text('Aprenda no seu ritmo.', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
              const SizedBox(height: 7),
              Text('Lições curtas, exercícios interactivos e ferramentas linguísticas no mesmo lugar.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: .85), height: 1.45)),
              const SizedBox(height: 18),
              Wrap(spacing: 10, runSpacing: 8, children: [
                FilledButton.icon(onPressed: onLearn, icon: const Icon(Icons.play_arrow_rounded), label: const Text('Começar a aprender'), style: FilledButton.styleFrom(backgroundColor: AppConstants.gold, foregroundColor: AppConstants.navy)),
                OutlinedButton.icon(onPressed: onTranslate, icon: const Icon(Icons.translate_rounded), label: const Text('Abrir tradutor'), style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: BorderSide(color: Colors.white.withValues(alpha: .6)))),
              ]),
            ],
          );
          if (stacked) return content;
          return Row(children: [Expanded(child: content), const SizedBox(width: 14), const Icon(Icons.public_rounded, color: Color(0x66FFFFFF), size: 100)]);
        }),
      );
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.label, required this.value, required this.tint});
  final IconData icon;
  final String label;
  final String value;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SurfaceCard(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: tint),
        const SizedBox(height: 12),
        Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ]),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: Theme.of(context).dividerColor)),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(17),
            child: Row(children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color)),
              const SizedBox(width: 13),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant))])),
              const Icon(Icons.arrow_forward_ios_rounded, size: 15),
            ]),
          ),
        ),
      );
}
