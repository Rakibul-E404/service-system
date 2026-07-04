/**

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/utils/api/app_url.dart';
import '../../../core/utils/token_service/token_storage_service.dart';
import '../enum/subscription_type.dart'; // Import the enum

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubscriptionController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();
  final SharedPrefService _sharedPrefService = SharedPrefService();

  RxBool isLoading = false.obs;
  RxList<SubscriptionModel> subscriptionPlans = <SubscriptionModel>[].obs;

  // Observable current state
  Rx<String?> currentPackage = Rx<String?>(null);
  Rx<String?> endDate = Rx<String?>(null);
  Rx<String?> status = Rx<String?>(null);
  RxList<String> currentAccess = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    refreshSubscriptions();
  }

  // --- GETTERS FOR PERMISSIONS ---
  bool get canCall => currentAccess.contains('Call') && status.value == 'active';
  bool get canEmail => currentAccess.contains('Email') && status.value == 'active';
  bool get canMessage => currentAccess.contains('Massaging') && status.value == 'active';

  Future<void> refreshSubscriptions() async {
    isLoading.value = true;
    await Future.wait([
      fetchUserCurrentPlan(),
      fetchSubscriptions(),
    ]);
    isLoading.value = false;
  }

  Future<void> fetchUserCurrentPlan() async {
    try {
      final accessToken = await _sharedPrefService.getAccessToken();
      final response = await _networkCaller.getRequest(
        AppUrl.subscriptionGlobalGet,
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final responseData = response.jsonResponse!;
        if (responseData['success'] == true) {
          final data = responseData['data'];
          if (data != null && data['status'] == 'active') {
            final subscription = data['subscription'];
            currentPackage.value = subscription['title'];
            endDate.value = data['endDate'];
            status.value = data['status'];
            currentAccess.value = List<String>.from(subscription['access'] ?? []);
          } else {
            _clearSubscriptionData();
          }
        }
      }
    } catch (e) {
      _clearSubscriptionData();
    }
  }

  void _clearSubscriptionData() {
    currentPackage.value = null;
    currentAccess.clear();
    status.value = null;
    endDate.value = null;
  }

  Future<void> fetchSubscriptions() async {
    try {
      final accessToken = await _sharedPrefService.getAccessToken();
      final response = await _networkCaller.getRequest(
        'https://d7001.sobhoy.com/api/v1/subscription/',
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final model = SubscriptionListResponseModel.fromJson(response.jsonResponse!);
        subscriptionPlans.value = model.data.subscriptions;
        subscriptionPlans.sort((a, b) => a.price.compareTo(b.price));
      }
    } catch (e) {
      debugPrint('❌ Error: $e');
    }
  }

  // --- UPGRADE LOGIC ---
  Future<void> onUpgradeNow(SubscriptionModel plan) async {
    final confirmed = await _showUpgradeConfirmation(plan);
    if (!confirmed) return;

    try {
      _showLoading();
      final accessToken = await _sharedPrefService.getAccessToken();

      // Using the dynamic route helper for the URL
      final url = AppUrl.subscriptionDirectPurchase(plan.id);

      final response = await _networkCaller.postRequest(
        url,
        body: {},
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      Get.back(); // Close loading dialog

      if (response.isSuccess) {
        await fetchUserCurrentPlan();
        _showSuccessDialog(plan);
      } else {
        Get.snackbar(
          'Purchase Failed',
          response.errorMessage ?? 'Something went wrong',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar(
          'Error',
          'Connection failed',
          backgroundColor: Colors.red,
          colorText: Colors.white
      );
    }
  }

  // --- UI HELPERS ---
  bool isCurrentPlan(String title) => currentPackage.value == title;

  Color getPlanColor(String title) {
    switch (title.toLowerCase()) {
      case 'basic': return const Color(0xFFE53935);
      case 'standard': return const Color(0xFF1E88E5);
      case 'professional':
      case 'premium': return const Color(0xFFFDD835);
      default: return Colors.grey;
    }
  }

  Color getPlanBackgroundColor(String title) => getPlanColor(title).withOpacity(0.05);

  IconData getPlanIcon(String title) {
    if (title.toLowerCase() == 'basic') return Icons.card_giftcard;
    if (title.toLowerCase() == 'standard') return Icons.stars;
    return Icons.workspace_premium;
  }

  // --- DIALOGS ---
  void _showLoading() => Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false
  );

  Future<bool> _showUpgradeConfirmation(SubscriptionModel plan) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Upgrade to ${plan.title}'),
        content: Text('Would you like to subscribe for €${plan.price.toStringAsFixed(2)}?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: getPlanColor(plan.title)),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showSuccessDialog(SubscriptionModel plan) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text('Success'),
        content: Text('Your ${plan.title} plan is now active!'),
        actions: [
          Center(
            child: TextButton(
                onPressed: () => Get.back(),
                child: const Text('Continue')
            ),
          )
        ],
      ),
    );
  }
}


class SubscriptionListResponseModel {
  final bool success;
  final int code;
  final String message;
  final SubscriptionListData data;

  SubscriptionListResponseModel({
    required this.success,
    required this.code,
    required this.message,
    required this.data,
  });

  factory SubscriptionListResponseModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionListResponseModel(
      success: json['success'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: SubscriptionListData.fromJson(json['data'] ?? {}),
    );
  }
}
class SubscriptionListData {
  final List<SubscriptionModel> subscriptions;
  final Pagination pagination;

  SubscriptionListData({
    required this.subscriptions,
    required this.pagination,
  });

  factory SubscriptionListData.fromJson(Map<String, dynamic> json) {
    return SubscriptionListData(
      subscriptions: (json['data'] as List<dynamic>? ?? [])
          .map((e) => SubscriptionModel.fromJson(e))
          .toList(),
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }
}
class SubscriptionModel {
  final String id;
  final String title;
  final double price;
  final int duration;
  final String durationType;
  final List<String> description;
  final List<String> access;

  SubscriptionModel({
    required this.id,
    required this.title,
    required this.price,
    required this.duration,
    required this.durationType,
    required this.description,
    required this.access,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      duration: json['duration'] ?? 0,
      durationType: json['durationType'] ?? '',
      description: List<String>.from(json['description'] ?? []),
      access: List<String>.from(json['access'] ?? []),
    );
  }
}
class Pagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  Pagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'] ?? 0,
      limit: json['limit'] ?? 0,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}


class SubscriptionPlan {
  final String id;
  final String title;
  final SubscriptionType type; // Using enum
  final double price;
  final int duration;
  final List<String> description;

  SubscriptionPlan({
    required this.id,
    required this.title,
    required this.type,
    required this.price,
    required this.duration,
    required this.description,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      type: SubscriptionType.fromString(json['title']), // Convert to enum
      price: (json['price'] ?? 0).toDouble(),
      duration: json['duration'] ?? 0,
      description: List<String>.from(json['description'] ?? []),
    );
  }

  // Check if this is a specific plan type
  bool get isBasic => type == SubscriptionType.basic;
  bool get isStandard => type == SubscriptionType.standard;
  bool get isPremium => type == SubscriptionType.premium;
}
*/









