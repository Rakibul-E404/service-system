

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';
import '../../../core/network/network_caller.dart';
import '../../../core/utils/token_service/token_storage_service.dart';

class ProviderProfileController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();
  final SharedPrefService _sharedPrefService = SharedPrefService();

  RxBool isEditing = false.obs;
  RxBool isLoading = false.obs;
  Rx<File?> selectedImage = Rx<File?>(null);
  RxString providerId = ''.obs;

  // Business information
  RxString businessName = 'Add a business name'.obs;
  RxString category = 'Add a business category'.obs;
  RxString subCategory = 'Add a business sub-category'.obs;
  RxString location = 'Add a business location (State/Province/County)'.obs;
  RxString advertising = 'Add a business advertising'.obs;
  RxString contactDetails = 'Add a business contact details'.obs;
  RxString businessImage = ''.obs;

  // Text controllers for editing
  final TextEditingController nameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController subCategoryController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController advertisingController = TextEditingController();
  final TextEditingController contactController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchBusinessProfile();
  }

  @override
  void onClose() {
    nameController.dispose();
    categoryController.dispose();
    subCategoryController.dispose();
    locationController.dispose();
    advertisingController.dispose();
    contactController.dispose();
    super.onClose();
  }

  // Debug method to check SharedPreferences
  Future<void> debugSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');
      final refreshToken = prefs.getString('refreshToken');
      final userRole = prefs.getString('userRole');
      final providerId = prefs.getString('providerId');
      final isLoggedIn = prefs.getBool('isLoggedIn');

      debugPrint('🔍 SharedPreferences Debug:');
      debugPrint('   Access Token: ${accessToken != null ? "${accessToken.substring(0, 20)}..." : "null"}');
      debugPrint('   Refresh Token: ${refreshToken != null ? "${refreshToken.substring(0, 20)}..." : "null"}');
      debugPrint('   User Role: $userRole');
      debugPrint('   Provider ID: $providerId');
      debugPrint('   Is Logged In: $isLoggedIn');
    } catch (e) {
      debugPrint('❌ Error debugging SharedPreferences: $e');
    }
  }

  // Extract provider ID from JWT token
  String? getProviderIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        debugPrint('❌ Invalid token format');
        return null;
      }

      final payload = parts[1];
      // Add padding if needed
      String normalized = base64Url.normalize(payload);
      // Decode base64url
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(decoded);

      debugPrint('🔍 Token payload: $payloadMap');

      // Try different possible keys for provider ID
      return payloadMap['_id'] ??
          payloadMap['id'] ??
          payloadMap['providerId'] ??
          payloadMap['userId'] ??
          payloadMap['sub'];
    } catch (e) {
      debugPrint('❌ Error decoding token: $e');
      return null;
    }
  }

  // Fetch business profile from API
  Future<void> fetchBusinessProfile() async {
    try {
      isLoading.value = true;

      // Debug SharedPreferences first
      await debugSharedPreferences();

      // Try multiple ways to get provider ID
      String? providerIdValue = await _sharedPrefService.getProviderId();

      // If not found in SharedPreferences, try to get from token
      if (providerIdValue == null || providerIdValue.isEmpty) {
        debugPrint('🔄 Provider ID not found in SharedPreferences, trying token...');
        final accessToken = await _sharedPrefService.getAccessToken();
        if (accessToken != null && accessToken.isNotEmpty) {
          providerIdValue = getProviderIdFromToken(accessToken);
          if (providerIdValue != null) {
            debugPrint('✅ Found provider ID in token: $providerIdValue');
            // Save it for future use
            await _sharedPrefService.saveProviderId(providerIdValue);
          } else {
            debugPrint('❌ Provider ID not found in token either');
          }
        } else {
          debugPrint('❌ Access token is null or empty');
        }
      } else {
        debugPrint('✅ Using provider ID from SharedPreferences: $providerIdValue');
      }

      // If still not found, show specific error
      if (providerIdValue == null || providerIdValue.isEmpty) {
        Get.snackbar(
          'Authentication Error',
          'Unable to identify your account. Please login again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
        isLoading.value = false;
        return;
      }

      final providerAccessToken = await _sharedPrefService.getAccessToken();

      if (providerAccessToken == null || providerAccessToken.isEmpty) {
        throw Exception('Access token not found. Please login again.');
      }

      debugPrint('🌐 Fetching business profile for provider: $providerIdValue');

      final response = await _networkCaller.getRequest(
        'https://d7001.sobhoy.com/api/v1/business_profile/$providerIdValue',
        headers: {'Authorization': 'Bearer $providerAccessToken'},
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final data = response.jsonResponse!['data'];

        // Always update the provider ID from the response
        final String responseProviderId = data['_id'] ?? providerIdValue;
        providerId.value = responseProviderId;

        // Save the confirmed provider ID
        if (responseProviderId != providerIdValue) {
          await _sharedPrefService.saveProviderId(responseProviderId);
          debugPrint('✅ Updated provider ID in SharedPreferences: $responseProviderId');
        }

        // Update business information
        businessName.value = data['name'] ?? 'Add a business name';
        category.value = data['category'] ?? 'Add a business category';
        subCategory.value = data['subCategory'] ?? 'Add a business sub-category';
        location.value = data['location'] ?? 'Add a business location (State/Province/County)';
        advertising.value = data['advertising'] ?? 'Add a business advertising';
        contactDetails.value = data['phone'] ?? 'Add a business contact details';
        businessImage.value = data['image'] ?? '';

        _initializeControllers();
        debugPrint('✅ Business profile fetched successfully for provider: $responseProviderId');
      } else {
        throw Exception(response.errorMessage ?? 'Failed to fetch business profile. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching business profile: $e');
      Get.snackbar(
        'Error',
        'Failed to load business profile: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _initializeControllers() {
    nameController.text = businessName.value == 'Add a business name' ? '' : businessName.value;
    categoryController.text = category.value == 'Add a business category' ? '' : category.value;
    subCategoryController.text = subCategory.value == 'Add a business sub-category'
        ? ''
        : subCategory.value;
    locationController.text = location.value == 'Add a business location (State/Province/County)'
        ? ''
        : location.value;
    advertisingController.text = advertising.value == 'Add a business advertising'
        ? ''
        : advertising.value;
    contactController.text = contactDetails.value == 'Add a business contact details'
        ? ''
        : contactDetails.value;
  }

  // Image Picker Methods
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        selectedImage.value = File(image.path);
        Get.snackbar(
          'Success',
          'Image selected from gallery',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image from gallery',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image != null) {
        selectedImage.value = File(image.path);
        Get.snackbar(
          'Success',
          'Photo taken from camera',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to take photo',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void showImagePickerDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('Select Image', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _buildImagePickerOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: pickImageFromGallery,
                ),
                _buildImagePickerOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: pickImageFromCamera,
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel')
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildImagePickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        Get.back();
        onTap();
      },
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle),
            child: Icon(icon, size: 30, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void removeImage() {
    selectedImage.value = null;
    Get.snackbar(
      'Image Removed',
      'Business image has been removed',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Save/Update business profile
  Future<void> toggleEdit() async {
    if (isEditing.value) {
      // Save changes
      await _saveBusinessProfile();
    } else {
      // Enter edit mode
      _initializeControllers();
      isEditing.toggle();
    }
  }

  Future<void> _saveBusinessProfile() async {
    try {
      isLoading.value = true;

      // Get provider ID from SharedPreferences
      final String? providerIdValue = await _sharedPrefService.getProviderId();

      if (providerIdValue == null || providerIdValue.isEmpty) {
        throw Exception('Provider ID not found. Please login again.');
      }

      final Map<String, dynamic> body = {
        'name': nameController.text.isEmpty ? null : nameController.text,
        'category': categoryController.text.isEmpty ? null : categoryController.text,
        'subCategory': subCategoryController.text.isEmpty ? null : subCategoryController.text,
        'location': locationController.text.isEmpty ? null : locationController.text,
        'advertising': advertisingController.text.isEmpty ? null : advertisingController.text,
        'phone': contactController.text.isEmpty ? null : contactController.text,
      };

      // Remove null values
      body.removeWhere((key, value) => value == null);

      final providerAccessToken = await _sharedPrefService.getAccessToken();

      if (providerAccessToken == null || providerAccessToken.isEmpty) {
        throw Exception('Access token not found. Please login again.');
      }

      debugPrint('🌐 Updating business profile for provider: $providerIdValue');

      final response = await _networkCaller.putRequest(
        'https://d7001.sobhoy.com/api/v1/business_profile/$providerIdValue',
        body: body,
        headers: {'Authorization': 'Bearer $providerAccessToken'},
      );

      if (response.isSuccess) {
        // Update local values
        businessName.value = nameController.text.isEmpty
            ? 'Add a business name'
            : nameController.text;
        category.value = categoryController.text.isEmpty
            ? 'Add a business category'
            : categoryController.text;
        subCategory.value = subCategoryController.text.isEmpty
            ? 'Add a business sub-category'
            : subCategoryController.text;
        location.value = locationController.text.isEmpty
            ? 'Add a business location (State/Province/County)'
            : locationController.text;
        advertising.value = advertisingController.text.isEmpty
            ? 'Add a business advertising'
            : advertisingController.text;
        contactDetails.value = contactController.text.isEmpty
            ? 'Add a business contact details'
            : contactController.text;

        isEditing.toggle();

        Get.snackbar(
          'Success',
          'Business profile updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw Exception(response.errorMessage ?? 'Failed to update profile');
      }
    } catch (e) {
      debugPrint('❌ Error updating business profile: $e');
      Get.snackbar(
        'Error',
        'Failed to update business profile: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void cancelEdit() {
    _initializeControllers();
    selectedImage.value = null;
    isEditing.value = false;
  }

  // Force refresh method
  Future<void> forceRefresh() async {
    await fetchBusinessProfile();
  }
}







///
///
///
/// todo:: :: fixing the provider Id
///
///
///
///










