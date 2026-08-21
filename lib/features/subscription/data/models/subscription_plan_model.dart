class SubscriptionPlan {
  final String id;
  final String code;
  final String displayName;
  final int tierRank;
  final bool isReachedLimit;
  final SubscriptionFeatures features;
  final Map<String, SubscriptionPrice> prices;

  const SubscriptionPlan({
    required this.id,
    required this.code,
    required this.displayName,
    required this.tierRank,
    required this.isReachedLimit,
    required this.features,
    required this.prices,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    final plan = Map<String, dynamic>.from(json['plan'] as Map? ?? const {});
    final rawPrices = Map<String, dynamic>.from(
      json['prices'] as Map? ?? const {},
    );

    return SubscriptionPlan(
      id: plan['id']?.toString() ?? '',
      code: plan['code']?.toString() ?? '',
      displayName: plan['displayName']?.toString() ?? 'Plan',
      tierRank: (plan['tierRank'] as num?)?.toInt() ?? 0,
      isReachedLimit: json['isReachedLimit'] == true,
      features: SubscriptionFeatures.fromJson(
        Map<String, dynamic>.from(plan['features'] as Map? ?? const {}),
      ),
      prices: rawPrices.map(
        (key, value) => MapEntry(
          key,
          SubscriptionPrice.fromJson(
            Map<String, dynamic>.from(value as Map? ?? const {}),
          ),
        ),
      ),
    );
  }

  bool get isFree => prices.isEmpty || code.toLowerCase() == 'free';

  SubscriptionPrice? priceFor(String duration) => prices[duration];

  bool supportsDuration(String duration) => priceFor(duration) != null;
}

class SubscriptionFeatures {
  final Map<String, dynamic> raw;

  const SubscriptionFeatures({required this.raw});

  factory SubscriptionFeatures.fromJson(Map<String, dynamic> json) {
    return SubscriptionFeatures(raw: json);
  }

  /// Returns a list of human-readable feature strings for display.
  List<String> get displayFeatures {
    final list = <String>[];
    raw.forEach((key, value) {
      if (value == null) return;

      // Handle specific types or just convert to string
      if (value is bool) {
        if (value) {
          list.add(_normalizeKey(key));
        }
      } else if (value is List) {
        if (value.isNotEmpty) {
          list.add('$key: ${value.join(", ")}');
        }
      } else {
        // If the key is already descriptive (like in the new API), just show value or key: value
        if (_isDescriptiveKey(key)) {
          list.add('$key: $value');
        } else {
          list.add('$key: $value');
        }
      }
    });
    return list;
  }

  bool get adFree => raw['adFree'] == true || raw['Ad-free'] == true;
  String? get contentTier => raw['contentTier']?.toString();
  int? get maxDevices => _toInt(raw['maxDevices'] ?? raw['Supported Device']);
  int? get videoQuality =>
      _toInt(raw['videoQuality'] ?? raw['Video and Sound Quality']);
  bool get earlyAccess => raw['earlyAccess'] == true;
  bool get prioritySupport => raw['prioritySupport'] == true;

  int? _toInt(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) {
      final match = RegExp(r'(\d+)').firstMatch(value);
      if (match != null) return int.tryParse(match.group(1)!);
    }
    return null;
  }

  String _normalizeKey(String key) {
    // Convert camelCase to Title Case with spaces
    final result = key.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(1)}',
    );
    return result[0].toUpperCase() + result.substring(1).trim();
  }

  bool _isDescriptiveKey(String key) {
    // Keys from the new API like "Video and Sound Quality" are already descriptive
    return key.contains(' ');
  }
}

class SubscriptionPrice {
  final int amountMinor;
  final String currency;
  final int version;
  final String priceVersionId;

  const SubscriptionPrice({
    required this.amountMinor,
    required this.currency,
    required this.version,
    required this.priceVersionId,
  });

  factory SubscriptionPrice.fromJson(Map<String, dynamic> json) {
    return SubscriptionPrice(
      amountMinor: (json['amountMinor'] as num?)?.toInt() ?? 0,
      currency: json['currency']?.toString() ?? 'INR',
      version: (json['version'] as num?)?.toInt() ?? 1,
      priceVersionId: json['priceVersionId']?.toString() ?? '',
    );
  }
}
