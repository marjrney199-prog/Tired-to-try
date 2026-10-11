bool get isSupported => false;
bool get isListening => false;

Future<void> listen({
  required String localeId,
  required void Function(String text, bool isFinal) onResult,
  required void Function(String message) onError,
}) async => throw UnsupportedError('O ditado por voz está disponível na app móvel. A PWA não usa o serviço de voz do navegador.');

Future<void> stop() async {}
Future<void> cancel() async {}
