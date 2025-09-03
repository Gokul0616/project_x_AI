import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'color_palette.dart';

class AppTextTheme {
  static TextTheme getTextTheme(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary(isDark),
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary(isDark),
        letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary(isDark),
        letterSpacing: -0.5,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary(isDark),
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary(isDark),
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary(isDark),
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary(isDark),
        height: 1.4,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary(isDark),
        height: 1.4,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary(isDark),
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary(isDark),
      ),
    );
  }

  static TextStyle getCustomText(
    BuildContext context, {
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double letterSpacing = 0,
    double height = 1.2,
    TextDecoration decoration = TextDecoration.none,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppColors.textPrimary(isDark),
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
    );
  }

  static TextStyle getButtonStyle(
    BuildContext context, {
    required ButtonSize size,
    Color? color,
  }) {
    final fontSize = switch (size) {
      ButtonSize.large => 17.0,
      ButtonSize.medium => 15.0,
      ButtonSize.small => 13.0,
    };

    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      color: color ?? AppColors.white,
    );
  }
}

enum ButtonSize { large, medium, small }
