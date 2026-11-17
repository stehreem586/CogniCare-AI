
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cognicare_ai/app/app.dart';
import 'package:cognicare_ai/core/constants/role_constants.dart';
import 'package:cognicare_ai/features/authentication/presentation/screens/splash_screen.dart';
import 'package:cognicare_ai/features/authentication/presentation/widgets/role_selector.dart';

void main() {
  testWidgets('CogniCare starts on the splash screen', (tester) async {
    await tester.pumpWidget(const CogniCareApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(SplashScreen), findsOneWidget);
  });

  testWidgets('RoleSelector renders Patient and Caregiver cards', (
    WidgetTester tester,
  ) async {
    UserRole selectedRole = UserRole.patient;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RoleSelector(
            selectedRole: selectedRole,
            onRoleChanged: (role) {
              selectedRole = role;
            },
          ),
        ),
      ),
    );

    expect(find.text('Select Your Role'), findsOneWidget);
    expect(find.text('Patient'), findsOneWidget);
    expect(find.text('Caregiver'), findsOneWidget);
  });
}
