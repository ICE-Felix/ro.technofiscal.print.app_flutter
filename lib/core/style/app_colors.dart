import 'package:flutter/material.dart';

class AppColors {
  // Kiosk Design System - Primary Colors
  static const Color kioskBlue = Color(0xFF2563EB); // Primary blue
  static const Color kioskGreen = Color(0xFF10B981); // Success/confirmation
  static const Color kioskRed = Color(0xFFEF4444); // Error/warning
  static const Color kioskYellow = Color(0xFFF59E0B); // Warning/attention

  // Gray Scale (matching Tailwind CSS gray palette)
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray900 = Color(0xFF111827);

  // Background Colors
  static const Color lightBackground = gray50;
  static const Color darkBackground = Color(0xFF4D217B);

  // Primary colors - using kiosk blue as primary
  static const Color primary = kioskBlue;
  static const Color secondary = kioskGreen;
  static const Color error = kioskRed;
  static const Color success = kioskGreen;
  static const Color warning = kioskYellow;
  static const Color info = kioskBlue;

  // Light theme colors
  static const Color background = lightBackground;
  static const Color surface = Colors.white;
  static const Color onSurface = gray900;
  static const Color onBackground = gray900;
  static const Color border = gray200;
  static const Color borderDark = gray300;

  // Text colors
  static const Color textPrimary = gray900;
  static const Color textSecondary = gray600;
  static const Color textTertiary = gray500;

  // Component colors
  static const Color cardBackground = Colors.white;
  static const Color inputBackground = Colors.white;
  static const Color buttonPrimary = kioskBlue;
  static const Color buttonSecondary = gray100;

  // State colors (matching kiosk design)
  static const Color blue50 = Color(0xFFEFF6FF);
  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color green50 = Color(0xFFF0FDF4);
  static const Color red50 = Color(0xFFFEF2F2);
  static const Color yellow50 = Color(0xFFFFFBEB);

  // Dark theme colors (legacy - keeping for compatibility)
  static const Color darkSurface = Color(0xFF6B4099);
  static const Color onDarkSurface = Colors.white;
  static const Color onDarkBackground = Colors.white;
  static const Color darkBorder = Color(0xFF8B5FBF);

  // Additional background variants for flexibility
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color purpleAccent = Color(0xFF8B5FBF);
}
