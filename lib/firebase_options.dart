// File generated from Firebase Console config
// Project: smart-carpool-connect

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return web; // Fallback to web config
      case TargetPlatform.windows:
        return web; // Fallback to web config
      case TargetPlatform.linux:
        return web; // Fallback to web config
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC1K7ltthSp48iHqioVv6xleAHIq6pAbik',
    appId: '1:612916804260:web:cade30121594ab3dea8431',
    messagingSenderId: '612916804260',
    projectId: 'smart-carpool-connect',
    authDomain: 'smart-carpool-connect.firebaseapp.com',
    storageBucket: 'smart-carpool-connect.firebasestorage.app',
  );

  // Android config - sẽ cập nhật sau khi thêm Android app
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC1K7ltthSp48iHqioVv6xleAHIq6pAbik',
    appId: '1:612916804260:web:cade30121594ab3dea8431',
    messagingSenderId: '612916804260',
    projectId: 'smart-carpool-connect',
    authDomain: 'smart-carpool-connect.firebaseapp.com',
    storageBucket: 'smart-carpool-connect.firebasestorage.app',
  );

  // iOS config - sẽ cập nhật sau khi thêm iOS app
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC1K7ltthSp48iHqioVv6xleAHIq6pAbik',
    appId: '1:612916804260:web:cade30121594ab3dea8431',
    messagingSenderId: '612916804260',
    projectId: 'smart-carpool-connect',
    authDomain: 'smart-carpool-connect.firebaseapp.com',
    storageBucket: 'smart-carpool-connect.firebasestorage.app',
    iosBundleId: 'com.example.smartCarpoolConnect',
  );
}
