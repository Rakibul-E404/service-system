/**

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
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

  // Helper method to get full image URL
  String getFullImageUrl() {
    if (businessImage.value.isEmpty) {
      return '';
    }

    // If the image already has a full URL, return it as is
    if (businessImage.value.startsWith('http')) {
      return businessImage.value;
    }

    // Otherwise, construct the full URL using your API base
    String imagePath = businessImage.value.startsWith('/')
        ? businessImage.value.substring(1)
        : businessImage.value;

    String fullUrl = 'https://d7001.sobhoy.com/$imagePath';
    debugPrint('🖼️ Constructed image URL: $fullUrl');

    return fullUrl;
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

        // Update business information with null checks
        businessName.value = _getValidString(data['name'], 'Add a business name');
        category.value = _getValidString(data['category'], 'Add a business category');
        subCategory.value = _getValidString(data['subCategory'], 'Add a business sub-category');
        location.value = _getValidString(data['location'], 'Add a business location (State/Province/County)');
        advertising.value = _getValidString(data['advertising'], 'Add a business advertising');
        contactDetails.value = _getValidString(data['phone'], 'Add a business contact details');
        businessImage.value = data['image'] ?? '';

        // Debug image information
        debugPrint('🖼️ Image path from API: ${data['image']}');
        debugPrint('🖼️ Full image URL: ${getFullImageUrl()}');

        _initializeControllers();
        debugPrint('✅ Business profile fetched successfully for provider: $responseProviderId');
      } else {
        // Handle specific validation errors
        if (response.statusCode == 400) {
          debugPrint('⚠️ Validation error in profile data, using cached data');
          // Don't throw error, just use existing data
          return;
        } else {
          throw Exception(response.errorMessage ?? 'Failed to fetch business profile. Status: ${response.statusCode}');
        }
      }
    } catch (e) {
      debugPrint('❌ Error fetching business profile: $e');
      // Don't show error snackbar for validation issues, just log them
      if (!e.toString().contains('enum value') && !e.toString().contains('ValidationError')) {
        Get.snackbar(
          'Error',
          'Failed to load business profile: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Helper method to handle empty or invalid string values
  String _getValidString(String? value, String defaultValue) {
    if (value == null || value.isEmpty || value == 'null') {
      return defaultValue;
    }
    return value;
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
      final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (image != null) {
        selectedImage.value = File(image.path);
        debugPrint('✅ Image selected from gallery: ${image.path}');
        Get.snackbar(
          'Success',
          'Image selected from gallery',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('❌ Error picking image from gallery: $e');
      Get.snackbar(
        'Error',
        'Failed to pick image from gallery: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (image != null) {
        selectedImage.value = File(image.path);
        debugPrint('✅ Image taken from camera: ${image.path}');
        Get.snackbar(
          'Success',
          'Photo taken from camera',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('❌ Error taking photo from camera: $e');
      Get.snackbar(
        'Error',
        'Failed to take photo: ${e.toString()}',
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
            const Text(
                'Select Image',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)
            ),
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
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 16),
                )
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
            decoration: BoxDecoration(
              color: Colors.blue[50],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 30, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void removeImage() {
    selectedImage.value = null;
    debugPrint('🗑️ Selected image removed');
    Get.snackbar(
      'Image Removed',
      'Selected image has been removed',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }

  // Upload image to server
  Future<void> uploadBusinessImage() async {
    try {
      if (selectedImage.value == null) {
        debugPrint('ℹ️ No image selected for upload');
        return; // No image selected
      }

      isLoading.value = true;
      debugPrint('🌐 Starting image upload...');

      final providerAccessToken = await _sharedPrefService.getAccessToken();

      if (providerAccessToken == null || providerAccessToken.isEmpty) {
        throw Exception('Access token not found. Please login again.');
      }

      // Check file size (25 MB limit)
      final file = selectedImage.value!;
      final fileSize = await file.length();
      const maxSize = 25 * 1024 * 1024; // 25 MB in bytes

      if (fileSize > maxSize) {
        throw Exception('Image size exceeds 25 MB limit. Please choose a smaller image.');
      }

      debugPrint('📤 Uploading image: ${file.path}');
      debugPrint('📊 File size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://d7001.sobhoy.com/api/v1/business_profile/upload-image'),
      );

      request.headers['Authorization'] = 'Bearer $providerAccessToken';

      // Add the image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          file.path,
        ),
      );

      debugPrint('🔄 Sending image upload request...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('📥 Image upload response status: ${response.statusCode}');
      debugPrint('📥 Image upload response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          // Try different possible keys for image URL
          final newImageUrl = responseData['data']['imageUrl'] ??
              responseData['data']['image'] ??
              responseData['imageUrl'] ??
              responseData['image'];

          if (newImageUrl != null && newImageUrl.isNotEmpty) {
            businessImage.value = newImageUrl;
            debugPrint('✅ Image uploaded successfully: $newImageUrl');

            // Clear the selected image after successful upload
            selectedImage.value = null;

            Get.snackbar(
              'Success',
              'Business image uploaded successfully',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: const Duration(seconds: 3),
            );
          } else {
            throw Exception('Image URL not found in response');
          }
        } else {
          throw Exception(responseData['message'] ?? 'Image upload failed');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to upload image. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error uploading image: $e');
      Get.snackbar(
        'Upload Failed',
        'Failed to upload image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Save/Update business profile using PUT API
  Future<void> toggleEdit() async {
    if (isEditing.value) {
      // Save changes - first upload image if selected, then update profile
      try {
        isLoading.value = true;

        // Upload image first if a new one is selected
        if (selectedImage.value != null) {
          debugPrint('🖼️ New image selected, uploading...');
          await uploadBusinessImage();
        } else {
          debugPrint('ℹ️ No new image selected, skipping upload');
        }

        // Then update the business profile
        await _updateBusinessProfile();

      } catch (e) {
        debugPrint('❌ Error in toggleEdit: $e');
        rethrow;
      } finally {
        isLoading.value = false;
      }
    } else {
      // Enter edit mode
      _initializeControllers();
      isEditing.toggle();
      debugPrint('✏️ Entered edit mode');
    }
  }

  // Update business profile using PUT API
  Future<void> _updateBusinessProfile() async {
    try {
      final providerAccessToken = await _sharedPrefService.getAccessToken();

      if (providerAccessToken == null || providerAccessToken.isEmpty) {
        throw Exception('Access token not found. Please login again.');
      }

      // Prepare the request body
      final Map<String, dynamic> requestBody = {
        'name': nameController.text.isNotEmpty ? nameController.text : null,
        'phone': contactController.text.isNotEmpty ? contactController.text : null,
        'location': locationController.text.isNotEmpty ? locationController.text : null,
        'category': categoryController.text.isNotEmpty ? categoryController.text : null,
        'subCategory': subCategoryController.text.isNotEmpty ? subCategoryController.text : null,
        'advertising': advertisingController.text.isNotEmpty ? advertisingController.text : null,
      };

      // Remove null values from the request body
      requestBody.removeWhere((key, value) => value == null);

      debugPrint('🌐 Updating business profile...');
      debugPrint('📦 Request Body: $requestBody');

      // Prepare headers
      final Map<String, String> headers = {
        'Authorization': 'Bearer $providerAccessToken',
        'Content-Type': 'application/json',
      };

      // Make PUT request
      final response = await _networkCaller.putRequest(
        'https://d7001.sobhoy.com/api/v1/business_profile',
        body: requestBody,
        headers: headers,
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final responseData = response.jsonResponse!;

        debugPrint('✅ Business profile updated successfully');
        debugPrint('📋 Response: $responseData');

        // Update local state with new data from response
        if (responseData['data'] != null) {
          final data = responseData['data'];

          // Update local values directly from the successful PUT response
          businessName.value = _getValidString(data['name'], 'Add a business name');
          contactDetails.value = _getValidString(data['phone'], 'Add a business contact details');
          location.value = _getValidString(data['location'], 'Add a business location (State/Province/County)');
          businessImage.value = data['image'] ?? businessImage.value; // Keep existing image if not updated

          // Update other fields if they exist in response
          if (data['category'] != null) category.value = _getValidString(data['category'], 'Add a business category');
          if (data['subCategory'] != null) subCategory.value = _getValidString(data['subCategory'], 'Add a business sub-category');
          if (data['advertising'] != null) advertising.value = _getValidString(data['advertising'], 'Add a business advertising');
        }

        // Exit edit mode
        isEditing.value = false;

        Get.snackbar(
          'Success',
          'Business profile updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // Don't call fetchBusinessProfile() here since it's causing validation errors
        // The local state is already updated from the PUT response

      } else {
        throw Exception(response.errorMessage ?? 'Failed to update business profile. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error updating business profile: $e');
      Get.snackbar(
        'Error',
        'Failed to update business profile: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
      rethrow;
    }
  }

  void cancelEdit() {
    _initializeControllers();
    selectedImage.value = null;
    isEditing.value = false;
    debugPrint('❌ Edit cancelled, changes discarded');
    Get.snackbar(
      'Cancelled',
      'Changes discarded',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  // Force refresh method
  Future<void> forceRefresh() async {
    debugPrint('🔄 Force refreshing business profile...');
    await fetchBusinessProfile();
  }
}
*/








