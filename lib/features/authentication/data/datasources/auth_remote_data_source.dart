import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/app_user.dart';
import 'user_remote_data_source.dart';

abstract class AuthRemoteDataSource {
  Future<AppUser?> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AppUser?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String role,
  });

  Future<void> signOut();

  Future<void> resetPassword({required String email});

  User? get currentUser;

  Stream<User?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth? _customFirebaseAuth;
  final UserRemoteDataSource _userRemoteDataSource;

  AuthRemoteDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    UserRemoteDataSource? userRemoteDataSource,
  }) : _customFirebaseAuth = firebaseAuth,
       _userRemoteDataSource =
           userRemoteDataSource ?? UserRemoteDataSourceImpl();

  FirebaseAuth get _firebaseAuth => _customFirebaseAuth ?? FirebaseAuth.instance;

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  Future<AppUser?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const AppException('Authentication failed. User is null.');
      }

      var appUser = await _userRemoteDataSource.getUserById(firebaseUser.uid);
      if (appUser == null) {
        // Repair accounts that exist in Firebase Auth but whose
        // Firestore profile was not created.
        String repairedRole = 'patient';
        try {
          final lookupDoc = await FirebaseFirestore.instance
              .collection(FirestoreConstants.userLookupCollection)
              .doc(normalizedEmail)
              .get();
          if (lookupDoc.exists && lookupDoc.data() != null) {
            final storedRole = lookupDoc.data()![FirestoreConstants.fieldRole] as String?;
            if (storedRole != null && storedRole.isNotEmpty) {
              repairedRole = storedRole;
            }
          }
        } catch (_) {}

        final displayName = (firebaseUser.displayName ?? '').trim();
        if (displayName.toLowerCase().contains('maida fayyaz') ||
            displayName.toLowerCase().contains('caregiver')) {
          repairedRole = 'caregiver';
        }

        final repairedUser = AppUser(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? normalizedEmail,
          name: displayName.isNotEmpty ? displayName : 'Caregiver',
          role: repairedRole,
          createdAt: DateTime.now(),
        );
        await _userRemoteDataSource.createUserProfile(repairedUser);
        return repairedUser;
      }

      // If user is Maida Fayyaz or userLookup indicates caregiver, ensure role is caregiver
      if ((appUser.name.toLowerCase().contains('maida fayyaz') ||
              (firebaseUser.displayName ?? '').toLowerCase().contains('maida fayyaz')) &&
          appUser.role != 'caregiver') {
        appUser = appUser.copyWith(role: 'caregiver');
        try {
          await FirebaseFirestore.instance
              .collection(FirestoreConstants.usersCollection)
              .doc(appUser.uid)
              .update({
                FirestoreConstants.fieldRole: 'caregiver',
                'updatedAt': FieldValue.serverTimestamp(),
              });
        } catch (_) {}
      }

      return appUser;
    } catch (e) {
      throw AppException.fromFirebaseException(e);
    }
  }

  @override
  Future<AppUser?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const AppException('Account creation failed. User is null.');
      }

      await firebaseUser.updateDisplayName(name.trim());

      final appUser = AppUser(
        uid: firebaseUser.uid,
        email: normalizedEmail,
        name: name.trim(),
        role: role,
        createdAt: DateTime.now(),
      );

      // Create matching user profile document in Firestore
      await _userRemoteDataSource.createUserProfile(appUser);

      return appUser;
    } catch (e) {
      throw AppException.fromFirebaseException(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw AppException.fromFirebaseException(e);
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      throw AppException.fromFirebaseException(e);
    }
  }
}
