// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyA3eBb2IEUf7P0d_nL9pY4q2EydwMUVLL0',
    appId: '1:605550970881:web:f3b0e0813cd257d4c85800',
    messagingSenderId: '605550970881',
    projectId: 'chat-app-aca0b',
    authDomain: 'chat-app-aca0b.firebaseapp.com',
    storageBucket: 'chat-app-aca0b.appspot.com',
    measurementId: 'G-1GMKMDZLXL',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDfD5Q_7fsIubBCZOh_vIp7IycVK7K4u_o',
    appId: '1:605550970881:android:a61a477be400b9b4c85800',
    messagingSenderId: '605550970881',
    projectId: 'chat-app-aca0b',
    storageBucket: 'chat-app-aca0b.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBG7iwt4Pv1TuGDbE6PYud4XMd06WpMP_M',
    appId: '1:605550970881:ios:417eebcdcc44f31cc85800',
    messagingSenderId: '605550970881',
    projectId: 'chat-app-aca0b',
    storageBucket: 'chat-app-aca0b.appspot.com',
    iosBundleId: 'com.example.chatApp',
  );
}