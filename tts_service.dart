import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  TtsService() : _engine = FlutterTts();
  final FlutterTts _engine;

  Future<void> speak(String text, String locale, {double rate = 0.48}) async {
    if (text.trim().isEmpty) return;
    await _engine.stop();
    await _engine.setLanguage(locale);
    await _engine.setSpeechRate(rate.clamp(0.25, 0.8).toDouble());
    await _engine.speak(text);
  }

  Future<void> stop() => _engine.stop();
}
