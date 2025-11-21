/**

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/utils/token_service/token_storage_service.dart';

class SubscriptionController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();
  final SharedPrefService _sharedPrefService = SharedPrefService();

  // Observable variables
  RxBool isLoading = false.obs;
  RxList<SubscriptionPlan> subscriptionPlans = <SubscriptionPlan>[].obs;
  Rx<String?> currentPackage = Rx<String?>(null);

  // Current subscription details (optional)
  Rx<String?> subscriptionId = Rx<String?>(null);
  Rx<String?> startDate = Rx<String?>(null);
  Rx<String?> endDate = Rx<String?>(null);
  Rx<String?> status = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchUserCurrentPlan(); // Fetch user's current plan first
    fetchSubscriptions();
  }

  // Fetch user's current subscription plan
  Future<void> fetchUserCurrentPlan() async {
    try {
      final accessToken = await _sharedPrefService.getAccessToken();

      final response = await _networkCaller.getRequest(
        'https://d7001.sobhoy.com/api/v1/subscription-purchase/current-plan',
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      debugPrint('🔍 Current Plan API Response: ${response.jsonResponse}');

      if (response.isSuccess && response.jsonResponse != null) {
        final responseData = response.jsonResponse!;

        if (responseData['success'] == true) {
          final data = responseData['data'];

          // Check if subscription is active
          if (data['status'] == 'active') {
            // Extract the subscription title from nested object
            final subscription = data['subscription'];
            currentPackage.value = subscription['title'];

            // Store additional subscription details
            subscriptionId.value = data['_id'];
            startDate.value = data['startDate'];
            endDate.value = data['endDate'];
            status.value = data['status'];

            debugPrint('✅ Current active plan: ${currentPackage.value}');
            debugPrint('🆔 Subscription ID: ${subscriptionId.value}');
            debugPrint('📅 Start Date: ${startDate.value}');
            debugPrint('📅 End Date: ${endDate.value}');
            debugPrint('📊 Status: ${status.value}');
          } else {
            debugPrint('⚠️ Subscription exists but is not active: ${data['status']}');
            _clearSubscriptionData();
          }
        } else {
          debugPrint('⚠️ No active subscription found');
          _clearSubscriptionData();
        }
      } else {
        debugPrint('⚠️ No current plan found or API error');
        _clearSubscriptionData();
      }
    } catch (e) {
      debugPrint('❌ Error fetching user subscription: $e');
      _clearSubscriptionData();
    }
  }

  // Helper method to clear subscription data
  void _clearSubscriptionData() {
    currentPackage.value = null;
    subscriptionId.value = null;
    startDate.value = null;
    endDate.value = null;
    status.value = null;
  }

  // Fetch subscriptions from API
  Future<void> fetchSubscriptions() async {
    try {
      isLoading.value = true;

      final accessToken = await _sharedPrefService.getAccessToken();
      final response = await _networkCaller.getRequest(
        'https://d7001.sobhoy.com/api/v1/subscription/',
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      debugPrint('🔍 Subscription API Response: ${response.jsonResponse}');

      if (response.isSuccess && response.jsonResponse != null) {
        final Map<String, dynamic> responseData = response.jsonResponse!;

        if (responseData['success'] == true) {
          final Map<String, dynamic> data = responseData['data'];
          final List<dynamic> plansList = data['data'] ?? [];

          debugPrint('🔍 Found ${plansList.length} subscription plans');

          // Convert API data to our model
          subscriptionPlans.value = plansList.map<SubscriptionPlan>((plan) {
            return SubscriptionPlan.fromJson(plan);
          }).toList();

          // Sort plans by price (Basic -> Standard -> Premium)
          subscriptionPlans.sort((a, b) => a.price.compareTo(b.price));

          debugPrint('✅ Successfully loaded ${subscriptionPlans.length} subscription plans');
        } else {
          debugPrint('❌ API returned success: false');
          subscriptionPlans.value = [];
        }
      } else {
        debugPrint('❌ API call failed: ${response.errorMessage}');
        subscriptionPlans.value = [];
      }
    } catch (e) {
      debugPrint('❌ Error fetching subscriptions: $e');
      subscriptionPlans.value = [];
      Get.snackbar(
        'Error',
        'Failed to load subscription plans',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Get color based on plan title
  Color getPlanColor(String title) {
    switch (title.toLowerCase()) {
      case 'basic':
        return const Color(0xFFE53935); // Red
      case 'standard':
        return const Color(0xFFFDD835); // Yellow
      case 'premium':
        return const Color(0xFFFDD835); // Yellow/Gold
      default:
        return const Color(0xFFFDD835);
    }
  }

  // Get background color based on plan title
  Color getPlanBackgroundColor(String title) {
    switch (title.toLowerCase()) {
      case 'basic':
        return const Color(0xFFFFF0F0); // Light red
      case 'standard':
        return const Color(0xFFFFFDE7); // Light yellow
      case 'premium':
        return const Color(0xFFFFFDE7); // Light yellow
      default:
        return const Color(0xFFFFFDE7);
    }
  }

  // Get icon based on plan title
  IconData getPlanIcon(String title) {
    switch (title.toLowerCase()) {
      case 'basic':
        return Icons.card_giftcard; // Basic crown equivalent
      case 'standard':
        return Icons.workspace_premium; // Standard crown
      case 'premium':
        return Icons.workspace_premium; // Premium crown
      default:
        return Icons.workspace_premium;
    }
  }

  // Check if this is the current plan
  bool isCurrentPlan(String title) {
    return currentPackage.value?.toLowerCase() == title.toLowerCase();
  }

  // Handle upgrade button tap
  Future<void> onUpgradeNow(SubscriptionPlan plan) async {
    // Show confirmation dialog first
    final confirmed = await _showUpgradeConfirmationDialog(plan);

    if (!confirmed) {
      return; // User cancelled
    }

    try {
      // Show loading dialog
      Get.dialog(
        const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing subscription...'),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      final accessToken = await _sharedPrefService.getAccessToken();

      // Build the API URL with subscriptionId and title
      final url = 'https://d7001.sobhoy.com/api/v1/subscription-purchase/${plan.id}/${plan.title.toLowerCase()}';

      debugPrint('🚀 Upgrading to: ${plan.title}');
      debugPrint('📡 POST URL: $url');

      final response = await _networkCaller.postRequest(
        url,
        body: {}, // Empty body as per API requirements
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      // Close loading dialog
      Get.back();

      debugPrint('📥 Subscription Purchase Response: ${response.jsonResponse}');

      if (response.isSuccess && response.jsonResponse != null) {
        final responseData = response.jsonResponse!;

        if (responseData['success'] == true) {
          // Update current package
          currentPackage.value = plan.title;

          // Refresh current plan data to get latest info
          await fetchUserCurrentPlan();

          Get.snackbar(
            'Success',
            'Successfully upgraded to ${plan.title} plan!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
            snackPosition: SnackPosition.BOTTOM,
          );

          // Optional: Show success dialog with details
          _showSubscriptionSuccessDialog(plan);
        } else {
          throw Exception(responseData['message'] ?? 'Failed to purchase subscription');
        }
      } else {
        throw Exception(response.errorMessage ?? 'Failed to purchase subscription');
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      debugPrint('❌ Error purchasing subscription: $e');

      Get.snackbar(
        'Error',
        'Failed to upgrade subscription: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Show confirmation dialog before purchase
  Future<bool> _showUpgradeConfirmationDialog(SubscriptionPlan plan) async {
    final result = await Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: getPlanColor(plan.title).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.workspace_premium,
                  color: getPlanColor(plan.title),
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Upgrade Subscription',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You are about to upgrade to the ${plan.title} plan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Plan:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          plan.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Duration:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${plan.duration} months',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '€ ${plan.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: getPlanColor(plan.title),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: getPlanColor(plan.title),
                        foregroundColor: plan.title.toLowerCase() == 'basic'
                            ? Colors.white
                            : Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return result ?? false;
  }

  // Show success dialog after subscription purchase
  void _showSubscriptionSuccessDialog(SubscriptionPlan plan) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green.shade700,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Subscription Activated!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You are now subscribed to ${plan.title} plan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              if (endDate.value != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Valid until ${_formatDate(endDate.value!)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Got it',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // Helper method to format date
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  // Refresh subscriptions
  Future<void> refreshSubscriptions() async {
    await fetchSubscriptions();
  }
}

class SubscriptionPlan {
  final String id;
  final String title;
  final double price;
  final int duration;
  final List<String> description;

  SubscriptionPlan({
    required this.id,
    required this.title,
    required this.price,
    required this.duration,
    required this.description,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      duration: json['duration'] ?? 0,
      description: List<String>.from(json['description'] ?? []),
    );
  }
}*/













