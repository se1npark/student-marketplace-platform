import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

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
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'Firebase options are configured for Android, iOS, macOS and web.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCgPWZAS2snAFV7Bz8gfjFDqJDonj2iMOc',
    appId: '1:359052378105:web:70aeb9f3c957a6abb84728',
    messagingSenderId: '359052378105',
    projectId: 'campus-cart-seinpark',
    authDomain: 'campus-cart-seinpark.firebaseapp.com',
    storageBucket: 'campus-cart-seinpark.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyACg5SicoMr3DpsaR3XjHOwfG5g9GcUZ44',
    appId: '1:359052378105:android:75b3d3a2c2128c8bb84728',
    messagingSenderId: '359052378105',
    projectId: 'campus-cart-seinpark',
    storageBucket: 'campus-cart-seinpark.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCBP4Rsm8lHzFLeiTB6v0M6P2iUSrUu_3k',
    appId: '1:359052378105:ios:c14b84a2dcc15202b84728',
    messagingSenderId: '359052378105',
    projectId: 'campus-cart-seinpark',
    storageBucket: 'campus-cart-seinpark.firebasestorage.app',
    iosBundleId: 'au.edu.mq.campusCart',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCBP4Rsm8lHzFLeiTB6v0M6P2iUSrUu_3k',
    appId: '1:359052378105:ios:c14b84a2dcc15202b84728',
    messagingSenderId: '359052378105',
    projectId: 'campus-cart-seinpark',
    storageBucket: 'campus-cart-seinpark.firebasestorage.app',
    iosBundleId: 'au.edu.mq.campusCart',
  );
}
