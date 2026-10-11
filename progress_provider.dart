import 'dart:math';

import 'package:flutter/foundation.dart';

import '../repositories/progress_repository.dart';

class ProgressProvider extends ChangeNotifier {
  ProgressProvider(this._repository);
  final ProgressRepository _repository;

  int totalXp = 0;
  int completedLessons = 0;
  int streak = 0;
  int completedToday = 0;
  int rank = 0;
  bool isLoading = false;
  List<Map<String, dynamic>> leaderboard = const [];

  List<String> get medals {
    final result = <String>[];
    if (totalXp >= 50) result.add('Bronze');
    if (totalXp >= 200) result.add('Prata');
    if (totalXp >= 500) result.add('Ouro');
    if (totalXp >= 1000) result.add('Diamante');
    return result;
  }

  double get dailyGoalProgress => (completedToday / 1).clamp(0, 1).toDouble();

  Future<void> refresh(String userId) async {
    isLoading = true;
    notifyListeners();
    try {
      final rows = await _repository.allProgress(userId);
      totalXp = rows.fold<int>(0, (sum, row) => sum + ((row['xp'] as num?)?.toInt() ?? 0));
      completedLessons = rows.fold<int>(0, (sum, row) => sum + ((row['lessons_completed'] as num?)?.toInt() ?? 0));
      streak = rows.fold<int>(0, (best, row) => max(best, (row['streak'] as num?)?.toInt() ?? 0));
      completedToday = await _repository.completedToday(userId);
      leaderboard = await _repository.leaderboard();
      final current = leaderboard.indexWhere((item) => item['id']?.toString() == userId);
      rank = current < 0 ? 0 : current + 1;
    } catch (_) {
      leaderboard = const [];
      rank = 0;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> completeLesson({
    required String userId,
    required String lessonId,
    required String language,
    required String level,
    required int score,
  }) async {
    final isNew = await _repository.completeLesson(
      userId: userId,
      lessonId: lessonId,
      language: language,
      level: level,
      score: score,
    );
    await refresh(userId);
    return isNew;
  }

  Future<Map<String, dynamic>> levelStats(String userId, String language, String level) =>
      _repository.stats(userId, language, level);
}
