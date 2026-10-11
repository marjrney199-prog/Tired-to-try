import 'speech_service_stub.dart'
    if (dart.library.io) 'speech_service_native.dart' as platform;

/// Adaptador que mantém o reconhecimento de voz no dispositivo móvel.
/// A implementação Web fica desactivada para evitar depender da API de voz do navegador.
class SpeechService {
  bool get isSupported => platform.isSupported;
  bool get isListening => platform.isListening;

  Future<void> listen({
    required String localeId,
    required void Function(String text, bool isFinal) onResult,
    required void Function(String message) onError,
  }) => platform.listen(localeId: localeId, onResult: onResult, onError: onError);

  Future<void> stop() => platform.stop();
  Future<void> cancel() => platform.cancel();
}
