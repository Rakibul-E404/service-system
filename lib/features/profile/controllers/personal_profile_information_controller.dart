
/**

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio; // Prefix dio to avoid ambiguity
import 'package:manx_mate/core/network/network_caller.dart';
import 'package:manx_mate/core/config/app_constants.dart';
import 'package:manx_mate/core/data/secured_storage.dart';
import '../../../core/network/network_response.dart';
import '../../../core/utils/api/app_url.dart';


class ProfileInformationController extends GetxController {
  RxBool isEditing = false.obs;
  RxBool isLoading = true.obs;
  RxBool isUploadingImage = false.obs;

  RxString name = ''.obs;
  RxString email = ''.obs;
  RxString location = ''.obs;
  RxString profileImage = ''.obs;
  RxString userId = ''.obs;
  RxString role = ''.obs;

  Rx<File?> selectedImageFile = Rx<File?>(null);
  final ImagePicker _imagePicker = ImagePicker();

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController locationController;

  final dio.Dio _dio = dio.Dio();

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    emailController = TextEditingController();
    locationController = TextEditingController();
    fetchUserProfile();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    locationController.dispose();
    super.onClose();
  }

  /// Show image picker options
  void showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Change Profile Picture',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.photo_camera, color: Colors.blue),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Colors.green),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    pickImage(ImageSource.gallery);
                  },
                ),
                if (selectedImageFile.value != null || profileImage.value.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text('Remove Photo'),
                    onTap: () {
                      Navigator.pop(context);
                      removeImage();
                    },
                  ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Pick image from camera or gallery
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Validate file extension
        final String extension = pickedFile.path.split('.').last.toLowerCase();
        if (!['jpg', 'jpeg', 'png'].contains(extension)) {
          Get.snackbar(
            'Invalid Format',
            'Please select a JPG, JPEG, or PNG image',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
          return;
        }

        // Validate file size (max 5MB)
        final File file = File(pickedFile.path);
        final int fileSize = await file.length();
        if (fileSize > 5 * 1024 * 1024) {
          Get.snackbar(
            'File Too Large',
            'Please select an image smaller than 5MB',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
          return;
        }

        selectedImageFile.value = file;
        debugPrint('✅ Image selected: ${pickedFile.path}');
        debugPrint('📦 File size: ${(fileSize / 1024).toStringAsFixed(2)} KB');
      }
    } catch (e) {
      debugPrint('❌ Error picking image: $e');
      Get.snackbar(
        'Error',
        'Failed to pick image. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  /// Remove selected image
  void removeImage() {
    selectedImageFile.value = null;
    Get.snackbar(
      'Success',
      'Profile picture removed',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  /// Fetch user profile from API
  Future<void> fetchUserProfile() async {
    try {
      isLoading.value = true;

      debugPrint('═══════════════════════════════════════');
      debugPrint('👤 FETCHING USER PROFILE');
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
      debugPrint('Token: ${token.substring(0, 20)}...');

      final NetworkResponse response = await NetworkCaller().getRequest(
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
          userId.value = data['_id'] ?? '';
          name.value = data['name'] ?? '';
          email.value = data['email'] ?? '';
          location.value = data['location'] ?? 'Not provided';
          profileImage.value = data['image'] ?? '';
          role.value = data['role'] ?? '';

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

  /// Update user profile with API
  Future<void> updateProfile() async {
    try {
      isLoading.value = true;

      debugPrint('═══════════════════════════════════════');
      debugPrint('✏️ UPDATING USER PROFILE (Partial Update)');
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

      // Build dynamic form data map
      final Map<String, dynamic> updateFields = {};

      // Compare only changed fields
      if (nameController.text.trim() != name.value.trim()) {
        updateFields['name'] = nameController.text.trim();
      }

      if (locationController.text.trim().toLowerCase() != location.value.trim().toLowerCase()) {
        updateFields['location'] = locationController.text.trim().toLowerCase();
      }

      // Add image if changed
      if (selectedImageFile.value != null) {
        String fileName = selectedImageFile.value!.path.split('/').last;
        updateFields['image'] = await dio.MultipartFile.fromFile(
          selectedImageFile.value!.path,
          filename: fileName,
        );
      }

      if (updateFields.isEmpty) {
        isLoading.value = false;
        Get.snackbar(
          'No Changes',
          'There is nothing to update',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      dio.FormData formData = dio.FormData.fromMap(updateFields);

      debugPrint('📤 Sending multipart request to ${AppUrl.updateSelfProfileUrl}');
      debugPrint('📝 Fields to update: $updateFields');

      final response = await _dio.put(
        AppUrl.updateSelfProfileUrl,
        data: formData,
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      debugPrint('───────────────────────────────────────');
      debugPrint('📥 API RESPONSE');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Data: ${response.data}');
      debugPrint('───────────────────────────────────────');

      isLoading.value = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final bool success = data['success'] ?? false;
        final String message = data['message'] ?? 'Profile updated successfully';

        if (success) {
          // Update reactive values only for changed fields
          if (updateFields.containsKey('name')) name.value = nameController.text;
          if (updateFields.containsKey('location')) location.value = locationController.text;
          if (updateFields.containsKey('image')) {
            profileImage.value = data['data']?['image'] ?? profileImage.value;
          }

          selectedImageFile.value = null;
          isEditing.value = false;

          Get.snackbar(
            'Success',
            message,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            icon: const Icon(Icons.check_circle, color: Colors.white),
          );

          await fetchUserProfile();
          debugPrint('✅ Profile updated successfully (partial)');
        } else {
          Get.snackbar(
            'Error',
            message,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        }
      } else {
        final String errorMessage = response.data['message'] ?? 'Failed to update profile';
        debugPrint('❌ Update Failed: $errorMessage');

        Get.snackbar(
          'Error',
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }

      debugPrint('═══════════════════════════════════════');
    } catch (e, stackTrace) {
      isLoading.value = false;
      debugPrint('❌ Update Profile Error: $e');
      debugPrint('StackTrace: $stackTrace');

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
      updateProfile();
    } else {
      nameController.text = name.value;
      emailController.text = email.value;
      locationController.text = location.value;
      isEditing.value = true;
    }
  }

  void cancelEdit() {
    nameController.text = name.value;
    emailController.text = email.value;
    locationController.text = location.value;
    selectedImageFile.value = null;
    isEditing.value = false;
  }

  /// Get full image URL using AppUrl.getUserProfileImageUrl
  String getImageUrl() {
    if (selectedImageFile.value != null) {
      return selectedImageFile.value!.path;
    }

    if (profileImage.isEmpty) return '';

    // Call the static method from AppUrl class
    return AppUrl.getUserProfileImageUrl(profileImage.value);
  }

  /// Check if displaying local file
  bool isLocalImage() {
    return selectedImageFile.value != null;
  }
}
*/







