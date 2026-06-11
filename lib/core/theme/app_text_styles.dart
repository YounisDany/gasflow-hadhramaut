import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/l10n.dart';
import 'app_colors.dart';

/// Text styles that follow the active locale's preferred typeface.
/// Cairo is used for Arabic (excellent Arabic glyph coverage) and Inter for
/// English. Each getter is computed on access so widgets pick up the new
/// font as soon as `MaterialApp` rebuilds with a new locale.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _base({
    required double size,
    required FontWeight weight,
    Color? color,
    double height = 1.3,
    double? letterSpacing,
  }) {
    final s = TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color ?? AppColors.textPrimary,
      height: height,
      letterSpacing: letterSpacing,
    );
    return L10n.isAr ? GoogleFonts.cairo(textStyle: s) : GoogleFonts.inter(textStyle: s);
  }

  static TextStyle get displayLarge =>
      _base(size: 32, weight: FontWeight.w700, height: 1.15);

  static TextStyle get headlineLarge =>
      _base(size: 26, weight: FontWeight.w700, height: 1.2);

  static TextStyle get headlineMedium =>
      _base(size: 22, weight: FontWeight.w700, height: 1.25);

  static TextStyle get titleLarge =>
      _base(size: 18, weight: FontWeight.w600);

  static TextStyle get titleMedium =>
      _base(size: 16, weight: FontWeight.w600);

  static TextStyle get bodyLarge =>
      _base(size: 15, weight: FontWeight.w500, height: 1.45);

  static TextStyle get bodyMedium => _base(
        size: 14,
        weight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.45,
      );

  static TextStyle get bodySmall => _base(
        size: 12,
        weight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  static TextStyle get labelLarge => _base(
        size: 14,
        weight: FontWeight.w600,
        color: Colors.white,
      );

  static TextStyle get caption => _base(
        size: 11,
        weight: FontWeight.w600,
        color: AppColors.textHint,
        letterSpacing: 0.4,
      );
}
