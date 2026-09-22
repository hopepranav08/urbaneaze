import 'package:flutter/material.dart';

/// UrbanEaze "Terra" palette — warm, earthy, premium.
/// Jade green primary, terracotta + sand accents.
/// Light = porcelain & cream. Dark = warm charcoal, never blue-black.
class AppColors {
  AppColors._();

  // ── Dark theme backgrounds (warm charcoal) ──────────────────────────
  static const darkBg = Color(0xFF141210);
  static const darkSurface = Color(0xFF1C1916);
  static const darkSurfaceHigh = Color(0xFF272220);
  static const darkBorder = Color(0x1AFFFFFF);

  // ── Light theme backgrounds (porcelain & cream) ─────────────────────
  static const lightBg = Color(0xFFF6F3EE);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceHigh = Color(0xFFEFE9E0);
  static const lightBorder = Color(0x14201A14);

  // ── Glassmorphism ───────────────────────────────────────────────────
  static const glassDark = Color(0xB31C1916);
  static const glassLight = Color(0xA6FFFFFF);
  static const glassBorderDark = Color(0x21FFFFFF);
  static const glassBorderLight = Color(0xD9FFFFFF);

  // ── Shared accents ──────────────────────────────────────────────────
  static const primary = Color(0xFF2A9D8F); // jade
  static const primaryDeep = Color(0xFF1F7468);
  static const primaryLight = Color(0xFF9AD6CD);
  static const secondary = Color(0xFFE76F51); // terracotta
  static const sand = Color(0xFFE9C46A);
  static const danger = Color(0xFFE5484D);
  static const warning = Color(0xFFED9B40);
  static const success = Color(0xFF43AA8B);

  // ── Role colors ─────────────────────────────────────────────────────
  static const adminColor = Color(0xFFA06CD5); // plum
  static const residentColor = Color(0xFF2A9D8F); // jade
  static const guardColor = Color(0xFFED9B40); // amber

  // ── Dark theme text (warm off-whites) ───────────────────────────────
  static const darkTextPrimary = Color(0xFFF3EFE9);
  static const darkTextSecondary = Color(0xFFA39A8E);
  static const darkTextMuted = Color(0xFF5C554C);

  // ── Light theme text (warm inks) ────────────────────────────────────
  static const lightTextPrimary = Color(0xFF211D19);
  static const lightTextSecondary = Color(0xFF6B635A);
  static const lightTextMuted = Color(0xFFA89F94);

  // ── Gradient presets ────────────────────────────────────────────────
  static const heroGradientColors = [Color(0xFF2FA98C), Color(0xFF16766B)];
  static const heroWarmGradientColors = [Color(0xFFE76F51), Color(0xFFE9A23B)];
  static const dangerGradientColors = [Color(0xFFE5484D), Color(0xFFE76F51)];
  static const approveGradientColors = [Color(0xFF43AA8B), Color(0xFF2A9D8F)];
  static const adminGradientColors = [Color(0xFFA06CD5), Color(0xFF7A5FC7)];
  static const guardGradientColors = [Color(0xFFED9B40), Color(0xFFE76F51)];

  static LinearGradient heroGradient({AlignmentGeometry begin = Alignment.topLeft, AlignmentGeometry end = Alignment.bottomRight}) =>
      LinearGradient(begin: begin, end: end, colors: heroGradientColors);

  static LinearGradient heroWarmGradient() =>
      const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: heroWarmGradientColors);

  static LinearGradient dangerGradient() =>
      const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: dangerGradientColors);

  static LinearGradient approveGradient() =>
      const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: approveGradientColors);

  static LinearGradient adminGradient() =>
      const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: adminGradientColors);

  static LinearGradient guardGradient() =>
      const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: guardGradientColors);

  /// Soft tinted background for an accent color (chips, icons, badges).
  static Color tintOf(Color c, {double alpha = 0.13}) => c.withValues(alpha: alpha);
}
