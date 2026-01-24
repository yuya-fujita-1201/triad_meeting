import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import '../services/ad_service.dart';
import '../services/analytics_service.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

final analyticsProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService(FirebaseAnalytics.instance);
});

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final localStorageProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('LocalStorageService must be initialized');
});

final adServiceProvider = Provider<AdService>((ref) {
  return AdService(ref.read(analyticsProvider));
});
