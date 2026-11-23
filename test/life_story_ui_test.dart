import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cognicare_ai/features/life_story/domain/repositories/memory_repository.dart';
import 'package:cognicare_ai/features/life_story/data/models/memory_model.dart';
import 'package:cognicare_ai/features/life_story/presentation/screens/life_story_hub_screen.dart';
import 'package:cognicare_ai/features/life_story/presentation/screens/new_memory_screen.dart';
import 'package:cognicare_ai/features/life_story/presentation/screens/memory_library_screen.dart';
import 'package:cognicare_ai/features/life_story/presentation/screens/life_timeline_screen.dart';
import 'package:cognicare_ai/features/life_story/presentation/screens/relationship_map_screen.dart';
import 'package:cognicare_ai/features/life_story/presentation/screens/recall_prompts_screen.dart';

class MockMemoryRepository implements MemoryRepository {
  final List<MemoryModel> _items = [
    MemoryModel(
      id: 'm_school',
      patientId: 'p1',
      title: 'First day of school',
      date: DateTime(1989, 9, 1),
      place: 'Karachi',
      era: 'Childhood',
      illustrationKey: 'school_day',
      taggedPeople: [],
      audioDurationSeconds: 18,
      createdAt: DateTime(1989, 9, 1),
    ),
    MemoryModel(
      id: 'm1',
      patientId: 'p1',
      title: "Eid at Nani's house",
      date: DateTime(1998, 4, 14),
      place: 'Lahore',
      era: 'Childhood',
      illustrationKey: 'eid_house',
      taggedPeople: ['Ayesha', 'Nani', 'Tariq', 'Ammi'],
      audioDurationSeconds: 24,
      createdAt: DateTime(1998, 4, 14),
    ),
    MemoryModel(
      id: 'm_grad',
      patientId: 'p1',
      title: 'Graduation day',
      date: DateTime(2004, 5, 20),
      place: '',
      era: 'Adulthood',
      illustrationKey: 'graduation',
      taggedPeople: [],
      audioDurationSeconds: 30,
      createdAt: DateTime(2004, 5, 20),
    ),
    MemoryModel(
      id: 'm2',
      patientId: 'p1',
      title: 'Lahore Fort',
      date: DateTime(2006, 11, 20),
      place: 'Lahore',
      era: 'Adulthood',
      illustrationKey: 'lahore_fort',
      taggedPeople: ['Uncle Tariq'],
      createdAt: DateTime(2006, 11, 20),
    ),
    MemoryModel(
      id: 'm_recent',
      patientId: 'p1',
      title: 'Morning garden walk',
      date: DateTime(2024, 2, 10),
      place: 'Shalimar Gardens',
      era: 'Recent',
      illustrationKey: 'murree_picnic',
      taggedPeople: ['Zainab'],
      createdAt: DateTime(2024, 2, 10),
    ),
  ];

  @override
  Future<List<MemoryModel>> getMemories({required String patientId}) async =>
      _items;

  @override
  Future<MemoryModel> addMemory({required MemoryModel memory}) async {
    _items.add(memory);
    return memory;
  }

  @override
  Future<void> updateMemory({required MemoryModel memory}) async {}

  @override
  Future<void> deleteMemory({
    required String memoryId,
    required String patientId,
  }) async {}
}

