/**
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/routes/app_routes.dart';
import 'package:manx_mate/core/network/network_caller.dart';
import 'package:manx_mate/core/network/network_response.dart';
import '../../../core/utils/api/app_url.dart';

class SignUpController extends GetxController {
  final RxBool isTermsAndConditionAgreementAccept = false.obs;
  final RxString selectedRole = ''.obs;
  final RxBool isLoading = false.obs;
  final NetworkCaller _networkCaller = NetworkCaller();

  // Store user email and OTP for verification
  final RxString userEmail = ''.obs;
  final RxString oneTimeCode = ''.obs;

  set updateTermsAndConditionAgreementStatus(bool? value) {
    if (value != null) {
      isTermsAndConditionAgreementAccept.value = value;
    }
  }

  /// Set the user's selected role
  void setRole(String role) {
    selectedRole.value = role;
  }

  /// Sign up method that calls the API using NetworkCaller
  Future<void> signUp({
    required String name,
    required String email,
    required String location,
    required String password,
  }) async {
    try {
      isLoading.value = true;

      // Prepare request body
      final Map<String, dynamic> requestBody = {
        'name': name,
        'email': email,
        'location': location.toLowerCase(), // Convert to lowercase
        'password': password,
        'role': selectedRole.value, // Already stored as lowercase from role selection
      };

      debugPrint('📤 Sending Sign Up Request...');
      debugPrint('URL: ${AppUrl.signUpUrl}');
      debugPrint('Body: $requestBody');

      // Call the API using NetworkCaller
      final NetworkResponse response = await _networkCaller.postRequest(
        AppUrl.signUpUrl,
        body: requestBody,
        isLogin: false,
      );

      debugPrint('📥 Response received: ${response.toString()}');
      debugPrint('📥 Response JSON: ${response.jsonResponse}');

      isLoading.value = false;

      if (response.isSuccess) {
        // Extract data from response
        final bool success = response.jsonResponse?['success'] ?? false;
        final String message = response.jsonResponse?['message'] ?? 'Sign up successful!';
        final Map<String, dynamic>? data = response.jsonResponse?['data'];
        final String? otp = data?['oneTimeCode']?.toString();

        debugPrint('✅ Success: $success');
        debugPrint('📧 Message: $message');
        debugPrint('🔐 OTP: $otp');

        if (success && otp != null) {
          // Store email and OTP for verification
          userEmail.value = email;
          oneTimeCode.value = otp;

          // Show success message
          Get.snackbar(
            'Success',
            'OTP sent to your email: $email',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 3),
            icon: const Icon(Icons.check_circle, color: Colors.white),
          );

          // Navigate to OTP verification screen
          await Future.delayed(const Duration(milliseconds: 500));

          // Pass email and OTP to verification screen
          Get.toNamed(
            AppRoutes.verifyEmailRoute,
            arguments: {
              'email': email,
              'otp': otp,
              'fromSignUp': true,
            },
          );
        } else {
          // Handle case where success is true but no OTP
          Get.snackbar(
            'Error',
            'Registration successful but OTP not received. Please try again.',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 3),
            icon: const Icon(Icons.warning, color: Colors.white),
          );
        }
      } else {
        // Error - Extract error message from response
        String errorMessage = response.jsonResponse?['message'] ??
            response.errorMessage ??
            'Sign up failed. Please try again.';

        // Check if there's a more detailed error message
        if (response.jsonResponse != null) {
          final errors = response.jsonResponse!['errors'];
          if (errors != null && errors is Map) {
            // Extract first error message
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              errorMessage = firstError.first.toString();
            }
          }
        }

        debugPrint('❌ Error: $errorMessage');

        // Show error snackbar
        Get.snackbar(
          'Error',
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
          icon: const Icon(Icons.error, color: Colors.white),
        );
      }
    } catch (e) {
      isLoading.value = false;
      debugPrint('❌ Sign up error: $e');

      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }

  /// [onInit] Lifecycle method called when the controller is initialized.
  @override
  void onInit() {
    super.onInit();
    isTermsAndConditionAgreementAccept.value = false;
    isLoading.value = false;
  }

  /// [dispose] Lifecycle method called when the controller is destroyed.
  @override
  void dispose() {
    isTermsAndConditionAgreementAccept.value = false;
    selectedRole.value = '';
    isLoading.value = false;
    userEmail.value = '';
    oneTimeCode.value = '';
    super.dispose();
  }
}

*/








///
///
///
///
///
/// todo:::::: addign the resend functionality
///
///
///
///
///
///





