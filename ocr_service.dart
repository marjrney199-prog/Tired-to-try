import 'ocr_service_stub.dart'
    if (dart.library.io) 'ocr_service_native.dart' as platform;

/// A API nativa usa Google ML Kit no Android/iOS. O Web não recebe uma
/// implementação falsa: informa claramente quando a plataforma não é suportada.
class OcrService {
  Future<String> extractText(String imagePath) => platform.extractText(imagePath);
  bool get isSupported => platform.isSupported;
}
