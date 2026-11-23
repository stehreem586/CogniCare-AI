import '../../data/models/memory_model.dart';

abstract class MemoryRepository {
  Future<List<MemoryModel>> getMemories({required String patientId});
  Future<MemoryModel> addMemory({required MemoryModel memory});
  Future<void> updateMemory({required MemoryModel memory});
  Future<void> deleteMemory({
    required String memoryId,
    required String patientId,
  });
}
