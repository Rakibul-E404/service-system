


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/utils/token_service/token_storage_service.dart';

import '../../home/model/sub_category_model.dart';
import '../model/business_profile_response_model.dart';


import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ProviderProfileController extends GetxController {
  // --- Loading States ---
  final isLoading = false.obs;
  final isEditing = false.obs;
  final isUploadingImage = false.obs;
  final providerId = ''.obs;

  // --- Observable Data ---
  final businessName = ''.obs;
  final location = ''.obs;
  final description = ''.obs;
  final contactDetails = ''.obs;
  final email = ''.obs;
  final businessImage = ''.obs;
  final address = ''.obs;
  final category = ''.obs;

  final categoryId = ''.obs;
  final selectedSubCategoryId = ''.obs;
  final isSubLoading = false.obs;
  final subCategories = <SubCategoryModel>[].obs;


  final Rx<File?> selectedImageFile = Rx<File?>(null); // Added for update
  final availability = <String, AvailabilityDay>{}.obs;

  // --- Network Service ---
  final NetworkCaller _networkCaller = NetworkCaller();

  // --- Text Controllers ---
  late TextEditingController nameController;
  late TextEditingController locationController;
  late TextEditingController descriptionController;
  late TextEditingController contactController;
  late TextEditingController emailController;
  late TextEditingController addressController;

  @override
  void onInit() {
    super.onInit();
    debugPrint('🚀 Initializing ProviderProfileController');
    _initializeControllers();
    fetchBusinessProfile();
  }

  // --- NEW: UPDATE METHOD (Multipart PUT) ---
  Future<void> updateBusinessProfile({
    required String name,
    required String phone,
    required String description,
    required String serviceCategory,
    required String region,
    required String location,
  }) async {
    try {
      isLoading.value = true;
      final token = await _getAuthToken();

      // Creating the Multipart Request manually
      var request = http.MultipartRequest('PUT', Uri.parse(AppUrl.updateBusinessProfile));

      // Headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Form Fields (Name, Phone, etc.)
      request.fields.addAll({
        "name": name,
        "phone": phone,
        "description": description,
        "serviceCategory": serviceCategory,
        "region": region.toLowerCase(),
        "location": location,
      });

      // Image File (If selected)
      if (selectedImageFile.value != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          selectedImageFile.value!.path,
        ));
      }

      // Send Request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      var jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        Get.snackbar('Success', jsonResponse['message'] ?? 'Profile updated',
            backgroundColor: Colors.green, colorText: Colors.white);

        selectedImageFile.value = null;
        await fetchBusinessProfile(); // Refresh data
        Get.back();
      } else {
        Get.snackbar('Update Failed', jsonResponse['message'] ?? 'Error ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('🧨 Update Error: $e');
      Get.snackbar('Error', 'Something went wrong');
    } finally {
      isLoading.value = false;
    }
  }

  // Helper to pick image
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImageFile.value = File(image.path);
    }
  }

  // --- EXISTING CODE REMAINS THE SAME ---

  String get todayHours {
    if (availability.isEmpty) return 'Loading hours...';
    String dayName = DateFormat('EEEE').format(DateTime.now());
    final todayData = availability[dayName];
    if (todayData == null || !todayData.isAvailable) {
      return 'Today: Closed';
    }
    return 'Today: ${_formatTime(todayData.openingTime)} - ${_formatTime(todayData.closingTime)}';
  }

  String _formatTime(int hour) {
    final tempDate = DateTime(2026, 1, 1, hour, 0);
    return DateFormat('h:mm a').format(tempDate);
  }

  Future<String?> _getAuthToken() async {
    final tokenService = SharedPrefService();
    return await tokenService.getAccessToken();
  }

  void _initializeControllers() {
    nameController = TextEditingController(text: businessName.value);
    locationController = TextEditingController(text: location.value);
    descriptionController = TextEditingController(text: description.value);
    contactController = TextEditingController(text: contactDetails.value);
    emailController = TextEditingController(text: email.value);
    addressController = TextEditingController(text: address.value);
  }

  @override
  void onClose() {
    nameController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    contactController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.onClose();
  }

  Future<void> fetchBusinessProfile() async {
    try {
      isLoading.value = true;
      final token = await _getAuthToken();
      if (token == null || token.isEmpty) return;

      final response = await _networkCaller.getRequest(
        AppUrl.getBusinessProfile,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final profileResponse = BusinessProfileResponse.fromJson(response.jsonResponse!);
        final rawData = response.jsonResponse!['data'] as Map<String, dynamic>?;
        String emailValue = rawData?['email']?.toString() ?? '';
        _mapModelToUI(profileResponse.data, emailValue: emailValue);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _mapModelToUI(BusinessProfile data, {String emailValue = ''}) {
    providerId.value = data.id;
    businessName.value = data.name;
    location.value = data.location;
    description.value = data.description;
    contactDetails.value = data.phone;
    address.value = data.region;
    // ✅ FIX: serviceCategory is now an object
    category.value = data.serviceCategory.name;
    categoryId.value = data.serviceCategory.id;
    category.value = data.serviceCategory.name;
    email.value = emailValue;
    businessImage.value = data.image;

    nameController.text = businessName.value;
    locationController.text = location.value;
    descriptionController.text = description.value;
    contactController.text = contactDetails.value;
    addressController.text = address.value;
    emailController.text = email.value;

    availability.value = data.availability;
  }


  void cancelEdit() {
    nameController.text = businessName.value;
    locationController.text = location.value;
    descriptionController.text = description.value;
    contactController.text = contactDetails.value;
    addressController.text = address.value;
    emailController.text = email.value;
    isEditing.value = false;
  }

  void forceRefresh() => fetchBusinessProfile();

  String getFullImageUrl() {
    if (businessImage.value.isEmpty) return '';
    if (businessImage.value.startsWith('http')) return businessImage.value;
    return '${AppUrl.baseUrl}${businessImage.value}';
  }

  void showImagePickerDialog() {
    pickImage(); // Connect the logic
  }
}