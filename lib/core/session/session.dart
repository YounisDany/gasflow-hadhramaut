import 'package:flutter/foundation.dart';

/// Lightweight session + current-user profile. Holds whatever the UI needs to
/// gate areas and pre-fill forms before a real backend is wired in. Every field
/// is a [ValueNotifier] so gated areas re-render without manual setState.
class Session {
  Session._();

  static final ValueNotifier<bool> isGuestNotifier = ValueNotifier(true);
  static final ValueNotifier<bool> isJoinedNotifier = ValueNotifier(false);

  /// Current account role: 'citizen' | 'agent' | 'admin'. Used to restore the
  /// right home after relaunch and to colour role-specific UI.
  static final ValueNotifier<String> roleNotifier = ValueNotifier('citizen');

  /// Whether the user finished the data-registration step. When false (and not
  /// a guest) the home + settings surface a "complete your profile" prompt so a
  /// user who bailed out of registration can resume and send their request.
  static final ValueNotifier<bool> profileCompleteNotifier =
      ValueNotifier(false);

  // ─────────────── Editable profile (shared: registration ⇄ settings) ───────────────
  static final ValueNotifier<String> nameNotifier = ValueNotifier('');
  static final ValueNotifier<String> emailNotifier = ValueNotifier('');
  static final ValueNotifier<String> phoneNotifier = ValueNotifier('');
  static final ValueNotifier<String> regionNotifier = ValueNotifier('');

  /// Saved location captured during registration (null until set).
  static final ValueNotifier<double?> latNotifier = ValueNotifier(null);
  static final ValueNotifier<double?> lngNotifier = ValueNotifier(null);

  static bool get hasLocation =>
      latNotifier.value != null && lngNotifier.value != null;

  static bool get isGuest => isGuestNotifier.value;
  static set isGuest(bool v) => isGuestNotifier.value = v;

  static String get role => roleNotifier.value;
  static set role(String v) => roleNotifier.value = v;

  static bool get isJoined => isJoinedNotifier.value;
  static set isJoined(bool v) => isJoinedNotifier.value = v;

  static bool get profileComplete => profileCompleteNotifier.value;
  static set profileComplete(bool v) => profileCompleteNotifier.value = v;

  /// Persist the profile captured during registration / settings edit.
  static void saveProfile({
    String? name,
    String? email,
    String? phone,
    String? region,
    double? lat,
    double? lng,
  }) {
    if (name != null) nameNotifier.value = name;
    if (email != null) emailNotifier.value = email;
    if (phone != null) phoneNotifier.value = phone;
    if (region != null) regionNotifier.value = region;
    if (lat != null) latNotifier.value = lat;
    if (lng != null) lngNotifier.value = lng;
  }

  static void signOut() {
    isGuestNotifier.value = true;
    isJoinedNotifier.value = false;
    roleNotifier.value = 'citizen';
    profileCompleteNotifier.value = false;
    nameNotifier.value = '';
    emailNotifier.value = '';
    phoneNotifier.value = '';
    regionNotifier.value = '';
    latNotifier.value = null;
    lngNotifier.value = null;
  }
}
