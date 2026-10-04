import 'package:flutter_test/flutter_test.dart';
import 'package:cognicare_ai/features/authentication/data/models/app_user.dart';
import 'package:cognicare_ai/features/profile/data/models/health_profile.dart';
import 'package:cognicare_ai/features/profile/data/models/emergency_contact.dart';
import 'package:cognicare_ai/features/caregiver/data/models/caregiver_patient_link.dart';

void main() {
  group('Data Models Unit Tests', () {
    test('AppUser fromMap and toMap', () {
      final map = {
        'uid': 'user123',
        'email': 'user@example.com',
        'name': 'Ayesha Khan',
        'role': 'patient',
      };

      final user = AppUser.fromMap(map);
      expect(user.uid, 'user123');
      expect(user.email, 'user@example.com');
      expect(user.name, 'Ayesha Khan');
      expect(user.role, 'patient');

      final toMap = user.toMap();
      expect(toMap['uid'], 'user123');
      expect(toMap['email'], 'user@example.com');
      expect(toMap['role'], 'patient');
    });

    test('HealthProfile serialization', () {
      final health = HealthProfile(
        dementiaStage: 'Mild',
        medicalHistory: 'Hypertension',
        careNotes: 'Morning walks recommended',
      );

      final map = health.toMap();
      expect(map['dementiaStage'], 'Mild');
      expect(map['medicalHistory'], 'Hypertension');
      expect(map['careNotes'], 'Morning walks recommended');

      final restored = HealthProfile.fromMap(map);
      expect(restored.dementiaStage, 'Mild');
      expect(restored.medicalHistory, 'Hypertension');
    });

    test('EmergencyContact serialization', () {
      final contact = EmergencyContact(
        id: 'c1',
        name: 'Sara Khan',
        relationship: 'Daughter',
        phone: '03001234567',
      );

      final map = contact.toMap();
      expect(map['id'], 'c1');
      expect(map['name'], 'Sara Khan');
      expect(map['relationship'], 'Daughter');
      expect(map['phone'], '03001234567');

      final restored = EmergencyContact.fromMap(map);
      expect(restored.name, 'Sara Khan');
      expect(restored.phone, '03001234567');
    });

    test('CaregiverPatientLink serialization', () {
      final link = CaregiverPatientLink(
        id: 'link1',
        caregiverId: 'cg123',
        patientId: 'p456',
      );

      final map = link.toMap();
      expect(map['id'], 'link1');
      expect(map['caregiverId'], 'cg123');
      expect(map['patientId'], 'p456');

      final restored = CaregiverPatientLink.fromMap(map);
      expect(restored.caregiverId, 'cg123');
      expect(restored.patientId, 'p456');
    });
  });
}
