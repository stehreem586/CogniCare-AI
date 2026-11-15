import 'package:flutter_test/flutter_test.dart';

import 'package:cognicare_ai/app/app.dart';
import 'package:cognicare_ai/features/authentication/presentation/screens/splash_screen.dart';

void main() {
  testWidgets('CogniCare starts on the splash screen', (tester) async {
    await tester.pumpWidget(const CogniCareApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(SplashScreen), findsOneWidget);
  });
}