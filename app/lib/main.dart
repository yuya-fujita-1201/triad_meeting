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
import 'services/purchase_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool firebaseReady = false;
  final localStorage = LocalStorageService();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    firebaseReady = true;
  } on FirebaseException catch (e) {
    // FirebaseCore が既に初期化済みの場合は duplicate-app が出る可能性があるため継続する
    if (e.code == 'duplicate-app') {
      firebaseReady = true;
    } else {
      debugPrint('❌ Firebase init failed: $e');
    }
  } catch (e) {
    // Firebase の初期化失敗時は機能を制限して起動を継続する
    debugPrint('❌ Firebase init failed: $e');
  }

  if (firebaseReady) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  try {
    await MobileAds.instance.initialize();
  } catch (e) {
    // 広告SDK初期化失敗時もアプリ起動は継続する
    debugPrint('❌ AdMob init failed: $e');
  }

  try {
    await localStorage.init();
  } catch (e) {
    // ローカル保存領域の初期化失敗時は、アプリ起動を止めない
    debugPrint('❌ LocalStorage init failed: $e');
  }

  if (firebaseReady) {
    try {
      await FirebaseAuth.instance.signInAnonymously();
    } catch (_) {
      // Continue with limited mode if anonymous sign-in fails
    }
  }

  // RevenueCat 初期化
  final purchaseService = PurchaseService();
  try {
    await purchaseService.init();
  } catch (e) {
    // 課金SDK初期化失敗時も続行
    debugPrint('❌ Purchase init failed: $e');
  }

  runZonedGuarded(
    () {
      runApp(
        ProviderScope(
          overrides: [
            localStorageProvider.overrideWithValue(localStorage),
            purchaseServiceProvider.overrideWith((ref) => purchaseService),
          ],
          child: const TriadCouncilApp(),
        ),
      );
    },
    (error, stack) {
      if (firebaseReady) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      } else {
        debugPrint('🟠 Unhandled app error: $error\n$stack');
      }
    },
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
    // Firebaseが初期化されている場合のみログを送信
    try {
      unawaited(ref.read(analyticsProvider).logAppOpen());
    } catch (e) {
      print('🔴 Analytics failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🟢 Building MaterialApp');
    return MaterialApp(
      title: '三賢会議',
      theme: AppTheme.lightTheme(),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
