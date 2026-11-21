import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Light Theme Colors (from Master Prompt Section 5)
  static const Color lightBackground = Color(0xFFF5F7FA);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightPrimary = Color(0xFF387A36);
  static const Color lightTextPrimary = Color(0xFF172033);
  static const Color lightTextSecondary = Color(0xFF596579);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightSurfaceVariant = Color(0xFFEDF2F7);

  // Dark Theme Colors (from Master Prompt Section 5)
  static const Color darkBackground = Color(0xFF111827);
  static const Color darkCard = Color(0xFF1B2433);
  static const Color darkPrimary = Color(0xFFB7F36B);
  static const Color darkPrimaryContainer = Color(0xFF225420);
  static const Color darkTextPrimary = Color(0xFFF3F4F6);
  static const Color darkTextSecondary = Color(0xFFA7B0C0);
  static const Color darkBorder = Color(0xFF2D3748);
  static const Color darkSurfaceVariant = Color(0xFF232D3F);

  // Semantic Colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Nutrition Macro Colors
  static const Color protein = Color(0xFF3B82F6); // Blue
  static const Color carbs = Color(0xFFF59E0B);   // Amber
  static const Color fat = Color(0xFFEC4899);     // Rose
}
