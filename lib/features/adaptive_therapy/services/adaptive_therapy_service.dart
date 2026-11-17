export '../data/models/therapy_models.dart';

import '../data/models/therapy_models.dart';
import '../data/repositories/adaptive_therapy_repository.dart';

class TherapyRecommendationMatch {
  const TherapyRecommendationMatch({
    required this.category,
    required this.difficulty,
    required this.title,
    required this.reason,
  });

  final String category;
  final TherapyDifficulty difficulty;
  final String title;
  final String reason;
}

class TherapyModuleState {
  const TherapyModuleState({
    required this.activities,
    required this.typeItems,
    required this.recommendedActivity,
    required this.preference,
  });

  final List<TherapyActivity> activities;
  final List<TherapyTypeItem> typeItems;
  final TherapyActivity? recommendedActivity;
  final PatientPreference preference;
}

class AdaptiveTherapyService {
  const AdaptiveTherapyService();

  static TherapyDifficulty resolveDifficulty({
    required List<double> recentScores,
    required String category,
  }) {
    final averageScore = recentScores.isEmpty
        ? 0.5
        : recentScores.reduce((sum, score) => sum + score) / recentScores.length;

    if ((averageScore >= 0.8) || (category.toLowerCase() == 'games' && averageScore >= 0.7)) {
      return TherapyDifficulty.hard;
    }

    if (averageScore >= 0.55) {
      return TherapyDifficulty.medium;
    }

    return TherapyDifficulty.easy;
  }

  static TherapyDifficulty resolveDifficultyFromPerformance({
    required double performanceScore,
    required String category,
  }) {
    if (performanceScore >= 0.8 || (category.toLowerCase() == 'games' && performanceScore >= 0.7)) {
      return TherapyDifficulty.hard;
    }
    if (performanceScore >= 0.55) {
      return TherapyDifficulty.medium;
    }
    return TherapyDifficulty.easy;
  }

  static double calculatePerformanceScore({
    required int correctAnswers,
    required int totalQuestions,
  }) {
    if (totalQuestions <= 0) {
      return 0.0;
    }

    return (correctAnswers / totalQuestions).clamp(0.0, 1.0);
  }

  static TherapyRecommendationMatch matchActivityRecommendation({
    required String currentMood,
    required int confidence,
    required double recentPerformance,
    required String preferredCategory,
    required Map<String, int> history,
  }) {
    final normalizedMood = currentMood.toLowerCase();
    final historyCategory = history.isEmpty
        ? preferredCategory
        : history.entries.reduce((winner, current) => current.value > winner.value ? current : winner).key;

    final preferred = preferredCategory.isNotEmpty ? preferredCategory : historyCategory;

    final category = (() {
      if (normalizedMood.contains('sad') || normalizedMood.contains('low') || normalizedMood.contains('stress')) {
        return 'Relaxation';
      }
      if (normalizedMood.contains('anxious') || normalizedMood.contains('tense')) {
        return 'Music';
      }
      if (normalizedMood.contains('happy') || normalizedMood.contains('calm') || confidence >= 80) {
        return preferred.isNotEmpty ? preferred : 'Games';
      }
      if (recentPerformance >= 0.7) {
        return 'Games';
      }
      return preferred.isNotEmpty ? preferred : 'Relaxation';
    })();

    final difficulty = resolveDifficultyFromPerformance(
      performanceScore: recentPerformance,
      category: category,
    );

    final title = switch (category) {
      'Relaxation' => 'Deep Breathing Exercise',
      'Games' => 'Memory Match Game',
      'Music' => 'Music Therapy Session',
      _ => 'Mindful Walk',
    };

    final reason = switch (category) {
      'Relaxation' => 'A gentle reset is most helpful for a low-energy mood and stress.',
      'Games' => 'Your recent performance suggests a slightly more engaging challenge would work well.',
      'Music' => 'A calm, sensory session can help restore focus and emotional balance.',
      _ => 'This activity aligns with your current preferences and supports steadier routines.',
    };

    return TherapyRecommendationMatch(
      category: category,
      difficulty: difficulty,
      title: title,
      reason: reason,
    );
  }

  static Future<TherapyModuleState> loadTherapyState({String? patientId}) async {
    final patientIdValue = AdaptiveTherapyRepository.currentPatientId(patientId: patientId);
    final activities = await AdaptiveTherapyRepository.fetchActivities();
    final preference = await AdaptiveTherapyRepository.fetchPatientPreference(patientId: patientIdValue);

    final history = <String, int>{
      for (final activity in activities) activity.category: (activities.where((item) => item.category == activity.category).length),
    };

    final recommendation = matchActivityRecommendation(
      currentMood: preference.preferredMood,
      confidence: preference.confidence,
      recentPerformance: preference.recentScores.isEmpty ? 0.6 : preference.recentScores.reduce((sum, value) => sum + value) / preference.recentScores.length,
      preferredCategory: preference.preferredCategory,
      history: history,
    );

    final recommendedActivity = activities.firstWhere(
      (activity) => activity.category == recommendation.category,
      orElse: () => activities.first,
    );

    final typeItems = activities
        .map(
          (activity) => TherapyTypeItem(
            title: activity.title,
            subtitle: activity.description,
            iconKind: activity.iconKind,
            routeName: activity.category == 'Relaxation' ||
                activity.category == 'Mindfulness' ||
                activity.category == 'Music'
                ? '/activity-detail'
              : activity.category == 'Games' ||
                  activity.category == 'Memory' ||
                  activity.id == 'life-story-reflection'
                    ? '/cognitive-game'
                    : '/memory-exercise',
            activityId: activity.id,
          ),
        )
        .toList();

    return TherapyModuleState(
      activities: activities,
      typeItems: typeItems,
      recommendedActivity: recommendedActivity,
      preference: preference,
    );
  }

  static Future<void> saveActivityCompletion({
    required String patientId,
    required String activityId,
    required String activityTitle,
    required String category,
    required int correctAnswers,
    required int totalQuestions,
    required int elapsedSeconds,
    required TherapyDifficulty difficulty,
  }) async {
    final score = calculatePerformanceScore(
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
    );

    final session = ActivitySession(
      patientId: patientId,
      activityId: activityId,
      category: category,
      activityTitle: activityTitle,
      startedAt: DateTime.now().subtract(Duration(seconds: elapsedSeconds)),
      completedAt: DateTime.now(),
      difficulty: difficulty,
      performanceScore: score,
      durationSeconds: elapsedSeconds,
    );

    await AdaptiveTherapyRepository.saveActivitySession(session);
  }

  static Future<void> saveActivityFeedback({
    required String patientId,
    required String activityId,
    required double rating,
    required String comment,
  }) async {
    final sentiment = rating >= 4.0 ? 'positive' : rating >= 2.5 ? 'neutral' : 'negative';
    final feedback = ActivityFeedback(
      patientId: patientId,
      activityId: activityId,
      rating: rating,
      comment: comment,
      sentiment: sentiment,
      createdAt: DateTime.now(),
    );

    await AdaptiveTherapyRepository.saveActivityFeedback(feedback);
  }
}
