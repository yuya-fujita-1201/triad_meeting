import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../config/app_config.dart';

/// プレミアムプランの種類
enum PremiumPlan {
  weekly,
  monthly,
}

/// 課金状態を管理するサービス
class PurchaseService extends ChangeNotifier {
  PurchaseService();

  bool _isInitialized = false;
  bool _isPurchasesAvailable = false;
  bool _configureAttempted = false; // Purchases.configure() 二重呼び出し防止
  bool _isPremium = false;
  List<StoreProduct> _products = [];
  String? _errorMessage;

  bool get isPremium => _isPremium;
  bool get isInitialized => _isInitialized;
  bool get isAvailable => _isPurchasesAvailable;
  List<StoreProduct> get products => _products;
  String? get errorMessage => _errorMessage;

  /// APIキーがプレースホルダーかどうかを検証
  static bool _isPlaceholderKey(String key) {
    final lower = key.toLowerCase();
    return key.isEmpty ||
        lower.contains('placeholder') ||
        lower.startsWith('appl_xxxx') ||
        lower == 'appl_' ||
        lower.startsWith('your_');
  }

  /// RevenueCat を初期化（リトライロジック付き）
  Future<void> init() async {
    if (_isInitialized) return;

    final apiKey = AppConfig.revenueCatApiKey;

    // プレースホルダーキーの検出
    if (_isPlaceholderKey(apiKey)) {
      debugPrint('⚠️ RevenueCat API Key が未設定またはプレースホルダーです: '
          '${apiKey.isEmpty ? "(空)" : apiKey.substring(0, apiKey.length.clamp(0, 10))}...');
      _isPurchasesAvailable = false;
      _errorMessage = '課金機能は現在利用できません。設定を確認してください。';
      _isInitialized = true;
      notifyListeners();
      return;
    }

    // Purchases.configure() は1度しか呼べないため、フラグで防止
    if (!_configureAttempted) {
      _configureAttempted = true;
      try {
        await Purchases.setLogLevel(LogLevel.debug);
        final configuration = PurchasesConfiguration(apiKey);
        await Purchases.configure(configuration);
        _isPurchasesAvailable = true;
      } catch (e) {
        debugPrint('❌ RevenueCat configure エラー: $e');
        _isPurchasesAvailable = false;
        _errorMessage = 'ただいま準備中です。少し時間をおいて再度お試しください。';
        _isInitialized = true;
        notifyListeners();
        return;
      }
    }

    _isInitialized = true;

    // 課金状態と商品情報をリトライ付きで取得
    await refreshPurchaseStatus();
    await _loadProductsWithRetry();

    notifyListeners();
  }

  /// 課金状態をリフレッシュ
  Future<void> refreshPurchaseStatus() async {
    if (!_isPurchasesAvailable) {
      _isPremium = false;
      notifyListeners();
      return;
    }
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      _isPremium = customerInfo
              .entitlements.all[AppConfig.premiumEntitlementId]?.isActive ??
          false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ 課金状態取得エラー: $e');
    }
  }

  /// 商品情報をリトライ付きで読み込み（iPad初期化遅延対策）
  Future<void> _loadProductsWithRetry() async {
    if (!_isPurchasesAvailable) {
      _products = [];
      notifyListeners();
      return;
    }

    const maxRetries = 3;
    const retryDelays = [Duration(seconds: 2), Duration(seconds: 4)];

    for (var attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final offerings = await Purchases.getOfferings()
            .timeout(const Duration(seconds: 15));
        final current = offerings.current;
        if (current != null) {
          _products = current.availablePackages
              .map((p) => p.storeProduct)
              .toList();
        }

        // Offeringsが空の場合、直接productIDsで取得を試みる
        if (_products.isEmpty) {
          _products = await Purchases.getProducts(
            [AppConfig.weeklyProductId, AppConfig.monthlyProductId],
          ).timeout(const Duration(seconds: 15));
        }

        if (_products.isNotEmpty) {
          _errorMessage = null;
          notifyListeners();
          return; // 成功
        }
      } catch (e) {
        debugPrint('❌ 商品情報取得エラー (試行 ${attempt + 1}/${maxRetries + 1}): $e');
      }

      // 最後の試行でなければリトライ待機
      if (attempt < maxRetries) {
        final delay = attempt < retryDelays.length
            ? retryDelays[attempt]
            : retryDelays.last;
        await Future.delayed(delay);
      }
    }

    // 全リトライ失敗
    debugPrint('⚠️ 商品情報の取得に全て失敗しました');
    _errorMessage = 'プラン情報を取得できませんでした。時間をおいて再度お試しください。';
    notifyListeners();
  }

  /// 商品情報を読み込み（外部から手動リロード用）
  Future<void> loadProducts() async {
    await _loadProductsWithRetry();
  }

  /// サブスクリプションを購入
  Future<bool> purchase(StoreProduct product) async {
    if (!_isPurchasesAvailable) {
      _errorMessage = '課金機能が利用できません。設定を確認してください。';
      notifyListeners();
      return false;
    }

    try {
      _errorMessage = null;
      notifyListeners();

      final customerInfo = await Purchases.purchaseStoreProduct(product);
      _isPremium = customerInfo
              .entitlements.all[AppConfig.premiumEntitlementId]?.isActive ??
          false;
      notifyListeners();
      return _isPremium;
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) {
        // ユーザーがキャンセル
        return false;
      }
      _errorMessage = '購入処理でエラーが発生しました';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = '購入処理でエラーが発生しました: $e';
      notifyListeners();
      return false;
    }
  }

  /// 購入を復元
  Future<bool> restore() async {
    if (!_isPurchasesAvailable) {
      _errorMessage = '課金機能が利用できません。設定を確認してください。';
      notifyListeners();
      return false;
    }

    try {
      _errorMessage = null;
      notifyListeners();

      final customerInfo = await Purchases.restorePurchases();
      _isPremium = customerInfo
              .entitlements.all[AppConfig.premiumEntitlementId]?.isActive ??
          false;
      notifyListeners();
      return _isPremium;
    } catch (e) {
      _errorMessage = '復元に失敗しました: $e';
      notifyListeners();
      return false;
    }
  }
}
