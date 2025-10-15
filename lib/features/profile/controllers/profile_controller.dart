import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/network/network_caller.dart';
import 'package:manx_mate/core/config/app_constants.dart';
import 'package:manx_mate/core/data/secured_storage.dart';
import 'package:manx_mate/core/network/network_response.dart';
import '../../../core/utils/api/app_url.dart';

class ProfileController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();

  // Observables
  RxString name = ''.obs;
  RxString email = ''.obs;
  RxString profileImage = ''.obs;
  RxString location = ''.obs;
  RxString role = ''.obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  /// Fetch user profile data
  Future<void> fetchUserProfile() async {
    try {
      isLoading.value = true;

      debugPrint('═══════════════════════════════════════');
      debugPrint('👤 FETCHING USER PROFILE (ProfileScreen)');
      debugPrint('═══════════════════════════════════════');

      final String? token = await SecureStorageService().read(AppConstants.authToken);

      if (token == null || token.isEmpty) {
        debugPrint('❌ No auth token found');
        Get.snackbar(
          'Error',
          'Please login again',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        isLoading.value = false;
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
          name.value = data['name'] ?? '';
          email.value = data['email'] ?? '';
          profileImage.value = data['image'] ?? '';
          location.value = data['location'] ?? '';
          role.value = data['role'] ?? '';

          debugPrint('📛 Name: ${name.value}');
          debugPrint('📧 Email: ${email.value}');
          debugPrint('🖼️ Image: ${profileImage.value}');
          debugPrint('📍 Location: ${location.value}');
          debugPrint('🎭 Role: ${role.value}');
        } else {
          debugPrint('❌ Failed to parse profile data');
          Get.snackbar(
            'Error',
            'Failed to load profile data',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        }
      } else {
        final String errorMessage = response.jsonResponse?['message'] ??
            response.errorMessage ??
            'Failed to load profile';

        debugPrint('❌ Failed to load profile: $errorMessage');

        Get.snackbar(
          'Error',
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e, stackTrace) {
      isLoading.value = false;
      debugPrint('❌ EXCEPTION OCCURRED');
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');

      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      debugPrint('═══════════════════════════════════════');
    }
  }

  /// Get full image URL using AppUrl.getUserProfileImageUrl
  String getImageUrl() {
    if (profileImage.isEmpty) return '';
    return AppUrl.getUserProfileImageUrl(profileImage.value);
  }

  /// Refresh profile data
  Future<void> refreshProfile() async {
    await fetchUserProfile();
  }
}