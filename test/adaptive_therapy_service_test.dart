import 'package:flutter_test/flutter_test.dart';
import 'package:cognicare_ai/features/adaptive_therapy/services/adaptive_therapy_service.dart';

void main() {
  group('AdaptiveTherapyService', () {
    test('recommendation logic prefers relaxing activities for low mood state', () {
      final result = AdaptiveTherapyService.matchActivityRecommendation(
        currentMood: 'Low',
        confidence: 52,
        recentPerformance: 0.38,
        preferredCategory: 'Relaxation',
        history: const {'Relaxation': 3, 'Games': 1, 'Music': 1},
      );

      expect(result.category, 'Relaxation');
      expect(result.difficulty, TherapyDifficulty.easy);
    });

    test('difficulty escalates when performance is consistently high', () {
      final difficulty = AdaptiveTherapyService.resolveDifficulty(
        recentScores: const [0.88, 0.92, 0.95],
        category: 'Games',
      );

      expect(difficulty, TherapyDifficulty.hard);
    });

    test('performance score converts to expected range', () {
      final score = AdaptiveTherapyService.calculatePerformanceScore(
        correctAnswers: 4,
        totalQuestions: 5,
      );

      expect(score, 0.8);
    });
  });
}
