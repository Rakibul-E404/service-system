import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:manx_mate/core/network/network_caller.dart';
import 'package:manx_mate/core/network/network_response.dart';
import '../../../core/config/app_constants.dart';
import '../../../core/data/secured_storage.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/api/app_url.dart';
import '../../../core/utils/token_service/token_storage_service.dart';
import '../screens/profile_service.dart';

class SignInController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isGoogleSignInLoading = false.obs;
  RxString savedRole = ''.obs;
  final NetworkCaller _networkCaller = NetworkCaller();
  final SharedPrefService _sharedPrefService = SharedPrefService();

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
          await _handleSuccessfulLogin(data, tokens, message);
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

  /// Handle successful login and save tokens
  Future<void> _handleSuccessfulLogin(
      Map<String, dynamic> data,
      Map<String, dynamic> tokens,
      String message,
      ) async {
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
    debugPrint('🎭 Role from API: $userRole');

    if (accessToken != null && refreshToken != null && userRole != null) {
      // Get ProfileService instance
      final ProfileService profileService = Get.find<ProfileService>();

      // Save login data through ProfileService
      await profileService.saveLoginData(
        accessToken: accessToken,
        refreshToken: refreshToken,
        userRole: userRole,
        userId: userId ?? '',
        userName: userName,
        userEmail: userEmail,
      );


      // Wait a bit for profile to load
      await Future.delayed(const Duration(milliseconds: 800));

      // Navigate based on role
      final String route = userRole.toLowerCase() == 'user'
          ? AppRoutes.mainBottomNavPage
          : AppRoutes.providerMainBottomNavPage;

      debugPrint('🔄 Navigating to: $route');

      Get.offAllNamed(route);

      debugPrint('🎉 Sign in completed successfully!');
    } else {
      debugPrint('❌ Missing required data for login');
      Get.snackbar(
        'Error',
        'Invalid response from server. Missing required data.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
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

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '695021061678-alestl47nmltb1kds35ojadofjsc1lmg.apps.googleusercontent.com',
    scopes: <String>['email', 'profile'],
  );

  /// Handle Google Sign In with OAuth API (WITHOUT Firebase)
  Future<void> handleGoogleSignIn({String role = 'user'}) async {
    try {
      isGoogleSignInLoading.value = true;

      debugPrint('═══════════════════════════════════════');
      debugPrint('🔐 GOOGLE SIGN IN STARTED');
      debugPrint('🎭 Role: $role');
      debugPrint('═══════════════════════════════════════');

      // Sign out first to ensure user can select account
      await _googleSignIn.signOut();

      // Trigger Google Sign In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint('❌ Google Sign In cancelled by user');
        isGoogleSignInLoading.value = false;
        return;
      }

      debugPrint('✅ Google Sign In successful');
      debugPrint('👤 User: ${googleUser.displayName}');
      debugPrint('📧 Email: ${googleUser.email}');
      debugPrint('🖼️ Photo: ${googleUser.photoUrl}');

      // ============================================
      // Call OAuth Login API directly (NO Firebase needed)
      // ============================================
      await _loginWithOAuth(
        name: googleUser.displayName ?? 'Google User',
        email: googleUser.email ?? '',
        role: role,
        image: googleUser.photoUrl ?? '',
        provider: 'google',
      );
    } catch (error, stackTrace) {
      isGoogleSignInLoading.value = false;
      debugPrint('❌ Google Sign In Error: $error');
      debugPrint('📚 StackTrace: $stackTrace');

      Get.snackbar(
        'Error',
        'Google sign in failed. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }

  /// Login with OAuth API
  Future<void> _loginWithOAuth({
    required String name,
    required String email,
    required String role,
    required String image,
    required String provider,
  }) async {
    try {
      debugPrint('───────────────────────────────────────');
      debugPrint('📤 CALLING OAUTH LOGIN API');
      debugPrint('───────────────────────────────────────');

      final String oauthUrl = '${AppUrl.baseUrl}/auth/login_with_oauth';

      final Map<String, dynamic> requestBody = {
        'name': name,
        'email': email,
        'role': role,
        'image': image,
        'provider': provider,
      };

      debugPrint('URL: $oauthUrl');
      debugPrint('Body: $requestBody');

      final NetworkResponse response = await _networkCaller.postRequest(
        oauthUrl,
        body: requestBody,
        isLogin: true,
      );

      debugPrint('───────────────────────────────────────');
      debugPrint('📥 OAUTH API RESPONSE');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Is Success: ${response.isSuccess}');
      debugPrint('Response JSON: ${response.jsonResponse}');
      debugPrint('───────────────────────────────────────');

      isGoogleSignInLoading.value = false;

      if (response.isSuccess) {
        final bool success = response.jsonResponse?['success'] ?? false;
        final String message = response.jsonResponse?['message'] ?? 'Sign in successful!';
        final Map<String, dynamic>? data = response.jsonResponse?['data'];
        final Map<String, dynamic>? tokens = response.jsonResponse?['tokens'];

        debugPrint('✅ OAuth Login Success: $success');
        debugPrint('📧 Message: $message');
        debugPrint('📦 Data: $data');
        debugPrint('🔑 Tokens: $tokens');

        if (success && data != null && tokens != null) {
          await _handleSuccessfulLogin(data, tokens, message);
        } else {
          debugPrint('⚠️ Missing data or tokens in OAuth response');
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
        String errorMessage = 'OAuth login failed. Please try again.';

        if (response.jsonResponse != null) {
          errorMessage = response.jsonResponse?['message'] ??
              response.errorMessage ??
              errorMessage;
        }

        debugPrint('❌ OAuth Login Failed: $errorMessage');

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
      isGoogleSignInLoading.value = false;
      debugPrint('❌ OAuth API Exception: $e');
      debugPrint('📚 StackTrace: $stackTrace');

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

  /// [onInit] Lifecycle method called when the controller is initialized.
  @override
  Future<void> onInit() async {
    super.onInit();
    savedRole.value = await SecureStorageService().read(AppConstants.roleType) ?? '';
    isLoading.value = false;
    isGoogleSignInLoading.value = false;
    isTermsAndConditionAgreementAccept.value = false;
  }

  /// [dispose] Lifecycle method called when the controller is destroyed.
  @override
  void dispose() {
    isLoading.value = false;
    isGoogleSignInLoading.value = false;
    isTermsAndConditionAgreementAccept.value = false;
    super.dispose();
  }
}