///
///
///
/// todo::: matching with subscription id
///
///
///
///




import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/utils/api/app_url.dart';
import '../../../core/utils/token_service/token_storage_service.dart';

class SubscriptionController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();
  final SharedPrefService _sharedPrefService = SharedPrefService();

  RxBool isLoading = false.obs;
  RxList<SubscriptionModel> subscriptionPlans = <SubscriptionModel>[].obs;

  // Observable current state
  Rx<String?> currentPackageId = Rx<String?>(null);
  Rx<String?> currentPackageTitle = Rx<String?>(null);
  Rx<String?> endDate = Rx<String?>(null);
  Rx<String?> status = Rx<String?>(null);
  RxList<String> currentAccess = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    refreshSubscriptions();
  }

  // --- GETTERS FOR PERMISSIONS ---
  bool get canCall => currentAccess.contains('Call') && status.value == 'active';
  bool get canEmail => currentAccess.contains('Email') && status.value == 'active';
  bool get canMessage => currentAccess.contains('Massaging') && status.value == 'active';

  Future<void> refreshSubscriptions() async {
    isLoading.value = true;
    await Future.wait([
      fetchUserCurrentPlan(),
      fetchSubscriptions(),
    ]);
    isLoading.value = false;
  }

  Future<void> fetchUserCurrentPlan() async {
    try {
      final accessToken = await _sharedPrefService.getAccessToken();
      final response = await _networkCaller.getRequest(
        AppUrl.subscriptionGlobalGet,
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final responseData = response.jsonResponse!;
        if (responseData['success'] == true) {
          final data = responseData['data'];
          if (data != null && data['status'] == 'active') {
            final subscription = data['subscription'];
            currentPackageId.value = subscription['_id'];
            currentPackageTitle.value = subscription['title'];
            endDate.value = data['endDate'];
            status.value = data['status'];
            currentAccess.value = List<String>.from(data['access'] ?? []);
          } else {
            _clearSubscriptionData();
          }
        }
      }
    } catch (e) {
      _clearSubscriptionData();
    }
  }

  void _clearSubscriptionData() {
    currentPackageId.value = null;
    currentPackageTitle.value = null;
    currentAccess.clear();
    status.value = null;
    endDate.value = null;
  }

  Future<void> fetchSubscriptions() async {
    try {
      final accessToken = await _sharedPrefService.getAccessToken();
      final response = await _networkCaller.getRequest(
        // 'https://d7001.sobhoy.com/api/v1/subscription/',
        'https://5003.dipudebnath.tech/api/v1/subscription/',
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final model = SubscriptionListResponseModel.fromJson(response.jsonResponse!);
        subscriptionPlans.value = model.data.subscriptions;
        subscriptionPlans.sort((a, b) => a.price.compareTo(b.price));
      }
    } catch (e) {
      debugPrint('❌ Error: $e');
    }
  }

  // --- UPGRADE LOGIC ---
  Future<void> onUpgradeNow(SubscriptionModel plan) async {
    final confirmed = await _showUpgradeConfirmation(plan);
    if (!confirmed) return;

    try {
      _showLoading();
      final accessToken = await _sharedPrefService.getAccessToken();
      final url = AppUrl.subscriptionDirectPurchase(plan.id);

      final response = await _networkCaller.postRequest(
        url,
        body: {},
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (Get.isDialogOpen ?? false) Get.back(); // Close loading dialog

      if (response.isSuccess) {
        await fetchUserCurrentPlan();
        _showSuccessDialog(plan);
      } else {
        Get.snackbar(
          'Purchase Failed',
          response.errorMessage ?? 'Something went wrong',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar(
        'Error',
        'Connection failed',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // --- UI HELPERS ---
  bool isCurrentPlan(SubscriptionModel plan) {
    return currentPackageId.value == plan.id;
  }

  Color getPlanColor(String title) {
    switch (title.toLowerCase()) {
      case 'basic':
        return const Color(0xFFE53935);
      case 'standard':
        return const Color(0xFF1E88E5);
      case 'professional':
      case 'premium':
        return const Color(0xFFFDD835);
      default:
        return Colors.grey;
    }
  }

  Color getPlanBackgroundColor(String title) => getPlanColor(title).withOpacity(0.05);

  IconData getPlanIcon(String title) {
    if (title.toLowerCase() == 'basic') return Icons.card_giftcard;
    if (title.toLowerCase() == 'standard') return Icons.stars;
    return Icons.workspace_premium;
  }

  // --- DIALOGS ---
  void _showLoading() => Get.dialog(
    const Center(child: CircularProgressIndicator()),
    barrierDismissible: false,
  );

  Future<bool> _showUpgradeConfirmation(SubscriptionModel plan) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Upgrade to ${plan.title}'),
        content: Text('Would you like to subscribe for €${plan.price.toStringAsFixed(2)}?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: getPlanColor(plan.title)),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showSuccessDialog(SubscriptionModel plan) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text('Success'),
        content: Text('Your ${plan.title} plan is now active!'),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Get.back(),
              child: const Text('Continue'),
            ),
          )
        ],
      ),
    );
  }
}

