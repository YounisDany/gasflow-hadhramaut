import 'package:flutter/material.dart';

import 'theme_controller.dart';

/// Brand palette. Brand accents are constant across themes; surfaces, text and
/// soft tints are getters that flip with [ThemeController.isDark] so the whole
/// app — including hand-painted widgets — switches in one place.
class AppColors {
  AppColors._();

  static bool get _dark => ThemeController.isDark;

  // ─────────────── Brand (theme-independent) ───────────────
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryLight = Color(0xFF1E88E5);

  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF1565C0);

  static const Color shadow = Color(0x141565C0);

  // ─────────────── Surfaces / structure (theme-aware) ───────────────
  static Color get background =>
      _dark ? const Color(0xFF0B1220) : const Color(0xFFF6F8FB);
  static Color get surface =>
      _dark ? const Color(0xFF121C2E) : Colors.white;
  static Color get surfaceAlt =>
      _dark ? const Color(0xFF18233A) : const Color(0xFFF6F8FB);
  static Color get border =>
      _dark ? const Color(0xFF26344E) : const Color(0xFFE5E9F0);
  static Color get divider =>
      _dark ? const Color(0xFF1E2A40) : const Color(0xFFEDF1F6);

  // ─────────────── Text (theme-aware) ───────────────
  static Color get textPrimary =>
      _dark ? const Color(0xFFE8EDF5) : const Color(0xFF0F172A);
  static Color get textSecondary =>
      _dark ? const Color(0xFFA1B0C7) : const Color(0xFF64748B);
  static Color get textHint =>
      _dark ? const Color(0xFF6C7C95) : const Color(0xFF94A3B8);

  // ─────────────── Soft accent tints (theme-aware) ───────────────
  static Color get primarySoft =>
      _dark ? const Color(0xFF15294A) : const Color(0xFFDCE7F7);
  static Color get successSoft =>
      _dark ? const Color(0xFF0F3026) : const Color(0xFFDCFCE7);
  static Color get warningSoft =>
      _dark ? const Color(0xFF3A2D0E) : const Color(0xFFFEF3C7);
  static Color get dangerSoft =>
      _dark ? const Color(0xFF3A1A1C) : const Color(0xFFFEE2E2);
  static Color get infoSoft => primarySoft;

  // ─────────────── Hadhrami identity accents (theme-independent) ───────────────
  // Inspired by Shibam's mudbrick towers, Wadi Hadhramaut sand and the
  // whitewashed window trim of Hadhrami architecture. The brand blue stays the
  // primary action colour; these warm tones carry the cultural identity in
  // backgrounds, patterns and illustrations.
  static const Color clay = Color(0xFFB86B4B);
  static const Color clayDark = Color(0xFF7E4327);
  static const Color clayLight = Color(0xFFD89A78);
  static const Color sand = Color(0xFFEADCC2);
  static const Color sandDeep = Color(0xFFD9C2A0);
  static const Color ochre = Color(0xFFD99A4E);
  static const Color palm = Color(0xFF5E8C61);
  static const Color warmWhite = Color(0xFFF7F1E6);
  static const Color night = Color(0xFF0C2138);

  // ─────────────── Gradients ───────────────
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary, primaryDark],
  );

  /// Deep night-to-clay wash used on the splash & onboarding backdrops.
  static const LinearGradient hadhramiGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [night, primaryDark, clayDark],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [ochre, clay, clayDark],
  );

  // ─────────────── Elevation (theme-aware) ───────────────
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: (_dark ? Colors.black : const Color(0xFF1565C0))
              .withValues(alpha: _dark ? 0.45 : 0.06),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: (_dark ? Colors.black : const Color(0xFF0F172A))
              .withValues(alpha: _dark ? 0.5 : 0.08),
          blurRadius: 24,
          spreadRadius: -4,
          offset: const Offset(0, 12),
        ),
      ];
}
