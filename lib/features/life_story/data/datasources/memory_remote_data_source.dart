import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../../core/constants/firestore_constants.dart';
import '../models/memory_model.dart';

abstract class MemoryRemoteDataSource {
  Future<List<MemoryModel>> getMemories({required String patientId});
  Future<MemoryModel> addMemory({required MemoryModel memory});
  Future<void> updateMemory({required MemoryModel memory});
  Future<void> deleteMemory({
    required String memoryId,
    required String patientId,
  });
}

class MemoryRemoteDataSourceImpl implements MemoryRemoteDataSource {
  final FirebaseFirestore _firestore;

  // In-memory cache & initial demo memories matching the design screens
  static final Map<String, List<MemoryModel>> _cachedMemories = {};

  MemoryRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  static List<MemoryModel> getDemoMemories(String patientId) {
    return [
      MemoryModel(
        id: 'mem_school',
        patientId: patientId,
        title: 'First day of school',
        date: DateTime(1989, 9, 1),
        place: 'Karachi',
        era: 'Childhood',
        illustrationKey: 'school_day',
        taggedPeople: [],
        audioDurationSeconds: 18,
        aiSuggestions: ['School', 'Karachi', 'Class of 89', 'Childhood'],
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        isFavorite: true,
      ),
      MemoryModel(
        id: 'mem_1',
        patientId: patientId,
        title: "Eid at Nani's house",
        date: DateTime(1998, 4, 14),
        place: 'Lahore',
        era: 'Childhood',
        illustrationKey: 'eid_house',
        taggedPeople: ['Ayesha', 'Nani', 'Tariq', 'Ammi'],
        audioDurationSeconds: 24,
        aiSuggestions: ['Eid', 'Lahore', 'Nani', '1998'],
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        isFavorite: true,
      ),
      MemoryModel(
        id: 'mem_4',
        patientId: patientId,
        title: 'Graduation day',
        date: DateTime(2004, 5, 20),
        place: '',
        era: 'Adulthood',
        illustrationKey: 'graduation',
        taggedPeople: ['Prof. Kamal', 'Classmates'],
        audioDurationSeconds: 30,
        aiSuggestions: ['Graduation', 'College', 'Degree', '2004'],
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      MemoryModel(
        id: 'mem_2',
        patientId: patientId,
        title: 'Lahore Fort',
        date: DateTime(2006, 11, 20),
        place: 'Lahore',
        era: 'Adulthood',
        illustrationKey: 'lahore_fort',
        taggedPeople: ['Uncle Tariq', 'Hamza'],
        audioDurationSeconds: 45,
        aiSuggestions: ['Lahore Fort', 'Trip', 'History', '2006'],
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
      MemoryModel(
        id: 'mem_3',
        patientId: patientId,
        title: 'Family picnic in Murree',
        date: DateTime(2009, 7, 18),
        place: 'Murree',
        era: 'Adulthood',
        illustrationKey: 'murree_picnic',
        taggedPeople: ['Rahim', 'Zainab', 'Kids'],
        audioDurationSeconds: 60,
        aiSuggestions: ['Murree', 'Picnic', 'Hills', '2009'],
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
        isFavorite: true,
      ),
      MemoryModel(
        id: 'mem_5',
        patientId: patientId,
        title: 'Wedding day',
        date: DateTime(2012, 12, 10),
        place: 'Islamabad',
        era: 'Adulthood',
        illustrationKey: 'wedding',
        taggedPeople: ['Zainab (Wife)', 'Parents'],
        audioDurationSeconds: 50,
        aiSuggestions: ['Wedding', 'Valima', 'Family', '2012'],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      MemoryModel(
        id: 'mem_6',
        patientId: patientId,
        title: 'Grandkids visit Lahore',
        date: DateTime(2023, 8, 15),
        place: 'Lahore',
        era: 'Recent',
        illustrationKey: 'eid_house',
        taggedPeople: ['Sara', 'Bilal', 'Zainab'],
        audioDurationSeconds: 35,
        aiSuggestions: ['Grandkids', 'Family', 'Recent'],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      MemoryModel(
        id: 'mem_7',
        patientId: patientId,
        title: 'Morning garden walk',
        date: DateTime(2024, 2, 10),
        place: 'Shalimar Gardens',
        era: 'Recent',
        illustrationKey: 'murree_picnic',
        taggedPeople: ['Zainab'],
        audioDurationSeconds: 22,
        aiSuggestions: ['Walk', 'Gardens', 'Recent'],
        createdAt: DateTime.now(),
      ),
    ];
  }

  @override
  Future<List<MemoryModel>> getMemories({required String patientId}) async {
    // Widget tests can use the deterministic demo fixture without Firebase.
    if (Firebase.apps.isEmpty) {
      if (!_cachedMemories.containsKey(patientId) ||
          _cachedMemories[patientId]!.isEmpty) {
        _cachedMemories[patientId] = getDemoMemories(patientId);
      }
      return _cachedMemories[patientId]!;
    }

    try {
      final snapshot = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(patientId)
          .collection(FirestoreConstants.memoriesCollection)
          .orderBy('date', descending: true)
          .get()
          .timeout(const Duration(seconds: 4));

      if (snapshot.docs.isNotEmpty) {
        final list = snapshot.docs
            .map((doc) => MemoryModel.fromMap(doc.data(), doc.id))
            .toList();
        _cachedMemories[patientId] = list;
        return list;
      }
      _cachedMemories[patientId] = [];
      return const [];
    } catch (_) {
      // Never show another patient's/demo content when the real data cannot
      // be read. A cached list is safe because it is keyed by patientId.
      return _cachedMemories[patientId] ?? const [];
    }
  }

  @override
  Future<MemoryModel> addMemory({required MemoryModel memory}) async {
    if (Firebase.apps.isEmpty) {
      final localId = memory.id.isNotEmpty
          ? memory.id
          : 'mem_${DateTime.now().millisecondsSinceEpoch}';
      final newMemory = memory.copyWith(id: localId);
      _updateLocalCache(newMemory);
      return newMemory;
    }

    try {
      final docRef = _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(memory.patientId)
          .collection(FirestoreConstants.memoriesCollection)
          .doc();

      final newMemory = memory.copyWith(id: docRef.id);
      await docRef.set(newMemory.toMap()).timeout(const Duration(seconds: 4));

      _updateLocalCache(newMemory);
      return newMemory;
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<void> updateMemory({required MemoryModel memory}) async {
    if (Firebase.apps.isEmpty) {
      _updateLocalCache(memory);
      return;
    }
    await _firestore
        .collection(FirestoreConstants.usersCollection)
        .doc(memory.patientId)
        .collection(FirestoreConstants.memoriesCollection)
        .doc(memory.id)
        .update(memory.toMap())
        .timeout(const Duration(seconds: 4));

    _updateLocalCache(memory);
  }

  @override
  Future<void> deleteMemory({
    required String memoryId,
    required String patientId,
  }) async {
    if (Firebase.apps.isEmpty) {
      if (_cachedMemories.containsKey(patientId)) {
        _cachedMemories[patientId]!.removeWhere((m) => m.id == memoryId);
      }
      return;
    }
    await _firestore
        .collection(FirestoreConstants.usersCollection)
        .doc(patientId)
        .collection(FirestoreConstants.memoriesCollection)
        .doc(memoryId)
        .delete()
        .timeout(const Duration(seconds: 4));

    if (_cachedMemories.containsKey(patientId)) {
      _cachedMemories[patientId]!.removeWhere((m) => m.id == memoryId);
    }
  }

  void _updateLocalCache(MemoryModel memory) {
    final list = _cachedMemories.putIfAbsent(memory.patientId, () => []);
    final index = list.indexWhere((m) => m.id == memory.id);
    if (index >= 0) {
      list[index] = memory;
    } else {
      list.insert(0, memory);
    }
  }
}
