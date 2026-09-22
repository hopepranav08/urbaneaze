import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Sora for display/headlines (geometric, characterful),
/// Manrope for body/labels (smooth, highly readable).
class AppTypography {
  AppTypography._();

  static TextStyle display(Color c, {double size = 32, FontWeight w = FontWeight.w700}) =>
      GoogleFonts.sora(fontSize: size, fontWeight: w, color: c, letterSpacing: -0.8, height: 1.15);

  static TextStyle body(Color c, {double size = 14, FontWeight w = FontWeight.w400, double ls = 0}) =>
      GoogleFonts.manrope(fontSize: size, fontWeight: w, color: c, letterSpacing: ls);

  static TextTheme _theme(Color primary, Color secondary, Color muted) => TextTheme(
        displayLarge: display(primary, size: 32),
        displayMedium: display(primary, size: 28),
        displaySmall: display(primary, size: 24, w: FontWeight.w600),
        headlineLarge: display(primary, size: 22, w: FontWeight.w600),
        headlineMedium: display(primary, size: 20, w: FontWeight.w600),
        headlineSmall: display(primary, size: 18, w: FontWeight.w600),
        titleLarge: body(primary, size: 16, w: FontWeight.w700),
        titleMedium: body(primary, size: 15, w: FontWeight.w600),
        titleSmall: body(secondary, size: 14, w: FontWeight.w600),
        bodyLarge: body(primary, size: 16),
        bodyMedium: body(primary, size: 14),
        bodySmall: body(secondary, size: 12),
        labelLarge: body(primary, size: 14, w: FontWeight.w700, ls: 0.2),
        labelMedium: body(secondary, size: 12, w: FontWeight.w600),
        labelSmall: body(muted, size: 11, w: FontWeight.w700, ls: 0.8),
      );

  static TextTheme darkTextTheme = _theme(
      AppColors.darkTextPrimary, AppColors.darkTextSecondary, AppColors.darkTextMuted);

  static TextTheme lightTextTheme = _theme(
      AppColors.lightTextPrimary, AppColors.lightTextSecondary, AppColors.lightTextMuted);
}
