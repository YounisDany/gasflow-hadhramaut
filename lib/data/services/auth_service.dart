import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Thin wrapper around Firebase Auth + the `users/{uid}` profile document.
/// Roles live in Firestore (`role: admin|agent|citizen`); the fixed admin
/// email is always treated as admin even before its doc exists.
class AuthService {
  AuthService._();

  static FirebaseAuth get _auth => FirebaseAuth.instance;
  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  static const String adminEmail = 'admin@gmail.com';

  /// True once `Firebase.initializeApp()` succeeds. When false the app is in
  /// local demo mode and auth screens take an offline path.
  static bool ready = false;

  static User? get currentUser => ready ? _auth.currentUser : null;
  static Stream<User?> authChanges() => _auth.authStateChanges();

  static Future<UserCredential> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password);

  static Future<UserCredential> signUp({
    required String email,
    required String password,
    required String role,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), password: password);
    await _db.collection('users').doc(cred.user!.uid).set({
      'email': email.trim(),
      'role': role,
      'profileComplete': false,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    }, SetOptions(merge: true));
    return cred;
  }

  /// 'admin' | 'agent' | 'citizen'
  static Future<String> roleForCurrentUser() async {
    if (!ready) return 'citizen';
    final user = _auth.currentUser;
    if (user == null) return 'citizen';
    if ((user.email ?? '').toLowerCase() == adminEmail) return 'admin';
    final doc = await _db.collection('users').doc(user.uid).get();
    return (doc.data()?['role'] as String?) ?? 'citizen';
  }

  static Future<Map<String, dynamic>?> profileForCurrentUser() async {
    if (!ready) return null;
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _db.collection('users').doc(user.uid).get();
    return doc.data();
  }

  /// Merge profile fields (name/phone/region/profileComplete…) into users/{uid}.
  static Future<void> saveProfile(Map<String, dynamic> data) async {
    if (!ready) return;
    final user = _auth.currentUser;
    if (user == null) return;
    // Fire-and-forget: written to the local cache now, synced when online.
    _db.collection('users').doc(user.uid).set(data, SetOptions(merge: true));
  }

  static Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  static Future<void> signOut() async {
    if (!ready) return;
    await _auth.signOut();
  }
}
