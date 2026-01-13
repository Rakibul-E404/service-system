import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/network/network_caller.dart';
import 'package:manx_mate/core/network/network_response.dart';
import 'package:manx_mate/core/routes/app_routes.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';
import 'package:manx_mate/core/utils/custom_snack_bar.dart';

class ForgotPasswordController extends GetxController {
  final TextEditingController forgotPasswordTEController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final RxBool loader = false.obs;

  Future<void> sendOtp() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    try {
      loader.value = true;

      final String email = forgotPasswordTEController.text.trim();

      debugPrint('═══════════════════════════════════════');
      debugPrint('📤 SENDING OTP FOR FORGOT PASSWORD');
      debugPrint('Email: $email');
      debugPrint('URL: ${AppUrl.forgotPassword}');

      final NetworkResponse response = await NetworkCaller().postRequest(
        AppUrl.forgotPassword,
        body: <String, dynamic>{"email": email},
      );

      debugPrint('📥 Response Status Code: ${response.statusCode}');
      debugPrint('📥 Response Success: ${response.isSuccess}');
      debugPrint('📥 Response JSON: ${response.jsonResponse}');
      debugPrint('═══════════════════════════════════════');

      loader.value = false;

      if (response.isSuccess) {
        final bool success = response.jsonResponse?['success'] ?? false;
        final String message = response.jsonResponse?['message'] ??
            'OTP has been sent to your email';

        debugPrint('✅ OTP sent successfully');

        ToastManager.show(
          message: message,
          backgroundColor: Colors.green,
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );

        // Navigate to verify email with proper arguments
        await Future.delayed(const Duration(milliseconds: 500));

        debugPrint('🔄 Navigating to verify email screen');
        debugPrint('📧 Passing email: $email');
        debugPrint('🏷️ From forgot password: true');

        Get.toNamed(
          AppRoutes.verifyEmailRoute,
          arguments: {
            'email': email,
            'fromForgotPassword': true,
          },
        );
      } else {
        final String errorMessage = response.jsonResponse?['message'] ??
            'Failed to send OTP. Please try again.';

        debugPrint('❌ Failed to send OTP: $errorMessage');

        ToastManager.show(
          message: errorMessage,
          backgroundColor: Colors.red,
          icon: const Icon(Icons.error, color: Colors.white),
        );
      }
    } catch (error, stackTrace) {
      loader.value = false;
      debugPrint('❌ EXCEPTION in forgetPassword');
      debugPrint('Error: ${error.toString()}');
      debugPrint('StackTrace: $stackTrace');

      ToastManager.show(
        message: 'An unexpected error occurred. Please try again.',
        backgroundColor: Colors.red,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }

  @override
  void dispose() {
    forgotPasswordTEController.dispose();
    super.dispose();
  }
}