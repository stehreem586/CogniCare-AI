import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F7CF6)),
      scaffoldBackgroundColor: const Color(0xFFF5F8FC),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF5F8FC),
        elevation: 0,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Color(0xFF25415B)),
      ),
    );
  }
}
