import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

import 'auth_service.dart';

/// Thin wrapper around Firebase Storage for uploading generated assets (e.g.
/// a citizen's QR image) and getting back a shareable download URL.
class StorageService {
  StorageService._();

  /// Returns the download URL, or null when Firebase isn't configured (demo
  /// mode) so callers can fall back to a local-only flow.
  static Future<String?> uploadBytes(
    String path,
    Uint8List bytes, {
    String contentType = 'image/png',
  }) async {
    if (!AuthService.ready) return null;
    final ref = FirebaseStorage.instance.ref(path);
    await ref.putData(bytes, SettableMetadata(contentType: contentType));
    return ref.getDownloadURL();
  }
}
