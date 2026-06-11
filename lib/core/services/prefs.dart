import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper over [SharedPreferences] for app-wide local persistence:
/// the onboarding flag, the remembered session, and the offline data cache
/// and mutation queue. Call [init] once during startup before any access.
class Prefs {
  Prefs._();

  static SharedPreferences? _p;

  static Future<void> init() async {
    _p ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get _prefs {
    final p = _p;
    if (p == null) {
      throw StateError('Prefs.init() must be awaited before use');
    }
    return p;
  }

  static const _kOnboardingSeen = 'onboarding_seen';

  static bool get onboardingSeen => _prefs.getBool(_kOnboardingSeen) ?? false;
  static Future<void> setOnboardingSeen(bool v) =>
      _prefs.setBool(_kOnboardingSeen, v);

  // ─────────────── Remembered session (local / demo persistence) ───────────────
  // When "remember me" is on we persist the signed-in profile so the user lands
  // straight on their home after relaunch. Sign-out clears [_kSignedIn] and the
  // profile keys but keeps [_kRememberMe] so the checkbox remembers its state.
  static const _kSignedIn = 'session_signed_in';
  static const _kRememberMe = 'session_remember_me';
  static const _kRole = 'session_role';
  static const _kName = 'session_name';
  static const _kEmail = 'session_email';
  static const _kPhone = 'session_phone';
  static const _kRegion = 'session_region';
  static const _kProfileComplete = 'session_profile_complete';
  static const _kIsJoined = 'session_is_joined';
  static const _kLat = 'session_lat';
  static const _kLng = 'session_lng';

  static bool get signedIn => _prefs.getBool(_kSignedIn) ?? false;
  static bool get rememberMe => _prefs.getBool(_kRememberMe) ?? true;
  static Future<void> setRememberMe(bool v) =>
      _prefs.setBool(_kRememberMe, v);

  static String get sessionRole => _prefs.getString(_kRole) ?? 'citizen';
  static String get sessionName => _prefs.getString(_kName) ?? '';
  static String get sessionEmail => _prefs.getString(_kEmail) ?? '';
  static String get sessionPhone => _prefs.getString(_kPhone) ?? '';
  static String get sessionRegion => _prefs.getString(_kRegion) ?? '';
  static bool get sessionProfileComplete =>
      _prefs.getBool(_kProfileComplete) ?? false;
  static bool get sessionIsJoined => _prefs.getBool(_kIsJoined) ?? false;
  static double? get sessionLat => _prefs.getDouble(_kLat);
  static double? get sessionLng => _prefs.getDouble(_kLng);

  /// Persist the signed-in profile so it survives relaunch.
  static Future<void> saveSession({
    required String role,
    required String name,
    required String email,
    required String phone,
    required String region,
    required bool profileComplete,
    required bool isJoined,
    double? lat,
    double? lng,
  }) async {
    await _prefs.setBool(_kSignedIn, true);
    await _prefs.setString(_kRole, role);
    await _prefs.setString(_kName, name);
    await _prefs.setString(_kEmail, email);
    await _prefs.setString(_kPhone, phone);
    await _prefs.setString(_kRegion, region);
    await _prefs.setBool(_kProfileComplete, profileComplete);
    await _prefs.setBool(_kIsJoined, isJoined);
    if (lat != null) {
      await _prefs.setDouble(_kLat, lat);
    } else {
      await _prefs.remove(_kLat);
    }
    if (lng != null) {
      await _prefs.setDouble(_kLng, lng);
    } else {
      await _prefs.remove(_kLng);
    }
  }

  /// Forget the remembered session (keeps the [rememberMe] preference).
  static Future<void> clearSession() async {
    await _prefs.remove(_kSignedIn);
    await _prefs.remove(_kRole);
    await _prefs.remove(_kName);
    await _prefs.remove(_kEmail);
    await _prefs.remove(_kPhone);
    await _prefs.remove(_kRegion);
    await _prefs.remove(_kProfileComplete);
    await _prefs.remove(_kIsJoined);
    await _prefs.remove(_kLat);
    await _prefs.remove(_kLng);
  }

  // Generic helpers used by the session and the offline store.
  static String? getString(String key) => _prefs.getString(key);
  static Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);
  static bool getBool(String key, {bool fallback = false}) =>
      _prefs.getBool(key) ?? fallback;
  static Future<void> setBool(String key, bool value) =>
      _prefs.setBool(key, value);
  static Future<void> remove(String key) => _prefs.remove(key);
}
