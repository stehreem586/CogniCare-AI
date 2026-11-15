import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/emergency_contact.dart';
import '../models/health_profile.dart';
import '../models/user_profile.dart';

abstract class ProfileRemoteDataSource {
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

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore _firestore;

  ProfileRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserProfile?> getUserProfile({required String uid}) async {
    try {
      final doc = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(uid)
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
  Future<void> updateUserProfile({required UserProfile profile}) async {
    try {
      final targetUid = profile.uid.isNotEmpty
          ? profile.uid
          : FirebaseAuth.instance.currentUser?.uid;

      if (targetUid == null || targetUid.isEmpty) {
        throw const AppException('User ID is missing. Cannot update profile.');
      }

      final profileMap = profile.copyWith(uid: targetUid).toMap();
      profileMap['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(targetUid)
          .set(profileMap, SetOptions(merge: true));
    } catch (e) {
      throw AppException.fromFirebaseException(e);
    }
  }

  @override
  Future<HealthProfile?> getHealthProfile({required String uid}) async {
    try {
      final doc = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(uid)
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
  Future<void> updateHealthProfile({
    required String uid,
    required HealthProfile profile,
  }) async {
    try {
      await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(uid)
          .collection(FirestoreConstants.healthProfileSubcollection)
          .doc(FirestoreConstants.healthProfileDocId)
          .set(profile.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw AppException.fromFirebaseException(e);
    }
  }

  @override
  Future<List<EmergencyContact>> getEmergencyContacts({required String uid}) async {
    try {
      final snapshot = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(uid)
          .collection(FirestoreConstants.emergencyContactsSubcollection)
          .orderBy(FirestoreConstants.fieldCreatedAt, descending: true)
          .get();

      return snapshot.docs
          .map((doc) => EmergencyContact.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw AppException.fromFirebaseException(e);
    }
  }

  @override
  Stream<List<EmergencyContact>> streamEmergencyContacts({required String uid}) {
    return _firestore
        .collection(FirestoreConstants.usersCollection)
        .doc(uid)
        .collection(FirestoreConstants.emergencyContactsSubcollection)
        .orderBy(FirestoreConstants.fieldCreatedAt, descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EmergencyContact.fromMap(doc.data(), doc.id))
            .toList());
  }

  @override
  Future<void> addEmergencyContact({
    required String uid,
    required EmergencyContact contact,
  }) async {
    try {
      final docRef = _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(uid)
          .collection(FirestoreConstants.emergencyContactsSubcollection)
          .doc();

      final data = contact.copyWith(id: docRef.id, createdAt: DateTime.now()).toMap();
      await docRef.set(data);
    } catch (e) {
      throw AppException.fromFirebaseException(e);
    }
  }

  @override
  Future<void> updateEmergencyContact({
    required String uid,
    required EmergencyContact contact,
  }) async {
    try {
      await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(uid)
          .collection(FirestoreConstants.emergencyContactsSubcollection)
          .doc(contact.id)
          .update(contact.toMap());
    } catch (e) {
      throw AppException.fromFirebaseException(e);
    }
  }

  @override
  Future<void> deleteEmergencyContact({
    required String uid,
    required String contactId,
  }) async {
    try {
      await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(uid)
          .collection(FirestoreConstants.emergencyContactsSubcollection)
          .doc(contactId)
          .delete();
    } catch (e) {
      throw AppException.fromFirebaseException(e);
    }
  }
}
