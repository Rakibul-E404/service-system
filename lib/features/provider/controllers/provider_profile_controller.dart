


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/utils/token_service/token_storage_service.dart';

import '../model/business_profile_response_model.dart';


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


  final availability = <String, AvailabilityDay>{}.obs;

  String get todayHours {
    if (availability.isEmpty) return 'Loading hours...';

    // 1. Get current day name with Capitalized first letter (e.g., "Wednesday")
    // Your API uses "Wednesday", not "wednesday"
    String dayName = DateFormat('EEEE').format(DateTime.now());

    // 2. Look up in availability map
    final todayData = availability[dayName];

    // 3. Handle Null or Closed status
    if (todayData == null || !todayData.isAvailable) {
      return 'Today: Closed';
    }

    // 4. Format and Return
    return 'Today: ${_formatTime(todayData.openingTime)} - ${_formatTime(todayData.closingTime)}';
  }

  String _formatTime(int hour) {
    // Since your API sends 9 instead of 900, we use it directly as the hour
    final tempDate = DateTime(2026, 1, 1, hour, 0);
    return DateFormat('h:mm a').format(tempDate);
  }

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

  // Helper to get token from shared preferences
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
    debugPrint('🗑 Disposing ProviderProfileController');
    nameController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    contactController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.onClose();
  }

  // --- API Fetching ---

  Future<void> fetchBusinessProfile() async {
    try {
      isLoading.value = true;

      // 1. Get the real token
      final token = await _getAuthToken();

      if (token == null || token.isEmpty) {
        debugPrint('❌ No token found');
        Get.snackbar('Auth Error', 'Please log in again');
        return;
      }

      debugPrint('📡 Fetching profile from: ${AppUrl.getBusinessProfile}');

      final response = await _networkCaller.getRequest(
        AppUrl.getBusinessProfile,
        headers: {
          'Authorization': 'Bearer $token', // Dynamic token fix
        },
      );

      debugPrint('📥 Response Code: ${response.statusCode}');

      if (response.isSuccess && response.jsonResponse != null) {
        // Ensure you match the 'data' nesting of your specific API response
        final profileResponse = BusinessProfileResponse.fromJson(response.jsonResponse!);

        // Check if email exists in the raw response data
        final rawData = response.jsonResponse!['data'] as Map<String, dynamic>?;
        String emailValue = '';
        if (rawData != null && rawData.containsKey('email')) {
          emailValue = rawData['email']?.toString() ?? '';
        }

        _mapModelToUI(profileResponse.data, emailValue: emailValue);
      } else if (response.statusCode == 401) {
        debugPrint('❌ Unauthorized: Token might be expired or malformed');
        Get.snackbar('Session Expired', 'Please log in again');
      } else {
        debugPrint('❌ Server Error: ${response.errorMessage}');
        Get.snackbar('Error', 'Failed to fetch profile: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('🧨 Connection/Mapping Error: $e');
      Get.snackbar('Error', 'Connection error');
    } finally {
      isLoading.value = false;
    }
  }

  void _mapModelToUI(BusinessProfile data, {String emailValue = ''}) {
    debugPrint('Mapping ID: ${data.id}');

    providerId.value = data.id ?? '';
    businessName.value = data.name ?? '';
    location.value = data.location ?? '';
    description.value = data.description ?? '';
    contactDetails.value = data.phone ?? '';
    address.value = data.region ?? '';
    email.value = emailValue; // Set email from raw response
    businessImage.value = data.image ?? '';

    // Update controllers so Edit Mode starts with current data
    nameController.text = businessName.value;
    locationController.text = location.value;
    descriptionController.text = description.value;
    contactController.text = contactDetails.value;
    addressController.text = address.value;
    emailController.text = email.value;
    availability.value = data.availability;

    debugPrint('✅ Data mapping complete');
  }


  void cancelEdit() {
    debugPrint('🚫 Resetting fields');
    nameController.text = businessName.value;
    locationController.text = location.value;
    descriptionController.text = description.value;
    contactController.text = contactDetails.value;
    addressController.text = address.value;
    emailController.text = email.value; // Reset email field too
    isEditing.value = false;
  }

  void forceRefresh() => fetchBusinessProfile();

  String getFullImageUrl() {
    if (businessImage.value.isEmpty) return '';
    if (businessImage.value.startsWith('http')) return businessImage.value;
    return '${AppUrl.baseUrl}${businessImage.value}';
  }

  void showImagePickerDialog() {
    debugPrint('📸 Image picker clicked');
  }
}