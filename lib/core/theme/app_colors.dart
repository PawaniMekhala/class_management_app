import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(
    0xFF3D5AFE,
  ); // ocean teal (buttons, app bar, links)
  static const Color secondary = Color(
    0xFF2196F3,
  ); // sea green (accents, chips, FAB)

  // Extras from the logo
  static const Color primaryDark = Color(
    0xFF64B5F6,
  ); // deep teal (pressed states, headers)
  static const Color primaryLight = Color(
    0xFF11A2AB,
  ); // turquoise (icons, highlights)
  static const Color accent = Color(
    0xFF6DC775,
  ); // fresh green (badges, progress)

  static const Color background = Color(
    0xFFF4F8F7,
  ); // soft teal-tinted off-white
  static const Color surface = Colors.white;

  static const Color textPrimary = Color(0xFF0D424C);
  static const Color textSecondary = Color(0xFF5B7C82);

  static const Color border = Color(0xFFD5E5E3);

  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF2E9E5B);

  // Logo-style gradient (splash screen, headers, hero cards)
  static const LinearGradient brandGradient = LinearGradient(
    colors: [
      Color(0xFF0F7A8D),
      Color(0xFF11A2AB),
      Color(0xFF3EB393),
      Color(0xFF6DC775),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Authentication screens (Sign In, Register, Change Password)
  static const Color authBackground = Color(0xFFF4F5FC);
  static const Color authFieldBackground = Color(0xFFFFFFFF);
  static const Color authFieldBorder = Color(0xFFE2E8F0);
  static const Color authIcon = Color(0xFF7E8AA8);
  static const Color authHint = Color(0xFF929BB2);
  static const Color authHeading = Color(0xFF293B78);
}
