import '../core/database/app_database.dart';

class ProgressRepository {
  ProgressRepository(this._database);
  final AppDatabase _database;

  Future<bool> completeLesson({
    required String userId,
    required String lessonId,
    required String language,
    required String level,
    required int score,
  }) async {
    final now = DateTime.now();
    final isNew = await _database.recordCompletion({
      'user_id': userId,
      'lesson_id': lessonId,
      'language': language,
      'level': level,
      'score': score.clamp(0, 100).toInt(),
      'completed_at': now.toIso8601String(),
    });
    if (!isNew) return false;

    final previous = await _database.progressFor(userId, language, level);
    final lastActive = DateTime.tryParse(previous['last_active']?.toString() ?? '');
    final today = DateTime(now.year, now.month, now.day);
    var streak = (previous['streak'] as num?)?.toInt() ?? 0;
    if (lastActive == null) {
      streak = 1;
    } else {
      final lastDay = DateTime(lastActive.year, lastActive.month, lastActive.day);
      final gap = today.difference(lastDay).inDays;
      if (gap == 1) {
        streak++;
      } else if (gap > 1) {
        streak = 1;
      }
    }

    final oldXp = (previous['xp'] as num?)?.toInt() ?? 0;
    final oldLessons = (previous['lessons_completed'] as num?)?.toInt() ?? 0;
    final xpAward = 10 + (score.clamp(0, 100) ~/ 10);
    await _database.saveProgress({
      'user_id': userId,
      'language': language,
      'level': level,
      'xp': oldXp + xpAward,
      'lessons_completed': oldLessons + 1,
      'streak': streak,
      'last_active': today.toIso8601String(),
    });
    return true;
  }

  Future<Map<String, dynamic>> stats(String userId, String language, String level) =>
      _database.levelStats(userId, language, level);

  Future<List<Map<String, dynamic>>> allProgress(String userId) =>
      _database.progressForUser(userId);

  Future<int> completedToday(String userId) => _database.completedToday(userId);

  Future<List<Map<String, dynamic>>> leaderboard() => _database.localLeaderboard();
}