void main() {
  testWidgets(
    'LifeStoryHubScreen renders header, patient card, carousel and next session',
    (tester) async {
      final mockRepo = MockMemoryRepository();

      await tester.pumpWidget(
        MaterialApp(
          home: LifeStoryHubScreen(
            memoryRepository: mockRepo,
            patientName: 'Mr. Rahim Khan',
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Good evening'), findsOneWidget);
      expect(find.text('Mr. Rahim Khan'), findsOneWidget);
      expect(find.text("Mr. Rahim Khan's Memories"), findsOneWidget);
      expect(find.text('See all'), findsOneWidget);
      expect(find.text('Next session • 5:00 PM'), findsOneWidget);
      expect(find.text('"Who is this?" • 8 photos'), findsOneWidget);
    },
  );

  testWidgets(
    'NewMemoryScreen renders title, era pills, people tag and Save button',
    (tester) async {
      final mockRepo = MockMemoryRepository();

      await tester.pumpWidget(
        MaterialApp(home: NewMemoryScreen(memoryRepository: mockRepo)),
      );

      await tester.pumpAndSettle();

      expect(find.text('New memory'), findsOneWidget);
      expect(find.text('AI assist'), findsOneWidget);
      expect(find.text('Childhood'), findsOneWidget);
      expect(find.text('Adulthood'), findsOneWidget);
      expect(find.text('Recent'), findsOneWidget);
      expect(find.text('+ Tag'), findsOneWidget);
      expect(find.text('Save memory'), findsOneWidget);
    },
  );

  testWidgets(
    'MemoryLibraryScreen renders search, filter pills, on this day card',
    (tester) async {
      final mockRepo = MockMemoryRepository();

      await tester.pumpWidget(
        MaterialApp(home: MemoryLibraryScreen(memoryRepository: mockRepo)),
      );

      await tester.pumpAndSettle();

      expect(find.text('Memory library'), findsOneWidget);
      expect(find.text('Search people, places, events'), findsOneWidget);
      expect(find.text('People'), findsOneWidget);
      expect(find.text('Places'), findsOneWidget);
      expect(find.text('Events'), findsOneWidget);
    },
  );

  testWidgets(
    'LifeTimelineScreen renders header, subtitle, era filter and items',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockRepo = MockMemoryRepository();

      await tester.pumpWidget(
        MaterialApp(home: LifeTimelineScreen(memoryRepository: mockRepo)),
      );

      await tester.pumpAndSettle();

      // 1. Header elements
      expect(find.text('Life timeline'), findsOneWidget);
      expect(
        find.text("Rahim's story, from childhood to today"),
        findsOneWidget,
      );
      expect(find.text('Childhood'), findsOneWidget);
      expect(find.text('Adulthood'), findsOneWidget);
      expect(find.text('Recent'), findsOneWidget);

      // 2. Childhood timeline cards matching FE-2 mockup
      expect(find.text('1989 • Age 6'), findsOneWidget);
      expect(find.text('First day of school'), findsOneWidget);
      expect(find.text('Karachi'), findsOneWidget);

      expect(find.text('1998 • Age 15'), findsOneWidget);
      expect(find.text("Eid at Nani's house"), findsOneWidget);
      expect(find.text('Lahore • 4 people'), findsOneWidget);

      expect(find.text('2004 • Age 21'), findsOneWidget);
      expect(find.text('Graduation day'), findsOneWidget);

      // 3. Bottom Bar
      expect(find.text('Timeline'), findsOneWidget);
    },
  );

  testWidgets('LifeTimelineScreen switches between eras smoothly', (
    tester,
  ) async {
    final mockRepo = MockMemoryRepository();

    await tester.pumpWidget(
      MaterialApp(home: LifeTimelineScreen(memoryRepository: mockRepo)),
    );

    await tester.pumpAndSettle();

    // Tap Adulthood
    await tester.tap(find.text('Adulthood'));
    await tester.pumpAndSettle();

    expect(find.text('Lahore Fort'), findsOneWidget);
    expect(find.text('First day of school'), findsNothing);

    // Tap Recent
    await tester.tap(find.text('Recent'));
    await tester.pumpAndSettle();

    expect(find.text('Morning garden walk'), findsOneWidget);
    expect(find.text('Lahore Fort'), findsNothing);
  });

  testWidgets(
    'LifeTimelineScreen tapping card opens memory detail bottom sheet',
    (tester) async {
      final mockRepo = MockMemoryRepository();

      await tester.pumpWidget(
        MaterialApp(home: LifeTimelineScreen(memoryRepository: mockRepo)),
      );

      await tester.pumpAndSettle();

      // Tap on First day of school
      await tester.tap(find.text('First day of school'));
      await tester.pumpAndSettle();

      expect(find.text('Era: Childhood'), findsOneWidget);
      expect(find.text('Voice Memory Story:'), findsOneWidget);
    },
  );

  testWidgets(
    'RelationshipMapScreen renders header, graph, legend and selected node card',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockRepo = MockMemoryRepository();

      await tester.pumpWidget(
        MaterialApp(
          home: RelationshipMapScreen(
            memoryRepository: mockRepo,
            animate: false,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 1. Header elements matching FE-3
      expect(find.text('Relationship map'), findsOneWidget);
      expect(find.text('Tap a node to explore connections'), findsOneWidget);

      // 2. Bottom card for selected node (default Ayesha matching design)
      expect(find.text('Ayesha • Daughter'), findsOneWidget);
      expect(find.text('14 memories • 3 places'), findsOneWidget);
      expect(find.text('View'), findsOneWidget);

      // 3. Legend dots & Link action
      expect(find.text('People'), findsOneWidget);
      expect(find.text('Places'), findsOneWidget);
      expect(find.text('Events'), findsOneWidget);
      expect(find.text('Link'), findsOneWidget);
    },
  );

  testWidgets('RelationshipMapScreen opens Link dialog when + Link is tapped', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final mockRepo = MockMemoryRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: RelationshipMapScreen(memoryRepository: mockRepo, animate: false),
      ),
    );

    await tester.pumpAndSettle();

    // Tap "+ Link"
    await tester.tap(find.text('Link'));
    await tester.pumpAndSettle();

    expect(find.text('Link new relationship'), findsOneWidget);
    expect(find.text('Add to Relationship Map'), findsOneWidget);
  });

  testWidgets(
    'RelationshipMapScreen opens linked memories when View is tapped',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockRepo = MockMemoryRepository();

      await tester.pumpWidget(
        MaterialApp(
          home: RelationshipMapScreen(
            memoryRepository: mockRepo,
            animate: false,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap "View"
      await tester.tap(find.text('View'));
      await tester.pumpAndSettle();

      expect(find.text('Ayesha • Daughter'), findsWidgets);
      expect(find.textContaining('associated memories found'), findsWidgets);
    },
  );

  testWidgets(
    'RecallPromptsScreen renders header, featured card, queue and schedule banner',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockRepo = MockMemoryRepository();

      await tester.pumpWidget(
        MaterialApp(home: RecallPromptsScreen(memoryRepository: mockRepo)),
      );

      await tester.pumpAndSettle();

      // 1. Header elements matching FE-4
      expect(find.text('Recall prompts'), findsOneWidget);
      expect(find.text('Generated from stored memories'), findsOneWidget);
      expect(find.text('AI'), findsOneWidget);

      // 2. Featured prompt card
      expect(find.text('Easy'), findsOneWidget);
      expect(find.text("From: Eid at Nani's house"), findsOneWidget);
      expect(
        find.text('"Do you remember who made sheer khurma on Eid morning?"'),
        findsOneWidget,
      );
      expect(find.text('Send'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);

      // 3. Queued prompts
      expect(
        find.text('"Which city did you visit with Ayesha?"'),
        findsOneWidget,
      );
      expect(find.text('Medium • Lahore Fort'), findsOneWidget);
      expect(
        find.text('"What colour was your wedding sherwani?"'),
        findsOneWidget,
      );
      expect(find.text('Medium • Wedding day'), findsOneWidget);

      // 4. Smart Schedule Banner
      expect(find.textContaining('Smart schedule: daily at'), findsOneWidget);
    },
  );

  testWidgets(
    'RecallPromptsScreen tapping AI generates new prompt and Send dispatches',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockRepo = MockMemoryRepository();

      await tester.pumpWidget(
        MaterialApp(home: RecallPromptsScreen(memoryRepository: mockRepo)),
      );

      await tester.pumpAndSettle();

      // Tap Send
      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Prompt dispatched'), findsOneWidget);

      // Wait for first snackbar to dismiss
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      // Tap AI
      await tester.tap(find.text('AI'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('New AI recall prompt generated'),
        findsOneWidget,
      );
    },
  );

  testWidgets('RecallPromptsScreen tapping Edit opens prompt editor', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final mockRepo = MockMemoryRepository();

    await tester.pumpWidget(
      MaterialApp(home: RecallPromptsScreen(memoryRepository: mockRepo)),
    );

    await tester.pumpAndSettle();

    // Tap Edit
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Recall Prompt'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
  });
}
