import 'package:flutter/material.dart';
import 'app/theme.dart';
import 'features/adaptive_therapy/adaptive_therapy_module.dart';

/// Standalone entry for Adaptive Therapy (Module 3) frontend.
/// Run with: flutter run -t lib/therapy_main.dart
/// This does not initialize Firebase — backend comes later.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: const AdaptiveTherapyModule(),
    );
  }
}
