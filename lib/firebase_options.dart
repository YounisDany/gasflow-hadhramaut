// File generated for the GasFlow Firebase project (gas-app-f3481).
// Running `flutterfire configure` later will regenerate this file and add the
// Android/web platforms automatically.
//
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Web is not configured yet — run `flutterfire configure` to add it.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return ios;
      case TargetPlatform.android:
        throw UnsupportedError(
          'Android needs google-services.json — run `flutterfire configure` '
          'or add the Android app in the Firebase console.',
        );
      default:
        throw UnsupportedError(
          'This platform is not configured yet — run `flutterfire configure`.',
        );
    }
  }

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDoNjF_c9UOReTdMpE8Hw5-NPMTTNstGuk',
    appId: '1:314227834152:ios:b8f6e481d5775803bee41d',
    messagingSenderId: '314227834152',
    projectId: 'gas-app-f3481',
    storageBucket: 'gas-app-f3481.firebasestorage.app',
    databaseURL: 'https://gas-app-f3481-default-rtdb.firebaseio.com',
    iosBundleId: 'com.younisdany.gasflow',
  );
}
