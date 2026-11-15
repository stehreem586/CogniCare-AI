import '../../data/models/emergency_contact.dart';
import '../../data/models/health_profile.dart';
import '../../data/models/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile?> getUserProfile({required String uid});
  Future<void> updateUserProfile({required UserProfile profile});

  Future<HealthProfile?> getHealthProfile({required String uid});
  Future<void> updateHealthProfile({
    required String uid,
    required HealthProfile profile,
  });

  Future<List<EmergencyContact>> getEmergencyContacts({required String uid});
  Stream<List<EmergencyContact>> streamEmergencyContacts({required String uid});
  Future<void> addEmergencyContact({
    required String uid,
    required EmergencyContact contact,
  });
  Future<void> updateEmergencyContact({
    required String uid,
    required EmergencyContact contact,
  });
  Future<void> deleteEmergencyContact({
    required String uid,
    required String contactId,
  });
}
