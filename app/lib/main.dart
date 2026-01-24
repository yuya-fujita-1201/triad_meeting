import 'dart:async';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'firebase_options.dart';
import 'providers/providers.dart';
import 'screens/home_screen.dart';
import 'services/local_storage_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var firebaseReady = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseReady = true;
  } catch (_) {
    firebaseReady = false;
  }

  if (firebaseReady) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  await MobileAds.instance.initialize();

  final localStorage = LocalStorageService();
  await localStorage.init();

  if (firebaseReady) {
    try {
      await FirebaseAuth.instance.signInAnonymously();
    } catch (_) {
      // Firebase settings may be missing in early setup; continue with limited mode.
    }
  }

  runApp(
    ProviderScope(
      overrides: [
        localStorageProvider.overrideWithValue(localStorage),
      ],
      child: const TriadCouncilApp(),
    ),
  );
}

class TriadCouncilApp extends ConsumerStatefulWidget {
  const TriadCouncilApp({super.key});

  @override
  ConsumerState<TriadCouncilApp> createState() => _TriadCouncilAppState();
}

class _TriadCouncilAppState extends ConsumerState<TriadCouncilApp> {
  @override
  void initState() {
    super.initState();
    unawaited(ref.read(analyticsProvider).logAppOpen());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '三賢会議',
      theme: AppTheme.lightTheme(),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
