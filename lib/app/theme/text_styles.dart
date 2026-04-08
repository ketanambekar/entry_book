import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static TextTheme textTheme(Color color) {
    final base = GoogleFonts.poppinsTextTheme();
    return base.copyWith(
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: color,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: color,
      ),
      bodyLarge: base.bodyLarge?.copyWith(color: color),
      bodyMedium: base.bodyMedium?.copyWith(color: color),
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }
}
