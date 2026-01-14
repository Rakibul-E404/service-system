


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/utils/token_service/token_storage_service.dart';

import '../../home/model/sub_category_model.dart';
import '../model/business_profile_response_model.dart';


import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../model/sub_category_service_response.dart';
import 'category_controller.dart';

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
  final selectedSubCategoryIds = <String>[].obs;
  final subToServiceMap = <String, String>{}.obs;

  final subscriptionAccess = <String>[].obs; // Make this observable
  final isSubscribed = false.obs;
  // --- Network Service ---
  final NetworkCaller _networkCaller = NetworkCaller();


  final processingId = ''.obs;
  final isSelfServiceLoading = false.obs;
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


  void toggleSubCategory(String id) {
    if (selectedSubCategoryIds.contains(id)) {
      selectedSubCategoryIds.remove(id);
    } else {
      selectedSubCategoryIds.add(id);
    }
  }

// Helper to show names in the main UI
  String get selectedSubCategoryNames {
    if (selectedSubCategoryIds.isEmpty) return "Select Sub-Categories";
    // Match IDs to Names from the CategoryController list
    final categoryCtrl = Get.find<CategoryController>();
    return categoryCtrl.subCategories
        .where((sub) => selectedSubCategoryIds.contains(sub.id))
        .map((sub) => sub.name)
        .join(", ");
  }

  // --- NEW: UPDATE METHOD (Multipart PUT) ---
  // Remove serviceCategory and subCategory from the parameters
  Future<void> updateBusinessProfile({
    required String name,
    required String phone,
    required String description,
    required String region,
    required String location,
    String? serviceCategoryId, // Added optional parameter
  }) async {
    try {
      isLoading.value = true;
      final token = await _getAuthToken();

      debugPrint('🌐 --- STARTING PROFILE UPDATE ---');
      var request = http.MultipartRequest('PUT', Uri.parse(AppUrl.updateBusinessProfile));

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Base fields
      Map<String, String> fields = {
        "name": name,
        "phone": phone,
        "description": description,
        "region": region.toLowerCase(),
        "location": location,
      };

      // LOGIC: Only add serviceCategory if it was passed from the UI (first-time set)
      if (serviceCategoryId != null && serviceCategoryId.isNotEmpty) {
        fields["serviceCategory"] = serviceCategoryId;
        debugPrint('📝 New Category ID included: $serviceCategoryId');
      }

      request.fields.addAll(fields);

      // Image Handling
      if (selectedImageFile.value != null) {
        String filePath = selectedImageFile.value!.path;
        String extension = filePath.split('.').last.toLowerCase();
        String subType = (extension == 'jpg' || extension == 'jpeg') ? 'jpeg' : extension;

        request.files.add(await http.MultipartFile.fromPath(
          'image',
          filePath,
          contentType: http.MediaType('image', subType),
        ));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      var jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        Get.snackbar('Success', jsonResponse['message'] ?? 'Profile updated',
            backgroundColor: Colors.green, colorText: Colors.white);

        selectedImageFile.value = null;
        await fetchBusinessProfile();
        Get.back();
      } else {
        Get.snackbar('Update Failed', jsonResponse['message'] ?? 'Error ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('🧨 CRITICAL ERROR: $e');
      Get.snackbar('Error', 'Something went wrong');
    } finally {
      isLoading.value = false;
    }
  }

// --- Updated: Flexible Image Picker ---
  Future<void> pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 80, // Optional: Compress for faster uploads
      );

      if (image != null) {
        selectedImageFile.value = File(image.path);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      Get.snackbar('Error', 'Failed to pick image');
    }
  }

  // --- Updated: Show Selection Dialog ---
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
        child: Wrap(
          children: [
            const ListTile(
              title: Text('Select Image Source',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primaryColor),
              title: const Text('Gallery'),
              onTap: () {
                Get.back(); // Close bottom sheet
                pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primaryColor),
              title: const Text('Camera'),
              onTap: () {
                Get.back(); // Close bottom sheet
                pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }


  Future<void> fetchSelfServices() async {
    try {
      isSelfServiceLoading.value = true;
      final token = await _getAuthToken();

      final response = await http.get(
        Uri.parse(AppUrl.subCategorySelfService),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        final serviceResponse = ServiceResponse.fromJson(decodedData);

        // Clear old data
        subToServiceMap.clear();
        selectedSubCategoryIds.clear();

        for (var service in serviceResponse.data) {
          String subId = service.subCategory.id;
          String serviceId = service.id; // The ID needed for DELETE

          selectedSubCategoryIds.add(subId);
          subToServiceMap[subId] = serviceId; // Store relationship
        }
        debugPrint('✅ Mapped ${subToServiceMap.length} services for deletion');
      }
    } catch (e) {
      debugPrint('🧨 Fetch Self Service Error: $e');
    } finally {
      isSelfServiceLoading.value = false;
    }
  }

  Future<void> toggleSubCategoryService(String subCategoryId) async {
    try {
      processingId.value = subCategoryId;
      final token = await _getAuthToken();

      bool isCurrentlySelected = selectedSubCategoryIds.contains(subCategoryId);

      // IF selected, use the ServiceModel ID from the map. IF NOT, use Sub-Category ID for creation.
      String targetId = isCurrentlySelected
          ? subToServiceMap[subCategoryId] ?? ''
          : subCategoryId;

      final String url = "${AppUrl.baseUrl}/service/$targetId";
      String method = isCurrentlySelected ? 'DELETE' : 'POST';

      debugPrint('🚀 $method Request to: $url');

      final response = await (isCurrentlySelected
          ? http.delete(Uri.parse(url), headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      })
          : http.post(Uri.parse(url), headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      }));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);

        if (isCurrentlySelected) {
          selectedSubCategoryIds.remove(subCategoryId);
          subToServiceMap.remove(subCategoryId);
        } else {
          selectedSubCategoryIds.add(subCategoryId);
          // After POST, the backend usually returns the new ServiceModel ID in 'data'
          // Save it so we can delete it later without refreshing
          if (json['data'] != null && json['data']['_id'] != null) {
            subToServiceMap[subCategoryId] = json['data']['_id'];
          }
        }

        Get.snackbar('Success', isCurrentlySelected ? 'Removed' : 'Added',
            snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 1));
      } else {
        Get.snackbar('Error', 'Failed to update: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('🧨 API Error: $e');
    } finally {
      processingId.value = '';
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

    isSubscribed.value = data.isSubscribed;
    subscriptionAccess.assignAll(data.subscriptionAccess);
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
    String imageUrl = businessImage.value;

    if (imageUrl.isEmpty) return "";

    // Check if the URL is already a full path (e.g., https://...)
    if (imageUrl.startsWith('http') || imageUrl.startsWith('https')) {
      return imageUrl;
    }

    // If it's a relative path, prepend the Base URL
    // Ensure there is a "/" between the base and the path
    String baseUrl = AppUrl.imageBaseUrl;
    if (!baseUrl.endsWith('/') && !imageUrl.startsWith('/')) {
      return '$baseUrl/$imageUrl';
    }

    return '$baseUrl$imageUrl';
  }


}