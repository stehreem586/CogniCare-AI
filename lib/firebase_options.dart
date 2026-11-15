import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

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
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDMaxlsGWBT2qwvGKNXIOWT_eHh92zIsZI',
    appId: '1:487269984632:web:44872718cf9044e088408d',
    messagingSenderId: '487269984632',
    projectId: 'myandroidapp-7feb6',
    authDomain: 'myandroidapp-7feb6.firebaseapp.com',
    storageBucket: 'myandroidapp-7feb6.firebasestorage.app',
    measurementId: 'G-QXY014ET0L',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC_XY8MzCdGzM7YGnBL_H4PRDAVkH1PqBs',
    appId: '1:487269984632:android:489bc70068590e7788408d',
    messagingSenderId: '487269984632',
    projectId: 'myandroidapp-7feb6',
    storageBucket: 'myandroidapp-7feb6.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDcO_BWoer63SJz-MG20-7BR0cHjzBSkzI',
    appId: '1:487269984632:ios:d447cb16350c9e1188408d',
    messagingSenderId: '487269984632',
    projectId: 'myandroidapp-7feb6',
    storageBucket: 'myandroidapp-7feb6.firebasestorage.app',
    iosBundleId: 'com.example.cognicareAi',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDcO_BWoer63SJz-MG20-7BR0cHjzBSkzI',
    appId: '1:487269984632:ios:d447cb16350c9e1188408d',
    messagingSenderId: '487269984632',
    projectId: 'myandroidapp-7feb6',
    storageBucket: 'myandroidapp-7feb6.firebasestorage.app',
    iosBundleId: 'com.example.cognicareAi',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDMaxlsGWBT2qwvGKNXIOWT_eHh92zIsZI',
    appId: '1:487269984632:web:87ac7aee81aac2c688408d',
    messagingSenderId: '487269984632',
    projectId: 'myandroidapp-7feb6',
    authDomain: 'myandroidapp-7feb6.firebaseapp.com',
    storageBucket: 'myandroidapp-7feb6.firebasestorage.app',
    measurementId: 'G-85VJXHHH5G',
  );
}
