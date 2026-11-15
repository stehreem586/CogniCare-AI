import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cognicare_ai/features/adaptive_therapy/data/assessment_catalog.dart';
import 'package:cognicare_ai/features/adaptive_therapy/presentation/screens/assessment_activities_screen.dart';
import 'package:cognicare_ai/features/adaptive_therapy/presentation/screens/assessment_home_screen.dart';

void main() {
  testWidgets('Activities page exposes only the three selected activities', (tester) async {
    final selected = AssessmentCatalog.activities.take(3).toList();
    await tester.pumpWidget(MaterialApp(
      home: AssessmentActivitiesScreen(selectedActivities: selected, onStart: () {}),
    ));

    expect(find.text(selected[0].title), findsOneWidget);
    expect(find.text(selected[1].title), findsOneWidget);
    expect(find.text(selected[2].title), findsOneWidget);
    expect(find.text(AssessmentCatalog.activities[3].title), findsNothing);
    expect(find.text('Activity 1 of 3'), findsNothing);
  });

  testWidgets('Home dashboard does not render the seven-game catalogue', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: AssessmentHomeScreen(reports: const [], onStart: () {}, onReports: () {}),
    ));

    expect(find.text('Your cognitive dashboard'), findsOneWidget);
    expect(find.text('Available activities'), findsNothing);
    expect(find.text('Start assessment'), findsOneWidget);
  });
}
