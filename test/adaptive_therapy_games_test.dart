import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cognicare_ai/features/adaptive_therapy/data/models/therapy_models.dart';
import 'package:cognicare_ai/features/adaptive_therapy/presentation/screens/activity_complete_screen.dart';
import 'package:cognicare_ai/features/adaptive_therapy/presentation/screens/cognitive_game_screen.dart';
import 'package:cognicare_ai/features/adaptive_therapy/presentation/screens/memory_exercise_screen.dart';
import 'package:cognicare_ai/features/adaptive_therapy/presentation/screens/patient_therapy_shell.dart';

void main() {
  testWidgets('storytelling session returns one total after its final question', (tester) async {
    TherapyActivityResult? result;

    await tester.pumpWidget(
      MaterialApp(
        home: CognitiveGameScreen(
          activityId: 'story-recall',
          onComplete: (value) => result = value,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Session score'), findsNothing);
    expect(result, isNull);

    await tester.tap(find.text('Begin questions'));
    await tester.pump();
    await tester.tap(find.text('Blue'));
    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(find.text('Step 2 of 3'), findsOneWidget);
    expect(result, isNull);

    await tester.tap(find.text('Oranges and bread'));
    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(find.text('Step 3 of 3'), findsOneWidget);
    expect(result, isNull);

    await tester.tap(find.text('Her neighbor Omar'));
    await tester.tap(find.text('Finish'));
    await tester.pump();

    expect(result, isNotNull);
    expect(result!.correctAnswers, 3);
    expect(result!.totalQuestions, 3);
    expect(result!.percentage, 100);
  });

  testWidgets('park memory session returns one total after its final question', (tester) async {
    TherapyActivityResult? result;

    await tester.pumpWidget(
      MaterialApp(
        home: MemoryExerciseScreen(onComplete: (value) => result = value),
      ),
    );
    await tester.pump(const Duration(seconds: 10));

    expect(find.text('Session score'), findsNothing);
    expect(result, isNull);

    await tester.tap(find.text('Start recall'));
    await tester.pump();
    await tester.tap(find.text('Two'));
    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(find.text('Question 2 of 3'), findsOneWidget);
    expect(result, isNull);

    await tester.tap(find.text('Bottom right'));
    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.tap(find.text('Tan'));
    await tester.tap(find.text('Finish'));
    await tester.pump();

    expect(result, isNotNull);
    expect(result!.correctAnswers, 3);
    expect(result!.totalQuestions, 3);
    expect(result!.percentage, 100);
  });

  testWidgets('completion shows the activity total without emotion confidence', (tester) async {
    final result = TherapyActivityResult(
      activityId: 'story-recall',
      activityTitle: 'Storytelling & Recall',
      category: 'Games',
      correctAnswers: 2,
      totalQuestions: 3,
      elapsedSeconds: 90,
      difficulty: TherapyDifficulty.medium,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ActivityCompleteScreen(
          result: result,
          onViewNext: () {},
          onBackHome: () {},
        ),
      ),
    );

    expect(find.text('67%  ·  2 of 3 correct'), findsOneWidget);
    expect(find.text('Your Current Emotion'), findsNothing);
    expect(find.textContaining('Confidence:'), findsNothing);
  });

  testWidgets('patient More has no caregiver access and includes patient tools', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PatientTherapyShell(initialTab: TherapyModuleTab.more),
      ),
    );

    expect(find.text('More'), findsOneWidget);
    expect(find.text('All therapy types'), findsOneWidget);
    expect(find.text('Wellness tips'), findsOneWidget);
    expect(find.text('Caregiver view (Module 3)'), findsNothing);
  });
}
