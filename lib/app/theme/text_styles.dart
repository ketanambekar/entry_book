import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static TextTheme textTheme(Color color) {
    // Use local Poppins font with Google Fonts as fallback
    final base = GoogleFonts.poppinsTextTheme();
    return base.copyWith(
      headlineMedium: base.headlineMedium?.copyWith(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w700,
        color: color,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        color: color,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontFamily: 'Poppins',
        color: color,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontFamily: 'Poppins',
        color: color,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }
}
