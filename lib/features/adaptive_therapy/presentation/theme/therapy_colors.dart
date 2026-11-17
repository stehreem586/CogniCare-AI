import 'package:flutter/material.dart';

/// Visual tokens for Adaptive Therapy (Module 3) only.
class TherapyColors {
  TherapyColors._();

  static const Color navy = Color(0xFF123A63);
  static const Color navySoft = Color(0xFF1A4A7A);
  static const Color primary = Color(0xFF2B9FE0);
  static const Color primaryDark = Color(0xFF1A86C8);
  static const Color teal = Color(0xFF2EC4A0);
  static const Color tealDark = Color(0xFF1DB978);
  static const Color text = Color(0xFF1E3A5F);
  static const Color muted = Color(0xFF7A90A8);
  static const Color body = Color(0xFF5B738C);
  static const Color border = Color(0xFFE6EEF6);
  static const Color bgTop = Color(0xFFF3F8FD);
  static const Color bgBottom = Color(0xFFFFFFFF);
  static const Color cardMint = Color(0xFFECF8F4);
  static const Color cardBlue = Color(0xFFECF5FC);
  static const Color cardPurple = Color(0xFFF4ECFB);
  static const Color cardPeach = Color(0xFFFFF4E5);
  static const Color cardPink = Color(0xFFFDECF2);
  static const Color cardYellow = Color(0xFFFFF6D8);
}

class TherapyGradients {
  TherapyGradients._();

  static const LinearGradient page = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [TherapyColors.bgTop, Color(0xFFF8FBFE), TherapyColors.bgBottom],
    stops: [0, 0.35, 1],
  );

  static const LinearGradient primaryButton = LinearGradient(
    colors: [Color(0xFF2BB0E8), Color(0xFF1A86C8)],
  );
}
