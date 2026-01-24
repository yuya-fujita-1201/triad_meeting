import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  AnalyticsService(this._analytics);

  factory AnalyticsService.disabled() => AnalyticsService(null);

  final FirebaseAnalytics? _analytics;

  Future<void> logAppOpen() async {
    if (_analytics == null) return;
    await _analytics!.logAppOpen();
  }

  Future<void> logConsultationStart() async {
    if (_analytics == null) return;
    await _analytics!.logEvent(name: 'consultation_start');
  }

  Future<void> logConsultationComplete() async {
    if (_analytics == null) return;
    await _analytics!.logEvent(name: 'consultation_complete');
  }

  Future<void> logAdImpression() async {
    if (_analytics == null) return;
    await _analytics!.logEvent(name: 'ad_impression');
  }
}
