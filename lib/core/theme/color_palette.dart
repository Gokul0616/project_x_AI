import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkGray = Color(0xFF202327);
  static const Color midGray = Color(0xFF536471);
  static const Color lightGray = Color(0xFFD6D9DB);

  // Accent color (Twitter-like blue)
  static const Color blue = Color(0xFF1D9BF0);
  static const Color blueHighlight = Color(0xFF1A8CD8);
  static const Color blueDisabled = Color(0x801D9BF0);

  // Dark Theme Colors
  static const Color darkBackground = black;
  static const Color darkSurface = Color(0xFF15181C);
  static const Color darkCard = Color(0xFF202327);
  static const Color darkBorder = Color(0xFF2F3336);
  static const Color darkTextPrimary = white;
  static const Color darkTextSecondary = midGray;

  // Light Theme Colors
  static const Color lightBackground = white;
  static const Color lightSurface = Color(0xFFF7F9FA);
  static const Color lightCard = white;
  static const Color lightBorder = Color(0xFFE1E8ED);
  static const Color lightTextPrimary = Color(0xFF14171A);
  static const Color lightTextSecondary = Color(0xFF657786);

  // Context-aware colors
  static Color backgroundColor(bool isDark) =>
      isDark ? darkBackground : lightBackground;
  static Color surfaceColor(bool isDark) => isDark ? darkSurface : lightSurface;
  static Color cardColor(bool isDark) => isDark ? darkCard : lightCard;
  static Color borderColor(bool isDark) => isDark ? darkBorder : lightBorder;
  static Color textPrimary(bool isDark) =>
      isDark ? darkTextPrimary : lightTextPrimary;
  static Color textSecondary(bool isDark) =>
      isDark ? darkTextSecondary : lightTextSecondary;

  // Legacy compatibility (can be removed later)
  static const Color backgroundColor1 = darkBackground;
  static const Color surfaceColor1 = darkSurface;
  static const Color cardColor1 = darkCard;
  static const Color textPrimary1 = darkTextPrimary;
  static const Color textSecondary1 = darkTextSecondary;
  static const Color borderColor1 = darkBorder;

  // Feedback colors (same for both themes)
  static const Color success = Color(0xFF00CB6A);
  static const Color error = Color(0xFFF91880);
  static const Color warning = Color(0xFFF7B955);
  static const Color info = Color(0xFF1D9BF0);

  // Text colors (legacy)
  static const Color textDisabled = Color(0x80536471);

  // Overlay colors
  static const Color overlay = Color(0x6615181C);
}
