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
  final RxString userEmail = ''.obs; // Make observable
  Timer? _timer;
  final NetworkCaller _networkCaller = NetworkCaller();

  String receivedOtp = '';
  bool fromForgotPassword = false;

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

    if (userEmail.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Email not found. Please go back and try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.error, color: Colors.white),
      );
      return;
    }

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

      // Prepare request body
      final Map<String, dynamic> requestBody = {
        'email': userEmail.value,
        'oneTimeCode': otpCode.value,
      };

      debugPrint('📤 API REQUEST');
      debugPrint('URL: ${AppUrl.verifyOtpUrl}');
      debugPrint('Method: POST');
      debugPrint('Body: $requestBody');
      debugPrint('From Forgot Password: $fromForgotPassword');

      // Call the API
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
      debugPrint('───────────────────────────────────────');

      isLoading.value = false;

      if (response.isSuccess) {
        final bool success = response.jsonResponse?['success'] ?? false;
        final String message =
            response.jsonResponse?['message'] ?? 'Verification successful!';

        debugPrint('✅ Verification Success: $success');

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

          await Future.delayed(const Duration(milliseconds: 1500));

          // Navigate based on source
          if (fromForgotPassword) {
            debugPrint('🔄 Navigating to reset password screen...');
            Get.offAllNamed(
              AppRoutes.resetPasswordRoute,
              arguments: {
                'email': userEmail.value,
                'otp': otpCode.value,
              },
            );
          } else {
            debugPrint('🔄 Navigating to login screen...');
            Get.offAllNamed(AppRoutes.loginRoute);
          }
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
        String errorMessage = 'Invalid OTP. Please try again.';

        if (response.jsonResponse != null) {
          errorMessage = response.jsonResponse?['message'] ??
              response.errorMessage ??
              errorMessage;

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
    if (userEmail.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Email not found',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    try {
      isLoading.value = true;
      debugPrint('📤 Resending OTP to: ${userEmail.value}');

      final Map<String, dynamic> requestBody = {
        'email': userEmail.value,
      };

      final NetworkResponse response = await _networkCaller.postRequest(
        fromForgotPassword ? AppUrl.forgotPassword : AppUrl.signUpUrl,
        body: requestBody,
      );

      isLoading.value = false;

      if (response.isSuccess) {
        startCountdown();
        Get.snackbar(
          'Success',
          'OTP resent to your email',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to resend OTP',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
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

  @override
  void onInit() {
    super.onInit();

    debugPrint('═══════════════════════════════════════');
    debugPrint('🚀 VERIFY EMAIL CONTROLLER INITIALIZED');
    debugPrint('═══════════════════════════════════════');

    final arguments = Get.arguments;

    debugPrint('📦 Arguments received: $arguments');
    debugPrint('📦 Arguments type: ${arguments.runtimeType}');

    if (arguments != null) {
      if (arguments is Map<String, dynamic>) {
        userEmail.value = arguments['email'] ?? '';
        receivedOtp = arguments['otp'] ?? '';
        fromForgotPassword = arguments['fromForgotPassword'] ?? false;
      } else if (arguments is String) {
        userEmail.value = arguments;
      }
    }

    debugPrint('📧 User Email: ${userEmail.value}');
    debugPrint('🔐 OTP from previous screen: $receivedOtp');
    debugPrint('📍 From Forgot Password: $fromForgotPassword');
    debugPrint('═══════════════════════════════════════');

    if (userEmail.value.isEmpty) {
      debugPrint('⚠️ WARNING: User email is empty!');
      Future.delayed(Duration.zero, () {
        Get.snackbar(
          'Error',
          'Email not found. Please go back and try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.error, color: Colors.white),
        );
      });
    }

    startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    debugPrint('🛑 VerifyEmailController disposed');
    super.dispose();
  }
}