import '../../domain/repositories/memory_repository.dart';
import '../datasources/memory_remote_data_source.dart';
import '../models/memory_model.dart';

class MemoryRepositoryImpl implements MemoryRepository {
  final MemoryRemoteDataSource _remoteDataSource;

  MemoryRepositoryImpl({MemoryRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? MemoryRemoteDataSourceImpl();

  @override
  Future<List<MemoryModel>> getMemories({required String patientId}) {
    return _remoteDataSource.getMemories(patientId: patientId);
  }

  @override
  Future<MemoryModel> addMemory({required MemoryModel memory}) {
    return _remoteDataSource.addMemory(memory: memory);
  }

  @override
  Future<void> updateMemory({required MemoryModel memory}) {
    return _remoteDataSource.updateMemory(memory: memory);
  }

  @override
  Future<void> deleteMemory({
    required String memoryId,
    required String patientId,
  }) {
    return _remoteDataSource.deleteMemory(
      memoryId: memoryId,
      patientId: patientId,
    );
  }
}
