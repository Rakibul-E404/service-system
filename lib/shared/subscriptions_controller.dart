
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/shared/subscriptions_get_response_model.dart';
import '../../core/network/network_caller.dart';
import '../core/config/app_constants.dart';
import '../core/data/secured_storage.dart';
import '../core/utils/api/app_url.dart';

class SubscriptionsController extends GetxController {
  // Observables
  final RxBool isLoading = false.obs;
  final Rx<ProviderSubscriptionData?> subscriptionData = Rx<ProviderSubscriptionData?>(null);

  // Dependencies
  final NetworkCaller _networkCaller = NetworkCaller();
  final SecureStorageService _secureStorage = SecureStorageService();

  @override
  void onInit() {
    super.onInit();
    fetchSubscription();
  }

  /// 🔹 API: FETCH PROVIDER SUBSCRIPTION
  Future<void> fetchSubscription() async {
    try {
      isLoading.value = true;

      // Get token from secure storage
      final String? token = await _secureStorage.read(AppConstants.authToken);

      if (token == null) {
        debugPrint("❌ No Auth Token found for Subscription");
        return;
      }

      final response = await _networkCaller.getRequest(
        AppUrl.subscriptionGlobalGet, // Update this path if needed
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final resModel = SubscriptionsGetResponseModel.fromJson(response.jsonResponse!);
        subscriptionData.value = resModel.data;
      } else {
        debugPrint("❌ Failed to fetch subscription: ${response.errorMessage}");
      }
    } catch (e) {
      debugPrint("🔥 Subscription Controller Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔹 HELPER: Check if subscription is active
  bool get isSubscriptionActive {
    if (subscriptionData.value == null) return false;
    return subscriptionData.value!.status.toLowerCase() == 'active';
  }

  /// 🔹 HELPER: Calculate remaining days
  int get remainingDays {
    if (subscriptionData.value?.endDate == null) return 0;
    final difference = subscriptionData.value!.endDate!.difference(DateTime.now());
    return difference.inDays > 0 ? difference.inDays : 0;
  }


  bool get canAccessOpeningHours {
    if (subscriptionData.value == null) return false;

    // Logic: Must be active AND have the specific access string
    bool isActive = subscriptionData.value!.status.toLowerCase() == 'active';
    bool hasFeature = subscriptionData.value!.access.contains("OpeningHours");

    return isActive && hasFeature;
  }

  bool get canAccessQuotes {
    final data = subscriptionData.value;
    if (data == null) return false;

    final bool isActive = data.status.toLowerCase() == 'active';
    final bool hasFeature = data.access.contains("PostInquiry"); // Logic: check for PostInquiry

    return isActive && hasFeature;
  }


  bool get hasQuoteAccess =>
      subscriptionData.value?.status.toLowerCase() == 'active' &&
          (subscriptionData.value?.access.contains("PostInquiry") ?? false);



  // Inside SubscriptionsController
  bool get canCall =>
      subscriptionData.value?.status.toLowerCase() == 'active' &&
          (subscriptionData.value?.access.contains("Call") ?? false);

  bool get canEmail =>
      subscriptionData.value?.status.toLowerCase() == 'active' &&
          (subscriptionData.value?.access.contains("Email") ?? false);

  bool get canMessage =>
      subscriptionData.value?.status.toLowerCase() == 'active' &&
          (subscriptionData.value?.access.contains("Massaging") ?? false);

// Helper for the Snackbar
  void showPremiumContactAlert(String feature) {
    Get.snackbar(
      "Premium Feature",
      "The $feature option is only available for active Premium members.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.amber[800],
      colorText: Colors.white,
      margin: const EdgeInsets.all(15),
      icon: const Icon(Icons.stars, color: Colors.white),
    );
  }
}