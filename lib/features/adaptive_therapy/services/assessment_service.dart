import 'dart:math';

import '../data/assessment_catalog.dart';
import '../data/models/therapy_models.dart';

class AssessmentService {
  AssessmentService._();

  static List<AssessmentActivityDefinition> selectActivities({
    List<AssessmentActivityDefinition> available = AssessmentCatalog.activities,
    List<Set<String>> previousCombinations = const [],
    Random? random,
  }) {
    if (available.length < 3) {
      throw ArgumentError('At least three assessment activities are required.');
    }

    final combinations = <String>{
      for (final previous in previousCombinations)
        (previous.toList()..sort()).join('|'),
    };
    final generator = random ?? Random();

    for (var attempt = 0; attempt < 20; attempt++) {
      final shuffled = [...available]..shuffle(generator);
      final selected = shuffled.take(3).toList();
      final key = selected.map((item) => item.id).toList()..sort();
      if (!combinations.contains(key.join('|'))) return selected;
    }

    final fallback = [...available]..shuffle(generator);
    return fallback.take(3).toList();
  }

  static int score({required int correctAnswers, required int totalQuestions}) {
    if (totalQuestions <= 0) return 0;
    return ((correctAnswers / totalQuestions) * 100).round().clamp(0, 100);
  }

  static int overallScore(List<AssessmentActivityScore> scores) {
    if (scores.isEmpty) return 0;
    final total = scores.fold<int>(0, (sum, item) => sum + item.score);
    return (total / scores.length).round().clamp(0, 100);
  }
}