///
///
///
/// todo:: making the location as dropdown view
///
///
///



import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio; // Prefix dio to avoid ambiguity
import 'package:manx_mate/core/network/network_caller.dart';
import 'package:manx_mate/core/config/app_constants.dart';
import 'package:manx_mate/core/data/secured_storage.dart';
import '../../../core/network/network_response.dart';
import '../../../core/utils/api/app_url.dart';

class ProfileInformationController extends GetxController {
  RxBool isEditing = false.obs;
  RxBool isLoading = true.obs;
  RxBool isUploadingImage = false.obs;

  RxString name = ''.obs;
  RxString email = ''.obs;
  RxString location = ''.obs;
  RxString profileImage = ''.obs;
  RxString userId = ''.obs;
  RxString role = ''.obs;

  // Location dropdown
  final List<String> locationOptions = ['north', 'south', 'east', 'west'];
  RxString selectedLocation = ''.obs;

  Rx<File?> selectedImageFile = Rx<File?>(null);
  final ImagePicker _imagePicker = ImagePicker();

  late TextEditingController nameController;
  late TextEditingController emailController;
  // Remove locationController since we're using dropdown

  final dio.Dio _dio = dio.Dio();

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    emailController = TextEditingController();
    fetchUserProfile();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    super.onClose();
  }

  /// Show image picker options
  void showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Change Profile Picture',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.photo_camera, color: Colors.blue),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Colors.green),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    pickImage(ImageSource.gallery);
                  },
                ),
                if (selectedImageFile.value != null || profileImage.value.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text('Remove Photo'),
                    onTap: () {
                      Navigator.pop(context);
                      removeImage();
                    },
                  ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Pick image from camera or gallery
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Validate file extension
        final String extension = pickedFile.path.split('.').last.toLowerCase();
        if (!['jpg', 'jpeg', 'png'].contains(extension)) {
          Get.snackbar(
            'Invalid Format',
            'Please select a JPG, JPEG, or PNG image',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
          return;
        }

        // Validate file size (max 5MB)
        final File file = File(pickedFile.path);
        final int fileSize = await file.length();
        if (fileSize > 5 * 1024 * 1024) {
          Get.snackbar(
            'File Too Large',
            'Please select an image smaller than 5MB',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
          return;
        }

        selectedImageFile.value = file;
        debugPrint('✅ Image selected: ${pickedFile.path}');
        debugPrint('📦 File size: ${(fileSize / 1024).toStringAsFixed(2)} KB');
      }
    } catch (e) {
      debugPrint('❌ Error picking image: $e');
      Get.snackbar(
        'Error',
        'Failed to pick image. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  /// Remove selected image
  void removeImage() {
    selectedImageFile.value = null;
    Get.snackbar(
      'Success',
      'Profile picture removed',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  /// Fetch user profile from API
  Future<void> fetchUserProfile() async {
    try {
      isLoading.value = true;

      debugPrint('═══════════════════════════════════════');
      debugPrint('👤 FETCHING USER PROFILE');
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
      debugPrint('Token: ${token.substring(0, 20)}...');

      final NetworkResponse response = await NetworkCaller().getRequest(
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
          userId.value = data['_id'] ?? '';
          name.value = data['name'] ?? '';
          email.value = data['email'] ?? '';
          location.value = data['location'] ?? '';
          profileImage.value = data['image'] ?? '';
          role.value = data['role'] ?? '';

          nameController.text = name.value;
          emailController.text = email.value;

          // Set selected location from API response
          if (location.value.isNotEmpty && locationOptions.contains(location.value.toLowerCase())) {
            selectedLocation.value = location.value.toLowerCase();
          } else {
            selectedLocation.value = ''; // No selection if invalid location
          }

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

  /// Update user profile with API
  Future<void> updateProfile() async {
    try {
      isLoading.value = true;

      debugPrint('═══════════════════════════════════════');
      debugPrint('✏️ UPDATING USER PROFILE (Partial Update)');
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

      // Build dynamic form data map
      final Map<String, dynamic> updateFields = {};

      // Compare only changed fields
      if (nameController.text.trim() != name.value.trim()) {
        updateFields['name'] = nameController.text.trim();
      }

      // Check if location changed (using lowercase)
      if (selectedLocation.value.isNotEmpty && selectedLocation.value != location.value.toLowerCase()) {
        updateFields['location'] = selectedLocation.value.toLowerCase();
      }

      // Add image if changed
      if (selectedImageFile.value != null) {
        String fileName = selectedImageFile.value!.path.split('/').last;
        updateFields['image'] = await dio.MultipartFile.fromFile(
          selectedImageFile.value!.path,
          filename: fileName,
        );
      }

      if (updateFields.isEmpty) {
        isLoading.value = false;
        Get.snackbar(
          'No Changes',
          'There is nothing to update',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      dio.FormData formData = dio.FormData.fromMap(updateFields);

      debugPrint('📤 Sending multipart request to ${AppUrl.updateSelfProfileUrl}');
      debugPrint('📝 Fields to update: $updateFields');

      final response = await _dio.put(
        AppUrl.updateSelfProfileUrl,
        data: formData,
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      debugPrint('───────────────────────────────────────');
      debugPrint('📥 API RESPONSE');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Data: ${response.data}');
      debugPrint('───────────────────────────────────────');

      isLoading.value = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final bool success = data['success'] ?? false;
        final String message = data['message'] ?? 'Profile updated successfully';

        if (success) {
          // Update reactive values only for changed fields
          if (updateFields.containsKey('name')) name.value = nameController.text;
          if (updateFields.containsKey('location')) location.value = selectedLocation.value;
          if (updateFields.containsKey('image')) {
            profileImage.value = data['data']?['image'] ?? profileImage.value;
          }

          selectedImageFile.value = null;
          isEditing.value = false;

          Get.snackbar(
            'Success',
            message,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            icon: const Icon(Icons.check_circle, color: Colors.white),
          );

          await fetchUserProfile();
          debugPrint('✅ Profile updated successfully (partial)');
        } else {
          Get.snackbar(
            'Error',
            message,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        }
      } else {
        final String errorMessage = response.data['message'] ?? 'Failed to update profile';
        debugPrint('❌ Update Failed: $errorMessage');

        Get.snackbar(
          'Error',
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }

      debugPrint('═══════════════════════════════════════');
    } catch (e, stackTrace) {
      isLoading.value = false;
      debugPrint('❌ Update Profile Error: $e');
      debugPrint('StackTrace: $stackTrace');

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
      updateProfile();
    } else {
      nameController.text = name.value;
      emailController.text = email.value;
      // Set selected location when entering edit mode
      if (location.value.isNotEmpty && locationOptions.contains(location.value.toLowerCase())) {
        selectedLocation.value = location.value.toLowerCase();
      } else {
        selectedLocation.value = '';
      }
      isEditing.value = true;
    }
  }

  void cancelEdit() {
    nameController.text = name.value;
    emailController.text = email.value;
    // Reset location selection
    if (location.value.isNotEmpty && locationOptions.contains(location.value.toLowerCase())) {
      selectedLocation.value = location.value.toLowerCase();
    } else {
      selectedLocation.value = '';
    }
    selectedImageFile.value = null;
    isEditing.value = false;
  }

  /// Get full image URL using AppUrl.getUserProfileImageUrl
  String getImageUrl() {
    if (selectedImageFile.value != null) {
      return selectedImageFile.value!.path;
    }

    if (profileImage.isEmpty) return '';

    // Call the static method from AppUrl class
    return AppUrl.getUserProfileImageUrl(profileImage.value);
  }

  /// Check if displaying local file
  bool isLocalImage() {
    return selectedImageFile.value != null;
  }

  /// Format location for display (capitalize first letter)
  String getDisplayLocation() {
    if (location.value.isEmpty) return 'Not provided';
    return location.value[0].toUpperCase() + location.value.substring(1);
  }
}