// ------------------ MODELS ------------------

class SubscriptionListResponseModel {
  final bool success;
  final int code;
  final String message;
  final SubscriptionListData data;

  SubscriptionListResponseModel({
    required this.success,
    required this.code,
    required this.message,
    required this.data,
  });

  factory SubscriptionListResponseModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionListResponseModel(
      success: json['success'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: SubscriptionListData.fromJson(json['data'] ?? {}),
    );
  }
}

class SubscriptionListData {
  final List<SubscriptionModel> subscriptions;
  final Pagination pagination;

  SubscriptionListData({
    required this.subscriptions,
    required this.pagination,
  });

  factory SubscriptionListData.fromJson(Map<String, dynamic> json) {
    return SubscriptionListData(
      subscriptions: (json['data'] as List<dynamic>? ?? [])
          .map((e) => SubscriptionModel.fromJson(e))
          .toList(),
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

class SubscriptionModel {
  final String id;
  final String title;
  final double price;
  final int duration;
  final String durationType;
  final List<String> description;
  final List<String> access;

  SubscriptionModel({
    required this.id,
    required this.title,
    required this.price,
    required this.duration,
    required this.durationType,
    required this.description,
    required this.access,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      duration: json['duration'] ?? 0,
      durationType: json['durationType'] ?? '',
      description: List<String>.from(json['description'] ?? []),
      access: List<String>.from(json['access'] ?? []),
    );
  }
}

class Pagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  Pagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'] ?? 0,
      limit: json['limit'] ?? 0,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}
