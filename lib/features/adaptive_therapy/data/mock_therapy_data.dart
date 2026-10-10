/// Frontend-only mock content for Adaptive Therapy (Module 3).
/// Replace with API/Firestore later — no backend calls live here.
class TherapyMocks {
  TherapyMocks._();

  static const String patientFirstName = 'Ahmed';
  static const String caregiverName = 'Sara Khan';
  static const String caregiverRole = 'Caregiver';
  static const String emotion = 'Calm';
  static const int confidence = 82;
}

class TherapyActivity {
  const TherapyActivity({
    required this.id,
    required this.title,
    required this.category,
    required this.durationLabel,
    required this.description,
    required this.benefits,
    required this.iconKind,
  });

  final String id;
  final String title;
  final String category;
  final String durationLabel;
  final String description;
  final List<String> benefits;
  final TherapyIconKind iconKind;
}

enum TherapyIconKind { leaf, games, mindfulness, reminiscence, routine }

class TherapyTypeItem {
  const TherapyTypeItem({
    required this.title,
    required this.subtitle,
    required this.iconKind,
    required this.routeName,
  });

  final String title;
  final String subtitle;
  final TherapyIconKind iconKind;
  final String routeName;
}

class WellnessTip {
  const WellnessTip({
    required this.title,
    required this.body,
    required this.category,
    required this.iconKind,
  });

  final String title;
  final String body;
  final String category;
  final TipIconKind iconKind;
}

enum TipIconKind { water, sleep, move }

class CaregiverRecItem {
  const CaregiverRecItem({
    required this.title,
    required this.status,
    required this.time,
    required this.iconKind,
  });

  final String title;
  final String status;
  final String time;
  final TherapyIconKind iconKind;
}

class MockTherapyCatalog {
  MockTherapyCatalog._();

  static const breathing = TherapyActivity(
    id: 'breathing',
    title: 'Deep Breathing Exercise',
    category: 'Relaxation',
    durationLabel: '5 min',
    description:
        'This breathing exercise helps calm your mind, reduce stress and improve focus.',
    benefits: [
      'Reduces anxiety',
      'Improves focus',
      'Supports better sleep',
    ],
    iconKind: TherapyIconKind.leaf,
  );

  static const types = [
    TherapyTypeItem(
      title: 'Relaxation Exercises',
      subtitle: 'Reduce stress and feel calmer',
      iconKind: TherapyIconKind.leaf,
      routeName: TherapyRouteNames.activityDetail,
    ),
    TherapyTypeItem(
      title: 'Cognitive Games',
      subtitle: 'Improve focus and memory',
      iconKind: TherapyIconKind.games,
      routeName: TherapyRouteNames.cognitiveGame,
    ),
    TherapyTypeItem(
      title: 'Mindfulness Activities',
      subtitle: 'Stay present and positive',
      iconKind: TherapyIconKind.mindfulness,
      routeName: TherapyRouteNames.activityDetail,
    ),
    TherapyTypeItem(
      title: 'Life Story Reminiscence',
      subtitle: 'Recall happy memories',
      iconKind: TherapyIconKind.reminiscence,
      routeName: TherapyRouteNames.memoryExercise,
    ),
    TherapyTypeItem(
      title: 'Daily Routine Support',
      subtitle: 'Build healthy habits',
      iconKind: TherapyIconKind.routine,
      routeName: TherapyRouteNames.activityDetail,
    ),
  ];

  static const tips = [
    WellnessTip(
      title: 'Stay Hydrated',
      body: 'Drink water regularly to keep your mind and body healthy.',
      category: 'Health',
      iconKind: TipIconKind.water,
    ),
    WellnessTip(
      title: 'Get Enough Sleep',
      body: 'Good sleep improves memory and mood.',
      category: 'Sleep',
      iconKind: TipIconKind.sleep,
    ),
    WellnessTip(
      title: 'Keep Moving',
      body: 'Light exercise boosts your energy and happiness.',
      category: 'Mood',
      iconKind: TipIconKind.move,
    ),
  ];

  static const caregiverRecs = [
    CaregiverRecItem(
      title: 'Breathing Exercise',
      status: 'Completed',
      time: 'Today, 10:30 AM',
      iconKind: TherapyIconKind.leaf,
    ),
    CaregiverRecItem(
      title: 'Cognitive Puzzle Game',
      status: 'Completed',
      time: 'Today, 09:25 AM',
      iconKind: TherapyIconKind.games,
    ),
    CaregiverRecItem(
      title: 'Mindfulness Activity',
      status: 'Upcoming',
      time: 'Today, 04:00 PM',
      iconKind: TherapyIconKind.mindfulness,
    ),
  ];
}

class TherapyRouteNames {
  TherapyRouteNames._();

  static const String shell = '/';
  static const String types = '/types';
  static const String relaxation = '/relaxation';
  static const String cognitiveGame = '/cognitive-game';
  static const String memoryExercise = '/memory-exercise';
  static const String activityDetail = '/activity-detail';
  static const String activityComplete = '/activity-complete';
  static const String caregiver = '/caregiver';
}
