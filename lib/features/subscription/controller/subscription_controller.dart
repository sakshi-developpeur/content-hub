import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:estoriz/core/utils/app_colors.dart';
import 'package:estoriz/features/subscription/data/models/subscription_plan_model.dart';
import 'package:estoriz/features/subscription/data/models/payment_model.dart';
import 'package:estoriz/features/subscription/data/services/subscription_service.dart';
import 'package:estoriz/features/subscription/data/services/payment_service.dart';
import 'package:estoriz/features/subscription/data/services/iap_service.dart';

class SubscriptionController extends GetxController {
  static const String _fallbackRazorpayKeyId = String.fromEnvironment(
    'RAZORPAY_KEY_ID',
    defaultValue: 'rzp_test_SSeS8bLQO24cdE',
  );

  static const String _packageName = 'com.estoriz.app';

  SubscriptionController({
    required SubscriptionService subscriptionService,
    required PaymentService paymentService,
    required IapService iapService,
  }) : _subscriptionService = subscriptionService,
       _paymentService = paymentService,
       _iapService = iapService;

  final SubscriptionService _subscriptionService;
  final PaymentService _paymentService;
  final IapService _iapService;
  late final Razorpay _razorpay;

  // Plan loading state
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedDuration = 'monthly'.obs;
  final RxList<SubscriptionPlan> plans = <SubscriptionPlan>[].obs;

  // Payment state
  final RxString paymentStatus = PaymentStatus.idle.toString().obs;
  final RxString processingPlanId = ''.obs;
  final RxString paymentError = ''.obs;
  final RxString activePlanId = ''.obs;
  final RxString activePlanCode = ''.obs;
  SubscriptionPlan? _currentPlanForPayment;

  // IAP state
  final RxBool isIapAvailable = false.obs;

  /// Check if a specific plan is currently processing payment
  bool isProcessingPlan(SubscriptionPlan plan) {
    return processingPlanId.value == plan.id;
  }

  bool isCurrentPlan(SubscriptionPlan plan) {
    if (plan.id.isNotEmpty && activePlanId.value.isNotEmpty) {
      return plan.id == activePlanId.value;
    }
    if (activePlanCode.value.isNotEmpty) {
      return plan.code.toLowerCase() == activePlanCode.value.toLowerCase();
    }
    return false;
  }

  List<String> get availableDurations {
    final durations = <String>{};
    for (final plan in plans) {
      durations.addAll(plan.prices.keys);
    }
    if (durations.isEmpty) return ['monthly', 'yearly'];

    final list = durations.toList();
    // Sort them in a preferred order
    final order = ['monthly', 'quarterly', 'yearly', 'one_time'];
    list.sort((a, b) {
      final indexA = order.indexOf(a);
      final indexB = order.indexOf(b);
      if (indexA != -1 && indexB != -1) return indexA.compareTo(indexB);
      if (indexA != -1) return -1;
      if (indexB != -1) return 1;
      return a.compareTo(b);
    });
    return list;
  }

  List<SubscriptionPlan> get visiblePlans {
    final duration = selectedDuration.value;
    return plans
        .where((plan) => plan.isFree || plan.supportsDuration(duration))
        .toList(growable: false);
  }

  @override
  void onInit() {
    super.onInit();
    _initializeRazorpay();
    _initializeIap();
    fetchPlans();
  }

  @override
  void onClose() {
    _razorpay.clear();
    _iapService.dispose();
    super.onClose();
  }

  // ═══════════════════════════════════════════════════════════════════
  // RAZORPAY
  // ═══════════════════════════════════════════════════════════════════

  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    paymentStatus.value = PaymentStatus.loading.toString();
    paymentError.value = '';

    final plan = _currentPlanForPayment;
    final billingCycle = selectedDuration.value;
    if (plan == null) {
      processingPlanId.value = '';
      paymentStatus.value = PaymentStatus.failure.toString();
      paymentError.value = 'Plan details missing for payment verification.';
      Get.snackbar('Verification Failed', paymentError.value);
      return;
    }

    _verifyRazorpayPayment(
      planCode: plan.code,
      billingCycle: billingCycle,
      razorpayOrderId: response.orderId ?? '',
      razorpayPaymentId: response.paymentId ?? '',
      razorpaySignature: response.signature ?? '',
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    processingPlanId.value = '';
    final message = response.message ?? 'Payment failed. Please try again.';
    final lower = message.toLowerCase();
    final cancelled = lower.contains('cancel');
    paymentStatus.value = cancelled
        ? PaymentStatus.cancelled.toString()
        : PaymentStatus.failure.toString();
    paymentError.value = message;

    Get.snackbar(
      cancelled ? 'Payment Cancelled' : 'Payment Failed',
      paymentError.value,
      duration: const Duration(seconds: 4),
      colorText: const Color(0xFFFFFFFF),
    );
    _currentPlanForPayment = null;
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    paymentStatus.value = PaymentStatus.loading.toString();
    Get.snackbar(
      'Processing',
      'Please complete payment in ${response.walletName}',
    );
  }

