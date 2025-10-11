import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/network/network_caller.dart';
import 'package:manx_mate/core/network/network_response.dart';
import 'package:manx_mate/core/routes/app_routes.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';

class ResetPasswordController extends GetxController {
  final RxBool isLoading = false.obs;
  final NetworkCaller _networkCaller = NetworkCaller();

  String userEmail = '';
  String userOtp = '';

  /// Reset password with API
  Future<void> resetPassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    // Validate passwords match
    if (newPassword != confirmPassword) {
      Get.snackbar(
        'Error',
        'Passwords do not match!',
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
        'Password must be at least 6 characters!',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.error, color: Colors.white),
      );
      return;
    }

    // Check if email is available
    if (userEmail.isEmpty) {
      Get.snackbar(
        'Error',
        'Session expired. Please start again.',
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
      debugPrint('🔐 RESETTING PASSWORD');
      debugPrint('═══════════════════════════════════════');

      // Prepare request body - MATCHING POSTMAN FORMAT
      final Map<String, dynamic> requestBody = {
        'email': userEmail,
        'password': newPassword, // Changed from 'newPassword' to 'password'
      };

      debugPrint('📤 API REQUEST');
      debugPrint('URL: ${AppUrl.resetPasswordUrl}');
      debugPrint('Body: ${{"email": userEmail, "password": "***"}}');

      // Call the API
      final NetworkResponse response = await _networkCaller.postRequest(
        AppUrl.resetPasswordUrl,
        body: requestBody,
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
            'Password reset successful!';

        debugPrint('✅ Password Reset Success: $success');

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

          // Navigate to login screen
          await Future.delayed(const Duration(milliseconds: 1500));
          debugPrint('🔄 Navigating to login screen...');
          Get.offAllNamed(AppRoutes.loginRoute);
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
        String errorMessage = 'Failed to reset password. Please try again.';

        if (response.jsonResponse != null) {
          errorMessage = response.jsonResponse?['message'] ??
              response.errorMessage ??
              errorMessage;
        }

        debugPrint('❌ Password Reset Failed: $errorMessage');

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

    debugPrint('═══════════════════════════════════════');
    debugPrint('🔐 RESET PASSWORD CONTROLLER INITIALIZED');
    debugPrint('═══════════════════════════════════════');

    // Get email from arguments (we don't need OTP for reset)
    final arguments = Get.arguments;
    debugPrint('📦 Arguments received: $arguments');

    if (arguments != null && arguments is Map<String, dynamic>) {
      userEmail = arguments['email'] ?? '';
    }

    debugPrint('📧 User Email: $userEmail');
    debugPrint('═══════════════════════════════════════');

    if (userEmail.isEmpty) {
      debugPrint('⚠️ WARNING: Email is missing!');
      Future.delayed(Duration.zero, () {
        Get.snackbar(
          'Error',
          'Session expired. Please start the password reset process again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}