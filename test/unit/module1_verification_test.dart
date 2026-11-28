import 'package:flutter_test/flutter_test.dart';
import 'package:cognicare_ai/core/constants/role_constants.dart';
import 'package:cognicare_ai/features/authentication/data/models/app_user.dart';
import 'package:cognicare_ai/features/caregiver/data/models/caregiver_patient_link.dart';
import 'package:cognicare_ai/features/profile/data/models/emergency_contact.dart';
import 'package:cognicare_ai/features/profile/data/models/health_profile.dart';
import 'package:cognicare_ai/features/profile/data/models/user_profile.dart';

void main() {
  group('Module 1 (FE-1 to FE-5) Verification Tests', () {
    test('FE-1: Role-based access keys and UserRole parsing', () {
      expect(UserRole.fromString('caregiver'), equals(UserRole.caregiver));
      expect(UserRole.fromString('patient'), equals(UserRole.patient));
      expect(UserRole.fromString('unknown'), equals(UserRole.patient));

      expect(UserRole.caregiver.key, equals('caregiver'));
      expect(UserRole.patient.key, equals('patient'));
      expect(UserRole.caregiver.title, equals('Caregiver'));
      expect(UserRole.patient.title, equals('Patient'));

      final appUser = AppUser(
        uid: 'user_1',
        email: 'caregiver@example.com',
        name: 'Maida Fayyaz',
        role: 'caregiver',
        createdAt: DateTime(2026, 1, 1),
      );

      final userMap = appUser.toMap();
      expect(userMap['role'], equals('caregiver'));
      expect(userMap['email'], equals('caregiver@example.com'));
      expect(userMap['name'], equals('Maida Fayyaz'));
    });

    test('FE-2: User and Caregiver profile model serialization and updating', () {
      final profile = UserProfile(
        uid: 'caregiver_42',
        role: 'caregiver',
        name: 'Maida Fayyaz',
        email: 'maida@example.com',
        phone: '03001234567',
        dateOfBirth: '1995-05-15',
        createdAt: DateTime(2026, 2, 1),
      );

      final map = profile.toMap();
      expect(map['uid'], equals('caregiver_42'));
      expect(map['role'], equals('caregiver'));
      expect(map['name'], equals('Maida Fayyaz'));
      expect(map['email'], equals('maida@example.com'));
      expect(map['phone'], equals('03001234567'));
      expect(map['dateOfBirth'], equals('1995-05-15'));

      final restored = UserProfile.fromMap(map, 'caregiver_42');
      expect(restored.name, equals('Maida Fayyaz'));
      expect(restored.role, equals('caregiver'));
      expect(restored.phone, equals('03001234567'));
      expect(restored.dateOfBirth, equals('1995-05-15'));

      // Test copyWith for profile updates
      final updated = restored.copyWith(
        name: 'Maida Fayyaz Updated',
        phone: '03009876543',
      );
      expect(updated.name, equals('Maida Fayyaz Updated'));
      expect(updated.phone, equals('03009876543'));
      expect(updated.role, equals('caregiver'));
      expect(updated.dateOfBirth, equals('1995-05-15'));
    });

    test('FE-3: Health Information and Emergency Contacts serialization', () {
      final health = HealthProfile(
        dementiaStage: 'Mild',
        medicalHistory: 'Hypertension, early Alzheimer diagnosed in 2024',
        careNotes: 'Needs gentle reminder for afternoon medication at 4pm',
        updatedAt: DateTime(2026, 3, 1),
      );

      final healthMap = health.toMap();
      expect(healthMap['dementiaStage'], equals('Mild'));
      expect(healthMap['medicalHistory'], contains('Alzheimer'));
      expect(healthMap['careNotes'], contains('4pm'));

      final restoredHealth = HealthProfile.fromMap(healthMap);
      expect(restoredHealth.dementiaStage, equals('Mild'));
      expect(restoredHealth.medicalHistory, equals(health.medicalHistory));
      expect(restoredHealth.careNotes, equals(health.careNotes));

      final contact = EmergencyContact(
        id: 'contact_1',
        name: 'Dr. Tariq',
        relationship: 'Primary Neurologist',
        phone: '03215551234',
        createdAt: DateTime(2026, 1, 10),
      );

      final contactMap = contact.toMap();
      expect(contactMap['name'], equals('Dr. Tariq'));
      expect(contactMap['relationship'], equals('Primary Neurologist'));
      expect(contactMap['phone'], equals('03215551234'));

      final restoredContact = EmergencyContact.fromMap(contactMap, 'contact_1');
      expect(restoredContact.id, equals('contact_1'));
      expect(restoredContact.name, equals('Dr. Tariq'));
      expect(restoredContact.relationship, equals('Primary Neurologist'));
    });

    test('FE-4: Caregiver-Patient link model serialization', () {
      final link = CaregiverPatientLink(
        id: 'caregiver1_patient1',
        caregiverId: 'caregiver1',
        patientId: 'patient1',
        createdAt: DateTime(2026, 4, 1),
      );

      final linkMap = link.toMap();
      expect(linkMap['caregiverId'], equals('caregiver1'));
      expect(linkMap['patientId'], equals('patient1'));

      final restoredLink = CaregiverPatientLink.fromMap(linkMap, 'caregiver1_patient1');
      expect(restoredLink.id, equals('caregiver1_patient1'));
      expect(restoredLink.caregiverId, equals('caregiver1'));
      expect(restoredLink.patientId, equals('patient1'));
    });
  });
}
