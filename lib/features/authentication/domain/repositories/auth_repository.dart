import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/app_user.dart';

abstract class AuthRepository {
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

  Future<AppUser?> getCurrentUser();

  Future<String?> getUserRole(String uid);

  Stream<User?> get authStateChanges;
}
