import 'package:flutter/material.dart';

/// Global light/dark switch. Mirrors the [L10n]/[Session] notifier pattern so
/// `MaterialApp` rebuilds (and every `AppColors` getter re-evaluates) the
/// moment the mode changes — no context needed at the color layer.
class ThemeController {
  ThemeController._();

  static final ValueNotifier<ThemeMode> notifier =
      ValueNotifier(ThemeMode.light);

  static bool get isDark => notifier.value == ThemeMode.dark;

  static void toggle() =>
      notifier.value = isDark ? ThemeMode.light : ThemeMode.dark;

  static void setDark(bool dark) =>
      notifier.value = dark ? ThemeMode.dark : ThemeMode.light;
}
