import 'package:firebase_auth/firebase_auth.dart';
import '../features/authentication/data/models/app_user.dart';
import '../features/authentication/domain/repositories/auth_repository.dart';
import '../features/authentication/data/repositories/auth_repository_impl.dart';

class AuthStateService {
  final AuthRepository _authRepository;
  AppUser? _currentUserProfile;

  AuthStateService({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepositoryImpl();

  static final AuthStateService instance = AuthStateService();

  User? get currentFirebaseUser => FirebaseAuth.instance.currentUser;
  AppUser? get currentUserProfile => _currentUserProfile;
  bool get isAuthenticated => currentFirebaseUser != null;

  Stream<User?> get authStateChanges => _authRepository.authStateChanges;

  Future<AppUser?> loadCurrentUser() async {
    _currentUserProfile = await _authRepository.getCurrentUser();
    return _currentUserProfile;
  }

  void setCurrentUser(AppUser? user) {
    _currentUserProfile = user;
  }

  Future<void> logout() async {
    await _authRepository.signOut();
    _currentUserProfile = null;
  }
}
