import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

extension AppTextTheme on TextTheme {
  TextTheme get poppinsTextTheme => copyWith(
    displayLarge: GoogleFonts.poppins(textStyle: displayLarge),
    displayMedium: GoogleFonts.poppins(textStyle: displayMedium),
    displaySmall: GoogleFonts.poppins(textStyle: displaySmall),
    headlineLarge: GoogleFonts.poppins(textStyle: headlineLarge),
    headlineMedium: GoogleFonts.poppins(textStyle: headlineMedium),
    headlineSmall: GoogleFonts.poppins(textStyle: headlineSmall),
    titleLarge: GoogleFonts.poppins(textStyle: titleLarge),
    titleMedium: GoogleFonts.poppins(textStyle: titleMedium),
    titleSmall: GoogleFonts.poppins(textStyle: titleSmall),
    bodyLarge: GoogleFonts.poppins(textStyle: bodyLarge),
    bodyMedium: GoogleFonts.poppins(textStyle: bodyMedium),
    bodySmall: GoogleFonts.poppins(textStyle: bodySmall),
    labelLarge: GoogleFonts.poppins(textStyle: labelLarge),
    labelMedium: GoogleFonts.poppins(textStyle: labelMedium),
    labelSmall: GoogleFonts.poppins(textStyle: labelSmall),
  );
}

@Deprecated('Use Theme.of(context).textTheme instead')
class TextStyles {
  @Deprecated('Use Theme.of(context).textTheme.displayLarge instead')
  static final TextStyle displayLarge = GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  @Deprecated('Use Theme.of(context).textTheme.displayMedium instead')
  static final TextStyle displayMedium = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  @Deprecated('Use Theme.of(context).textTheme.displaySmall instead')
  static final TextStyle displaySmall = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  @Deprecated('Use Theme.of(context).textTheme.titleLarge instead')
  static final TextStyle titleLarge = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  @Deprecated('Use Theme.of(context).textTheme.titleMedium instead')
  static final TextStyle titleMedium = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  @Deprecated('Use Theme.of(context).textTheme.titleSmall instead')
  static final TextStyle titleSmall = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  @Deprecated('Use Theme.of(context).textTheme.bodyLarge instead')
  static final TextStyle bodyLarge = GoogleFonts.poppins(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  @Deprecated('Use Theme.of(context).textTheme.bodyMedium instead')
  static final TextStyle bodyMedium = GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  @Deprecated('Use Theme.of(context).textTheme.bodySmall instead')
  static final TextStyle bodySmall = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  @Deprecated('Use Theme.of(context).textTheme.labelSmall instead')
  static final TextStyle caption = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  @Deprecated('Use Theme.of(context).textTheme.labelLarge instead')
  static final TextStyle buttonLarge = GoogleFonts.poppins(
    fontSize: 17,
    fontWeight: FontWeight.w700,
  );

  @Deprecated('Use Theme.of(context).textTheme.labelMedium instead')
  static final TextStyle buttonMedium = GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );

  @Deprecated('Use Theme.of(context).textTheme.labelSmall instead')
  static final TextStyle buttonSmall = GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );

  @Deprecated(
    'Use Theme.of(context).textTheme and modify the style using copyWith instead',
  )
  static TextStyle customText({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double letterSpacing = 0,
    double height = 1.2,
    TextDecoration decoration = TextDecoration.none,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
    );
  }
}
