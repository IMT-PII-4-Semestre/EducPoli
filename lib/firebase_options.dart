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
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAOA3n9FjuW4BJYvnoI9t5nTjTeRcM5FcI',
    appId: '1:1052981911635:android:db00b5001fd1ceebd926a6',
    messagingSenderId: '1052981911635',
    projectId: 'educpoli',
    storageBucket: 'educpoli.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAOA3n9FjuW4BJYvnoI9t5nTjTeRcM5FcI',
    appId: '1:1052981911635:web:PLACEHOLDER',
    messagingSenderId: '1052981911635',
    projectId: 'educpoli',
    authDomain: 'educpoli.firebaseapp.com',
    storageBucket: 'educpoli.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAOA3n9FjuW4BJYvnoI9t5nTjTeRcM5FcI',
    appId: '1:1052981911635:ios:PLACEHOLDER',
    messagingSenderId: '1052981911635',
    projectId: 'educpoli',
    storageBucket: 'educpoli.firebasestorage.app',
    iosBundleId: 'com.exemplo.educPoli',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAOA3n9FjuW4BJYvnoI9t5nTjTeRcM5FcI',
    appId: '1:1052981911635:macos:PLACEHOLDER',
    messagingSenderId: '1052981911635',
    projectId: 'educpoli',
    storageBucket: 'educpoli.firebasestorage.app',
    iosBundleId: 'com.exemplo.educPoli',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAOA3n9FjuW4BJYvnoI9t5nTjTeRcM5FcI',
    appId: '1:1052981911635:windows:PLACEHOLDER',
    messagingSenderId: '1052981911635',
    projectId: 'educpoli',
    authDomain: 'educpoli.firebaseapp.com',
    storageBucket: 'educpoli.firebasestorage.app',
  );
}