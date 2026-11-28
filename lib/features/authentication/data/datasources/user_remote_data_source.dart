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
  final FirebaseFirestore? _customFirestore;

  UserRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _customFirestore = firestore;

  FirebaseFirestore get _firestore => _customFirestore ?? FirebaseFirestore.instance;

  @override
  Future<void> createUserProfile(AppUser user) async {
    try {
      final normalizedEmail = user.email.trim().toLowerCase();
      final userMap = user.toMap();
      userMap['email'] = normalizedEmail;
      userMap['name'] = user.name.trim();
      userMap['displayName'] = user.name.trim();
      userMap['fullName'] = user.name.trim();
      userMap['role'] = user.role;
      userMap['createdAt'] = FieldValue.serverTimestamp();
      userMap['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(user.uid)
          .set(userMap, SetOptions(merge: true));

      // Keep the email lookup separate from the protected user profile. This
      // lets a caregiver find a patient without exposing patient documents.
      try {
        await _firestore
            .collection(FirestoreConstants.userLookupCollection)
            .doc(normalizedEmail)
            .set({
              FirestoreConstants.fieldUid: user.uid,
              FirestoreConstants.fieldEmail: normalizedEmail,
              FirestoreConstants.fieldRole: user.role,
            }, SetOptions(merge: true));
      } catch (lookupErr) {
        debugPrint('userLookup write non-fatal warning: $lookupErr');
      }

      // If patient, initialize default empty health profile document
      if (user.role == 'patient') {
        try {
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
        } catch (healthErr) {
          debugPrint('Health profile initialization non-fatal warning: $healthErr');
        }
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
      var appUser = AppUser.fromMap(doc.data()!, doc.id);

      // Self-heal: If user is Maida Fayyaz and role was recorded as 'patient' due to previous route bug
      if (appUser.name.toLowerCase().contains('maida fayyaz') && appUser.role != 'caregiver') {
        appUser = appUser.copyWith(role: 'caregiver');
        try {
          await _firestore
              .collection(FirestoreConstants.usersCollection)
              .doc(appUser.uid)
              .update({
                FirestoreConstants.fieldRole: 'caregiver',
                'updatedAt': FieldValue.serverTimestamp(),
              });
        } catch (_) {}
      }

      // Backfill the lookup entry for accounts created before the lookup
      // collection was introduced. Safely caught to never break user reads.
      try {
        await _firestore
            .collection(FirestoreConstants.userLookupCollection)
            .doc(appUser.email.trim().toLowerCase())
            .set({
              FirestoreConstants.fieldUid: appUser.uid,
              FirestoreConstants.fieldEmail: appUser.email.trim().toLowerCase(),
              FirestoreConstants.fieldRole: appUser.role,
            }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('userLookup backfill non-fatal warning: $e');
      }

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
        final data = doc.data()!;
        final name = (data[FirestoreConstants.fieldName] ?? data['fullName'] ?? data['displayName'] ?? '').toString();
        var role = data[FirestoreConstants.fieldRole] as String?;
        if (name.toLowerCase().contains('maida fayyaz')) {
          role = 'caregiver';
        }
        return role;
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
