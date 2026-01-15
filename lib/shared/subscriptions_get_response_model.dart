
class SubscriptionsGetResponseModel {
  final bool success;
  final int code;
  final String message;
  final ProviderSubscriptionData data;

  SubscriptionsGetResponseModel({
    required this.success,
    required this.code,
    required this.message,
    required this.data,
  });

  factory SubscriptionsGetResponseModel.fromJson(
      Map<String, dynamic> json) {
    return SubscriptionsGetResponseModel(
      success: json['success'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: ProviderSubscriptionData.fromJson(json['data'] ?? {}),
    );
  }
}
class ProviderSubscriptionData {
  final String id;
  final SubscriptionInfo subscription;
  final List<String> access;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;
  final DateTime? createdAt;

  ProviderSubscriptionData({
    required this.id,
    required this.subscription,
    required this.access,
    this.startDate,
    this.endDate,
    required this.status,
    this.createdAt,
  });

  factory ProviderSubscriptionData.fromJson(Map<String, dynamic> json) {
    return ProviderSubscriptionData(
      id: json['_id'] ?? '',
      subscription: SubscriptionInfo.fromJson(json['subscription'] ?? {}),
      access: List<String>.from(json['access'] ?? []),
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : null,
      endDate:
      json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      status: json['status'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }
}
class SubscriptionInfo {
  final String id;
  final String title;

  SubscriptionInfo({
    required this.id,
    required this.title,
  });

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) {
    return SubscriptionInfo(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
    );
  }
}
