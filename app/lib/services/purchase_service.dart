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
  bool _isPremium = false;
  List<StoreProduct> _products = [];
  String? _errorMessage;

  bool get isPremium => _isPremium;
  bool get isInitialized => _isInitialized;
  List<StoreProduct> get products => _products;
  String? get errorMessage => _errorMessage;

  /// RevenueCat を初期化
  Future<void> init() async {
    if (_isInitialized) return;

    final apiKey = AppConfig.revenueCatApiKey;
    if (apiKey.isEmpty) {
      debugPrint('⚠️ RevenueCat API Key が未設定です');
      _isInitialized = true;
      notifyListeners();
      return;
    }

    try {
      await Purchases.setLogLevel(LogLevel.debug);
      final configuration = PurchasesConfiguration(apiKey);
      await Purchases.configure(configuration);
      _isInitialized = true;

      // 現在の課金状態を取得
      await refreshPurchaseStatus();

      // 商品情報を取得
      await loadProducts();
    } catch (e) {
      debugPrint('❌ RevenueCat 初期化エラー: $e');
      _errorMessage = 'サブスクリプションサービスの初期化に失敗しました';
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// 課金状態をリフレッシュ
  Future<void> refreshPurchaseStatus() async {
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

  /// 商品情報を読み込み
  Future<void> loadProducts() async {
    try {
      final offerings = await Purchases.getOfferings();
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
        );
      }
      notifyListeners();
    } catch (e) {
      debugPrint('❌ 商品情報取得エラー: $e');
    }
  }

  /// サブスクリプションを購入
  Future<bool> purchase(StoreProduct product) async {
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
