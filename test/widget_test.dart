import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cognicare_ai/core/constants/role_constants.dart';
import 'package:cognicare_ai/features/authentication/presentation/widgets/role_selector.dart';

void main() {
  testWidgets('RoleSelector renders Patient and Caregiver cards', (WidgetTester tester) async {
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