import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/routes/app_routes.dart';
import 'package:manx_mate/core/network/network_caller.dart';
import 'package:manx_mate/core/network/network_response.dart';
import '../../../core/utils/api/app_url.dart';

class SignUpController extends GetxController {
  final RxBool isTermsAndConditionAgreementAccept = false.obs;
  final RxString selectedRole = ''.obs;
  final RxBool isLoading = false.obs;
  final NetworkCaller _networkCaller = NetworkCaller();

  // Store user data for verification and resend
  final RxString userEmail = ''.obs;
  final RxString userName = ''.obs;
  final RxString userLocation = ''.obs;
  final RxString userPassword = ''.obs;
  final RxString oneTimeCode = ''.obs;

  set updateTermsAndConditionAgreementStatus(bool? value) {
    if (value != null) {
      isTermsAndConditionAgreementAccept.value = value;
    }
  }

  /// Set the user's selected role
  void setRole(String role) {
    selectedRole.value = role;
  }

  /// Sign up method that calls the API using NetworkCaller
  Future<void> signUp({
    required String name,
    required String email,
    required String location,
    required String password,
  }) async {
    try {
      isLoading.value = true;

      // Store user data for resend functionality
      userName.value = name;
      userEmail.value = email;
      userLocation.value = location;
      userPassword.value = password;

      // Prepare request body
      final Map<String, dynamic> requestBody = {
        'name': name,
        'email': email,
        'location': location.toLowerCase(),
        'password': password,
        'role': selectedRole.value,
      };

      debugPrint('📤 Sending Sign Up Request...');
      debugPrint('URL: ${AppUrl.signUpUrl}');
      debugPrint('Body: $requestBody');

      // Call the API using NetworkCaller
      final NetworkResponse response = await _networkCaller.postRequest(
        AppUrl.signUpUrl,
        body: requestBody,
        isLogin: false,
      );

      debugPrint('📥 Response received: ${response.toString()}');
      debugPrint('📥 Response JSON: ${response.jsonResponse}');

      isLoading.value = false;

      if (response.isSuccess) {
        // Extract data from response
        final bool success = response.jsonResponse?['success'] ?? false;
        final String message = response.jsonResponse?['message'] ?? 'Sign up successful!';
        final Map<String, dynamic>? data = response.jsonResponse?['data'];
        final String? otp = data?['oneTimeCode']?.toString();

        debugPrint('✅ Success: $success');
        debugPrint('📧 Message: $message');
        debugPrint('🔐 OTP: $otp');

        if (success && otp != null) {
          // Store OTP
          oneTimeCode.value = otp;

          // Show success message
          Get.snackbar(
            'Success',
            'OTP sent to your email: $email',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 3),
            icon: const Icon(Icons.check_circle, color: Colors.white),
          );

          // Navigate to OTP verification screen with all data
          await Future.delayed(const Duration(milliseconds: 500));

          Get.toNamed(
            AppRoutes.verifyEmailRoute,
            arguments: {
              'email': email,
              'name': name,
              'location': location,
              'password': password,
              'role': selectedRole.value,
              'otp': otp,
              'fromSignUp': true,
            },
          );
        } else {
          Get.snackbar(
            'Error',
            'Registration successful but OTP not received. Please try again.',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 3),
            icon: const Icon(Icons.warning, color: Colors.white),
          );
        }
      } else {
        // Error - Extract error message from response
        String errorMessage = response.jsonResponse?['message'] ??
            response.errorMessage ??
            'Sign up failed. Please try again.';

        // Check if there's a more detailed error message
        if (response.jsonResponse != null) {
          final errors = response.jsonResponse!['errors'];
          if (errors != null && errors is Map) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              errorMessage = firstError.first.toString();
            }
          }
        }

        debugPrint('❌ Error: $errorMessage');

        Get.snackbar(
          'Error',
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
          icon: const Icon(Icons.error, color: Colors.white),
        );
      }
    } catch (e) {
      isLoading.value = false;
      debugPrint('❌ Sign up error: $e');

      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }

  @override
  void onInit() {
    super.onInit();
    isTermsAndConditionAgreementAccept.value = false;
    isLoading.value = false;
  }

  @override
  void dispose() {
    isTermsAndConditionAgreementAccept.value = false;
    selectedRole.value = '';
    isLoading.value = false;
    userEmail.value = '';
    userName.value = '';
    userLocation.value = '';
    userPassword.value = '';
    oneTimeCode.value = '';
    super.dispose();
  }
}