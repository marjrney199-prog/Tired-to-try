import 'package:hive/hive.dart';

/// Hive guarda preferências, sessão e dados auxiliares locais.
class LocalStorage {
  LocalStorage._();

  static const _boxName = 'ea_hub_preferences';
  static Box<dynamic>? _box;

  static Future<void> initialize() async {
    _box ??= await Hive.openBox<dynamic>(_boxName);
  }

  static Box<dynamic> get _store {
    final box = _box;
    if (box == null) throw StateError('O armazenamento local ainda não foi inicializado.');
    return box;
  }

  static String? get sessionUserId => _store.get('session_user_id')?.toString();

  static Future<void> saveSession(String? userId) async {
    if (userId == null) {
      await _store.delete('session_user_id');
    } else {
      await _store.put('session_user_id', userId);
    }
  }

  static bool get darkMode => _store.get('dark_mode', defaultValue: false) == true;

  static Future<void> setDarkMode(bool value) => _store.put('dark_mode', value);

  static String? avatarFor(String userId) => _store.get('avatar_$userId')?.toString();

  static Future<void> setAvatar(String userId, String? dataUri) async {
    if (dataUri == null) {
      await _store.delete('avatar_$userId');
    } else {
      await _store.put('avatar_$userId', dataUri);
    }
  }

  static List<String> get enabledLanguageCodes {
    final raw = _store.get('enabled_languages');
    if (raw is List) return raw.map((value) => value.toString()).toList();
    return const ['en', 'pt', 'fr', 'es', 'de', 'it', 'ar', 'zh', 'sw'];
  }

  static Future<void> setEnabledLanguageCodes(List<String> codes) =>
      _store.put('enabled_languages', codes);

  static List<Map<String, dynamic>> get customLessons {
    final raw = _store.get('custom_lessons');
    if (raw is! List) return <Map<String, dynamic>>[];
    return raw.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
  }

  static Future<void> saveCustomLesson(Map<String, dynamic> lesson) async {
    final lessons = customLessons;
    lessons.insert(0, lesson);
    await _store.put('custom_lessons', lessons);
  }

  static String get recoveryCodeHint => _store.get('recovery_code_hint', defaultValue: '') as String;
}
