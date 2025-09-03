import 'package:flutter/material.dart';
import 'color_palette.dart';
import 'text_theme.dart';

class AppTheme {
  static ThemeData getTheme(BuildContext context, bool isDark) {
    final baseTheme = isDark ? ThemeData.dark() : ThemeData.light();

    return baseTheme.copyWith(
      scaffoldBackgroundColor: AppColors.backgroundColor(isDark),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundColor(isDark),
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary(isDark)),
        titleTextStyle: AppTextTheme.getCustomText(
          context,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.blue,
          textStyle: AppTextTheme.getButtonStyle(
            context,
            size: ButtonSize.medium,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blue,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.blueDisabled,
          disabledForegroundColor: AppColors.white.withOpacity(0.5),
          textStyle: AppTextTheme.getButtonStyle(
            context,
            size: ButtonSize.large,
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.blue,
          textStyle: AppTextTheme.getButtonStyle(
            context,
            size: ButtonSize.medium,
          ),
          side: const BorderSide(color: AppColors.blue, width: 1),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceColor(isDark),
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.blue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: AppTextTheme.getCustomText(
          context,
          fontSize: 17,
          color: AppColors.textSecondary(isDark),
        ),
        labelStyle: AppTextTheme.getCustomText(
          context,
          fontSize: 17,
          color: AppColors.textPrimary(isDark),
        ),
        errorStyle: AppTextTheme.getCustomText(
          context,
          fontSize: 14,
          color: AppColors.error,
        ),
      ),
      colorScheme:
          (isDark ? const ColorScheme.dark() : const ColorScheme.light())
              .copyWith(
                primary: AppColors.blue,
                secondary: AppColors.blueHighlight,
                surface: AppColors.surfaceColor(isDark),
                error: AppColors.error,
              ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceColor(isDark),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.borderColor(isDark), width: 1),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.borderColor(isDark),
        thickness: 0.5,
        space: 0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.backgroundColor(isDark),
        selectedItemColor: AppColors.blue,
        unselectedItemColor: AppColors.textSecondary(isDark),
        elevation: 0,
      ),
      textTheme: AppTextTheme.getTextTheme(context),
    );
  }
}
