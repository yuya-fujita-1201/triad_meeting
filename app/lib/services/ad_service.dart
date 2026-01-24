import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/app_config.dart';
import 'analytics_service.dart';

class AdService {
  AdService(this._analytics);

  final AnalyticsService _analytics;
  InterstitialAd? _interstitialAd;
  bool _loading = false;
  bool _pendingShow = false;

  void loadInterstitial() {
    if (_loading) return;
    _loading = true;
    InterstitialAd.load(
      adUnitId: AppConfig.adMobInterstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _loading = false;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (_) => _analytics.logAdImpression(),
            onAdDismissedFullScreenContent: (ad) => ad.dispose(),
            onAdFailedToShowFullScreenContent: (ad, _) => ad.dispose(),
          );
          if (_pendingShow) {
            _pendingShow = false;
            showInterstitialIfReady();
          }
        },
        onAdFailedToLoad: (_) {
          _loading = false;
        },
      ),
    );
  }

  void showInterstitialIfReady() {
    final ad = _interstitialAd;
    if (ad == null) {
      _pendingShow = true;
      return;
    }
    _interstitialAd = null;
    ad.show();
  }
}
