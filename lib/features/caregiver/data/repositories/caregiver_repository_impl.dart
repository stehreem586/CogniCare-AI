import '../../../profile/data/models/health_profile.dart';
import '../../../profile/data/models/user_profile.dart';
import '../../domain/repositories/caregiver_repository.dart';
import '../datasources/caregiver_remote_data_source.dart';
import '../models/caregiver_patient_link.dart';

class CaregiverRepositoryImpl implements CaregiverRepository {
  final CaregiverRemoteDataSource _remoteDataSource;

  CaregiverRepositoryImpl({CaregiverRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? CaregiverRemoteDataSourceImpl();

  @override
  Future<List<CaregiverPatientLink>> getLinkedPatients({required String caregiverId}) {
    return _remoteDataSource.getLinkedPatients(caregiverId: caregiverId);
  }

  @override
  Future<List<UserProfile>> getLinkedPatientProfiles({required String caregiverId}) {
    return _remoteDataSource.getLinkedPatientProfiles(caregiverId: caregiverId);
  }

  @override
  Future<UserProfile?> getPatientProfile({required String patientId}) {
    return _remoteDataSource.getPatientProfile(patientId: patientId);
  }

  @override
  Future<HealthProfile?> getPatientHealthProfile({required String patientId}) {
    return _remoteDataSource.getPatientHealthProfile(patientId: patientId);
  }

  @override
  Future<void> updatePatientProfile({required UserProfile profile}) {
    return _remoteDataSource.updatePatientProfile(profile: profile);
  }

  @override
  Future<void> updatePatientHealthProfile({
    required String patientId,
    required HealthProfile profile,
  }) {
    return _remoteDataSource.updatePatientHealthProfile(
      patientId: patientId,
      profile: profile,
    );
  }

  @override
  Future<void> linkPatientByEmail({
    required String caregiverId,
    required String patientEmail,
  }) {
    return _remoteDataSource.linkPatientByEmail(
      caregiverId: caregiverId,
      patientEmail: patientEmail,
    );
  }
}
