import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:cognicare_ai/features/adaptive_therapy/data/assessment_catalog.dart';
import 'package:cognicare_ai/features/adaptive_therapy/data/models/therapy_models.dart';
import 'package:cognicare_ai/features/adaptive_therapy/services/assessment_service.dart';

void main() {
  test('selects three unique activities and avoids a previous combination', () {
    final first = AssessmentService.selectActivities(random: Random(4));
    final second = AssessmentService.selectActivities(
      previousCombinations: [first.map((item) => item.id).toSet()],
      random: Random(4),
    );

    expect(first, hasLength(3));
    expect(first.map((item) => item.id).toSet(), hasLength(3));
    expect(second.map((item) => item.id).toSet(), isNot(first.map((item) => item.id).toSet()));
  });

  test('combines actual activity answers into one percentage', () {
    final scores = [
      AssessmentActivityScore(
        activityId: 'one',
        activityTitle: 'One',
        correctAnswers: 2,
        totalQuestions: 3,
        score: 67,
        completedAt: DateTime(2026, 1, 1),
      ),
      AssessmentActivityScore(
        activityId: 'two',
        activityTitle: 'Two',
        correctAnswers: 3,
        totalQuestions: 3,
        score: 100,
        completedAt: DateTime(2026, 1, 1),
      ),
      AssessmentActivityScore(
        activityId: 'three',
        activityTitle: 'Three',
        correctAnswers: 1,
        totalQuestions: 3,
        score: 33,
        completedAt: DateTime(2026, 1, 1),
      ),
    ];

    expect(AssessmentService.overallScore(scores), 67);
    expect(AssessmentCatalog.activities, hasLength(7));
  });

  test('averages only the three selected normalized activity scores', () {
    final scores = [
      AssessmentActivityScore(
        activityId: 'story',
        activityTitle: 'Story',
        correctAnswers: 1,
        totalQuestions: 1,
        score: 100,
        completedAt: DateTime(2026, 1, 1),
      ),
      AssessmentActivityScore(
        activityId: 'cards',
        activityTitle: 'Cards',
        correctAnswers: 1,
        totalQuestions: 2,
        score: 50,
        completedAt: DateTime(2026, 1, 1),
      ),
      AssessmentActivityScore(
        activityId: 'objects',
        activityTitle: 'Objects',
        correctAnswers: 9,
        totalQuestions: 10,
        score: 90,
        completedAt: DateTime(2026, 1, 1),
      ),
    ];

    expect(AssessmentService.overallScore(scores), 80);
  });
}
