import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

Future<String> extractText(String imagePath) async {
  final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
  try {
    final image = InputImage.fromFilePath(imagePath);
    final result = await recognizer.processImage(image);
    return result.text;
  } finally {
    await recognizer.close();
  }
}

bool get isSupported => true;
