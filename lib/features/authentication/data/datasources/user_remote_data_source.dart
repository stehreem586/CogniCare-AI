import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/app_user.dart';

abstract class UserRemoteDataSource {
  Future<void> createUserProfile(AppUser user);
  Future<AppUser?> getUserById(String uid);
  Future<String?> getUserRole(String uid);
  Future<void> updateUserProfile(AppUser user);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final FirebaseFirestore _firestore;

  UserRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> createUserProfile(AppUser user) async {
    try {
      final userMap = user.toMap();
      userMap['createdAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(user.uid)
          .set(userMap, SetOptions(merge: true));

      // Keep the email lookup separate from the protected user profile. This
      // lets a caregiver find a patient without exposing patient documents.
      await _firestore
          .collection(FirestoreConstants.userLookupCollection)
          .doc(user.email.trim().toLowerCase())
          .set({
            FirestoreConstants.fieldUid: user.uid,
            FirestoreConstants.fieldEmail: user.email.trim().toLowerCase(),
            FirestoreConstants.fieldRole: user.role,
          }, SetOptions(merge: true));

      // If patient, initialize default empty health profile document
      if (user.role == 'patient') {
        await _firestore
            .collection(FirestoreConstants.usersCollection)
            .doc(user.uid)
            .collection(FirestoreConstants.healthProfileSubcollection)
            .doc(FirestoreConstants.healthProfileDocId)
            .set({
              FirestoreConstants.fieldDementiaStage: 'Mild',
              FirestoreConstants.fieldMedicalHistory: '',
              FirestoreConstants.fieldCareNotes: '',
              FirestoreConstants.fieldUpdatedAt: FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Firestore error during profile creation: $e');
      throw AppException.fromFirebaseException(e);
    }
  }

  @override
  Future<AppUser?> getUserById(String uid) async {
    try {
      final doc = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(uid)
          .get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }
      final appUser = AppUser.fromMap(doc.data()!, doc.id);

      // Backfill the lookup entry for accounts created before the lookup
      // collection was introduced.
      await _firestore
          .collection(FirestoreConstants.userLookupCollection)
          .doc(appUser.email.trim().toLowerCase())
          .set({
            FirestoreConstants.fieldUid: appUser.uid,
            FirestoreConstants.fieldEmail: appUser.email.trim().toLowerCase(),
            FirestoreConstants.fieldRole: appUser.role,
          }, SetOptions(merge: true));

      return appUser;
    } catch (e) {
      throw AppException.fromFirebaseException(e);
    }
  }

  @override
  Future<String?> getUserRole(String uid) async {
    try {
      final doc = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(uid)
          .get();

      if (doc.exists && doc.data() != null) {
        return doc.data()![FirestoreConstants.fieldRole] as String?;
      }
      return null;
    } catch (e) {
      throw AppException.fromFirebaseException(e);
    }
  }

  @override
  Future<void> updateUserProfile(AppUser user) async {
    try {
      final targetUid = user.uid.isNotEmpty
          ? user.uid
          : FirebaseAuth.instance.currentUser?.uid;

      if (targetUid == null || targetUid.isEmpty) {
        throw const AppException(
          'User ID is missing. Cannot update user profile.',
        );
      }

      final userMap = user.copyWith(uid: targetUid).toMap();
      userMap['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(targetUid)
          .set(userMap, SetOptions(merge: true));
    } catch (e) {
      throw AppException.fromFirebaseException(e);
    }
  }
}
