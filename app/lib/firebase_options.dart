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
        return linux;
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBabtyCa0fIi9bLMQ5mHRI0UMdWeeeMPe8',
    appId: '1:734293857109:web:placeholder8ed5dc',
    messagingSenderId: '734293857109',
    projectId: 'triad-meeting',
    storageBucket: 'triad-meeting.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBabtyCa0fIi9bLMQ5mHRI0UMdWeeeMPe8',
    appId: '1:734293857109:android:placeholder8ed5dc',
    messagingSenderId: '734293857109',
    projectId: 'triad-meeting',
    storageBucket: 'triad-meeting.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBabtyCa0fIi9bLMQ5mHRI0UMdWeeeMPe8',
    appId: '1:734293857109:ios:31cbff54fa6eb9228ed5dc',
    messagingSenderId: '734293857109',
    projectId: 'triad-meeting',
    storageBucket: 'triad-meeting.firebasestorage.app',
    iosBundleId: 'com.sankenkaigi.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBabtyCa0fIi9bLMQ5mHRI0UMdWeeeMPe8',
    appId: '1:734293857109:ios:31cbff54fa6eb9228ed5dc',
    messagingSenderId: '734293857109',
    projectId: 'triad-meeting',
    storageBucket: 'triad-meeting.firebasestorage.app',
    iosBundleId: 'com.sankenkaigi.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBabtyCa0fIi9bLMQ5mHRI0UMdWeeeMPe8',
    appId: '1:734293857109:web:placeholder8ed5dc',
    messagingSenderId: '734293857109',
    projectId: 'triad-meeting',
    storageBucket: 'triad-meeting.firebasestorage.app',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyBabtyCa0fIi9bLMQ5mHRI0UMdWeeeMPe8',
    appId: '1:734293857109:web:placeholder8ed5dc',
    messagingSenderId: '734293857109',
    projectId: 'triad-meeting',
    storageBucket: 'triad-meeting.firebasestorage.app',
  );
}