///
///
///
///
/// todo::: fixing the informations
///
///
///
///


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
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
  RxString location = 'Add a business location (State/Province/County)'.obs;
  RxString contactDetails = 'Add a business contact details'.obs;
  RxString description = 'Add a business description'.obs;
  RxString businessImage = ''.obs;

  // Text controllers for editing
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchBusinessProfile();
  }

  @override
  void onClose() {
    nameController.dispose();
    locationController.dispose();
    contactController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  // Helper method to get full image URL
  String getFullImageUrl() {
    if (businessImage.value.isEmpty) {
      return '';
    }

    // If the image already has a full URL, return it as is
    if (businessImage.value.startsWith('http')) {
      return businessImage.value;
    }

    // Otherwise, construct the full URL using your API base
    String imagePath = businessImage.value.startsWith('/')
        ? businessImage.value.substring(1)
        : businessImage.value;

    String fullUrl = 'https://d7001.sobhoy.com/$imagePath';
    debugPrint('🖼️ Constructed image URL: $fullUrl');

    return fullUrl;
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

        // Update business information with null checks
        businessName.value = _getValidString(data['name'], 'Add a business name');
        location.value = _getValidString(data['location'], 'Add a business location (State/Province/County)');
        contactDetails.value = _getValidString(data['phone'], 'Add a business contact details');
        description.value = _getValidString(data['description'], 'Add a business description');
        businessImage.value = data['image'] ?? '';

        // Debug image information
        debugPrint('🖼️ Image path from API: ${data['image']}');
        debugPrint('🖼️ Full image URL: ${getFullImageUrl()}');

        _initializeControllers();
        debugPrint('✅ Business profile fetched successfully for provider: $responseProviderId');
      } else {
        // Handle specific validation errors
        if (response.statusCode == 400) {
          debugPrint('⚠️ Validation error in profile data, using cached data');
          // Don't throw error, just use existing data
          return;
        } else {
          throw Exception(response.errorMessage ?? 'Failed to fetch business profile. Status: ${response.statusCode}');
        }
      }
    } catch (e) {
      debugPrint('❌ Error fetching business profile: $e');
      // Don't show error snackbar for validation issues, just log them
      if (!e.toString().contains('enum value') && !e.toString().contains('ValidationError')) {
        Get.snackbar(
          'Error',
          'Failed to load business profile: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Helper method to handle empty or invalid string values
  String _getValidString(String? value, String defaultValue) {
    if (value == null || value.isEmpty || value == 'null') {
      return defaultValue;
    }
    return value;
  }

  void _initializeControllers() {
    nameController.text = businessName.value == 'Add a business name' ? '' : businessName.value;
    locationController.text = location.value == 'Add a business location (State/Province/County)' ? '' : location.value;
    contactController.text = contactDetails.value == 'Add a business contact details' ? '' : contactDetails.value;
    descriptionController.text = description.value == 'Add a business description' ? '' : description.value;
  }

  // Image Picker Methods
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (image != null) {
        selectedImage.value = File(image.path);
        debugPrint('✅ Image selected from gallery: ${image.path}');
        Get.snackbar(
          'Success',
          'Image selected from gallery',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('❌ Error picking image from gallery: $e');
      Get.snackbar(
        'Error',
        'Failed to pick image from gallery: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (image != null) {
        selectedImage.value = File(image.path);
        debugPrint('✅ Image taken from camera: ${image.path}');
        Get.snackbar(
          'Success',
          'Photo taken from camera',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('❌ Error taking photo from camera: $e');
      Get.snackbar(
        'Error',
        'Failed to take photo: ${e.toString()}',
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
            const Text(
                'Select Image',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)
            ),
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
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 16),
                )
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
            decoration: BoxDecoration(
              color: Colors.blue[50],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 30, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void removeImage() {
    selectedImage.value = null;
    debugPrint('🗑️ Selected image removed');
    Get.snackbar(
      'Image Removed',
      'Selected image has been removed',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }

  // Upload image to server
  Future<void> uploadBusinessImage() async {
    try {
      if (selectedImage.value == null) {
        debugPrint('ℹ️ No image selected for upload');
        return; // No image selected
      }

      isLoading.value = true;
      debugPrint('🌐 Starting image upload...');

      final providerAccessToken = await _sharedPrefService.getAccessToken();

      if (providerAccessToken == null || providerAccessToken.isEmpty) {
        throw Exception('Access token not found. Please login again.');
      }

      // Check file size (25 MB limit)
      final file = selectedImage.value!;
      final fileSize = await file.length();
      const maxSize = 25 * 1024 * 1024; // 25 MB in bytes

      if (fileSize > maxSize) {
        throw Exception('Image size exceeds 25 MB limit. Please choose a smaller image.');
      }

      debugPrint('📤 Uploading image: ${file.path}');
      debugPrint('📊 File size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://d7001.sobhoy.com/api/v1/business_profile/upload-image'),
      );

      request.headers['Authorization'] = 'Bearer $providerAccessToken';

      // Add the image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          file.path,
        ),
      );

      debugPrint('🔄 Sending image upload request...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('📥 Image upload response status: ${response.statusCode}');
      debugPrint('📥 Image upload response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          // Try different possible keys for image URL
          final newImageUrl = responseData['data']['imageUrl'] ??
              responseData['data']['image'] ??
              responseData['imageUrl'] ??
              responseData['image'];

          if (newImageUrl != null && newImageUrl.isNotEmpty) {
            businessImage.value = newImageUrl;
            debugPrint('✅ Image uploaded successfully: $newImageUrl');

            // Clear the selected image after successful upload
            selectedImage.value = null;

            Get.snackbar(
              'Success',
              'Business image uploaded successfully',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: const Duration(seconds: 3),
            );
          } else {
            throw Exception('Image URL not found in response');
          }
        } else {
          throw Exception(responseData['message'] ?? 'Image upload failed');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to upload image. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error uploading image: $e');
      Get.snackbar(
        'Upload Failed',
        'Failed to upload image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Save/Update business profile using PUT API
  Future<void> toggleEdit() async {
    if (isEditing.value) {
      // Save changes - first upload image if selected, then update profile
      try {
        isLoading.value = true;

        // Upload image first if a new one is selected
        if (selectedImage.value != null) {
          debugPrint('🖼️ New image selected, uploading...');
          await uploadBusinessImage();
        } else {
          debugPrint('ℹ️ No new image selected, skipping upload');
        }

        // Then update the business profile
        await _updateBusinessProfile();

      } catch (e) {
        debugPrint('❌ Error in toggleEdit: $e');
        rethrow;
      } finally {
        isLoading.value = false;
      }
    } else {
      // Enter edit mode
      _initializeControllers();
      isEditing.toggle();
      debugPrint('✏️ Entered edit mode');
    }
  }

  // Update business profile using PUT API
  Future<void> _updateBusinessProfile() async {
    try {
      final providerAccessToken = await _sharedPrefService.getAccessToken();

      if (providerAccessToken == null || providerAccessToken.isEmpty) {
        throw Exception('Access token not found. Please login again.');
      }

      // Prepare the request body
      final Map<String, dynamic> requestBody = {
        'name': nameController.text.isNotEmpty ? nameController.text : null,
        'phone': contactController.text.isNotEmpty ? contactController.text : null,
        'location': locationController.text.isNotEmpty ? locationController.text : null,
        'description': descriptionController.text.isNotEmpty ? descriptionController.text : null,
      };

      // Remove null values from the request body
      requestBody.removeWhere((key, value) => value == null);

      debugPrint('🌐 Updating business profile...');
      debugPrint('📦 Request Body: $requestBody');

      // Prepare headers
      final Map<String, String> headers = {
        'Authorization': 'Bearer $providerAccessToken',
        'Content-Type': 'application/json',
      };

      // Make PUT request
      final response = await _networkCaller.putRequest(
        'https://d7001.sobhoy.com/api/v1/business_profile',
        body: requestBody,
        headers: headers,
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final responseData = response.jsonResponse!;

        debugPrint('✅ Business profile updated successfully');
        debugPrint('📋 Response: $responseData');

        // Update local state with new data from response
        if (responseData['data'] != null) {
          final data = responseData['data'];

          // Update local values directly from the successful PUT response
          businessName.value = _getValidString(data['name'], 'Add a business name');
          contactDetails.value = _getValidString(data['phone'], 'Add a business contact details');
          location.value = _getValidString(data['location'], 'Add a business location (State/Province/County)');
          description.value = _getValidString(data['description'], 'Add a business description');
          businessImage.value = data['image'] ?? businessImage.value; // Keep existing image if not updated
        }

        // Exit edit mode
        isEditing.value = false;

        Get.snackbar(
          'Success',
          'Business profile updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // Don't call fetchBusinessProfile() here since it's causing validation errors
        // The local state is already updated from the PUT response

      } else {
        throw Exception(response.errorMessage ?? 'Failed to update business profile. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error updating business profile: $e');
      Get.snackbar(
        'Error',
        'Failed to update business profile: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
      rethrow;
    }
  }

  void cancelEdit() {
    _initializeControllers();
    selectedImage.value = null;
    isEditing.value = false;
    debugPrint('❌ Edit cancelled, changes discarded');
    Get.snackbar(
      'Cancelled',
      'Changes discarded',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  // Force refresh method
  Future<void> forceRefresh() async {
    debugPrint('🔄 Force refreshing business profile...');
    await fetchBusinessProfile();
  }
}