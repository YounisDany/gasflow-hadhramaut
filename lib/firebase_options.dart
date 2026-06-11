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
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return ios;
      case TargetPlatform.android:
        return android;
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
    databaseURL: 'https://gas-app-f3481-default-rtdb.firebaseio.com',
    storageBucket: 'gas-app-f3481.firebasestorage.app',
    iosBundleId: 'com.younisdany.gasflow',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBlczAD_B2ot4_4S9srfzImPLjIDB1mnEo',
    appId: '1:314227834152:web:85df29c5bbb0f286bee41d',
    messagingSenderId: '314227834152',
    projectId: 'gas-app-f3481',
    authDomain: 'gas-app-f3481.firebaseapp.com',
    databaseURL: 'https://gas-app-f3481-default-rtdb.firebaseio.com',
    storageBucket: 'gas-app-f3481.firebasestorage.app',
    measurementId: 'G-3G2XDVNRWY',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDHhhhkhWpxbTPCYy3VnRsabrAS06rOd58',
    appId: '1:314227834152:android:66b5c9c499d29e23bee41d',
    messagingSenderId: '314227834152',
    projectId: 'gas-app-f3481',
    databaseURL: 'https://gas-app-f3481-default-rtdb.firebaseio.com',
    storageBucket: 'gas-app-f3481.firebasestorage.app',
  );

}