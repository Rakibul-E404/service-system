/**
import 'dart:async';

import 'package:get/get.dart';

class VerifyEmailController extends GetxController {

  final RxInt secondsRemaining = 25.obs;
  Timer? _timer;


  void startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (secondsRemaining.value > 0) {
        secondsRemaining.value--;
      } else {
        _timer?.cancel();
      }
    });
  }

  /// [onInit] Lifecycle method called when the controller is initialized.
  ///
  /// Resets loading states, clears existing data, and triggers and more..
  /// initial fetch
  ///
  @override
  void onInit() {
    super.onInit();
    startCountdown();
  }

  /// [dispose] Lifecycle method called when the controller is destroyed.
  ///
  /// Cleans up by resetting loading states and clearing lists and more...
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
*/










///
///------ todo:::: adding api
///




import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/network/network_caller.dart';
import 'package:manx_mate/core/network/network_response.dart';
import 'package:manx_mate/core/routes/app_routes.dart';

import '../../../core/utils/api/app_url.dart';

class VerifyEmailController extends GetxController {
  final RxInt secondsRemaining = 60.obs;
  final RxBool isLoading = false.obs;
  final RxString otpCode = ''.obs;
  Timer? _timer;
  final NetworkCaller _networkCaller = NetworkCaller();

  // User email and OTP from sign up
  String userEmail = '';
  String receivedOtp = '';

  void startCountdown() {
    secondsRemaining.value = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (secondsRemaining.value > 0) {
        secondsRemaining.value--;
      } else {
        _timer?.cancel();
      }
    });
  }

  /// Set OTP code
  void setOtpCode(String code) {
    otpCode.value = code;
    debugPrint('🔢 OTP Code entered: $code');
  }

  /// Verify OTP with API
  Future<void> verifyOtp() async {
    debugPrint('═══════════════════════════════════════');
    debugPrint('🔐 VERIFYING OTP');
    debugPrint('═══════════════════════════════════════');

    if (otpCode.value.isEmpty || otpCode.value.length < 6) {
      debugPrint('❌ Invalid OTP length: ${otpCode.value.length}');
      Get.snackbar(
        'Error',
        'Please enter a valid 6-digit OTP',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.error, color: Colors.white),
      );
      return;
    }

    try {
      isLoading.value = true;

      // Prepare request body - EXACTLY as your API expects
      final Map<String, dynamic> requestBody = {
        'email': userEmail,
        'oneTimeCode': otpCode.value,
      };

      debugPrint('📤 API REQUEST');
      debugPrint('URL: ${AppUrl.verifyOtpUrl}');
      debugPrint('Method: POST');
      debugPrint('Body: $requestBody');
      debugPrint('Email: $userEmail');
      debugPrint('OTP Entered: ${otpCode.value}');
      debugPrint('OTP Received from SignUp: $receivedOtp');

      // Call the API using NetworkCaller
      final NetworkResponse response = await _networkCaller.postRequest(
        AppUrl.verifyOtpUrl,
        body: requestBody,
        isLogin: false,
      );

      debugPrint('───────────────────────────────────────');
      debugPrint('📥 API RESPONSE');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Is Success: ${response.isSuccess}');
      debugPrint('Response JSON: ${response.jsonResponse}');
      debugPrint('Error Message: ${response.errorMessage}');
      debugPrint('───────────────────────────────────────');

      isLoading.value = false;

      if (response.isSuccess) {
        // Extract data from response
        final bool success = response.jsonResponse?['success'] ?? false;
        final String message = response.jsonResponse?['message'] ??
            'Email verified successfully!';
        final dynamic data = response.jsonResponse?['data'];

        debugPrint('✅ Verification Success: $success');
        debugPrint('📧 Message: $message');
        debugPrint('📦 Data: $data');

        if (success) {
          // Show success message
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
          debugPrint('⚠️ Success flag is false');
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
        // Extract error message from response
        String errorMessage = 'Invalid OTP. Please try again.';

        if (response.jsonResponse != null) {
          errorMessage = response.jsonResponse?['message'] ??
              response.errorMessage ??
              errorMessage;

          // Check for detailed errors
          final errors = response.jsonResponse?['errors'];
          if (errors != null) {
            debugPrint('🔍 Detailed Errors: $errors');
            if (errors is Map) {
              final firstError = errors.values.first;
              if (firstError is List && firstError.isNotEmpty) {
                errorMessage = firstError.first.toString();
              }
            }
          }
        }

        debugPrint('❌ Verification Failed: $errorMessage');

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

  /// Resend OTP
  Future<void> resendOtp() async {
    try {
      isLoading.value = true;

      debugPrint('📤 Resending OTP to: $userEmail');

      // TODO: Implement resend OTP API call if you have the endpoint
      // For now, just restart the timer

      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      startCountdown();
      isLoading.value = false;

      Get.snackbar(
        'Success',
        'OTP resent to your email',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    } catch (e) {
      isLoading.value = false;
      debugPrint('❌ Resend OTP error: $e');

      Get.snackbar(
        'Error',
        'Failed to resend OTP. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }

  /// [onInit] Lifecycle method called when the controller is initialized.
  @override
  void onInit() {
    super.onInit();

    debugPrint('═══════════════════════════════════════');
    debugPrint('🚀 VERIFY EMAIL CONTROLLER INITIALIZED');
    debugPrint('═══════════════════════════════════════');

    // Get email and OTP from navigation arguments
    final arguments = Get.arguments as Map<String, dynamic>?;

    debugPrint('📦 Arguments received: $arguments');

    if (arguments != null) {
      userEmail = arguments['email'] ?? '';
      receivedOtp = arguments['otp'] ?? '';
    }

    debugPrint('📧 User Email: $userEmail');
    debugPrint('🔐 OTP from SignUp: $receivedOtp');
    debugPrint('═══════════════════════════════════════');

    if (userEmail.isEmpty) {
      debugPrint('⚠️ WARNING: User email is empty!');
    }
    if (receivedOtp.isEmpty) {
      debugPrint('⚠️ WARNING: OTP is empty!');
    }

    startCountdown();
  }

  /// [dispose] Lifecycle method called when the controller is destroyed.
  @override
  void dispose() {
    _timer?.cancel();
    debugPrint('🛑 VerifyEmailController disposed');
    super.dispose();
  }
}