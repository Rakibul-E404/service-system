import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/network/network_caller.dart';
import 'package:manx_mate/core/network/network_response.dart';
import '../../../core/config/app_constants.dart';
import '../../../core/data/secured_storage.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/api/app_url.dart';

class SignInController extends GetxController {
  final RxBool isLoading = false.obs;
  RxString savedRole = ''.obs;
  final NetworkCaller _networkCaller = NetworkCaller();

  /// Sign in method that calls the API
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;

      // Prepare request body
      final Map<String, dynamic> requestBody = {
        'email': email,
        'password': password,
      };

      debugPrint('═══════════════════════════════════════');
      debugPrint('🔐 SIGNING IN');
      debugPrint('═══════════════════════════════════════');
      debugPrint('📤 API REQUEST');
      debugPrint('URL: ${AppUrl.signInUrl}');
      debugPrint('Body: $requestBody');

      // Call the API using NetworkCaller
      final NetworkResponse response = await _networkCaller.postRequest(
        AppUrl.signInUrl,
        body: requestBody,
        isLogin: true,
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
        final String message = response.jsonResponse?['message'] ?? 'Sign in successful!';
        final Map<String, dynamic>? data = response.jsonResponse?['data'];
        final Map<String, dynamic>? tokens = response.jsonResponse?['tokens'];

        debugPrint('✅ Sign In Success: $success');
        debugPrint('📧 Message: $message');
        debugPrint('📦 Data: $data');
        debugPrint('🔑 Tokens: $tokens');

        if (success && data != null && tokens != null) {
          // Extract tokens
          final String? accessToken = tokens['accessToken'];
          final String? refreshToken = tokens['refreshToken'];

          // Extract user data
          final String? userId = data['_id'];
          final String? userName = data['name'];
          final String? userEmail = data['email'];
          final String? userRole = data['role'];

          debugPrint('🔑 Access Token: ${accessToken?.substring(0, 20)}...');
          debugPrint('🔑 Refresh Token: ${refreshToken?.substring(0, 20)}...');
          debugPrint('👤 User ID: $userId');
          debugPrint('📛 Name: $userName');
          debugPrint('📧 Email: $userEmail');
          debugPrint('🎭 Role: $userRole');

          // Save tokens to secure storage
          if (accessToken != null) {
            await SecureStorageService().write(AppConstants.authToken, accessToken);
            debugPrint('✅ Access token saved');
          }

          if (refreshToken != null) {
            await SecureStorageService().write(AppConstants.refressToken, refreshToken);
            debugPrint('✅ Refresh token saved');
          }

          // Save user data
          if (userRole != null) {
            await SecureStorageService().write(AppConstants.roleType, userRole);
            savedRole.value = userRole;
            debugPrint('✅ Role saved: $userRole');
          }

          if (userId != null) {
            await SecureStorageService().write(AppConstants.userId, userId);
            debugPrint('✅ User ID saved');
          }

          if (userName != null) {
            await SecureStorageService().write(AppConstants.userName, userName);
            debugPrint('✅ User name saved');
          }

          // Mark user as logged in
          await SecureStorageService().write(AppConstants.isLoggedIn, 'true');
          debugPrint('✅ User marked as logged in');

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

          // Navigate based on role
          await Future.delayed(const Duration(milliseconds: 500));
          debugPrint('🔄 Navigating to ${userRole == "user" ? "User" : "Provider"} Dashboard...');

          Get.offAllNamed(
            userRole?.toLowerCase() == 'user'
                ? AppRoutes.mainBottomNavPage
                : AppRoutes.providerMainBottomNavPage,
          );
        } else {
          debugPrint('⚠️ Missing data or tokens in response');
          Get.snackbar(
            'Error',
            'Invalid response from server. Please try again.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            icon: const Icon(Icons.error, color: Colors.white),
          );
        }
      } else {
        String errorMessage = 'Sign in failed. Please check your credentials.';

        if (response.jsonResponse != null) {
          errorMessage = response.jsonResponse?['message'] ??
              response.errorMessage ??
              errorMessage;
        }

        debugPrint('❌ Sign In Failed: $errorMessage');

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



  /// Handle sign in (kept for backward compatibility)
  Future<void> handleSignIn() async {
    // This method is called from the UI
    // The actual API call is in the signIn method above
    debugPrint('⚠️ handleSignIn called - use signIn(email, password) instead');
  }

  final RxBool isTermsAndConditionAgreementAccept = false.obs;

  set updateTermsAndConditionAgreementStatus(bool? value) {
    if (value != null) {
      isTermsAndConditionAgreementAccept.value = value;
    }
  }

  /// [onInit] Lifecycle method called when the controller is initialized.
  @override
  Future<void> onInit() async {
    super.onInit();
    savedRole.value = await SecureStorageService().read(AppConstants.roleType) ?? '';
    isLoading.value = false;
    isTermsAndConditionAgreementAccept.value = false;
  }

  /// [dispose] Lifecycle method called when the controller is destroyed.
  @override
  void dispose() {
    isLoading.value = false;
    isTermsAndConditionAgreementAccept.value = false;
    super.dispose();
  }
}