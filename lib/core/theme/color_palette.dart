import 'package:flutter/material.dart';

class AppColors {
  // Dark Theme Colors (Current)
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkGray = Color(0xFF202327);
  static const Color midGray = Color(0xFF536471);
  static const Color lightGray = Color(0xFFD6D9DB);
  
  // Light Theme Colors
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF7F9FA);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF0F1419);
  static const Color lightTextSecondary = Color(0xFF536471);
  static const Color lightBorder = Color(0xFFEFF3F4);
  
  // Accent color (Twitter-like blue)
  static const Color blue = Color(0xFF1D9BF0);
  static const Color blueHighlight = Color(0xFF1A8CD8);
  static const Color blueDisabled = Color(0x801D9BF0); // 50% opacity = 0x80
  
  // Theme-dependent colors
  static Color backgroundColor(bool isDark) => isDark ? black : lightBackground;
  static Color surfaceColor(bool isDark) => isDark ? Color(0xFF15181C) : lightSurface;
  static Color cardColor(bool isDark) => isDark ? Color(0xFF202327) : lightCard;
  static Color textPrimary(bool isDark) => isDark ? white : lightText;
  static Color textSecondary(bool isDark) => isDark ? Color(0xFF71767B) : lightTextSecondary; // Better contrast for dark mode
  static Color borderColor(bool isDark) => isDark ? Color(0xFF2F3336) : lightBorder;
  
  // Feedback colors
  static const Color success = Color(0xFF00CB6A);
  static const Color error = Color(0xFFF91880);
  static const Color warning = Color(0xFFF7B955);
  static const Color info = Color(0xFF1D9BF0);
  
  // Disabled text color
  static const Color textDisabled = Color(0x80536471); // 50% opacity
  
  // Overlay colors
  static const Color overlay = Color(0x6615181C); // Already using alpha = 0x66
}
