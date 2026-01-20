import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/network/network_caller.dart';
import 'package:manx_mate/core/config/app_constants.dart';
import 'package:manx_mate/core/data/secured_storage.dart';
import 'package:manx_mate/core/network/network_response.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/api/app_url.dart';
import '../../../core/utils/token_service/token_storage_service.dart';

class ProfileController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();
  final SharedPrefService _sharedPrefService = SharedPrefService();
  final SecureStorageService _secureStorage = SecureStorageService();

  // FIXED: Use explicit Rx types
  final RxString name = RxString('');
  final RxString email = RxString('');
  final RxString profileImage = RxString('');
  final RxString location = RxString('');
  final RxString role = RxString('');
  final RxBool isLoading = RxBool(false);
  final RxBool isLoggedIn = RxBool(false);

  @override
  void onInit() {
    super.onInit();
    debugPrint('🔄 ProfileController initialized');
    // Don't fetch here, use onReady
  }

  @override
  void onReady() {
    super.onReady();
    fetchUserProfile();
  }

  /// Fetch user profile data
  Future<void> fetchUserProfile() async {
    try {
      isLoading.value = true;

      debugPrint('═══════════════════════════════════════');
      debugPrint('👤 FETCHING USER PROFILE (ProfileController)');
      debugPrint('═══════════════════════════════════════');

      final String? token = await _secureStorage.read(AppConstants.authToken);

      if (token == null || token.isEmpty) {
        debugPrint('❌ No auth token found');
        isLoading.value = false;
        isLoggedIn.value = false;
        return;
      }

      debugPrint('📤 API REQUEST');
      debugPrint('URL: ${AppUrl.selfProfileUrl}');

      final NetworkResponse response = await _networkCaller.getRequest(
        AppUrl.selfProfileUrl,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('───────────────────────────────────────');
      debugPrint('📥 API RESPONSE');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Is Success: ${response.isSuccess}');
      debugPrint('Response JSON: ${response.jsonResponse}');
      debugPrint('───────────────────────────────────────');

      isLoading.value = false;

      if (response.isSuccess && response.jsonResponse != null) {
        final bool success = response.jsonResponse!['success'] ?? false;
        final Map<String, dynamic>? data = response.jsonResponse!['data'];

        debugPrint('✅ Profile Fetch Success: $success');
        debugPrint('📦 User Data: $data');

        if (success && data != null) {
          // FIXED: Always use .value for Rx variables
          name.value = data['name']?.toString() ?? '';
          email.value = data['email']?.toString() ?? '';
          profileImage.value = data['image']?.toString() ?? '';
          location.value = data['location']?.toString() ?? '';

          // FIXED: Handle role assignment safely
          final dynamic roleData = data['role'];
          if (roleData != null) {
            if (roleData is String) {
              role.value = roleData;
            } else if (roleData is int) {
              role.value = roleData.toString();
            } else {
              role.value = roleData.toString();
            }
          } else {
            role.value = 'user'; // Default value
          }

          isLoggedIn.value = true;

          debugPrint('📛 Name: ${name.value}');
          debugPrint('📧 Email: ${email.value}');
          debugPrint('🖼️ Image: ${profileImage.value}');
          debugPrint('📍 Location: ${location.value}');
          debugPrint('🎭 Role: ${role.value}');
        } else {
          debugPrint('❌ Failed to parse profile data');
          isLoggedIn.value = false;
          _showError('Failed to load profile data');
        }
      } else {
        final String errorMessage = response.jsonResponse?['message'] ??
            response.errorMessage ??
            'Failed to load profile';

        debugPrint('❌ Failed to load profile: $errorMessage');
        isLoggedIn.value = false;
        _showError(errorMessage);
      }
    } catch (e, stackTrace) {
      isLoading.value = false;
      isLoggedIn.value = false;
      debugPrint('❌ EXCEPTION OCCURRED');
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');
      _showError('An unexpected error occurred');
    } finally {
      debugPrint('═══════════════════════════════════════');
    }
  }

  /// Get full image URL using AppUrl.getUserProfileImageUrl
  String getImageUrl() {
    if (profileImage.value.isEmpty) return '';
    return AppUrl.getUserProfileImageUrl(profileImage.value);
  }

  /// Refresh profile data
  Future<void> refreshProfile() async {
    await fetchUserProfile();
  }

  /// Show error message
  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  /// Clear profile data without logging out
  Future<void> clearProfileData() async {
    name.value = '';
    email.value = '';
    profileImage.value = '';
    location.value = '';
    role.value = 'user';
    isLoggedIn.value = false;
    debugPrint('🧹 Profile data cleared');
  }

  /// Logout the user by clearing all stored data
  Future<void> logout() async {
    try {
      debugPrint('═══════════════════════════════════════');
      debugPrint('🚪 LOGGING OUT USER');
      debugPrint('═══════════════════════════════════════');

      // Show loading indicator
      isLoading.value = true;

      // ============================================
      // STEP 1: Clear SharedPreferences (login persistence)
      // ============================================
      debugPrint('🧹 Clearing SharedPreferences...');
      await _sharedPrefService.clearAll();
      debugPrint('✅ SharedPreferences cleared');

      // ============================================
      // STEP 2: Clear SecureStorage (all sensitive data)
      // ============================================
      debugPrint('🧹 Clearing SecureStorage...');

      // Clear auth tokens
      await _secureStorage.delete(AppConstants.authToken);
      debugPrint('✅ Auth token deleted');

      await _secureStorage.delete(AppConstants.refressToken);
      debugPrint('✅ Refresh token deleted');

      // Clear user data
      await _secureStorage.delete(AppConstants.roleType);
      debugPrint('✅ Role type deleted');

      await _secureStorage.delete(AppConstants.userId);
      debugPrint('✅ User ID deleted');

      await _secureStorage.delete(AppConstants.userName);
      debugPrint('✅ User name deleted');

      debugPrint('✅ All SecureStorage data cleared');

      // ============================================
      // STEP 3: Reset controller state
      // ============================================
      debugPrint('🔄 Resetting controller state...');
      await clearProfileData();
      isLoading.value = false;
      debugPrint('✅ Controller state reset');

      debugPrint('═══════════════════════════════════════');
      debugPrint('✅ LOGOUT COMPLETED SUCCESSFULLY');
      debugPrint('🔄 Navigating to Role Selection...');
      debugPrint('═══════════════════════════════════════');

      // ============================================
      // STEP 4: Navigate to role selection and clear navigation stack
      // ============================================
      Get.offAllNamed(AppRoutes.roleSelectionRoute);

      // Show success message after navigation
      await Future.delayed(const Duration(milliseconds: 300));
      Get.snackbar(
        'Success',
        'You have been logged out successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );

    } catch (e, stackTrace) {
      isLoading.value = false;
      debugPrint('═══════════════════════════════════════');
      debugPrint('❌ LOGOUT FAILED');
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');
      debugPrint('═══════════════════════════════════════');

      Get.snackbar(
        'Error',
        'An error occurred during logout. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }
}



