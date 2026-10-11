import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../core/database/app_database.dart';
import '../data/seed_data.dart';
import '../models/lexeme.dart';
import '../providers/auth_provider.dart';
import '../widgets/section_title.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final _search = TextEditingController();
  String _sourceCode = 'en';
  String _targetCode = 'pt';
  bool _favoritesOnly = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sourceLanguage = SeedData.language(_sourceCode);
    final targetLanguage = SeedData.language(_targetCode);
    final query = _search.text.trim().toLowerCase();
    final results = SeedData.lexemes.where((entry) {
      final word = entry.formFor(_sourceCode).toLowerCase();
      final translation = entry.formFor(_targetCode).toLowerCase();
      return query.isEmpty || word.contains(query) || translation.contains(query);
    }).toList();

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SectionTitle('Dicionário', subtitle: 'Pesquise no vocabulário incluído e guarde os seus favoritos.'),
              const SizedBox(height: 16),
              TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Pesquisar palavra ou tradução…',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _search.text.isEmpty ? null : IconButton(onPressed: () { _search.clear(); setState(() {}); }, icon: const Icon(Icons.close_rounded)),
                ),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(builder: (context, constraints) {
                final compact = constraints.maxWidth < 480;
                final fields = [
                  _languageDropdown(label: 'De', value: _sourceCode, onChanged: (value) => setState(() => _sourceCode = value ?? _sourceCode)),
                  IconButton(onPressed: () => setState(() { final old = _sourceCode; _sourceCode = _targetCode; _targetCode = old; }), icon: const Icon(Icons.swap_horiz_rounded), tooltip: 'Trocar idiomas'),
                  _languageDropdown(label: 'Para', value: _targetCode, onChanged: (value) => setState(() => _targetCode = value ?? _targetCode)),
                ];
                return compact
                    ? Row(children: [Expanded(child: fields[0]), fields[1], Expanded(child: fields[2])])
                    : Row(children: [Expanded(child: fields[0]), fields[1], Expanded(child: fields[2]), const SizedBox(width: 10), FilterChip(label: const Text('Favoritos'), selected: _favoritesOnly, avatar: const Icon(Icons.favorite_rounded, size: 17), onSelected: (value) => setState(() => _favoritesOnly = value))]);
              }),
              if (MediaQuery.sizeOf(context).width < 480)
                Align(alignment: Alignment.centerRight, child: FilterChip(label: const Text('Favoritos'), selected: _favoritesOnly, avatar: const Icon(Icons.favorite_rounded, size: 17), onSelected: (value) => setState(() => _favoritesOnly = value))),
              const SizedBox(height: 3),
              Text('${results.length} termos · ${sourceLanguage.name} → ${targetLanguage.name}', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ]),
          ),
          Expanded(
            child: results.isEmpty
                ? Center(child: Text(query.isEmpty ? 'Ainda não existem termos guardados.' : 'Nenhuma palavra encontrada.', style: theme.textTheme.bodyLarge))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: results.length,
                    itemBuilder: (context, index) => _DictionaryEntryCard(
                      key: ValueKey('${results[index].id}_$_sourceCode-$_targetCode'),
                      entry: results[index],
                      sourceCode: _sourceCode,
                      targetCode: _targetCode,
                      favoritesOnly: _favoritesOnly,
                      onFavoriteChanged: () => setState(() {}),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _languageDropdown({required String label, required String value, required ValueChanged<String?> onChanged}) => DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label, isDense: true),
        items: SeedData.languages.map((language) => DropdownMenuItem(value: language.code, child: Text('${language.flag} ${language.name}'))).toList(),
        onChanged: onChanged,
      );
}

class _DictionaryEntryCard extends StatelessWidget {
  const _DictionaryEntryCard({super.key, required this.entry, required this.sourceCode, required this.targetCode, required this.favoritesOnly, required this.onFavoriteChanged});
  final Lexeme entry;
  final String sourceCode;
  final String targetCode;
  final bool favoritesOnly;
  final VoidCallback onFavoriteChanged;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final database = context.read<AppDatabase>();
    if (user == null) return const SizedBox.shrink();
    return FutureBuilder<bool>(
      future: database.isWordFavorite(user.id, sourceCode, entry.formFor(sourceCode)),
      builder: (context, snapshot) {
        final favorite = snapshot.data ?? false;
        if (favoritesOnly && snapshot.connectionState == ConnectionState.done && !favorite) return const SizedBox.shrink();
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Theme.of(context).dividerColor)),
          child: ExpansionTile(
            leading: Container(width: 38, height: 38, decoration: BoxDecoration(color: AppConstants.gold.withValues(alpha: .16), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.translate_rounded, color: AppConstants.navy, size: 20)),
            title: Text(entry.formFor(sourceCode), style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text(entry.formFor(targetCode), style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            trailing: IconButton(
              tooltip: favorite ? 'Remover dos favoritos' : 'Adicionar aos favoritos',
              onPressed: () async {
                await database.setWordFavorite(user.id, sourceCode, entry.formFor(sourceCode), !favorite);
                onFavoriteChanged();
              },
              icon: Icon(favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: favorite ? Colors.redAccent : null),
            ),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              const Divider(height: 1),
              const SizedBox(height: 12),
              _DetailLine(label: 'Pronúncia', value: entry.pronunciationFor(sourceCode)),
              _DetailLine(label: 'Classe gramatical', value: entry.partOfSpeech),
              _DetailLine(label: 'Definição', value: entry.definition),
              _DetailLine(label: 'Sinónimos', value: entry.synonyms.isEmpty ? '—' : entry.synonyms.join(', ')),
              _DetailLine(label: 'Antónimos', value: entry.antonyms.isEmpty ? '—' : entry.antonyms.join(', ')),
              _DetailLine(label: 'Exemplo', value: entry.example),
            ],
          ),
        );
      },
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 9),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 132, child: Text('$label:', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700))),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.35))),
        ]),
      );
}
