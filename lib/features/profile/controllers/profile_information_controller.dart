import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/network/network_caller.dart';
import 'package:manx_mate/core/network/network_response.dart';
import 'package:manx_mate/core/config/app_constants.dart';
import 'package:manx_mate/core/data/secured_storage.dart';

import '../../../core/utils/api/app_url.dart';

class ProfileInformationController extends GetxController {
  RxBool isEditing = false.obs;
  RxBool isLoading = true.obs;

  RxString name = ''.obs;
  RxString email = ''.obs;
  RxString location = ''.obs;
  RxString profileImage = ''.obs;
  RxString userId = ''.obs;
  RxString role = ''.obs;

  // Text controllers for editing
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController locationController;

  final NetworkCaller _networkCaller = NetworkCaller();

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    emailController = TextEditingController();
    locationController = TextEditingController();

    // Fetch profile when controller initializes
    fetchUserProfile();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    locationController.dispose();
    super.onClose();
  }

  /// Fetch user profile from API
  Future<void> fetchUserProfile() async {
    try {
      isLoading.value = true;

      debugPrint('═══════════════════════════════════════');
      debugPrint('👤 FETCHING USER PROFILE');
      debugPrint('═══════════════════════════════════════');

      // Get auth token from secure storage
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
      debugPrint('Token: ${token.substring(0, 20)}...');

      // Call the API with authorization header
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

      if (response.isSuccess) {
        final bool success = response.jsonResponse?['success'] ?? false;
        final Map<String, dynamic>? data = response.jsonResponse?['data'];

        debugPrint('✅ Profile Fetch Success: $success');
        debugPrint('📦 User Data: $data');

        if (success && data != null) {
          // Extract user data
          userId.value = data['_id'] ?? '';
          name.value = data['name'] ?? '';
          email.value = data['email'] ?? '';
          location.value = data['location'] ?? 'Not provided';
          profileImage.value = data['image'] ?? '';
          role.value = data['role'] ?? '';

          // Update text controllers
          nameController.text = name.value;
          emailController.text = email.value;
          locationController.text = location.value;

          debugPrint('👤 User ID: ${userId.value}');
          debugPrint('📛 Name: ${name.value}');
          debugPrint('📧 Email: ${email.value}');
          debugPrint('📍 Location: ${location.value}');
          debugPrint('🖼️ Image: ${profileImage.value}');
          debugPrint('🎭 Role: ${role.value}');
        } else {
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

        debugPrint('❌ Profile Fetch Failed: $errorMessage');

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

  /// Update user profile (you can implement this later)
  Future<void> updateProfile() async {
    try {
      isLoading.value = true;

      debugPrint('═══════════════════════════════════════');
      debugPrint('✏️ UPDATING USER PROFILE');
      debugPrint('═══════════════════════════════════════');

      // Get auth token
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

      // Prepare request body
      final Map<String, dynamic> requestBody = {
        'name': nameController.text.trim(),
        'location': locationController.text.trim(),
      };

      debugPrint('📤 Update Request: $requestBody');

      // TODO: Call update profile API
      // You'll need to add the update endpoint to AppUrl
      // final NetworkResponse response = await _networkCaller.putRequest(
      //   AppUrl.updateProfileUrl,
      //   body: requestBody,
      //   headers: {
      //     'Authorization': 'Bearer $token',
      //   },
      // );

      // For now, just update locally
      await Future.delayed(const Duration(seconds: 1));

      // Update values
      name.value = nameController.text;
      location.value = locationController.text;

      isLoading.value = false;
      isEditing.value = false;

      Get.snackbar(
        'Success',
        'Profile updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );

      debugPrint('✅ Profile updated successfully');
      debugPrint('═══════════════════════════════════════');
    } catch (e) {
      isLoading.value = false;
      debugPrint('❌ Update Profile Error: $e');

      Get.snackbar(
        'Error',
        'Failed to update profile',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  void toggleEdit() {
    if (isEditing.value) {
      // Save changes
      updateProfile();
    } else {
      // Enter edit mode - sync controllers with current values
      nameController.text = name.value;
      emailController.text = email.value;
      locationController.text = location.value;
      isEditing.value = true;
    }
  }

  void cancelEdit() {
    // Reset controllers to original values
    nameController.text = name.value;
    emailController.text = email.value;
    locationController.text = location.value;
    isEditing.value = false;
  }

  /// Get full image URL
  String getImageUrl() {
    if (profileImage.isEmpty) return '';
    if (profileImage.value.startsWith('http')) {
      return profileImage.value;
    }
    // Assuming your images are served from the base URL
    return '${AppUrl.baseUrl.replaceAll('/api/v1', '')}/${profileImage.value}';
  }
}