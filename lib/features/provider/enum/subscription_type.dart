/// Global enum for subscription plan types
///
/// This enum represents all available subscription plans in the application.
/// Use this enum throughout the app for type-safe subscription handling.
enum SubscriptionType {
  /// No active subscription
  none,

  /// Basic subscription plan - Entry level features
  basic,

  /// Standard subscription plan - Mid-tier features
  standard,

  /// Premium subscription plan - Full features
  premium;

  /// Get the display name for the subscription type
  String get displayName {
    switch (this) {
      case SubscriptionType.none:
        return 'No Subscription';
      case SubscriptionType.basic:
        return 'Basic';
      case SubscriptionType.standard:
        return 'Standard';
      case SubscriptionType.premium:
        return 'Premium';
    }
  }

  /// Get the subscription type from a string (case-insensitive)
  static SubscriptionType fromString(String? value) {
    if (value == null || value.isEmpty) {
      return SubscriptionType.none;
    }

    switch (value.toLowerCase().trim()) {
      case 'basic':
        return SubscriptionType.basic;
      case 'standard':
        return SubscriptionType.standard;
      case 'premium':
        return SubscriptionType.premium;
      default:
        return SubscriptionType.none;
    }
  }

  /// Convert enum to string for API calls (lowercase)
  String toApiString() {
    switch (this) {
      case SubscriptionType.none:
        return '';
      case SubscriptionType.basic:
        return 'basic';
      case SubscriptionType.standard:
        return 'standard';
      case SubscriptionType.premium:
        return 'premium';
    }
  }

  /// Check if user has an active subscription
  bool get isActive => this != SubscriptionType.none;

  /// Check if this is a specific plan
  bool get isBasic => this == SubscriptionType.basic;
  bool get isStandard => this == SubscriptionType.standard;
  bool get isPremium => this == SubscriptionType.premium;

  /// Get tier level (higher is better)
  int get tierLevel {
    switch (this) {
      case SubscriptionType.none:
        return 0;
      case SubscriptionType.basic:
        return 1;
      case SubscriptionType.standard:
        return 2;
      case SubscriptionType.premium:
        return 3;
    }
  }

  /// Compare if this subscription is better than another
  bool isBetterThan(SubscriptionType other) {
    return tierLevel > other.tierLevel;
  }

  /// Compare if this subscription is worse than another
  bool isWorseThan(SubscriptionType other) {
    return tierLevel < other.tierLevel;
  }

  /// Get all active subscription types (excluding none)
  static List<SubscriptionType> get activeTypes => [
    SubscriptionType.basic,
    SubscriptionType.standard,
    SubscriptionType.premium,
  ];
}