///
///
///
/// todo:::: with enum
///
///
///




import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/utils/token_service/token_storage_service.dart';
import '../enum/subscription_type.dart'; // Import the enum

class SubscriptionController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();
  final SharedPrefService _sharedPrefService = SharedPrefService();

  // Observable variables
  RxBool isLoading = false.obs;
  RxList<SubscriptionPlan> subscriptionPlans = <SubscriptionPlan>[].obs;

  // Using enum instead of String for type safety
  Rx<SubscriptionType> currentSubscriptionType = SubscriptionType.none.obs;

  // Keep the old one for backward compatibility (optional)
  Rx<String?> currentPackage = Rx<String?>(null);

  // Current subscription details
  Rx<String?> subscriptionId = Rx<String?>(null);
  Rx<String?> startDate = Rx<String?>(null);
  Rx<String?> endDate = Rx<String?>(null);
  Rx<String?> status = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchUserCurrentPlan();
    fetchSubscriptions();
  }

  // Fetch user's current subscription plan
  Future<void> fetchUserCurrentPlan() async {
    try {
      final accessToken = await _sharedPrefService.getAccessToken();

      final response = await _networkCaller.getRequest(
        'https://d7001.sobhoy.com/api/v1/subscription-purchase/current-plan',
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      debugPrint('🔍 Current Plan API Response: ${response.jsonResponse}');

      if (response.isSuccess && response.jsonResponse != null) {
        final responseData = response.jsonResponse!;

        if (responseData['success'] == true) {
          final data = responseData['data'];

          // Check if subscription is active
          if (data['status'] == 'active') {
            final subscription = data['subscription'];
            final planTitle = subscription['title'] as String?;

            // Set both enum and string values
            currentSubscriptionType.value = SubscriptionType.fromString(planTitle);
            currentPackage.value = planTitle;

            // Store additional subscription details
            subscriptionId.value = data['_id'];
            startDate.value = data['startDate'];
            endDate.value = data['endDate'];
            status.value = data['status'];

            debugPrint('✅ Current active plan: ${currentSubscriptionType.value.displayName}');
            debugPrint('📊 Subscription Type: ${currentSubscriptionType.value}');
            debugPrint('🆔 Subscription ID: ${subscriptionId.value}');
            debugPrint('📅 Start Date: ${startDate.value}');
            debugPrint('📅 End Date: ${endDate.value}');
            debugPrint('📊 Status: ${status.value}');
          } else {
            debugPrint('⚠️ Subscription exists but is not active: ${data['status']}');
            _clearSubscriptionData();
          }
        } else {
          debugPrint('⚠️ No active subscription found');
          _clearSubscriptionData();
        }
      } else {
        debugPrint('⚠️ No current plan found or API error');
        _clearSubscriptionData();
      }
    } catch (e) {
      debugPrint('❌ Error fetching user subscription: $e');
      _clearSubscriptionData();
    }
  }

  // Helper method to clear subscription data
  void _clearSubscriptionData() {
    currentSubscriptionType.value = SubscriptionType.none;
    currentPackage.value = null;
    subscriptionId.value = null;
    startDate.value = null;
    endDate.value = null;
    status.value = null;
  }

  // Fetch subscriptions from API
  Future<void> fetchSubscriptions() async {
    try {
      isLoading.value = true;

      final accessToken = await _sharedPrefService.getAccessToken();
      final response = await _networkCaller.getRequest(
        'https://d7001.sobhoy.com/api/v1/subscription/',
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      debugPrint('🔍 Subscription API Response: ${response.jsonResponse}');

      if (response.isSuccess && response.jsonResponse != null) {
        final Map<String, dynamic> responseData = response.jsonResponse!;

        if (responseData['success'] == true) {
          final Map<String, dynamic> data = responseData['data'];
          final List<dynamic> plansList = data['data'] ?? [];

          debugPrint('🔍 Found ${plansList.length} subscription plans');

          subscriptionPlans.value = plansList.map<SubscriptionPlan>((plan) {
            return SubscriptionPlan.fromJson(plan);
          }).toList();

          // Sort plans by tier level
          subscriptionPlans.sort((a, b) => a.type.tierLevel.compareTo(b.type.tierLevel));

          debugPrint('✅ Successfully loaded ${subscriptionPlans.length} subscription plans');
        } else {
          debugPrint('❌ API returned success: false');
          subscriptionPlans.value = [];
        }
      } else {
        debugPrint('❌ API call failed: ${response.errorMessage}');
        subscriptionPlans.value = [];
      }
    } catch (e) {
      debugPrint('❌ Error fetching subscriptions: $e');
      subscriptionPlans.value = [];
      Get.snackbar(
        'Error',
        'Failed to load subscription plans',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Get color based on subscription type (using enum)
  Color getPlanColorByType(SubscriptionType type) {
    switch (type) {
      case SubscriptionType.basic:
        return const Color(0xFFE53935); // Red
      case SubscriptionType.standard:
        return const Color(0xFF1E88E5); // Blue
      case SubscriptionType.premium:
        return const Color(0xFFFDD835); // Gold
      case SubscriptionType.none:
        return Colors.grey;
    }
  }

  // Get color based on plan title (backward compatibility)
  Color getPlanColor(String title) {
    return getPlanColorByType(SubscriptionType.fromString(title));
  }

  // Get background color based on subscription type
  Color getPlanBackgroundColorByType(SubscriptionType type) {
    switch (type) {
      case SubscriptionType.basic:
        return const Color(0xFFFFF0F0); // Light red
      case SubscriptionType.standard:
        return const Color(0xFFE3F2FD); // Light blue
      case SubscriptionType.premium:
        return const Color(0xFFFFFDE7); // Light yellow
      case SubscriptionType.none:
        return Colors.grey.shade100;
    }
  }

  // Backward compatibility
  Color getPlanBackgroundColor(String title) {
    return getPlanBackgroundColorByType(SubscriptionType.fromString(title));
  }

  // Get icon based on subscription type
  IconData getPlanIconByType(SubscriptionType type) {
    switch (type) {
      case SubscriptionType.basic:
        return Icons.card_giftcard;
      case SubscriptionType.standard:
        return Icons.stars;
      case SubscriptionType.premium:
        return Icons.workspace_premium;
      case SubscriptionType.none:
        return Icons.block;
    }
  }

  // Backward compatibility
  IconData getPlanIcon(String title) {
    return getPlanIconByType(SubscriptionType.fromString(title));
  }

  // Check if this is the current plan (using enum)
  bool isCurrentPlanByType(SubscriptionType type) {
    return currentSubscriptionType.value == type && type != SubscriptionType.none;
  }

  // Backward compatibility
  bool isCurrentPlan(String title) {
    return isCurrentPlanByType(SubscriptionType.fromString(title));
  }

  // Check if user can upgrade to a plan
  bool canUpgradeTo(SubscriptionType targetType) {
    // Can't upgrade to none
    if (targetType == SubscriptionType.none) return false;

    // If no subscription, can upgrade to any
    if (currentSubscriptionType.value == SubscriptionType.none) return true;

    // Can only upgrade to better plans
    return targetType.isBetterThan(currentSubscriptionType.value);
  }

  // Check if user has active subscription
  bool get hasActiveSubscription => currentSubscriptionType.value.isActive;

  // Get current subscription display name
  String get currentSubscriptionName => currentSubscriptionType.value.displayName;

  // Handle upgrade button tap
  Future<void> onUpgradeNow(SubscriptionPlan plan) async {
    // Show confirmation dialog first
    final confirmed = await _showUpgradeConfirmationDialog(plan);

    if (!confirmed) {
      return;
    }

    try {
      // Show loading dialog
      Get.dialog(
        const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing subscription...'),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      final accessToken = await _sharedPrefService.getAccessToken();

      // Build the API URL with subscriptionId and title
      final url = 'https://d7001.sobhoy.com/api/v1/subscription-purchase/${plan.id}/${plan.type.toApiString()}';

      debugPrint('🚀 Upgrading to: ${plan.type.displayName}');
      debugPrint('📡 POST URL: $url');

      final response = await _networkCaller.postRequest(
        url,
        body: {},
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      // Close loading dialog
      Get.back();

      debugPrint('📥 Subscription Purchase Response: ${response.jsonResponse}');

      if (response.isSuccess && response.jsonResponse != null) {
        final responseData = response.jsonResponse!;

        if (responseData['success'] == true) {
          // Update current subscription type
          currentSubscriptionType.value = plan.type;
          currentPackage.value = plan.title;

          // Refresh current plan data
          await fetchUserCurrentPlan();

          Get.snackbar(
            'Success',
            'Successfully upgraded to ${plan.type.displayName} plan!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
            snackPosition: SnackPosition.BOTTOM,
          );

          _showSubscriptionSuccessDialog(plan);
        } else {
          throw Exception(responseData['message'] ?? 'Failed to purchase subscription');
        }
      } else {
        throw Exception(response.errorMessage ?? 'Failed to purchase subscription');
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      debugPrint('❌ Error purchasing subscription: $e');

      Get.snackbar(
        'Error',
        'Failed to upgrade subscription: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Show confirmation dialog
  Future<bool> _showUpgradeConfirmationDialog(SubscriptionPlan plan) async {
    final result = await Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: getPlanColorByType(plan.type).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  getPlanIconByType(plan.type),
                  color: getPlanColorByType(plan.type),
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Upgrade Subscription',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You are about to upgrade to the ${plan.type.displayName} plan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Plan:', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                        Text(plan.type.displayName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Duration:', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                        Text('${plan.duration} months', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        Text('€ ${plan.price.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: getPlanColorByType(plan.type))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: getPlanColorByType(plan.type),
                        foregroundColor: plan.type == SubscriptionType.basic ? Colors.white : Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Confirm', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return result ?? false;
  }

  // Show success dialog
  void _showSubscriptionSuccessDialog(SubscriptionPlan plan) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.green.shade100, shape: BoxShape.circle),
                child: Icon(Icons.check_circle, color: Colors.green.shade700, size: 48),
              ),
              const SizedBox(height: 16),
              const Text('Subscription Activated!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Text('You are now subscribed to ${plan.type.displayName} plan',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
              if (endDate.value != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text('Valid until ${_formatDate(endDate.value!)}',
                          style: TextStyle(fontSize: 13, color: Colors.blue.shade700, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Got it', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // Helper method to format date
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  // Refresh subscriptions
  Future<void> refreshSubscriptions() async {
    await Future.wait([
      fetchUserCurrentPlan(),
      fetchSubscriptions(),
    ]);
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