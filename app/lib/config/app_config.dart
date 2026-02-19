class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://us-central1-triad-meeting.cloudfunctions.net/api',
  );

  static const String adMobAppId = String.fromEnvironment(
    'ADMOB_APP_ID',
    defaultValue: 'ca-app-pub-2551004292724620~2672533121',
  );

  static const String adMobInterstitialId = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_ID',
    defaultValue: 'ca-app-pub-2551004292724620/2398469875',
  );

  // RevenueCat
  static const String revenueCatApiKey = String.fromEnvironment(
    'REVENUECAT_API_KEY',
    defaultValue: '', // RevenueCat ダッシュボードで取得した Apple API Key を設定
  );

  // RevenueCat Entitlement ID
  static const String premiumEntitlementId = 'premium';

  // RevenueCat Product IDs
  static const String weeklyProductId = 'triad_meeting_weekly';
  static const String monthlyProductId = 'triad_meeting_monthly';
}
