import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/emergency_contact.dart';
import '../models/health_profile.dart';
import '../models/user_profile.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl({ProfileRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? ProfileRemoteDataSourceImpl();

  @override
  Future<UserProfile?> getUserProfile({required String uid}) {
    return _remoteDataSource.getUserProfile(uid: uid);
  }

  @override
  Future<void> updateUserProfile({required UserProfile profile}) {
    return _remoteDataSource.updateUserProfile(profile: profile);
  }

  @override
  Future<HealthProfile?> getHealthProfile({required String uid}) {
    return _remoteDataSource.getHealthProfile(uid: uid);
  }

  @override
  Future<void> updateHealthProfile({
    required String uid,
    required HealthProfile profile,
  }) {
    return _remoteDataSource.updateHealthProfile(uid: uid, profile: profile);
  }

  @override
  Future<List<EmergencyContact>> getEmergencyContacts({required String uid}) {
    return _remoteDataSource.getEmergencyContacts(uid: uid);
  }

  @override
  Stream<List<EmergencyContact>> streamEmergencyContacts({required String uid}) {
    return _remoteDataSource.streamEmergencyContacts(uid: uid);
  }

  @override
  Future<void> addEmergencyContact({
    required String uid,
    required EmergencyContact contact,
  }) {
    return _remoteDataSource.addEmergencyContact(uid: uid, contact: contact);
  }

  @override
  Future<void> updateEmergencyContact({
    required String uid,
    required EmergencyContact contact,
  }) {
    return _remoteDataSource.updateEmergencyContact(uid: uid, contact: contact);
  }

  @override
  Future<void> deleteEmergencyContact({
    required String uid,
    required String contactId,
  }) {
    return _remoteDataSource.deleteEmergencyContact(uid: uid, contactId: contactId);
  }
}
