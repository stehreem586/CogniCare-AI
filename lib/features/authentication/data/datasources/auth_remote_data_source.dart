import 'package:firebase_auth/firebase_auth.dart';
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
  final FirebaseAuth _firebaseAuth;
  final UserRemoteDataSource _userRemoteDataSource;

  AuthRemoteDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    UserRemoteDataSource? userRemoteDataSource,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _userRemoteDataSource = userRemoteDataSource ?? UserRemoteDataSourceImpl();

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
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const AppException('Authentication failed. User is null.');
      }

      final appUser = await _userRemoteDataSource.getUserById(firebaseUser.uid);
      if (appUser == null) {
        // Fallback user if Firestore record wasn't created yet
        return AppUser(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? email,
          name: firebaseUser.displayName ?? '',
          role: 'patient',
          createdAt: DateTime.now(),
        );
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
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const AppException('Account creation failed. User is null.');
      }

      await firebaseUser.updateDisplayName(name.trim());

      final appUser = AppUser(
        uid: firebaseUser.uid,
        email: email.trim(),
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
