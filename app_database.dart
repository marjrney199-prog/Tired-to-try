import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

/// Persistência local. SQLite é usado no Android/iOS; no Web, onde o plugin
/// sqflite não tem suporte oficial, os mesmos registos são persistidos em Hive.
class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Database? _database;
  Box<dynamic>? _webStore;

  Future<void> initialize() async {
    if (kIsWeb) {
      _webStore ??= await Hive.openBox<dynamic>('ea_hub_web_database');
      return;
    }
    if (_database != null) return;

    final basePath = await getDatabasesPath();
    final dbPath = path.join(basePath, 'ea_language_hub.db');
    _database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            email TEXT NOT NULL,
            password_hash TEXT NOT NULL,
            password_salt TEXT NOT NULL,
            recovery_hash TEXT NOT NULL,
            recovery_salt TEXT NOT NULL,
            created_at TEXT NOT NULL,
            is_active INTEGER NOT NULL DEFAULT 1
          )
        ''');
        await db.execute('''
          CREATE TABLE progress (
            user_id TEXT NOT NULL,
            language TEXT NOT NULL,
            level TEXT NOT NULL,
            xp INTEGER NOT NULL DEFAULT 0,
            lessons_completed INTEGER NOT NULL DEFAULT 0,
            streak INTEGER NOT NULL DEFAULT 0,
            last_active TEXT NOT NULL DEFAULT '',
            PRIMARY KEY (user_id, language, level)
          )
        ''');
        await db.execute('''
          CREATE TABLE completions (
            user_id TEXT NOT NULL,
            lesson_id TEXT NOT NULL,
            language TEXT NOT NULL,
            level TEXT NOT NULL,
            score INTEGER NOT NULL,
            completed_at TEXT NOT NULL,
            PRIMARY KEY (user_id, lesson_id)
          )
        ''');
        await db.execute('''
          CREATE TABLE history (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            source_language TEXT NOT NULL,
            target_language TEXT NOT NULL,
            input_text TEXT NOT NULL,
            output_text TEXT NOT NULL,
            created_at TEXT NOT NULL,
            is_favorite INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE word_favorites (
            user_id TEXT NOT NULL,
            language TEXT NOT NULL,
            word TEXT NOT NULL,
            created_at TEXT NOT NULL,
            PRIMARY KEY (user_id, language, word)
          )
        ''');
        await db.execute('''
          CREATE TABLE certificates (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            language TEXT NOT NULL,
            level TEXT NOT NULL,
            score INTEGER NOT NULL,
            issued_at TEXT NOT NULL
          )
        ''');
        await db.execute("CREATE UNIQUE INDEX idx_users_email_unique ON users(email) WHERE email <> ''");
        await db.execute('CREATE INDEX idx_history_user_created ON history(user_id, created_at DESC)');
        await db.execute('CREATE INDEX idx_completions_user_level ON completions(user_id, language, level)');
      },
    );
  }

  Database get _db {
    final value = _database;
    if (value == null) throw StateError('A base de dados ainda não foi inicializada.');
    return value;
  }

  Box<dynamic> get _box {
    final value = _webStore;
    if (value == null) throw StateError('O armazenamento Web ainda não foi inicializado.');
    return value;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  List<Map<String, dynamic>> _asMapList(dynamic value) {
    if (value is! List) return <Map<String, dynamic>>[];
    return value.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Map<String, dynamic> _webMap(String key) => _asMap(_box.get(key));

  Future<void> _putWebMap(String key, Map<String, dynamic> value) async {
    await _box.put(key, value);
  }

  Future<Map<String, dynamic>?> userByEmail(String email) async {
    final normalized = email.trim().toLowerCase();
    if (kIsWeb) {
      final users = _webMap('users').values.map(_asMap);
      for (final user in users) {
        if ((user['email']?.toString().toLowerCase() ?? '') == normalized) return user;
      }
      return null;
    }
    final rows = await _db.query('users', where: 'email = ?', whereArgs: [normalized], limit: 1);
    return rows.isEmpty ? null : Map<String, dynamic>.from(rows.first);
  }

  Future<Map<String, dynamic>?> userById(String id) async {
    if (kIsWeb) {
      final value = _webMap('users')[id];
      return value == null ? null : _asMap(value);
    }
    final rows = await _db.query('users', where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : Map<String, dynamic>.from(rows.first);
  }

  Future<void> createUser(Map<String, dynamic> user) async {
    final normalizedUser = <String, dynamic>{
      ...user,
      'email': (user['email'] ?? '').toString().trim().toLowerCase(),
      'is_active': user['is_active'] ?? 1,
    };
    if (kIsWeb) {
      final users = _webMap('users');
      final email = normalizedUser['email'].toString();
      final duplicate = users.values.map(_asMap).any(
        (item) => (item['email']?.toString().toLowerCase() ?? '') == email && email.isNotEmpty,
      );
      if (duplicate) throw StateError('Este endereço de e-mail já está registado.');
      users[normalizedUser['id'].toString()] = normalizedUser;
      await _putWebMap('users', users);
      return;
    }
    try {
      await _db.insert('users', normalizedUser);
    } on DatabaseException catch (error) {
      if (error.isUniqueConstraintError()) {
        throw StateError('Este endereço de e-mail já está registado.');
      }
      rethrow;
    }
  }

  Future<void> updatePassword(String id, String hash, String salt) async {
    if (kIsWeb) {
      final users = _webMap('users');
      final user = _asMap(users[id]);
      if (user.isEmpty) throw StateError('Utilizador não encontrado.');
      user['password_hash'] = hash;
      user['password_salt'] = salt;
      users[id] = user;
      await _putWebMap('users', users);
      return;
    }
    await _db.update('users', {'password_hash': hash, 'password_salt': salt}, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> allUsers() async {
    if (kIsWeb) {
      final values = _webMap('users').values.map(_asMap).toList();
      values.sort((a, b) => (a['created_at'] ?? '').toString().compareTo((b['created_at'] ?? '').toString()));
      return values;
    }
    final rows = await _db.query('users', orderBy: 'created_at DESC');
    return rows.map((row) => Map<String, dynamic>.from(row)).toList();
  }

  Future<void> setUserActive(String id, bool active) async {
    if (kIsWeb) {
      final users = _webMap('users');
      final user = _asMap(users[id]);
      if (user.isEmpty) return;
      user['is_active'] = active ? 1 : 0;
      users[id] = user;
      await _putWebMap('users', users);
      return;
    }
    await _db.update('users', {'is_active': active ? 1 : 0}, where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, dynamic>> progressFor(String userId, String language, String level) async {
    if (kIsWeb) {
      final key = '$userId|$language|$level';
      return _asMap(_webMap('progress')[key]).isEmpty
          ? {'user_id': userId, 'language': language, 'level': level, 'xp': 0, 'lessons_completed': 0, 'streak': 0, 'last_active': ''}
          : _asMap(_webMap('progress')[key]);
    }
    final rows = await _db.query(
      'progress',
      where: 'user_id = ? AND language = ? AND level = ?',
      whereArgs: [userId, language, level],
      limit: 1,
    );
    return rows.isEmpty
        ? {'user_id': userId, 'language': language, 'level': level, 'xp': 0, 'lessons_completed': 0, 'streak': 0, 'last_active': ''}
        : Map<String, dynamic>.from(rows.first);
  }

  Future<void> saveProgress(Map<String, dynamic> progress) async {
    if (kIsWeb) {
      final all = _webMap('progress');
      final key = '${progress['user_id']}|${progress['language']}|${progress['level']}';
      all[key] = progress;
      await _putWebMap('progress', all);
      return;
    }
    await _db.insert('progress', progress, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> progressForUser(String userId) async {
    if (kIsWeb) {
      return _webMap('progress').values
          .map(_asMap)
          .where((row) => row['user_id']?.toString() == userId)
          .toList();
    }
    final rows = await _db.query('progress', where: 'user_id = ?', whereArgs: [userId]);
    return rows.map((row) => Map<String, dynamic>.from(row)).toList();
  }

  Future<bool> recordCompletion(Map<String, dynamic> completion) async {
    if (kIsWeb) {
      final list = _asMapList(_box.get('completions'));
      final exists = list.any((item) => item['user_id'] == completion['user_id'] && item['lesson_id'] == completion['lesson_id']);
      if (exists) return false;
      list.add(completion);
      await _box.put('completions', list);
      return true;
    }
    return _db.transaction((transaction) async {
      final existing = await transaction.query(
        'completions',
        columns: ['lesson_id'],
        where: 'user_id = ? AND lesson_id = ?',
        whereArgs: [completion['user_id'], completion['lesson_id']],
        limit: 1,
      );
      if (existing.isNotEmpty) return false;
      await transaction.insert('completions', completion);
      return true;
    });
  }

  Future<Map<String, dynamic>> levelStats(String userId, String language, String level) async {
    if (kIsWeb) {
      final rows = _asMapList(_box.get('completions')).where((row) =>
          row['user_id'] == userId && row['language'] == language && row['level'] == level).toList();
      final total = rows.fold<int>(0, (sum, row) => sum + ((row['score'] as num?)?.toInt() ?? 0));
      return {'count': rows.length, 'average': rows.isEmpty ? 0 : (total / rows.length).round()};
    }
    final rows = await _db.rawQuery(
      'SELECT COUNT(*) AS count, COALESCE(AVG(score), 0) AS average FROM completions WHERE user_id = ? AND language = ? AND level = ?',
      [userId, language, level],
    );
    return rows.isEmpty ? {'count': 0, 'average': 0} : Map<String, dynamic>.from(rows.first);
  }

  Future<void> addHistory(Map<String, dynamic> entry) async {
    if (kIsWeb) {
      final entries = _asMapList(_box.get('history'));
      entries.removeWhere((item) => item['id'] == entry['id']);
      entries.insert(0, entry);
      if (entries.length > 100) entries.removeRange(100, entries.length);
      await _box.put('history', entries);
      return;
    }
    await _db.insert('history', entry, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> historyForUser(String userId) async {
    if (kIsWeb) {
      final entries = _asMapList(_box.get('history'))
          .where((item) => item['user_id']?.toString() == userId)
          .toList();
      entries.sort((a, b) => (b['created_at'] ?? '').toString().compareTo((a['created_at'] ?? '').toString()));
      return entries;
    }
    final rows = await _db.query('history', where: 'user_id = ?', whereArgs: [userId], orderBy: 'created_at DESC', limit: 100);
    return rows.map((row) => Map<String, dynamic>.from(row)).toList();
  }

  Future<void> setHistoryFavorite(String id, bool favorite) async {
    if (kIsWeb) {
      final entries = _asMapList(_box.get('history'));
      for (final item in entries) {
        if (item['id'] == id) item['is_favorite'] = favorite ? 1 : 0;
      }
      await _box.put('history', entries);
      return;
    }
    await _db.update('history', {'is_favorite': favorite ? 1 : 0}, where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> isWordFavorite(String userId, String language, String word) async {
    if (kIsWeb) {
      return _asMapList(_box.get('word_favorites')).any((item) =>
          item['user_id'] == userId && item['language'] == language && item['word'] == word);
    }
    final rows = await _db.query(
      'word_favorites',
      columns: ['word'],
      where: 'user_id = ? AND language = ? AND word = ?',
      whereArgs: [userId, language, word],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<void> setWordFavorite(String userId, String language, String word, bool favorite) async {
    if (kIsWeb) {
      final list = _asMapList(_box.get('word_favorites'));
      list.removeWhere((item) => item['user_id'] == userId && item['language'] == language && item['word'] == word);
      if (favorite) {
        list.add({'user_id': userId, 'language': language, 'word': word, 'created_at': DateTime.now().toIso8601String()});
      }
      await _box.put('word_favorites', list);
      return;
    }
    if (favorite) {
      await _db.insert('word_favorites', {
        'user_id': userId,
        'language': language,
        'word': word,
        'created_at': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    } else {
      await _db.delete('word_favorites', where: 'user_id = ? AND language = ? AND word = ?', whereArgs: [userId, language, word]);
    }
  }

  Future<void> saveCertificate(Map<String, dynamic> certificate) async {
    if (kIsWeb) {
      final list = _asMapList(_box.get('certificates'));
      list.insert(0, certificate);
      await _box.put('certificates', list);
      return;
    }
    await _db.insert('certificates', certificate, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> certificatesForUser(String userId) async {
    if (kIsWeb) {
      return _asMapList(_box.get('certificates'))
          .where((item) => item['user_id']?.toString() == userId)
          .toList();
    }
    final rows = await _db.query('certificates', where: 'user_id = ?', whereArgs: [userId], orderBy: 'issued_at DESC');
    return rows.map((row) => Map<String, dynamic>.from(row)).toList();
  }

  Future<List<Map<String, dynamic>>> localLeaderboard() async {
    if (kIsWeb) {
      final users = _webMap('users').values.map(_asMap).toList();
      final progress = _webMap('progress').values.map(_asMap).toList();
      final leaderboard = users.where((user) => (user['is_active'] ?? 1) == 1).map((user) {
        final xp = progress.where((item) => item['user_id'] == user['id']).fold<int>(
          0,
          (sum, item) => sum + ((item['xp'] as num?)?.toInt() ?? 0),
        );
        return {'id': user['id'], 'name': user['name'], 'xp': xp};
      }).toList();
      leaderboard.sort((a, b) => ((b['xp'] as int?) ?? 0).compareTo((a['xp'] as int?) ?? 0));
      return leaderboard.take(20).toList();
    }
    final rows = await _db.rawQuery('''
      SELECT users.id, users.name, COALESCE(SUM(progress.xp), 0) AS xp
      FROM users LEFT JOIN progress ON progress.user_id = users.id
      WHERE users.is_active = 1
      GROUP BY users.id, users.name
      ORDER BY xp DESC, users.name ASC
      LIMIT 20
    ''');
    return rows.map((row) => Map<String, dynamic>.from(row)).toList();
  }

  Future<int> completedToday(String userId) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    if (kIsWeb) {
      return _asMapList(_box.get('completions')).where((item) {
        if (item['user_id']?.toString() != userId) return false;
        final date = DateTime.tryParse(item['completed_at']?.toString() ?? '');
        return date != null && !date.isBefore(start) && date.isBefore(end);
      }).length;
    }
    final result = await _db.rawQuery(
      'SELECT COUNT(*) AS count FROM completions WHERE user_id = ? AND completed_at >= ? AND completed_at < ?',
      [userId, start.toIso8601String(), end.toIso8601String()],
    );
    return (result.first['count'] as num).toInt();
  }

  Future<int> userCount() async {
    if (kIsWeb) return _webMap('users').length;
    final result = await _db.rawQuery('SELECT COUNT(*) AS count FROM users');
    return (result.first['count'] as num).toInt();
  }

  Future<int> historyCount() async {
    if (kIsWeb) return _asMapList(_box.get('history')).length;
    final result = await _db.rawQuery('SELECT COUNT(*) AS count FROM history');
    return (result.first['count'] as num).toInt();
  }

  Future<Map<String, dynamic>> exportBackup(String userId) async {
    final user = await userById(userId);
    final safeUser = user == null ? <String, dynamic>{} : Map<String, dynamic>.from(user);
    for (final secret in const ['password_hash', 'password_salt', 'recovery_hash', 'recovery_salt']) {
      safeUser.remove(secret);
    }
    final progress = await progressForUser(userId);
    final history = await historyForUser(userId);
    final certificates = await certificatesForUser(userId);
    final favorites = kIsWeb
        ? _asMapList(_box.get('word_favorites')).where((item) => item['user_id'] == userId).toList()
        : (await _db.query('word_favorites', where: 'user_id = ?', whereArgs: [userId])).map((row) => Map<String, dynamic>.from(row)).toList();
    return {
      'product': 'EA LANGUAGE HUB',
      'schema_version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'user': safeUser,
      'progress': progress,
      'history': history,
      'word_favorites': favorites,
      'certificates': certificates,
    };
  }
}