  Future<void> _verifyRazorpayPayment({
    required String planCode,
    required String billingCycle,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final verification = PaymentVerificationRequest(
      planCode: planCode,
      billingCycle: billingCycle,
      razorpayOrderId: razorpayOrderId,
      razorpayPaymentId: razorpayPaymentId,
      razorpaySignature: razorpaySignature,
    );

    final result = await _paymentService.verifyPayment(verification);
    _handleVerificationResult(result);
  }

  /// Initiate Razorpay payment for a plan.
  Future<void> initiateRazorpayPayment(SubscriptionPlan plan) async {
    final duration = selectedDuration.value;
    final selectedPrice = plan.priceFor(duration);

    _currentPlanForPayment = plan;
    processingPlanId.value = plan.id;
    paymentStatus.value = PaymentStatus.loading.toString();
    paymentError.value = '';

    final orderResult = await _paymentService.createOrder(
      planCode: plan.code,
      billingCycle: duration,
    );

    if (!orderResult.isSuccess || orderResult.data == null) {
      processingPlanId.value = '';
      paymentStatus.value = PaymentStatus.failure.toString();
      paymentError.value = orderResult.message ?? 'Failed to create order';
      Get.snackbar(
        'Error',
        paymentError.value,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    final order = orderResult.data!;
    _openRazorpayPayment(
      order: order,
      plan: plan,
      displayAmount: (selectedPrice?.amountMinor ?? 0) / 100,
    );
  }

  void _openRazorpayPayment({
    required RazorpayOrder order,
    required SubscriptionPlan plan,
    required double displayAmount,
  }) {
    final razorpayKey = order.razorpayKey.isNotEmpty
        ? order.razorpayKey
        : _fallbackRazorpayKeyId;

    if (razorpayKey.isEmpty) {
      processingPlanId.value = '';
      paymentStatus.value = PaymentStatus.failure.toString();
      paymentError.value =
          'Payment key is missing in order response. Please contact support.';
      Get.snackbar('Payment Setup Error', paymentError.value);
      return;
    }

    try {
      // NOTE: order.amount comes directly from the Razorpay order created
      // by the backend. It MUST be passed as-is — Razorpay rejects mismatches.
      // If the amount shown is wrong (e.g. ₹1.49 instead of ₹149), the
      // backend needs to create the order with amountMinor * 100 (paise).
      debugPrint(
        'Razorpay: orderId=${order.orderId}, '
        'amount=${order.amount} paise, '
        'currency=${order.currency}',
      );

      final options = <String, dynamic>{
        'key': razorpayKey,
        'order_id': order.orderId,
        'amount': order.amount,
        'currency': order.currency,
        'name': 'Estoriz',
        'description': '${plan.displayName} Subscription',
        'timeout': 300,
        'prefill': {},
        'theme': {'color': '#7C3AED'},
      };

      _razorpay.open(options);
    } catch (error) {
      processingPlanId.value = '';
      paymentStatus.value = PaymentStatus.failure.toString();
      paymentError.value = 'Failed to open payment gateway: $error';
      Get.snackbar('Error', paymentError.value);
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // IN-APP PURCHASE
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _initializeIap() async {
    await _iapService.initialize();
    isIapAvailable.value = _iapService.isAvailable;

    if (!_iapService.isAvailable) return;

    // Wire up purchase callbacks
    _iapService.onPurchaseCompleted = _handleIapPurchaseCompleted;
    _iapService.onPurchaseError = _handleIapPurchaseError;

    // Product IDs are fetched dynamically in fetchPlans() after the
    // API returns actual plan codes and billing cycles.
  }

  /// Initiate an In-App Purchase for a plan.
  void initiateIapPayment(SubscriptionPlan plan) {
    final duration = selectedDuration.value;
    final productId = IapService.productIdFor(plan.code, duration);

    _currentPlanForPayment = plan;
    processingPlanId.value = plan.id;
    paymentStatus.value = PaymentStatus.loading.toString();
    paymentError.value = '';

    final started = _iapService.buySubscription(productId);
    if (!started) {
      processingPlanId.value = '';
      paymentStatus.value = PaymentStatus.failure.toString();
    }
  }

  void _handleIapPurchaseCompleted(PurchaseDetails details) {
    final plan = _currentPlanForPayment;
    if (plan == null) {
      processingPlanId.value = '';
      paymentStatus.value = PaymentStatus.failure.toString();
      paymentError.value = 'Plan details missing for verification.';
      Get.snackbar('Verification Failed', paymentError.value);
      return;
    }

    paymentStatus.value = PaymentStatus.loading.toString();
    final billingCycle = selectedDuration.value;

    // Build gateway-specific verification payload
    Map<String, dynamic> verificationData;

    if (Platform.isIOS) {
      verificationData = ApplePayVerificationRequest(
        planCode: plan.code,
        billingCycle: billingCycle,
        receiptData: details.verificationData.serverVerificationData,
      ).toJson();
    } else {
      verificationData = GooglePlayVerificationRequest(
        planCode: plan.code,
        billingCycle: billingCycle,
        packageName: _packageName,
        purchaseToken: details.verificationData.serverVerificationData,
      ).toJson();
    }

    _verifyIapWithBackend(verificationData);
  }

  void _handleIapPurchaseError(String error) {
    processingPlanId.value = '';
    _currentPlanForPayment = null;
    final cancelled = error.toLowerCase().contains('cancel');
    paymentStatus.value = cancelled
        ? PaymentStatus.cancelled.toString()
        : PaymentStatus.failure.toString();
    paymentError.value = error;

    Get.snackbar(
      cancelled ? 'Purchase Cancelled' : 'Purchase Failed',
      error,
      duration: const Duration(seconds: 4),
      colorText: const Color(0xFFFFFFFF),
    );
  }

  Future<void> _verifyIapWithBackend(
    Map<String, dynamic> verificationData,
  ) async {
    final result = await _paymentService.verifyIapPayment(verificationData);
    _handleVerificationResult(result);
  }

  // ═══════════════════════════════════════════════════════════════════
  // SHARED
  // ═══════════════════════════════════════════════════════════════════

  /// Common handler for both Razorpay and IAP verification results.
  void _handleVerificationResult(dynamic result) {
    processingPlanId.value = '';
    _currentPlanForPayment = null;

    if (result.isSuccess && result.data!.isVerified) {
      paymentStatus.value = PaymentStatus.success.toString();
      paymentError.value = '';

      fetchPlans();

      Get.snackbar(
        'Payment Successful!',
        'Your subscription has been activated.',
        duration: const Duration(seconds: 3),
        colorText: const Color(0xFFFFFFFF),
      );
    } else {
      paymentStatus.value = PaymentStatus.failure.toString();
      paymentError.value =
          result.message ??
          'Payment verification failed. Please contact support.';

      Get.snackbar(
        'Verification Failed',
        paymentError.value,
        duration: const Duration(seconds: 4),
      );
    }
  }

  /// Entry point: shows the payment method selector, then routes to
  /// Razorpay or IAP based on the user's choice.
  Future<void> initiatePayment(SubscriptionPlan plan) async {
    // Free plan
    if (plan.isFree) {
      Get.snackbar('Free Plan', 'You are already using the free plan');
      return;
    }

    if (isCurrentPlan(plan)) {
      Get.snackbar('Current Plan', 'This plan is already active');
      return;
    }

    // Prevent concurrent payments
    if (processingPlanId.value.isNotEmpty) return;

    final duration = selectedDuration.value;
    final selectedPrice = plan.priceFor(duration);

    if (selectedPrice == null) {
      paymentError.value = 'Plan not available for selected duration';
      Get.snackbar('Error', paymentError.value);
      return;
    }

    // Show payment method selection bottom sheet
    _showPaymentMethodSheet(plan);
  }

  /// Shows a bottom sheet letting the user choose between Razorpay and
  /// Google Play / Apple Pay.
  void _showPaymentMethodSheet(SubscriptionPlan plan) {
    final context = Get.context;
    if (context == null) return;

    final platformLabel = Platform.isIOS ? 'Apple Pay' : 'Google Play';
    final platformIcon = Platform.isIOS ? Icons.apple : Icons.shop_rounded;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          border: Border(
            top: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 30.h),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 44.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              SizedBox(height: 20.h),

              // Title
              Text(
                'Choose Payment Method',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Select how you\'d like to pay for ${plan.displayName}',
                style: TextStyle(color: Colors.white54, fontSize: 12.sp),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 22.h),

              // Razorpay option
              _PaymentMethodTile(
                icon: Icons.account_balance_rounded,
                label: 'Razorpay',
                subtitle: 'UPI, Cards, Net Banking & more',
                accentColor: const Color(0xFF528FF0),
                onTap: () {
                  Navigator.of(context).pop();
                  initiateRazorpayPayment(plan);
                },
              ),
              SizedBox(height: 12.h),

              // Google Play / Apple Pay option
              _PaymentMethodTile(
                icon: platformIcon,
                label: platformLabel,
                subtitle: Platform.isIOS
                    ? 'Pay with your Apple ID'
                    : 'Pay with your Google account',
                accentColor: Platform.isIOS
                    ? Colors.white
                    : const Color(0xFF34A853),
                enabled: isIapAvailable.value,
                onTap: () {
                  Navigator.of(context).pop();
                  initiateIapPayment(plan);
                },
              ),

              if (!isIapAvailable.value) ...[
                SizedBox(height: 8.h),
                Text(
                  '$platformLabel is currently unavailable on this device',
                  style: TextStyle(
                    color: Colors.white30,
                    fontSize: 10.sp,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // PLANS & HELPERS
  // ═══════════════════════════════════════════════════════════════════

  Future<void> fetchPlans() async {
    isLoading.value = true;
    errorMessage.value = '';

    final activeResult = await _subscriptionService
        .fetchActiveSubscriptionPlan();
    if (activeResult.isSuccess && activeResult.data != null) {
      activePlanId.value = activeResult.data!.planId;
      activePlanCode.value = activeResult.data!.planCode ?? '';
    } else {
      activePlanId.value = '';
      activePlanCode.value = '';
    }

    final result = await _subscriptionService.fetchPlans();
    if (result.isSuccess && result.data != null) {
      plans.assignAll(result.data!);

      // Fetch IAP products for all plan codes
      if (_iapService.isAvailable) {
        final productIds = <String>{};
        for (final plan in plans) {
          if (!plan.isFree) {
            for (final cycle in plan.prices.keys) {
              productIds.add(IapService.productIdFor(plan.code, cycle));
            }
          }
        }
        if (productIds.isNotEmpty) {
          _iapService.fetchProducts(productIds);
        }
      }
    } else {
      plans.clear();
      errorMessage.value = result.message ?? 'Failed to load plans';
    }

    isLoading.value = false;
  }

  void changeDuration(String duration) {
    selectedDuration.value = duration;
  }

  String formatPrice(SubscriptionPrice? price) {
    if (price == null) return 'Free';
    final amount = price.amountMinor / 100;
    final isWhole = amount == amount.roundToDouble();
    final value = isWhole
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
    return '${_currencySymbol(price.currency)}$value';
  }

  String durationLabel(String duration) => _durationLabel(duration);

  String subtitleFor(SubscriptionPlan plan) {
    if (plan.isFree) return 'Start watching with basic access';
    final details = <String>[];
    if (plan.features.adFree) details.add('Ad-free');
    if (plan.features.maxDevices != null) {
      details.add('${plan.features.maxDevices} devices');
    }
    if (plan.features.earlyAccess) details.add('Early access');
    if (plan.features.prioritySupport) details.add('Priority support');

    if (details.isEmpty && plan.features.raw.isNotEmpty) {
      return plan.features.displayFeatures.take(2).join(' | ');
    }

    return details.join(' | ');
  }

  List<String> featureBullets(SubscriptionPlan plan) {
    final bullets = <String>[];

    // If we have display features from the new API, use them
    final displayFeatures = plan.features.displayFeatures;
    if (displayFeatures.isNotEmpty &&
        !plan.features.raw.containsKey('adFree')) {
      return displayFeatures;
    }

    bullets.add(
      plan.features.adFree
          ? 'Ad-free entertainment'
          : 'Standard streaming access',
    );

    // Add any other display features that aren't adFree
    for (final feature in displayFeatures) {
      if (feature.toLowerCase().contains('ad-free') ||
          feature.toLowerCase().contains('adfree')) {
        continue;
      }
      bullets.add(feature);
    }

    return bullets.toSet().toList(); // Remove duplicates
  }

  String _currencySymbol(String code) {
    switch (code.toUpperCase()) {
      case 'INR':
        return 'Rs ';
      case 'USD':
        return r'$';
      default:
        return '${code.toUpperCase()} ';
    }
  }

  String _durationLabel(String duration) {
    switch (duration) {
      case 'monthly':
        return 'Month';
      case 'quarterly':
        return '3 Months';
      case 'yearly':
        return 'Yearly';
      case 'one_time':
        return 'One-Time';
      default:
        return duration.isNotEmpty
            ? duration[0].toUpperCase() + duration.substring(1)
            : duration;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Payment method tile (used in the bottom sheet)
// ═══════════════════════════════════════════════════════════════════════

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.4,
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16.r),
          splashColor: accentColor.withValues(alpha: 0.15),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(icon, color: accentColor, size: 24.sp),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white30,
                  size: 16.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
