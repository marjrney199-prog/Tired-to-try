import 'package:speech_to_text/speech_to_text.dart';

final SpeechToText _speech = SpeechToText();

bool get isSupported => true;
bool get isListening => _speech.isListening;

Future<void> listen({
  required String localeId,
  required void Function(String text, bool isFinal) onResult,
  required void Function(String message) onError,
}) async {
  final available = await _speech.initialize(
    onError: (error) => onError(error.errorMsg),
  );
  if (!available) throw StateError('O reconhecimento de voz não está disponível neste dispositivo.');
  await _speech.listen(
    localeId: localeId,
    listenFor: const Duration(seconds: 30),
    pauseFor: const Duration(seconds: 3),
    partialResults: true,
    onResult: (result) => onResult(result.recognizedWords, result.finalResult),
  );
}

Future<void> stop() => _speech.stop();
Future<void> cancel() => _speech.cancel();
