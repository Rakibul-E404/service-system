
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/routes/app_routes.dart';
import 'package:manx_mate/shared/subscriptions_get_response_model.dart';
import '../../core/network/network_caller.dart';
import '../core/config/app_constants.dart';
import '../core/data/secured_storage.dart';
import '../core/utils/api/app_url.dart';
import '../core/utils/token_service/token_storage_service.dart';

class SubscriptionsController extends GetxController {
  // Observables
  final RxBool isLoading = false.obs;
  final Rx<ProviderSubscriptionData?> subscriptionData = Rx<ProviderSubscriptionData?>(null);

  // Dependencies
  final NetworkCaller _networkCaller = NetworkCaller();
  final SecureStorageService _secureStorage = SecureStorageService();

  final RxString userRole = ''.obs;

  Future<void> _initUserRole() async {
    userRole.value = await Get.find<SharedPrefService>().getUserRole() ?? '';

  }


  @override
  void onInit() {
    super.onInit();
    _initUserRole();
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

  bool get canMessage {

    if (userRole.value != "provider") {
      return true;
    }

    final bool isActive = subscriptionData.value?.status.toLowerCase() == 'active';
    final bool hasMessagingAccess = subscriptionData.value?.access.contains("Massaging") ?? false;

    return isActive && hasMessagingAccess;
  }

// Helper for the Alert Dialog with Upgrade Plan button
  void showPremiumContactAlert(String feature) {
    Get.dialog(
      AlertDialog(
        title: const Text("Premium Feature"),
        content: Text("The $feature option is only available for active Premium members."),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close the dialog
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close the dialog first
              Get.toNamed(AppRoutes.subscriptionPageRoute); // Navigate to subscription page
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[800],
              foregroundColor: Colors.white,
            ),
            child: const Text("Upgrade Plan"),
          ),
        ],
      ),
    );
  }
}