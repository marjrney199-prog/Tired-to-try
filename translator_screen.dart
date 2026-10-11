import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/constants/app_constants.dart';
import '../core/database/app_database.dart';
import '../data/seed_data.dart';
import '../models/app_language.dart';
import '../models/translation_result.dart';
import '../providers/auth_provider.dart';
import '../services/ocr_service.dart';
import '../services/speech_service.dart';
import '../services/translation_service.dart';
import '../services/tts_service.dart';
import '../widgets/section_title.dart';
import '../widgets/surface_card.dart';

enum _TranslatorMode { text, document, image, voice, history }

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  final _inputController = TextEditingController();
  final _imagePicker = ImagePicker();
  final _ocr = OcrService();
  String _sourceCode = 'en';
  String _targetCode = 'pt';
  _TranslatorMode _mode = _TranslatorMode.text;
  TranslationResult? _result;
  String? _historyId;
  String? _selectedFileName;
  String? _selectedImageName;
  bool _busy = false;
  bool _listening = false;
  bool _favorite = false;
  bool _ocrCompleted = false;
  double _ttsRate = 0.48;
  List<Map<String, dynamic>> _history = const [];

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SectionTitle('Tradutor', subtitle: 'Ferramentas locais para texto, documentos, imagem e voz.'),
              const SizedBox(height: 13),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: _TranslatorMode.values.map((mode) => Padding(
                  padding: const EdgeInsets.only(right: 7),
                  child: ChoiceChip(
                    avatar: Icon(_modeIcon(mode), size: 17),
                    label: Text(_modeLabel(mode)),
                    selected: _mode == mode,
                    onSelected: (_) {
                      setState(() => _mode = mode);
                      if (mode == _TranslatorMode.history) _loadHistory();
                    },
                    selectedColor: AppConstants.gold.withValues(alpha: .25),
                  ),
                )).toList()),
              ),
            ]),
          ),
          Expanded(child: _mode == _TranslatorMode.history ? _historyView(context) : _translationView(context)),
        ],
      ),
    );
  }

  Widget _translationView(BuildContext context) {
    final theme = Theme.of(context);
    final source = SeedData.language(_sourceCode);
    final target = SeedData.language(_targetCode);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 26),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        LayoutBuilder(builder: (context, constraints) {
          final narrow = constraints.maxWidth < 480;
          final sourceDrop = _languageDropdown('De', _sourceCode, (value) => setState(() { _sourceCode = value ?? _sourceCode; _result = null; }));
          final targetDrop = _languageDropdown('Para', _targetCode, (value) => setState(() { _targetCode = value ?? _targetCode; _result = null; }));
          return narrow
              ? Row(children: [Expanded(child: sourceDrop), IconButton(onPressed: _swapLanguages, tooltip: 'Trocar idiomas', icon: const Icon(Icons.swap_horiz_rounded)), Expanded(child: targetDrop)])
              : Row(children: [Expanded(child: sourceDrop), IconButton(onPressed: _swapLanguages, tooltip: 'Trocar idiomas', icon: const Icon(Icons.swap_horiz_rounded)), Expanded(child: targetDrop)]);
        }),
        const SizedBox(height: 12),
        if (_mode == _TranslatorMode.document) _documentPicker(context),
        if (_mode == _TranslatorMode.image) _imagePickerCard(context),
        if (_mode == _TranslatorMode.voice) _voiceCard(context, source.ttsLocale),
        SurfaceCard(
          padding: const EdgeInsets.all(15),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(_mode == _TranslatorMode.voice ? 'Transcrição / texto' : 'Texto de origem', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700))),
              if (_inputController.text.isNotEmpty)
                IconButton(tooltip: 'Copiar texto', onPressed: () => _copy(_inputController.text), icon: const Icon(Icons.copy_rounded, size: 19)),
            ]),
            TextField(
              controller: _inputController,
              minLines: 5,
              maxLines: 9,
              maxLength: 3000,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'Escreva, cole ou introduza texto…', alignLabelWithHint: true, border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none, filled: false, counterText: ''),
              onChanged: (_) { if (_result != null) setState(() => _result = null); },
            ),
            if (_selectedFileName != null && _mode == _TranslatorMode.document)
              _selectionLabel(Icons.description_outlined, _selectedFileName!),
            if (_selectedImageName != null && _mode == _TranslatorMode.image)
              _selectionLabel(Icons.image_outlined, _selectedImageName!),
          ]),
        ),
        if (_mode == _TranslatorMode.image && _ocrCompleted) ...[
          const SizedBox(height: 8),
          Wrap(spacing: 4, children: [
            TextButton.icon(onPressed: () => _copy(_inputController.text), icon: const Icon(Icons.copy_rounded, size: 18), label: const Text('Copiar texto OCR')),
            TextButton.icon(onPressed: () => Share.share(_inputController.text), icon: const Icon(Icons.share_outlined, size: 18), label: const Text('Partilhar')),
            TextButton.icon(onPressed: _saveOcr, icon: const Icon(Icons.bookmark_add_outlined, size: 18), label: const Text('Guardar')),
          ]),
        ],
        if (_mode == _TranslatorMode.voice && _inputController.text.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(spacing: 4, children: [
            TextButton.icon(onPressed: () => _copy(_inputController.text), icon: const Icon(Icons.copy_rounded, size: 18), label: const Text('Copiar ditado')),
            TextButton.icon(onPressed: () => Share.share(_inputController.text), icon: const Icon(Icons.share_outlined, size: 18), label: const Text('Partilhar')),
            TextButton.icon(onPressed: _saveVoiceText, icon: const Icon(Icons.bookmark_add_outlined, size: 18), label: const Text('Guardar')),
          ]),
        ],
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _busy ? null : () => _translate(context),
          icon: _busy ? const SizedBox(width: 17, height: 17, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.translate_rounded),
          label: Text(_busy ? 'A processar…' : 'Traduzir para ${target.name}'),
          style: FilledButton.styleFrom(backgroundColor: AppConstants.navy, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(50)),
        ),
        if (_result != null) ...[
          const SizedBox(height: 18),
          _translationResult(context, source, target),
        ],
        const SizedBox(height: 12),
        Text('Tradutor offline por vocabulário e frases incluídos. Não é tradução automática: texto não reconhecido mantém-se no original.', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.4)),
      ]),
    );
  }

  Widget _languageDropdown(String label, String value, ValueChanged<String?> onChanged) => DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label, isDense: true),
        items: SeedData.languages.map((language) => DropdownMenuItem(value: language.code, child: Text('${language.flag} ${language.name}'))).toList(),
        onChanged: onChanged,
      );

  Widget _documentPicker(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: OutlinedButton.icon(
          onPressed: _busy ? null : _pickDocument,
          icon: const Icon(Icons.upload_file_rounded),
          label: Text(_selectedFileName == null ? 'Importar ficheiro TXT, MD ou CSV' : 'Escolher outro ficheiro'),
        ),
      );

  Widget _imagePickerCard(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: SurfaceCard(
          padding: const EdgeInsets.all(14),
          child: Wrap(spacing: 9, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
            OutlinedButton.icon(onPressed: _busy || !_ocr.isSupported ? null : () => _pickImage(ImageSource.camera), icon: const Icon(Icons.camera_alt_outlined), label: const Text('Tirar foto')),
            OutlinedButton.icon(onPressed: _busy || !_ocr.isSupported ? null : () => _pickImage(ImageSource.gallery), icon: const Icon(Icons.photo_library_outlined), label: const Text('Importar imagem')),
            Text(_ocr.isSupported ? 'OCR Google ML Kit no dispositivo' : 'OCR disponível na app Android/iOS', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ]),
        ),
      );

  Widget _voiceCard(BuildContext context, String locale) {
    final supported = context.read<SpeechService>().isSupported;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SurfaceCard(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Icon(_listening ? Icons.mic_rounded : Icons.mic_none_rounded, color: _listening ? Colors.redAccent : AppConstants.navy),
          const SizedBox(width: 10),
          Expanded(child: Text(
            _listening ? 'A ouvir… fale agora.' : supported
                ? 'Ditado para ${SeedData.language(_sourceCode).name}. A disponibilidade offline depende do sistema.'
                : 'Ditado disponível na app móvel. A PWA não usa o serviço de voz do navegador.',
            style: Theme.of(context).textTheme.bodySmall,
          )),
          FilledButton.tonalIcon(
            onPressed: !supported ? null : _listening ? _stopListening : () => _startListening(locale),
            icon: Icon(_listening ? Icons.stop_rounded : Icons.mic_rounded),
            label: Text(_listening ? 'Parar' : 'Ditado'),
          ),
        ]),
      ),
    );
  }

  Widget _selectionLabel(IconData icon, String label) => Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Row(children: [Icon(icon, size: 17, color: AppConstants.gold), const SizedBox(width: 6), Expanded(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall))]),
      );

  Widget _translationResult(BuildContext context, AppLanguage source, AppLanguage target) {
    final result = _result!;
    final theme = Theme.of(context);
    return SurfaceCard(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text('Tradução · ${target.name}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
          IconButton(tooltip: 'Ouvir tradução', onPressed: () => _speakOutput(target.ttsLocale), icon: const Icon(Icons.volume_up_outlined)),
        ]),
        SelectableText(result.text, style: theme.textTheme.bodyLarge?.copyWith(height: 1.5)),
        const SizedBox(height: 9),
        Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 6, runSpacing: 4, children: [
          Text('Velocidade da voz:', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          _rateChip('Lento', .32),
          _rateChip('Normal', .48),
          _rateChip('Rápido', .68),
        ]),
        if (result.unknownTerms.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text('Termos não encontrados: ${result.unknownTerms.take(8).join(', ')}${result.unknownTerms.length > 8 ? '…' : ''}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
        ],
        const Divider(height: 24),
        Wrap(spacing: 4, runSpacing: 2, children: [
          TextButton.icon(onPressed: () => _copy(result.text), icon: const Icon(Icons.copy_rounded, size: 18), label: const Text('Copiar')),
          TextButton.icon(onPressed: () => Share.share(result.text), icon: const Icon(Icons.share_outlined, size: 18), label: const Text('Partilhar')),
          TextButton.icon(onPressed: _toggleFavorite, icon: Icon(_favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, size: 18, color: _favorite ? Colors.redAccent : null), label: Text(_favorite ? 'Guardado' : 'Guardar')),
        ]),
        Text('${result.matchedTerms} termo(s) reconhecido(s) · ${source.name} → ${target.name}', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ]),
    );
  }

  Widget _historyView(BuildContext context) {
    final theme = Theme.of(context);
    if (_history.isEmpty) {
      return Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.history_rounded, size: 44), const SizedBox(height: 10), Text('O histórico está vazio.', style: theme.textTheme.titleMedium), const SizedBox(height: 5), Text('As traduções guardadas neste dispositivo aparecerão aqui.', textAlign: TextAlign.center, style: theme.textTheme.bodySmall)])));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final row = _history[index];
        final date = DateTime.tryParse(row['created_at']?.toString() ?? '');
        final favorite = (row['is_favorite'] ?? 0) == 1;
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: theme.dividerColor)),
          child: ListTile(
            title: Text(row['input_text']?.toString() ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 3),
              Text(row['output_text']?.toString() ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
              if (date != null) Text('${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ]),
            isThreeLine: true,
            leading: const Icon(Icons.translate_rounded, color: AppConstants.gold),
            trailing: IconButton(
              tooltip: favorite ? 'Remover favorito' : 'Guardar favorito',
              onPressed: () async {
                await context.read<AppDatabase>().setHistoryFavorite(row['id'].toString(), !favorite);
                await _loadHistory();
              },
              icon: Icon(favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: favorite ? Colors.redAccent : null),
            ),
            onTap: () {
              setState(() {
                _sourceCode = row['source_language']?.toString() ?? 'en';
                _targetCode = row['target_language']?.toString() ?? 'pt';
                _inputController.text = row['input_text']?.toString() ?? '';
                _result = TranslationResult(text: row['output_text']?.toString() ?? '', matchedTerms: 0, unknownTerms: const []);
                _historyId = row['id']?.toString();
                _favorite = favorite;
                _mode = _TranslatorMode.text;
              });
            },
          ),
        );
      },
    );
  }

  Future<void> _translate(BuildContext context) async {
    final input = _inputController.text.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Escreva ou importe algum texto primeiro.')));
      return;
    }
    setState(() => _busy = true);
    try {
      final result = context.read<TranslationService>().translate(input: input, sourceCode: _sourceCode, targetCode: _targetCode);
      final user = context.read<AuthProvider>().currentUser;
      final id = DateTime.now().microsecondsSinceEpoch.toString();
      if (user != null) {
        await context.read<AppDatabase>().addHistory({
          'id': id,
          'user_id': user.id,
          'source_language': _sourceCode,
          'target_language': _targetCode,
          'input_text': input,
          'output_text': result.text,
          'created_at': DateTime.now().toIso8601String(),
          'is_favorite': 0,
        });
      }
      if (!mounted) return;
      setState(() { _result = result; _historyId = id; _favorite = false; _busy = false; });
    } catch (error) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível traduzir: $error')));
    }
  }

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['txt', 'md', 'csv'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.single;
      final bytes = file.bytes;
      if (bytes == null) throw StateError('Não foi possível ler o ficheiro seleccionado.');
      if (bytes.length > 1024 * 1024) throw StateError('O ficheiro excede o limite local de 1 MB.');
      final text = utf8.decode(bytes, allowMalformed: true);
      if (!mounted) return;
      setState(() { _inputController.text = text; _selectedFileName = file.name; _result = null; _ocrCompleted = false; });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao importar ficheiro: $error')));
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(source: source, imageQuality: 85, maxWidth: 2200);
      if (image == null || !mounted) return;
      setState(() { _selectedImageName = image.name; _busy = true; _ocrCompleted = false; });
      final text = await _ocr.extractText(image.path).timeout(const Duration(seconds: 15));
      if (!mounted) return;
      setState(() { _inputController.text = text; _result = null; _busy = false; _ocrCompleted = text.trim().isNotEmpty; });
      if (text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não foi encontrado texto legível na imagem.')));
      }
    } on UnsupportedError catch (error) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString().replaceFirst('UnsupportedError: ', ''))));
    } catch (error) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Falha na leitura OCR: $error')));
    }
  }

  Future<void> _startListening(String locale) async {
    setState(() => _listening = true);
    try {
      await context.read<SpeechService>().listen(
        localeId: locale,
        onResult: (text, isFinal) {
          if (!mounted) return;
          setState(() { _inputController.text = text; _inputController.selection = TextSelection.collapsed(offset: text.length); _result = null; });
          if (isFinal) setState(() => _listening = false);
        },
        onError: (message) {
          if (!mounted) return;
          setState(() => _listening = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Voz para texto: $message')));
        },
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _listening = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reconhecimento de voz indisponível: $error')));
    }
  }

  Future<void> _stopListening() async {
    await context.read<SpeechService>().stop();
    if (mounted) setState(() => _listening = false);
  }

  Widget _rateChip(String label, double rate) => ChoiceChip(
        label: Text(label),
        selected: (_ttsRate - rate).abs() < .01,
        onSelected: (_) => setState(() => _ttsRate = rate),
        visualDensity: VisualDensity.compact,
      );

  Future<void> _speakOutput(String locale) async {
    try {
      await context.read<TtsService>().speak(_result?.text ?? '', locale, rate: _ttsRate);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Texto para voz indisponível neste dispositivo.')));
    }
  }

  Future<void> _copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Texto copiado.')));
  }

  Future<void> _toggleFavorite() async {
    final id = _historyId;
    if (id == null) return;
    await context.read<AppDatabase>().setHistoryFavorite(id, !_favorite);
    if (mounted) setState(() => _favorite = !_favorite);
  }

  Future<void> _saveOcr() async {
    final user = context.read<AuthProvider>().currentUser;
    final text = _inputController.text.trim();
    if (user == null || text.isEmpty) return;
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    await context.read<AppDatabase>().addHistory({
      'id': id,
      'user_id': user.id,
      'source_language': _sourceCode,
      'target_language': _sourceCode,
      'input_text': text,
      'output_text': text,
      'created_at': DateTime.now().toIso8601String(),
      'is_favorite': 1,
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Texto OCR guardado nos favoritos do histórico.')));
  }

  Future<void> _saveVoiceText() async {
    final user = context.read<AuthProvider>().currentUser;
    final text = _inputController.text.trim();
    if (user == null || text.isEmpty) return;
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    await context.read<AppDatabase>().addHistory({
      'id': id,
      'user_id': user.id,
      'source_language': _sourceCode,
      'target_language': _sourceCode,
      'input_text': text,
      'output_text': text,
      'created_at': DateTime.now().toIso8601String(),
      'is_favorite': 1,
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transcrição guardada nos favoritos do histórico.')));
  }

  Future<void> _loadHistory() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;
    try {
      final entries = await context.read<AppDatabase>().historyForUser(user.id);
      if (mounted) setState(() => _history = entries);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível abrir o histórico: $error')));
    }
  }

  void _swapLanguages() => setState(() {
    final oldSource = _sourceCode;
    _sourceCode = _targetCode;
    _targetCode = oldSource;
    _result = null;
  });

  IconData _modeIcon(_TranslatorMode mode) => switch (mode) {
    _TranslatorMode.text => Icons.text_fields_rounded,
    _TranslatorMode.document => Icons.description_outlined,
    _TranslatorMode.image => Icons.document_scanner_outlined,
    _TranslatorMode.voice => Icons.mic_none_rounded,
    _TranslatorMode.history => Icons.history_rounded,
  };

  String _modeLabel(_TranslatorMode mode) => switch (mode) {
    _TranslatorMode.text => 'Texto',
    _TranslatorMode.document => 'Documento',
    _TranslatorMode.image => 'Imagem OCR',
    _TranslatorMode.voice => 'Voz',
    _TranslatorMode.history => 'Histórico',
  };
}
