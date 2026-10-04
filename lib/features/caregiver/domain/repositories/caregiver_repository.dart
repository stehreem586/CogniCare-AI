import '../../../profile/data/models/health_profile.dart';
import '../../../profile/data/models/user_profile.dart';
import '../../data/models/caregiver_patient_link.dart';

abstract class CaregiverRepository {
  Future<List<CaregiverPatientLink>> getLinkedPatients({required String caregiverId});
  Future<List<UserProfile>> getLinkedPatientProfiles({required String caregiverId});
  Future<UserProfile?> getPatientProfile({required String patientId});
  Future<HealthProfile?> getPatientHealthProfile({required String patientId});
  Future<void> updatePatientProfile({required UserProfile profile});
  Future<void> updatePatientHealthProfile({
    required String patientId,
    required HealthProfile profile,
  });
  Future<void> linkPatientByEmail({
    required String caregiverId,
    required String patientEmail,
  });
}
