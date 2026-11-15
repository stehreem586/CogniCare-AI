import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/user_remote_data_source.dart';
import '../models/app_user.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _authRemoteDataSource;
  final UserRemoteDataSource _userRemoteDataSource;

  AuthRepositoryImpl({
    AuthRemoteDataSource? authRemoteDataSource,
    UserRemoteDataSource? userRemoteDataSource,
  })  : _authRemoteDataSource = authRemoteDataSource ?? AuthRemoteDataSourceImpl(),
        _userRemoteDataSource = userRemoteDataSource ?? UserRemoteDataSourceImpl();

  @override
  Stream<User?> get authStateChanges => _authRemoteDataSource.authStateChanges;

  @override
  Future<AppUser?> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _authRemoteDataSource.signInWithEmail(
      email: email,
      password: password,
    );
  }

  @override
  Future<AppUser?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String role,
  }) {
    return _authRemoteDataSource.signUpWithEmail(
      email: email,
      password: password,
      name: name,
      role: role,
    );
  }

  @override
  Future<void> signOut() {
    return _authRemoteDataSource.signOut();
  }

  @override
  Future<void> resetPassword({required String email}) {
    return _authRemoteDataSource.resetPassword(email: email);
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final firebaseUser = _authRemoteDataSource.currentUser;
    if (firebaseUser == null) {
      return null;
    }
    return _userRemoteDataSource.getUserById(firebaseUser.uid);
  }

  @override
  Future<String?> getUserRole(String uid) {
    return _userRemoteDataSource.getUserRole(uid);
  }
}
