import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/service/socket_service.dart';
import '../../../core/utils/token_service/token_storage_service.dart';

class ProviderController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();
  final SharedPrefService _sharedPrefService = SharedPrefService();
  final ImagePicker _imagePicker = ImagePicker();

  // Observable variables
  RxBool isLoading = false.obs;
  RxBool isAvailable = false.obs;
  Rx<BusinessProfile?> businessProfile = Rx<BusinessProfile?>(null);

  // Ad creation screen state
  RxBool showAdCreationScreen = false.obs;
  RxBool isCreatingAd = false.obs;

  // Advertisement related observables
  RxInt activeAdsCount = 0.obs;
  RxList<Map<String, dynamic>> activeAds = <Map<String, dynamic>>[].obs;
  RxBool isLoadingAds = false.obs;

  // Ad creation form controllers
  final TextEditingController adTitleController = TextEditingController();
  final TextEditingController adDescController = TextEditingController();
  Rx<XFile?> selectedAdImage = Rx<XFile?>(null);
  Rx<XFile?> selectedAdVideo = Rx<XFile?>(null);

  @override
  void onInit() {
    super.onInit();
    SocketServices().init();
    fetchBusinessProfile();
    fetchAds();
  }

  @override
  void onClose() {
    adTitleController.dispose();
    adDescController.dispose();
    super.onClose();
  }

  // Fetch business profile data
  Future<void> fetchBusinessProfile() async {
    try {
      isLoading.value = true;

      final providerAccessToken = await _sharedPrefService.getAccessToken();
      final response = await _networkCaller.getRequest(
        'https://d7001.sobhoy.com/api/v1/business_profile',
        headers: {'Authorization': 'Bearer $providerAccessToken'},
      );

      if (response.isSuccess && response.jsonResponse != null) {
        businessProfile.value = BusinessProfile.fromJson(response.jsonResponse!['data']);
        isAvailable.value = businessProfile.value?.isAvailable ?? false;
      } else {
        throw Exception(response.errorMessage ?? 'Failed to fetch business profile');
      }
    } catch (e) {
      debugPrint('❌ Error fetching business profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch advertisements from API
  Future<void> fetchAds() async {
    try {
      isLoadingAds.value = true;

      final providerAccessToken = await _sharedPrefService.getAccessToken();
      final response = await _networkCaller.getRequest(
        'https://d7001.sobhoy.com/api/v1/adds/self',
        headers: {'Authorization': 'Bearer $providerAccessToken'},
      );

      debugPrint('🔍 API Response: ${response.jsonResponse}');
      debugPrint('🔍 API Success: ${response.isSuccess}');

      if (response.isSuccess && response.jsonResponse != null) {
        final Map<String, dynamic> responseData = response.jsonResponse!;

        if (responseData['success'] == true) {
          final Map<String, dynamic> data = responseData['data'];
          final List<dynamic> adsList = data['data'] ?? [];

          debugPrint('🔍 Found ${adsList.length} ads in API response');

          // Convert API data to our format
          activeAds.value = adsList.map<Map<String, dynamic>>((ad) {
            return {
              'id': ad['_id'] ?? '',
              'title': ad['title'] ?? 'No Title',
              'description': ad['description'] ?? 'No Description',
              'image': ad['image'] != null ? 'https://d7001.sobhoy.com/${ad['image']}' : null,
              'type': _determineAdType(ad['title'] ?? ''),
              'isActive': true,
              'createdAt': ad['createdAt'] ?? '',
              'hasImage': ad['image'] != null,
              'hasVideo': false,
            };
          }).toList();

          activeAdsCount.value = activeAds.length;

          debugPrint('✅ Successfully loaded ${activeAds.length} advertisements');
          debugPrint('📊 Ads data: $activeAds');
        } else {
          debugPrint('❌ API returned success: false');
          // Initialize with empty list if no ads
          activeAds.value = [];
          activeAdsCount.value = 0;
        }
      } else {
        debugPrint('❌ API call failed: ${response.errorMessage}');
        // Initialize with empty list on failure
        activeAds.value = [];
        activeAdsCount.value = 0;
      }
    } catch (e) {
      debugPrint('❌ Error fetching advertisements: $e');
      // Initialize with empty list on error
      activeAds.value = [];
      activeAdsCount.value = 0;
    } finally {
      isLoadingAds.value = false;
    }
  }

  // Update availability status
  Future<void> updateAvailability(bool value) async {
    try {
      isLoading.value = true;

      final Map<String, dynamic> body = {
        'isAvailable': value,
      };

      final response = await _networkCaller.putRequest(
        'https://d7001.sobhoy.com/api/v1/business_profile/availability',
        body: body,
        headers: {
          'Authorization': 'Bearer ${await _sharedPrefService.getAccessToken()}',
        },
      );

      if (response.isSuccess) {
        isAvailable.value = value;
        Get.snackbar('Success', 'Availability updated successfully');
      } else {
        throw Exception(response.errorMessage ?? 'Failed to update availability');
      }
    } catch (e) {
      debugPrint('❌ Error updating availability: $e');
      Get.snackbar('Error', 'Failed to update availability');
    } finally {
      isLoading.value = false;
    }
  }

  // Ad creation methods
  Future<void> pickAdImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (image != null) {
        selectedAdImage.value = image;
        selectedAdVideo.value = null;
      }
    } catch (e) {
      debugPrint('❌ Error picking image: $e');
      Get.snackbar(
        'Error',
        'Failed to pick image',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> pickAdVideo() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
      );
      if (video != null) {
        selectedAdVideo.value = video;
        selectedAdImage.value = null;
      }
    } catch (e) {
      debugPrint('❌ Error picking video: $e');
      Get.snackbar(
        'Error',
        'Failed to pick video',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void clearSelectedAdMedia() {
    selectedAdImage.value = null;
    selectedAdVideo.value = null;
  }

  void resetAdForm() {
    adTitleController.clear();
    adDescController.clear();
    clearSelectedAdMedia();
  }

  void closeAdCreationScreen() {
    showAdCreationScreen.value = false;
    resetAdForm();
    isCreatingAd.value = false;
  }

  // Create new advertisement - Complete version with file support
  Future<void> createNewAd(Map<String, dynamic> adData) async {
    try {
      isCreatingAd.value = true;

      final providerAccessToken = await _sharedPrefService.getAccessToken();

      // Check if we have files to upload
      final bool hasFiles = adData['imagePath'] != null || adData['videoPath'] != null;

      if (hasFiles) {
        // Use multipart request for files
        await _createAdWithFiles(adData, providerAccessToken!);
      } else {
        // Use existing POST request for text-only
        await _createTextOnlyAd(adData, providerAccessToken!);
      }

    } catch (e) {
      debugPrint('❌ Error creating ad: $e');
      Get.snackbar(
        'Error',
        'Failed to create advertisement: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isCreatingAd.value = false;
    }
  }

  // Create text-only advertisement using existing POST request
  Future<void> _createTextOnlyAd(Map<String, dynamic> adData, String token) async {
    final Map<String, dynamic> body = {
      'title': adData['title'],
      'description': adData['description'],
    };

    final response = await _networkCaller.postRequest(
      'https://d7001.sobhoy.com/api/v1/adds/create',
      body: body,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.isSuccess && response.jsonResponse != null) {
      final responseData = response.jsonResponse!;

      if (responseData['success'] == true) {
        _handleSuccessfulAdCreation(responseData['data']);
      } else {
        throw Exception(responseData['message'] ?? 'Failed to create advertisement');
      }
    } else {
      throw Exception(response.errorMessage ?? 'Failed to create advertisement');
    }
  }

  // Multipart file upload with MIME type support
  Future<void> _createAdWithFiles(Map<String, dynamic> adData, String token) async {
    try {
      final request = http.MultipartRequest(
          'POST',
          Uri.parse('https://d7001.sobhoy.com/api/v1/adds/create')
      );

      request.headers['Authorization'] = 'Bearer $token';

      // Add text fields
      request.fields['title'] = adData['title'];
      request.fields['description'] = adData['description'];

      // Add image file with MIME type
      if (adData['imagePath'] != null) {
        await _addFileToRequest(request, adData['imagePath']!, 'image');
      }

      // Add video file with MIME type
      if (adData['videoPath'] != null) {
        await _addFileToRequest(request, adData['videoPath']!, 'video');
      }

      debugPrint('🚀 Sending multipart request with files...');
      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      debugPrint('✅ Multipart Response Status: ${response.statusCode}');
      debugPrint('📄 Multipart Response Body: ${responseData.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(responseData.body);
        if (jsonResponse['success'] == true) {
          _handleSuccessfulAdCreation(jsonResponse['data']);
        } else {
          throw Exception(jsonResponse['message'] ?? 'Failed to create advertisement');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: Failed to upload ad');
      }
    } catch (e) {
      debugPrint('❌ Multipart upload error: $e');
      rethrow;
    }
  }

  // Helper method to add files to multipart request with proper MIME types
  Future<void> _addFileToRequest(http.MultipartRequest request, String filePath, String fieldName) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found: $filePath');
      }

      final fileStream = http.ByteStream(file.openRead());
      final fileLength = await file.length();

      // Get MIME type and file info
      final fileInfo = _getFileInfo(filePath);
      final contentType = MediaType.parse(fileInfo['mimeType']!);

      final multipartFile = http.MultipartFile(
        fieldName,
        fileStream,
        fileLength,
        filename: '${fieldName}_${DateTime.now().millisecondsSinceEpoch}.${fileInfo['extension']}',
        contentType: contentType,
      );

      request.files.add(multipartFile);
      debugPrint('📤 Added $fieldName: ${fileInfo['fileName']} (${fileInfo['mimeType']})');
    } catch (e) {
      debugPrint('❌ Error adding file $filePath: $e');
      rethrow;
    }
  }

  // Helper method to get proper MIME type and file extension
  Map<String, String> _getFileInfo(String filePath) {
    final mimeType = lookupMimeType(filePath) ?? 'application/octet-stream';
    final fileName = filePath.split('/').last;

    // Common MIME type mappings
    final mimeMap = {
      'image/jpeg': 'jpg',
      'image/jpg': 'jpg',
      'image/png': 'png',
      'image/gif': 'gif',
      'image/webp': 'webp',
      'image/bmp': 'bmp',
      'video/mp4': 'mp4',
      'video/avi': 'avi',
      'video/mov': 'mov',
      'video/wmv': 'wmv',
      'video/mkv': 'mkv',
      'video/webm': 'webm',
    };

    final fileExtension = mimeMap[mimeType] ?? filePath.split('.').last;

    return {
      'mimeType': mimeType,
      'fileName': fileName,
      'extension': fileExtension,
    };
  }

  void _handleSuccessfulAdCreation(Map<String, dynamic> createdAd) {
    // Add the new ad to local list
    final newAd = {
      'id': createdAd['_id'] ?? '',
      'title': createdAd['title'] ?? '',
      'description': createdAd['description'] ?? '',
      'image': createdAd['image'] != null
          ? 'https://d7001.sobhoy.com/${createdAd['image']}'
          : null,
      'video': createdAd['video'] != null
          ? 'https://d7001.sobhoy.com/${createdAd['video']}'
          : null,
      'type': _determineAdType(createdAd['title'] ?? ''),
      'isActive': true,
      'createdAt': createdAd['createdAt'] ?? '',
      'hasImage': createdAd['image'] != null,
      'hasVideo': createdAd['video'] != null,
    };

    activeAds.insert(0, newAd);
    activeAdsCount.value = activeAds.length;
    activeAds.refresh();

    // Reset form and close screen
    resetAdForm();
    showAdCreationScreen.value = false;

    Get.snackbar(
      'Success',
      'Advertisement created successfully!',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  String _determineAdType(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('offer') || lowerTitle.contains('discount') || lowerTitle.contains('special')) {
      return 'offer';
    } else if (lowerTitle.contains('event') || lowerTitle.contains('workshop') || lowerTitle.contains('seminar')) {
      return 'event';
    } else {
      return 'service';
    }
  }

  // Toggle ad status
  void toggleAdStatus(String adId) {
    final adIndex = activeAds.indexWhere((ad) => ad['id'] == adId);
    if (adIndex != -1) {
      activeAds[adIndex]['isActive'] = !(activeAds[adIndex]['isActive'] ?? false);
      activeAds.refresh();
      activeAdsCount.value = activeAds.where((ad) => ad['isActive'] == true).length;

      if (activeAds[adIndex]['isActive']) {
        Get.snackbar('Success', 'Advertisement resumed');
      } else {
        Get.snackbar('Success', 'Advertisement paused');
      }
    }
  }

  // Delete advertisement
  Future<void> deleteAd(String adId) async {
    try {
      final adIndex = activeAds.indexWhere((ad) => ad['id'] == adId);
      if (adIndex != -1) {
        activeAds.removeAt(adIndex);
        activeAdsCount.value = activeAds.where((ad) => ad['isActive'] == true).length;
        activeAds.refresh();

        Get.snackbar(
          'Success',
          'Advertisement deleted successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('❌ Error deleting ad: $e');
      Get.snackbar(
        'Error',
        'Failed to delete advertisement',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Get total clicks for UI
  int get totalAdClicks {
    return activeAds.fold(0, (int sum, ad) => sum + (ad['clicks'] as int));
  }

  // Get ad by ID
  Map<String, dynamic>? getAdById(String adId) {
    try {
      return activeAds.firstWhere((Map<String, dynamic> ad) => ad['id'] == adId);
    } catch (e) {
      return null;
    }
  }

  // Validate ad creation form
  bool validateAdForm() {
    if (adTitleController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter an advertisement title',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (adDescController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter an advertisement description',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  // Prepare ad data for creation
  Map<String, dynamic> prepareAdData() {
    return {
      'title': adTitleController.text.trim(),
      'description': adDescController.text.trim(),
      'imagePath': selectedAdImage.value?.path,
      'videoPath': selectedAdVideo.value?.path,
      'createdAt': DateTime.now(),
    };
  }

  // Refresh both profile and ads
  Future<void> refreshData() async {
    await Future.wait([
      fetchBusinessProfile(),
      fetchAds(),
    ]);
  }
}

class BusinessProfile {
  final String id;
  final String name;
  final String phone;
  final String description;
  final String location;
  final String image;
  final bool isAvailable;
  final bool isProfileComplete;
  final String createdAt;
  final int rating;
  final int ratingCount;

  BusinessProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.description,
    required this.location,
    required this.image,
    required this.isAvailable,
    required this.isProfileComplete,
    required this.createdAt,
    required this.rating,
    required this.ratingCount,
  });

  factory BusinessProfile.fromJson(Map<String, dynamic> json) {
    return BusinessProfile(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      image: json['image'] ?? '',
      isAvailable: json['isAvailable'] ?? false,
      isProfileComplete: json['isProfileComplete'] ?? false,
      createdAt: json['createdAt'] ?? '',
      rating: json['rating'] ?? 0,
      ratingCount: json['ratingCount'] ?? 0,
    );
  }
}