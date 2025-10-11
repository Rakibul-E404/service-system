/**
import 'package:get/get.dart';

class ChangePasswordController extends GetxController {

  final RxInt count = 0.obs;

  void increment() => count.value++;


  
  /// [onInit] Lifecycle method called when the controller is initialized.
  ///
  /// Resets loading states, clears existing data, and triggers and more..
  /// initial fetch
  /// 
  @override
  void onInit() {
    super.onInit();
    count.value = 0;
  }

  /// [dispose] Lifecycle method called when the controller is destroyed.
  ///
  /// Cleans up by resetting loading states and clearing lists and more...
  @override
  void dispose() {
    super.dispose();
    count.value = 0;
  }
}
*/





///
///
///
///
///
///
///
///
///
///
///




import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/network/network_caller.dart';
import 'package:manx_mate/core/network/network_response.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';
import 'package:manx_mate/core/config/app_constants.dart';
import 'package:manx_mate/core/data/secured_storage.dart';

class ChangePasswordController extends GetxController {
  final RxBool isLoading = false.obs;
  final NetworkCaller _networkCaller = NetworkCaller();

  /// Change password with API
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    // Validate passwords match
    if (newPassword != confirmPassword) {
      Get.snackbar(
        'Error',
        'New passwords do not match!',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.error, color: Colors.white),
      );
      return;
    }

    // Validate password length
    if (newPassword.length < 6) {
      Get.snackbar(
        'Error',
        'New password must be at least 6 characters!',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.error, color: Colors.white),
      );
      return;
    }

    // Validate old password is not empty
    if (oldPassword.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your old password!',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.error, color: Colors.white),
      );
      return;
    }

    // Validate new password is different from old
    if (oldPassword == newPassword) {
      Get.snackbar(
        'Error',
        'New password must be different from old password!',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.error, color: Colors.white),
      );
      return;
    }

    try {
      isLoading.value = true;

      debugPrint('═══════════════════════════════════════');
      debugPrint('🔐 CHANGING PASSWORD');
      debugPrint('═══════════════════════════════════════');

      // Get auth token
      final String? token = await SecureStorageService().read(AppConstants.authToken);

      if (token == null || token.isEmpty) {
        isLoading.value = false;
        Get.snackbar(
          'Error',
          'Session expired. Please login again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      // Prepare request body
      final Map<String, dynamic> requestBody = {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      };

      debugPrint('📤 API REQUEST');
      debugPrint('URL: ${AppUrl.updatePasswordUrl}');
      debugPrint('Body: ${{"oldPassword": "***", "newPassword": "***"}}');
      debugPrint('Token: ${token.substring(0, 20)}...');

      // Call the API with authorization header
      final NetworkResponse response = await _networkCaller.postRequest(
        AppUrl.updatePasswordUrl,
        body: requestBody,
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

      if (response.isSuccess) {
        final bool success = response.jsonResponse?['success'] ?? false;
        final String message = response.jsonResponse?['message'] ??
            'Password changed successfully!';

        debugPrint('✅ Password Change Success: $success');

        if (success) {
          Get.snackbar(
            'Success',
            message,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 2),
            icon: const Icon(Icons.check_circle, color: Colors.white),
          );

          // Go back after success
          await Future.delayed(const Duration(milliseconds: 1500));
          Get.back();
        } else {
          Get.snackbar(
            'Error',
            message,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            icon: const Icon(Icons.error, color: Colors.white),
          );
        }
      } else {
        String errorMessage = 'Failed to change password. Please try again.';

        if (response.jsonResponse != null) {
          errorMessage = response.jsonResponse?['message'] ??
              response.errorMessage ??
              errorMessage;
        }

        debugPrint('❌ Password Change Failed: $errorMessage');

        Get.snackbar(
          'Error',
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.error, color: Colors.white),
        );
      }
    } catch (e, stackTrace) {
      isLoading.value = false;
      debugPrint('❌ EXCEPTION OCCURRED');
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');

      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } finally {
      debugPrint('═══════════════════════════════════════');
    }
  }

  @override
  void onInit() {
    super.onInit();
    isLoading.value = false;
  }

  @override
  void dispose() {
    super.dispose();
  }
}