import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cognicare_ai/features/life_story/data/models/memory_model.dart';
import 'package:cognicare_ai/features/life_story/domain/repositories/memory_repository.dart';
import 'package:cognicare_ai/features/life_story/presentation/screens/life_story_hub_screen.dart';
import 'package:cognicare_ai/features/life_story/presentation/screens/recall_prompts_screen.dart';

class _PatientMemoryRepository implements MemoryRepository {
  final List<MemoryModel> memories;

  _PatientMemoryRepository(this.memories);

  @override
  Future<List<MemoryModel>> getMemories({required String patientId}) async =>
      memories;

  @override
  Future<MemoryModel> addMemory({required MemoryModel memory}) =>
      throw UnsupportedError('Patient memory view is read-only');

  @override
  Future<void> updateMemory({required MemoryModel memory}) =>
      throw UnsupportedError('Patient memory view is read-only');

  @override
  Future<void> deleteMemory({
    required String memoryId,
    required String patientId,
  }) => throw UnsupportedError('Patient memory view is read-only');
}

MemoryModel _memory() => MemoryModel(
  id: 'patient-memory-1',
  patientId: 'patient-1',
  title: 'Family picnic',
  date: DateTime(2020, 6, 1),
  place: 'Murree',
  era: 'Recent',
  taggedPeople: const ['Ayesha'],
  illustrationKey: 'murree_picnic',
  createdAt: DateTime(2020, 6, 1),
);

void main() {
  testWidgets('patient life story hub is read-only and uses saved memories', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LifeStoryHubScreen(
          patientId: 'patient-1',
          patientName: 'Haadi',
          readOnly: true,
          memoryRepository: _PatientMemoryRepository([_memory()]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('My Memories'), findsOneWidget);
    expect(find.text('Family picnic'), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsNothing);
  });

  testWidgets('patient memory activity supports answer, hint, and skip', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RecallPromptsScreen(
          patientId: 'patient-1',
          readOnly: true,
          memoryRepository: _PatientMemoryRepository([_memory()]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Who is this?'), findsOneWidget);
    expect(find.text('Do you remember?'), findsOneWidget);
    expect(find.text('Hint'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Edit'), findsNothing);

    await tester.drag(find.byType(ListView), const Offset(0, -280));
    await tester.pump();
    await tester.tap(find.text('Hint'));
    await tester.pump();
    expect(find.textContaining('Hint:'), findsOneWidget);

    await tester.ensureVisible(find.text('Skip'));
    await tester.tap(find.text('Skip'));
    await tester.pump();
    expect(find.textContaining('That is okay.'), findsOneWidget);
  });
}
