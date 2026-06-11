import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'auth_service.dart';

/// Firebase Cloud Messaging setup. In-app notifications live in Firestore (the
/// `notifications` collection) and are the source of truth for the notifications
/// screen; FCM adds tray/push delivery driven by a Cloud Function that watches
/// that collection (see functions/ + SETUP_FIREBASE.md).
class MessagingService {
  MessagingService._();

  static FirebaseMessaging get _fm => FirebaseMessaging.instance;

  static Future<void> init() async {
    if (!AuthService.ready) return;
    await _fm.requestPermission(alert: true, badge: true, sound: true);
  }

  /// Register this device's token against the signed-in user so the Cloud
  /// Function can push to them. Call right after a successful sign-in.
  static Future<void> registerToken() async {
    if (!AuthService.ready) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final token = await _fm.getToken();
    if (token == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'fcmTokens': FieldValue.arrayUnion([token]),
    }, SetOptions(merge: true));
  }

  static Future<void> clearToken() async {
    if (!AuthService.ready) return;
    final user = FirebaseAuth.instance.currentUser;
    final token = await _fm.getToken();
    if (user == null || token == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'fcmTokens': FieldValue.arrayRemove([token]),
    }, SetOptions(merge: true));
  }
}
