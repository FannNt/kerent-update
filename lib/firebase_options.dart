// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBjzu5jDQf5L-k8DItmwvCw47LA3MIdVtg',
    appId: '1:536032107614:web:748f3297dca48c4143e8cf',
    messagingSenderId: '536032107614',
    projectId: 'k3rent-eaed5',
    authDomain: 'k3rent-eaed5.firebaseapp.com',
    storageBucket: 'k3rent-eaed5.appspot.com',
    measurementId: 'G-3DVLDH4YXV',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCCPn2S5hzIjcIuzf-4qEAapo5p4DHt-So',
    appId: '1:536032107614:android:9bb08a490c69ca3943e8cf',
    messagingSenderId: '536032107614',
    projectId: 'k3rent-eaed5',
    storageBucket: 'k3rent-eaed5.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAyJUPAKVhs6UxcDzS7ivd1kih-Rj6xndU',
    appId: '1:389332734048:ios:8b3d6ff92297f0dee1b305',
    messagingSenderId: '389332734048',
    projectId: 'kerent-projects',
    storageBucket: 'kerent-projects.appspot.com',
    androidClientId: '389332734048-jqidonfg2bp029gk44jjkrhn7nn2ltd9.apps.googleusercontent.com',
    iosClientId: '389332734048-5g523130dc2ml3v8uhdjfc9ebr80sa8s.apps.googleusercontent.com',
    iosBundleId: 'com.example.kerent',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBjzu5jDQf5L-k8DItmwvCw47LA3MIdVtg',
    appId: '1:536032107614:web:07dff546ddbe743643e8cf',
    messagingSenderId: '536032107614',
    projectId: 'k3rent-eaed5',
    authDomain: 'k3rent-eaed5.firebaseapp.com',
    storageBucket: 'k3rent-eaed5.appspot.com',
    measurementId: 'G-C7Z7GM0K7F',
  );

}