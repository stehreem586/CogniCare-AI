import 'package:flutter/material.dart';

import 'app/theme.dart';
import 'core/firebase/firebase_initializer.dart';
import 'features/adaptive_therapy/assessment_module.dart';

/// Standalone entry for Adaptive Therapy (Module 3).
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeCogniCareFirebase();
  runApp(const AdaptiveTherapyPreviewApp());
}

class AdaptiveTherapyPreviewApp extends StatelessWidget {
  const AdaptiveTherapyPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CogniCare AI — Adaptive Therapy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AssessmentModule(),
    );
  }
}
