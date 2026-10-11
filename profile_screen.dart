import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/constants/app_constants.dart';
import '../core/database/app_database.dart';
import '../core/storage/local_storage.dart';
import '../data/seed_data.dart';
import '../models/app_user.dart';
import '../providers/auth_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/settings_provider.dart';
import '../services/certificate_service.dart';
import '../widgets/section_title.dart';
import '../widgets/surface_card.dart';
import 'admin_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.user});
  final AppUser user;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _picker = ImagePicker();
  final _certificateService = CertificateService();
  String? _avatarData;
  List<Map<String, dynamic>> _certificates = const [];
  List<Map<String, dynamic>> _history = const [];
  List<Map<String, dynamic>> _progressRows = const [];
  bool _loading = true;
  String _certificateLanguage = 'en';
  String _certificateLevel = 'A1';

  @override
  void initState() {
    super.initState();
    _avatarData = LocalStorage.avatarFor(widget.user.id);
    _loadLocalData();
  }

  Future<void> _loadLocalData() async {
    try {
      final database = context.read<AppDatabase>();
      final certs = await database.certificatesForUser(widget.user.id);
      final history = await database.historyForUser(widget.user.id);
      final progress = await database.progressForUser(widget.user.id);
      if (!mounted) return;
      setState(() {
        _certificates = certs;
        _history = history;
        _progressRows = progress;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível carregar alguns dados locais: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.watch<SettingsProvider>().themeMode == ThemeMode.dark;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('Perfil', subtitle: 'A sua conta e actividade ficam guardadas neste dispositivo.'),
          const SizedBox(height: 16),
          SurfaceCard(
            padding: const EdgeInsets.all(18),
            child: Row(children: [
              Stack(children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: AppConstants.navy.withValues(alpha: .12),
                  foregroundImage: _avatarData == null ? null : MemoryImage(base64Decode(_avatarData!)),
                  child: _avatarData == null ? Text(_initials(widget.user.name), style: const TextStyle(color: AppConstants.navy, fontWeight: FontWeight.w800, fontSize: 20)) : null,
                ),
                Positioned(right: -4, bottom: -5, child: IconButton.filledTonal(tooltip: 'Alterar fotografia', onPressed: _pickAvatar, icon: const Icon(Icons.camera_alt_outlined, size: 17), visualDensity: VisualDensity.compact)),
              ]),
              const SizedBox(width: 17),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.user.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(widget.user.isGuest ? 'Perfil offline neste dispositivo' : widget.user.email, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 7),
                Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4), decoration: BoxDecoration(color: AppConstants.gold.withValues(alpha: .15), borderRadius: BorderRadius.circular(20)), child: Text(widget.user.isGuest ? 'OFFLINE' : 'CONTA LOCAL', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800, color: AppConstants.navy))),
              ])),
            ]),
          ),
          const SizedBox(height: 14),
          Consumer<ProgressProvider>(builder: (context, progress, _) => LayoutBuilder(builder: (context, constraints) {
            final columns = constraints.maxWidth > 700 ? 4 : 2;
            final width = (constraints.maxWidth - (columns - 1) * 10) / columns;
            return Wrap(spacing: 10, runSpacing: 10, children: [
              SizedBox(width: width, child: _MiniStat(label: 'XP total', value: '${progress.totalXp}', icon: Icons.bolt_rounded, color: AppConstants.gold)),
              SizedBox(width: width, child: _MiniStat(label: 'Lições', value: '${progress.completedLessons}', icon: Icons.check_circle_outline_rounded, color: const Color(0xFF37A377))),
              SizedBox(width: width, child: _MiniStat(label: 'Sequência', value: '${progress.streak} dia(s)', icon: Icons.local_fire_department_outlined, color: const Color(0xFFE57C38))),
              SizedBox(width: width, child: _MiniStat(label: 'Ranking local', value: progress.rank == 0 ? '—' : '#${progress.rank}', icon: Icons.leaderboard_outlined, color: const Color(0xFF4C78B8))),
            ]);
          })),
          const SizedBox(height: 20),
          SectionTitle('Medalhas', subtitle: 'Conquistas por experiência acumulada.'),
          const SizedBox(height: 10),
          Consumer<ProgressProvider>(builder: (context, progress, _) => SurfaceCard(
            child: Wrap(spacing: 10, runSpacing: 10, children: [
              _MedalChip(name: 'Bronze', threshold: 50, xp: progress.totalXp, color: const Color(0xFFB77946)),
              _MedalChip(name: 'Prata', threshold: 200, xp: progress.totalXp, color: const Color(0xFF8A99A8)),
              _MedalChip(name: 'Ouro', threshold: 500, xp: progress.totalXp, color: AppConstants.gold),
              _MedalChip(name: 'Diamante', threshold: 1000, xp: progress.totalXp, color: const Color(0xFF49A8CB)),
            ]),
          )),
          const SizedBox(height: 20),
          SectionTitle('Idiomas estudados', subtitle: 'Cursos com progresso registado.'),
          const SizedBox(height: 10),
          SurfaceCard(child: _progressRows.isEmpty
              ? const Text('Ainda não iniciou uma lição. Escolha um idioma na área Aprender.')
              : Wrap(spacing: 8, runSpacing: 8, children: _progressRows.map((row) {
                  final language = SeedData.language(row['language']?.toString() ?? 'en');
                  return Chip(avatar: Text(language.flag), label: Text('${language.name} · ${row['level']}'));
                }).toList())),
          const SizedBox(height: 20),
          SectionTitle('Certificados', subtitle: 'Emitidos localmente em PDF.'),
          const SizedBox(height: 10),
          SurfaceCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('Certificado de nível', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              LayoutBuilder(builder: (context, constraints) {
                final narrow = constraints.maxWidth < 480;
                final language = DropdownButtonFormField<String>(
                  value: _certificateLanguage,
                  decoration: const InputDecoration(labelText: 'Idioma', isDense: true),
                  items: SeedData.languages.map((item) => DropdownMenuItem(value: item.code, child: Text('${item.flag} ${item.name}'))).toList(),
                  onChanged: (value) => setState(() => _certificateLanguage = value ?? _certificateLanguage),
                );
                final level = DropdownButtonFormField<String>(
                  value: _certificateLevel,
                  decoration: const InputDecoration(labelText: 'Nível', isDense: true),
                  items: SeedData.levels.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                  onChanged: (value) => setState(() => _certificateLevel = value ?? _certificateLevel),
                );
                return narrow ? Column(children: [language, const SizedBox(height: 10), level]) : Row(children: [Expanded(child: language), const SizedBox(width: 10), Expanded(child: level)]);
              }),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(onPressed: _issueCertificate, icon: const Icon(Icons.picture_as_pdf_outlined), label: const Text('Gerar certificado PDF')),
              const SizedBox(height: 5),
              Text('Disponível após concluir pelo menos 2 lições do nível com média mínima de 70%.', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              if (_certificates.isNotEmpty) ...[
                const Divider(height: 24),
                ..._certificates.take(5).map((certificate) {
                  final date = DateTime.tryParse(certificate['issued_at']?.toString() ?? '');
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.verified_outlined, color: AppConstants.gold),
                    title: Text('${SeedData.language(certificate['language']?.toString() ?? 'en').name} · ${certificate['level']}'),
                    subtitle: Text('Pontuação ${certificate['score']}%${date == null ? '' : ' · ${DateFormat('dd/MM/yyyy').format(date)}'}'),
                    dense: true,
                  );
                }),
              ],
            ]),
          ),
          const SizedBox(height: 20),
          SectionTitle('Actividade recente', subtitle: 'Histórico de traduções neste dispositivo.'),
          const SizedBox(height: 10),
          SurfaceCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: _loading
                ? const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()))
                : _history.isEmpty
                    ? const ListTile(leading: Icon(Icons.history_rounded), title: Text('Sem actividade recente'))
                    : Column(children: _history.take(3).map((row) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.translate_rounded, color: AppConstants.gold),
                        title: Text(row['input_text']?.toString() ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(row['output_text']?.toString() ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                        dense: true,
                      )).toList()),
          ),
          const SizedBox(height: 20),
          SectionTitle('Definições e dados', subtitle: 'Ferramentas de privacidade e manutenção local.'),
          const SizedBox(height: 10),
          SurfaceCard(
            padding: EdgeInsets.zero,
            child: Column(children: [
              SwitchListTile(
                secondary: Icon(isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined),
                title: const Text('Modo escuro'),
                subtitle: const Text('Aplicar tema escuro ao dispositivo.'),
                value: isDark,
                onChanged: (value) => context.read<SettingsProvider>().setDarkMode(value),
              ),
              const Divider(height: 1),
              ListTile(leading: const Icon(Icons.admin_panel_settings_outlined), title: const Text('Painel administrativo local'), trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AdminScreen()))),
              ListTile(leading: const Icon(Icons.backup_outlined), title: const Text('Exportar cópia de segurança'), subtitle: const Text('JSON sem hashes de autenticação.'), onTap: _exportBackup),
              ListTile(leading: const Icon(Icons.logout_rounded), title: const Text('Terminar sessão'), onTap: _confirmLogout),
            ]),
          ),
          const SizedBox(height: 12),
          Text('Dados e contas são locais a este dispositivo. O painel administrativo não é um serviço de gestão central.', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.4)),
        ]),
      ),
    );
  }

  Future<void> _pickAvatar() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 82, maxWidth: 700);
      if (image == null) return;
      final bytes = await image.readAsBytes();
      if (bytes.length > 2 * 1024 * 1024) throw StateError('A imagem é demasiado grande (limite local: 2 MB).');
      final encoded = base64Encode(bytes);
      await LocalStorage.setAvatar(widget.user.id, encoded);
      if (mounted) setState(() => _avatarData = encoded);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível guardar a fotografia: $error')));
    }
  }

  Future<void> _issueCertificate() async {
    final stats = await context.read<ProgressProvider>().levelStats(widget.user.id, _certificateLanguage, _certificateLevel);
    final count = (stats['count'] as num?)?.toInt() ?? 0;
    final average = (stats['average'] as num?)?.toInt() ?? 0;
    if (count < 2 || average < 70) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ainda não elegível: $count/2 lições e média de $average% (mínimo 70%).')));
      return;
    }
    try {
      final issuedAt = DateTime.now();
      final bytes = await _certificateService.build(
        userName: widget.user.name,
        language: SeedData.language(_certificateLanguage).name,
        level: _certificateLevel,
        score: average,
        issuedAt: issuedAt,
      );
      final id = issuedAt.microsecondsSinceEpoch.toString();
      await context.read<AppDatabase>().saveCertificate({
        'id': id,
        'user_id': widget.user.id,
        'language': _certificateLanguage,
        'level': _certificateLevel,
        'score': average,
        'issued_at': issuedAt.toIso8601String(),
      });
      if (!mounted) return;
      setState(() => _certificates = [
        {'id': id, 'user_id': widget.user.id, 'language': _certificateLanguage, 'level': _certificateLevel, 'score': average, 'issued_at': issuedAt.toIso8601String()},
        ..._certificates,
      ]);
      await Printing.layoutPdf(onLayout: (_) async => bytes, name: 'EA_LANGUAGE_HUB_${_certificateLanguage}_$_certificateLevel.pdf');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível gerar o certificado: $error')));
    }
  }

  Future<void> _exportBackup() async {
    try {
      final data = await context.read<AppDatabase>().exportBackup(widget.user.id);
      await Share.share(const JsonEncoder.withIndent('  ').convert(data), subject: 'Cópia de segurança EA LANGUAGE HUB');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Falha ao exportar: $error')));
    }
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terminar sessão?'),
        content: const Text('O seu progresso local será mantido neste dispositivo.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Terminar sessão'))],
      ),
    );
    if (shouldLogout == true && mounted) await context.read<AuthProvider>().logout();
  }

  String _initials(String value) => value.trim().split(RegExp(r'\s+')).take(2).map((part) => part.isEmpty ? '' : part[0].toUpperCase()).join();
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value, required this.icon, required this.color});
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => SurfaceCard(padding: const EdgeInsets.all(13), child: Row(children: [Icon(icon, color: color), const SizedBox(width: 9), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)), Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant))]))]));
}

class _MedalChip extends StatelessWidget {
  const _MedalChip({required this.name, required this.threshold, required this.xp, required this.color});
  final String name;
  final int threshold;
  final int xp;
  final Color color;
  @override
  Widget build(BuildContext context) {
    final unlocked = xp >= threshold;
    return Chip(
      avatar: Icon(Icons.workspace_premium_rounded, size: 19, color: unlocked ? color : Theme.of(context).disabledColor),
      label: Text('$name · $threshold XP'),
      backgroundColor: unlocked ? color.withValues(alpha: .12) : null,
      side: BorderSide(color: unlocked ? color.withValues(alpha: .6) : Theme.of(context).dividerColor),
    );
  }
}
