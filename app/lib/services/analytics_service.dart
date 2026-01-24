import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  AnalyticsService(this._analytics);

  final FirebaseAnalytics _analytics;

  Future<void> logAppOpen() => _analytics.logAppOpen();

  Future<void> logConsultationStart() =>
      _analytics.logEvent(name: 'consultation_start');

  Future<void> logConsultationComplete() =>
      _analytics.logEvent(name: 'consultation_complete');

  Future<void> logAdImpression() => _analytics.logEvent(name: 'ad_impression');
}
