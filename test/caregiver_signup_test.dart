import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cognicare_ai/app/routes.dart';
import 'package:cognicare_ai/core/constants/role_constants.dart';
import 'package:cognicare_ai/core/widgets/app_button.dart';
import 'package:cognicare_ai/features/authentication/data/models/app_user.dart';
import 'package:cognicare_ai/features/authentication/domain/repositories/auth_repository.dart';
import 'package:cognicare_ai/features/authentication/presentation/screens/signup_screen.dart';
import 'package:cognicare_ai/features/authentication/presentation/widgets/role_selector.dart';

class MockAuthRepository implements AuthRepository {
  String? lastSignedUpRole;
  String? lastSignedUpName;
  String? lastSignedUpEmail;

  @override
  Stream<User?> get authStateChanges => const Stream.empty();

  @override
  Future<AppUser?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    lastSignedUpEmail = email;
    lastSignedUpName = name;
    lastSignedUpRole = role;
    return AppUser(
      uid: 'caregiver_123',
      email: email,
      name: name,
      role: role,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<AppUser?> signInWithEmail({
    required String email,
    required String password,
  }) async => null;

  @override
  Future<void> signOut() async {}

  @override
  Future<void> resetPassword({required String email}) async {}

  @override
  Future<AppUser?> getCurrentUser() async => null;

  @override
  Future<String?> getUserRole(String uid) async => lastSignedUpRole ?? 'caregiver';
}

void main() {
  testWidgets('SignupScreen adopts Caregiver role from route arguments', (tester) async {
    final mockAuth = MockAuthRepository();

    await tester.pumpWidget(
      MaterialApp(
        initialRoute: '/starter',
        routes: {
          '/starter': (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.signup,
                      arguments: UserRole.caregiver,
                    );
                  },
                  child: const Text('Go To Signup'),
                ),
              ),
          AppRoutes.signup: (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            UserRole? initialRole;
            if (args is UserRole) {
              initialRole = args;
            } else if (args is String) {
              initialRole = UserRole.fromString(args);
            }
            return SignupScreen(
              initialRole: initialRole,
              authRepository: mockAuth,
            );
          },
        },
      ),
    );
    await tester.pumpAndSettle();

    // Tap button to navigate with arguments
    await tester.tap(find.text('Go To Signup'));
    await tester.pumpAndSettle();

    expect(find.byType(SignupScreen), findsOneWidget);

    // Verify RoleSelector is present and Caregiver is highlighted
    final roleSelectorFinder = find.byType(RoleSelector);
    expect(roleSelectorFinder, findsOneWidget);
    final roleSelector = tester.widget<RoleSelector>(roleSelectorFinder);
    expect(roleSelector.selectedRole, equals(UserRole.caregiver));
  });

  testWidgets('Caregiver signup creates user with role caregiver for Maida Fayyaz', (tester) async {
    final mockAuth = MockAuthRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: SignupScreen(
          initialRole: UserRole.caregiver,
          authRepository: mockAuth,
        ),
        routes: {
          AppRoutes.caregiverDashboard: (context) => const Scaffold(
                body: Text('Caregiver Dashboard View'),
              ),
          AppRoutes.adaptiveTherapy: (context) => const Scaffold(
                body: Text('Patient Therapy View'),
              ),
        },
      ),
    );
    await tester.pumpAndSettle();

    final textFields = find.byType(TextFormField);
    expect(textFields, findsNWidgets(5));

    // Fill form
    await tester.enterText(textFields.at(0), 'Maida Fayyaz');
    await tester.enterText(textFields.at(1), 'maida.fayyaz@example.com');
    await tester.enterText(textFields.at(2), '03001234567');
    await tester.enterText(textFields.at(3), 'Password123!');
    await tester.enterText(textFields.at(4), 'Password123!');

    await tester.pumpAndSettle();

    // Tap AppButton with ensureVisible
    final buttonFinder = find.byType(AppButton);
    expect(buttonFinder, findsOneWidget);
    await tester.ensureVisible(buttonFinder);
    await tester.pumpAndSettle();
    await tester.tap(buttonFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();

    expect(mockAuth.lastSignedUpName, equals('Maida Fayyaz'));
    expect(mockAuth.lastSignedUpRole, equals('caregiver'));
    expect(mockAuth.lastSignedUpEmail, equals('maida.fayyaz@example.com'));
  });
}
