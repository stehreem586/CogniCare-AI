import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../profile/data/models/health_profile.dart';
import '../../../profile/data/models/user_profile.dart';
import '../models/caregiver_patient_link.dart';

abstract class CaregiverRemoteDataSource {
  Future<List<CaregiverPatientLink>> getLinkedPatients({
    required String caregiverId,
  });
  Future<List<UserProfile>> getLinkedPatientProfiles({
    required String caregiverId,
  });
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

class CaregiverRemoteDataSourceImpl implements CaregiverRemoteDataSource {
  final FirebaseFirestore _firestore;

  CaregiverRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<CaregiverPatientLink>> getLinkedPatients({
    required String caregiverId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(FirestoreConstants.caregiverPatientLinksCollection)
          .where(FirestoreConstants.fieldCaregiverId, isEqualTo: caregiverId)
          .get();

      return snapshot.docs
          .map((doc) => CaregiverPatientLink.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw AppException.fromFirebaseException(e);
    }
  }

  @override
  Future<List<UserProfile>> getLinkedPatientProfiles({
    required String caregiverId,
  }) async {
    try {
      final links = await getLinkedPatients(caregiverId: caregiverId);
      if (links.isEmpty) return [];

      final List<UserProfile> patientProfiles = [];
      for (final link in links) {
        final profile = await getPatientProfile(patientId: link.patientId);
        if (profile != null) {
          patientProfiles.add(profile);
        }
      }
      return patientProfiles;
    } catch (e) {
      throw AppException.fromFirebaseException(e);
    }
  }

  @override
  Future<UserProfile?> getPatientProfile({required String patientId}) async {
    try {
      final doc = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(patientId)
          .get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return UserProfile.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw AppException.fromFirebaseException(e);
    }
  }

  @override
  Future<HealthProfile?> getPatientHealthProfile({
    required String patientId,
  }) async {
    try {
      final doc = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(patientId)
          .collection(FirestoreConstants.healthProfileSubcollection)
          .doc(FirestoreConstants.healthProfileDocId)
          .get();

      if (!doc.exists || doc.data() == null) {
        return const HealthProfile(dementiaStage: 'Mild');
      }
      return HealthProfile.fromMap(doc.data()!);
    } catch (e) {
      throw AppException.fromFirebaseException(e);
    }
  }

  @override
  Future<void> updatePatientProfile({required UserProfile profile}) async {
    try {
      if (profile.uid.isEmpty) {
        throw const AppException(
          'Patient ID is missing. Cannot update profile.',
        );
      }
      final profileMap = profile.toMap();
      profileMap['updatedAt'] = FieldValue.serverTimestamp();
      profileMap['name'] = profile.name.trim();
      profileMap['displayName'] = profile.name.trim();
      profileMap['fullName'] = profile.name.trim();

      await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(profile.uid)
          .set(profileMap, SetOptions(merge: true));

      if (profile.email.isNotEmpty) {
        try {
          await _firestore
              .collection(FirestoreConstants.userLookupCollection)
              .doc(profile.email.trim().toLowerCase())
              .set({
                FirestoreConstants.fieldName: profile.name.trim(),
                FirestoreConstants.fieldPhone: profile.phone,
              }, SetOptions(merge: true));
        } catch (_) {}
      }
    } catch (e) {
      throw AppException.fromFirebaseException(e);
    }
  }

  @override
  Future<void> updatePatientHealthProfile({
    required String patientId,
    required HealthProfile profile,
  }) async {
    try {
      await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(patientId)
          .collection(FirestoreConstants.healthProfileSubcollection)
          .doc(FirestoreConstants.healthProfileDocId)
          .set(profile.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw AppException.fromFirebaseException(e);
    }
  }

  @override
  Future<void> linkPatientByEmail({
    required String caregiverId,
    required String patientEmail,
  }) async {
    try {
      final normalizedEmail = patientEmail.trim().toLowerCase();
      final lookup = await _firestore
          .collection(FirestoreConstants.userLookupCollection)
          .doc(normalizedEmail)
          .get();

      String? patientId;
      if (lookup.exists && lookup.data() != null) {
        final lookupData = lookup.data()!;
        if (lookupData[FirestoreConstants.fieldRole] != 'patient') {
          throw const AppException(
            'The account with this email is not a patient.',
          );
        }
        patientId = lookupData[FirestoreConstants.fieldUid] as String?;
      } else {
        // Compatibility path for patient profiles created before userLookup.
        final legacyPatients = await _firestore
            .collection(FirestoreConstants.usersCollection)
            .where(FirestoreConstants.fieldEmail, isEqualTo: normalizedEmail)
            .where(FirestoreConstants.fieldRole, isEqualTo: 'patient')
            .limit(1)
            .get();
        if (legacyPatients.docs.isNotEmpty) {
          patientId = legacyPatients.docs.first.id;
        }
      }

      if (patientId == null || patientId.isEmpty) {
        throw const AppException('No patient found with this email address.');
      }

      // Check if link already exists
      final existingLink = await _firestore
          .collection(FirestoreConstants.caregiverPatientLinksCollection)
          .where(FirestoreConstants.fieldCaregiverId, isEqualTo: caregiverId)
          .where(FirestoreConstants.fieldPatientId, isEqualTo: patientId)
          .get();

      if (existingLink.docs.isNotEmpty) {
        throw const AppException('Patient is already linked to your account.');
      }

      final docRef = _firestore
          .collection(FirestoreConstants.caregiverPatientLinksCollection)
          .doc('${caregiverId}_$patientId');

      await docRef.set({
        FirestoreConstants.fieldCaregiverId: caregiverId,
        FirestoreConstants.fieldPatientId: patientId,
        FirestoreConstants.fieldCreatedAt: FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw AppException.fromFirebaseException(e);
    }
  }
}
