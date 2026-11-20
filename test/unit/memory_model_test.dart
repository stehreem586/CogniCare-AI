import 'package:flutter_test/flutter_test.dart';
import 'package:cognicare_ai/features/life_story/data/models/memory_model.dart';

void main() {
  group('Module 4 Life Story MemoryModel Tests', () {
    test('MemoryModel fromMap and toMap serialization', () {
      final now = DateTime(1998, 4, 14);
      final model = MemoryModel(
        id: 'mem_1',
        patientId: 'patient_123',
        caregiverId: 'caregiver_456',
        title: "Eid at Nani's house",
        date: now,
        place: 'Lahore',
        era: 'Childhood',
        illustrationKey: 'eid_house',
        taggedPeople: ['Ayesha', 'Nani'],
        audioDurationSeconds: 24,
        aiSuggestions: ['Eid', 'Lahore', 'Nani', '1998'],
        createdAt: now,
        isFavorite: true,
      );

      final map = model.toMap();
      expect(map['id'], 'mem_1');
      expect(map['title'], "Eid at Nani's house");
      expect(map['place'], 'Lahore');
      expect(map['era'], 'Childhood');
      expect(map['taggedPeople'], ['Ayesha', 'Nani']);
      expect(map['isFavorite'], true);

      final restored = MemoryModel.fromMap(map, 'mem_1');
      expect(restored.id, 'mem_1');
      expect(restored.title, "Eid at Nani's house");
      expect(restored.place, 'Lahore');
      expect(restored.era, 'Childhood');
      expect(restored.taggedPeople.length, 2);
      expect(restored.taggedPeople.contains('Ayesha'), true);
      expect(restored.taggedPeople.contains('Nani'), true);
    });

    test('MemoryModel copyWith updates fields correctly', () {
      final model = MemoryModel(
        id: '1',
        patientId: 'p1',
        title: 'Original Title',
        date: DateTime(2000),
        place: 'Islamabad',
        createdAt: DateTime(2000),
      );

      final updated = model.copyWith(
        title: 'Updated Title',
        place: 'Murree',
        era: 'Adulthood',
        taggedPeople: ['Hamza'],
      );

      expect(updated.title, 'Updated Title');
      expect(updated.place, 'Murree');
      expect(updated.era, 'Adulthood');
      expect(updated.taggedPeople, ['Hamza']);
      expect(updated.id, '1');
    });
  });
}
