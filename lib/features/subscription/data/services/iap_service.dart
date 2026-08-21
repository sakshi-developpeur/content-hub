import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Callback signature for completed purchases.
typedef IapPurchaseCallback = void Function(PurchaseDetails details);

/// Service wrapping the `in_app_purchase` plugin.
///
/// Manages the store connection, product fetching, purchase flow, and
/// forwards completed purchases to a registered callback so the controller
/// can verify them with the backend.
class IapService {
  IapService();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  /// Products fetched from the store, keyed by product ID.
  final Map<String, ProductDetails> products = {};

  /// Whether the IAP store is available on this device.
  bool isAvailable = false;

  /// External callback set by the controller to handle completed purchases.
  IapPurchaseCallback? onPurchaseCompleted;

  /// External callback for purchase errors.
  void Function(String error)? onPurchaseError;

  // ─── Initialise ──────────────────────────────────────────────────

  /// Call once to connect to the store and start listening for purchases.
  Future<void> initialize() async {
    isAvailable = await _iap.isAvailable();
    if (!isAvailable) {
      debugPrint('IapService: Store not available on this device');
      return;
    }

    // Listen to the purchase stream (auto-renewed / pending / completed).
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (Object error) {
        debugPrint('IapService: purchaseStream error → $error');
      },
    );
  }

  // ─── Fetch products ──────────────────────────────────────────────

  /// Load product details from the store for the given [productIds].
  ///
  /// Product IDs follow the pattern `com.estoriz.app.{planCode}_{billingCycle}`.
  /// Examples:
  ///   • `com.estoriz.app.basic_monthly`
  ///   • `com.estoriz.app.standard_monthly`
  ///   • `com.estoriz.app.gold_ai_one_time`
  ///   • `com.estoriz.app.lifetime_one_time`
  Future<void> fetchProducts(Set<String> productIds) async {
    if (!isAvailable || productIds.isEmpty) return;

    final response = await _iap.queryProductDetails(productIds);

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint(
        'IapService: Products NOT found in store → ${response.notFoundIDs}',
      );
    }

    products.clear();
    for (final product in response.productDetails) {
      products[product.id] = product;
    }

    debugPrint('IapService: Loaded ${products.length} products from store');
  }

  // ─── Purchase ────────────────────────────────────────────────────

  /// Start a subscription purchase for [productId].
  ///
  /// Returns `false` if the product wasn't found or the store is unavailable.
  bool buySubscription(String productId) {
    if (!isAvailable) {
      onPurchaseError?.call('Store is not available');
      return false;
    }

    final product = products[productId];
    if (product == null) {
      onPurchaseError?.call(
        'Product "$productId" not found in store. '
        'Please ensure it is configured in the Play Console / App Store Connect.',
      );
      return false;
    }

    final purchaseParam = PurchaseParam(productDetails: product);

    // Use buyNonConsumable for subscriptions (they are non-consumable).
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
    return true;
  }

  /// Restore previous purchases (useful for iOS).
  Future<void> restorePurchases() async {
    if (!isAvailable) return;
    await _iap.restorePurchases();
  }

  // ─── Product-ID helpers ──────────────────────────────────────────

  /// App package prefix used for store product IDs.
  static const String _prefix = 'com.estoriz.app';

  /// Builds the store product ID from plan code and billing cycle.
  ///
  /// Uses the format: `com.estoriz.app.{planCode}_{billingCycle}`
  ///
  /// ┌─────────────┬───────────────┬──────────────────────────────────────┐
  /// │ Plan Code   │ Billing Cycle │ Store Product ID                     │
  /// ├─────────────┼───────────────┼──────────────────────────────────────┤
  /// │ basic       │ monthly       │ com.estoriz.app.basic_monthly        │
  /// │ standard    │ monthly       │ com.estoriz.app.standard_monthly     │
  /// │ family      │ monthly       │ com.estoriz.app.family_monthly       │
  /// │ gold_ai     │ one_time      │ com.estoriz.app.gold_ai_one_time     │
  /// │ lifetime    │ one_time      │ com.estoriz.app.lifetime_one_time    │
  /// └─────────────┴───────────────┴──────────────────────────────────────┘
  static String productIdFor(String planCode, String billingCycle) {
    return '$_prefix.${planCode.toLowerCase()}_${billingCycle.toLowerCase()}';
  }

  /// Builds the set of product IDs for a plan given its billing cycles.
  ///
  /// The [billingCycles] come directly from the API response
  /// (e.g. `plan.prices.keys` → `{'monthly'}` or `{'one_time'}`).
  static Set<String> productIdsForPlan(
    String planCode,
    Iterable<String> billingCycles,
  ) {
    return billingCycles
        .map((cycle) => productIdFor(planCode, cycle))
        .toSet();
  }

  /// Returns the current platform's gateway name for the API.
  static String get gatewayName =>
      Platform.isIOS ? 'apple_pay' : 'google_play';

  // ─── Purchase stream handler ─────────────────────────────────────

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchase in purchaseDetailsList) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          debugPrint('IapService: Purchase completed → ${purchase.productID}');
          onPurchaseCompleted?.call(purchase);
          // Complete the purchase on the platform side.
          if (purchase.pendingCompletePurchase) {
            _iap.completePurchase(purchase);
          }
          break;

        case PurchaseStatus.error:
          debugPrint('IapService: Purchase error → ${purchase.error?.message}');
          onPurchaseError?.call(
            purchase.error?.message ?? 'Purchase failed. Please try again.',
          );
          if (purchase.pendingCompletePurchase) {
            _iap.completePurchase(purchase);
          }
          break;

        case PurchaseStatus.pending:
          debugPrint('IapService: Purchase pending → ${purchase.productID}');
          break;

        case PurchaseStatus.canceled:
          debugPrint('IapService: Purchase cancelled → ${purchase.productID}');
          onPurchaseError?.call('Purchase was cancelled.');
          if (purchase.pendingCompletePurchase) {
            _iap.completePurchase(purchase);
          }
          break;
      }
    }
  }

  // ─── Dispose ─────────────────────────────────────────────────────

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    onPurchaseCompleted = null;
    onPurchaseError = null;
  }
}
