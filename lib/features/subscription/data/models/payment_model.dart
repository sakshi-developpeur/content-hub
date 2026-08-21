/// Model for Razorpay order creation response
///
/// Handles multiple API response formats:
///   • `{ "data": { "order": { ... } } }`
///   • `{ "data": { "orderId": ..., "amount": ... } }`
///   • `{ "order": { ... } }`
///   • Flat: `{ "orderId": ..., "amount": ... }`
class RazorpayOrder {
  final String orderId;
  final int amount; // Always in the unit returned by the backend (rupees)
  final String currency;
  final String razorpayKey;

  RazorpayOrder({
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.razorpayKey,
  });

  /// Parse from API response — tries multiple nesting patterns.
  factory RazorpayOrder.fromJson(Map<String, dynamic> json) {
    // Unwrap nested structures: json → data → order
    final data = _asMap(json['data']) ?? json;
    final order = _asMap(data['order']) ?? data;

    // — Order ID —
    final orderId = _firstString([
      order['orderId'],
      order['id'],
      data['orderId'],
      data['id'],
      json['orderId'],
    ]);

    // — Amount (in the unit the backend uses, e.g. rupees) —
    final amount = _firstInt([
      order['amount'],
      order['amountMinor'],
      data['amount'],
      data['amountMinor'],
      json['amount'],
      json['amountMinor'],
    ]);

    // — Currency —
    final currency = _firstString([
          order['currency'],
          data['currency'],
          json['currency'],
        ]) ??
        'INR';

    // — Razorpay Key —
    final razorpayKey = _firstString([
          json['razorpay_key'],
          json['razorpayKey'],
          json['key'],
          data['razorpay_key'],
          data['razorpayKey'],
          data['key'],
          order['razorpay_key'],
          order['razorpayKey'],
          order['key'],
        ]) ??
        '';

    return RazorpayOrder(
      orderId: orderId ?? '',
      amount: amount ?? 0,
      currency: currency,
      razorpayKey: razorpayKey,
    );
  }

  /// Safely cast to Map<String, dynamic>, returns null otherwise.
  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  /// Returns the first non-null, non-empty String from a list of candidates.
  static String? _firstString(List<dynamic> candidates) {
    for (final c in candidates) {
      if (c == null) continue;
      final s = c.toString();
      if (s.isNotEmpty) return s;
    }
    return null;
  }

  /// Returns the first non-null int from a list of candidates.
  static int? _firstInt(List<dynamic> candidates) {
    for (final c in candidates) {
      if (c == null) continue;
      if (c is int) return c;
      if (c is num) return c.toInt();
      final parsed = int.tryParse(c.toString());
      if (parsed != null) return parsed;
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    'orderId': orderId,
    'amount': amount,
    'currency': currency,
    'razorpay_key': razorpayKey,
  };
}

/// Model for payment verification request
class PaymentVerificationRequest {
  final String planCode;
  final String billingCycle;
  final String razorpayOrderId;
  final String razorpayPaymentId;
  final String razorpaySignature;

  PaymentVerificationRequest({
    required this.planCode,
    required this.billingCycle,
    required this.razorpayOrderId,
    required this.razorpayPaymentId,
    required this.razorpaySignature,
  });

  Map<String, dynamic> toJson() => {
    'planCode': planCode,
    'billingCycle': billingCycle,
    'razorpayOrderId': razorpayOrderId,
    'razorpayPaymentId': razorpayPaymentId,
    'razorpaySignature': razorpaySignature,
  };
}

/// Model for payment verification response
class PaymentVerificationResponse {
  final bool isVerified;
  final String? message;
  final String? planId;
  final String? subscription;

  PaymentVerificationResponse({
    required this.isVerified,
    this.message,
    this.planId,
    this.subscription,
  });

  factory PaymentVerificationResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : (json['data'] is Map
              ? Map<String, dynamic>.from(json['data'])
              : const <String, dynamic>{});

    return PaymentVerificationResponse(
      isVerified:
          json['verified'] == true ||
          data['verified'] == true ||
          json['success'] == true,
      message: json['message']?.toString() ?? data['message']?.toString(),
      planId: data['planId']?.toString() ?? json['planId']?.toString(),
      subscription:
          data['subscription']?.toString() ?? json['subscription']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'verified': isVerified,
    'message': message,
    'planId': planId,
    'subscription': subscription,
  };
}

/// Enum for payment status
enum PaymentStatus { idle, loading, success, failure, cancelled }

/// Enum for payment error types
enum PaymentErrorType {
  networkError,
  timeoutError,
  verificationFailed,
  invalidOrder,
  unknown,
}

/// Enum for payment gateway type
enum PaymentGateway { razorpay, googlePlay, applePay }

/// Google Play IAP verification request
class GooglePlayVerificationRequest {
  final String planCode;
  final String billingCycle;
  final String packageName;
  final String purchaseToken;

  const GooglePlayVerificationRequest({
    required this.planCode,
    required this.billingCycle,
    required this.packageName,
    required this.purchaseToken,
  });

  Map<String, dynamic> toJson() => {
    'gateway': 'google_play',
    'planCode': planCode,
    'billingCycle': billingCycle,
    'packageName': packageName,
    'purchaseToken': purchaseToken,
  };
}

/// Apple Pay (App Store) IAP verification request
class ApplePayVerificationRequest {
  final String planCode;
  final String billingCycle;
  final String receiptData;

  const ApplePayVerificationRequest({
    required this.planCode,
    required this.billingCycle,
    required this.receiptData,
  });

  Map<String, dynamic> toJson() => {
    'gateway': 'apple_pay',
    'planCode': planCode,
    'billingCycle': billingCycle,
    'receiptData': receiptData,
  };
}
