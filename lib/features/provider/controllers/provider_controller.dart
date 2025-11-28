

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
  RxBool hasActiveSubscription = false.obs;
  Rx<SubscriptionInfo?> subscriptionInfo = Rx<SubscriptionInfo?>(null);

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
    initializeProviderData();
  }

  @override
  void onClose() {
    adTitleController.dispose();
    adDescController.dispose();
    super.onClose();
  }

  // Initialize all provider data
  Future<void> initializeProviderData() async {
    try {
      isLoading.value = true;
      await Future.wait([
        fetchBusinessProfile(),
        checkSubscriptionStatus(),
        fetchAds(),
      ]);
    } catch (e) {
      debugPrint('❌ Error initializing provider data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch business profile data
  Future<void> fetchBusinessProfile() async {
    try {
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
      rethrow;
    }
  }

  // Check subscription status
  Future<void> checkSubscriptionStatus() async {
    try {
      final providerAccessToken = await _sharedPrefService.getAccessToken();
      final response = await _networkCaller.getRequest(
        'https://d7001.sobhoy.com/api/v1/subscription/status',
        headers: {'Authorization': 'Bearer $providerAccessToken'},
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final responseData = response.jsonResponse!;
        if (responseData['success'] == true) {
          hasActiveSubscription.value = responseData['data']['isActive'] ?? false;
          if (responseData['data'] != null) {
            subscriptionInfo.value = SubscriptionInfo.fromJson(responseData['data']);
          }
        } else {
          hasActiveSubscription.value = false;
          subscriptionInfo.value = null;
        }
      } else {
        hasActiveSubscription.value = false;
        subscriptionInfo.value = null;
      }
    } catch (e) {
      debugPrint('❌ Error checking subscription status: $e');
      hasActiveSubscription.value = false;
      subscriptionInfo.value = null;
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
              'video': ad['video'] != null ? 'https://d7001.sobhoy.com/${ad['video']}' : null,
              'type': _determineAdType(ad['title'] ?? ''),
              'isActive': ad['isActive'] ?? true,
              'createdAt': ad['createdAt'] ?? '',
              'clicks': ad['clicks'] ?? 0,
              'views': ad['views'] ?? 0,
              'hasImage': ad['image'] != null,
              'hasVideo': ad['video'] != null,
            };
          }).toList();

          activeAdsCount.value = activeAds.length;

          debugPrint('✅ Successfully loaded ${activeAds.length} advertisements');
        } else {
          debugPrint('❌ API returned success: false');
          activeAds.value = [];
          activeAdsCount.value = 0;
        }
      } else {
        debugPrint('❌ API call failed: ${response.errorMessage}');
        activeAds.value = [];
        activeAdsCount.value = 0;
      }
    } catch (e) {
      debugPrint('❌ Error fetching advertisements: $e');
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
        Get.snackbar(
          'Success',
          'Availability updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw Exception(response.errorMessage ?? 'Failed to update availability');
      }
    } catch (e) {
      debugPrint('❌ Error updating availability: $e');
      Get.snackbar(
        'Error',
        'Failed to update availability',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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

        Get.snackbar(
          'Success',
          'Image selected',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
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

        Get.snackbar(
          'Success',
          'Video selected',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
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

  // Main ad creation method with subscription check
  Future<void> createNewAd(Map<String, dynamic> adData) async {
    try {
      // Check subscription first
      if (!hasActiveSubscription.value) {
        Get.snackbar(
          'Subscription Required',
          'You need an active subscription to create advertisements.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
        return;
      }

      isCreatingAd.value = true;

      final providerAccessToken = await _sharedPrefService.getAccessToken();

      // Check if we have files to upload
      final bool hasFiles = adData['imagePath'] != null || adData['videoPath'] != null;

      if (hasFiles) {
        await _createAdWithFiles(adData, providerAccessToken!);
      } else {
        await _createTextOnlyAd(adData, providerAccessToken!);
      }

    } catch (e) {
      debugPrint('❌ Error creating ad: $e');

      String errorMessage = _extractErrorMessage(e);

      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isCreatingAd.value = false;
    }
  }

  // Helper method to extract error message from various exception types
  String _extractErrorMessage(dynamic error) {
    try {
      if (error is String) {
        // Try to parse the string as JSON
        try {
          final errorJson = json.decode(error);
          if (errorJson is Map<String, dynamic>) {
            return errorJson['message'] ?? 'Failed to create advertisement';
          }
        } catch (e) {
          // If it's not JSON, return the original string
          return error;
        }
      } else if (error is http.Response) {
        // Handle http.Response errors
        try {
          final responseBody = json.decode(error.body);
          return responseBody['message'] ?? 'Failed to create advertisement';
        } catch (e) {
          return 'HTTP ${error.statusCode}: Failed to create advertisement';
        }
      } else if (error is Exception) {
        final errorString = error.toString();

        // Check if the exception contains JSON
        if (errorString.contains('{') && errorString.contains('}')) {
          try {
            final startIndex = errorString.indexOf('{');
            final endIndex = errorString.lastIndexOf('}') + 1;
            final jsonString = errorString.substring(startIndex, endIndex);
            final errorJson = json.decode(jsonString);
            return errorJson['message'] ?? 'Failed to create advertisement';
          } catch (e) {
            // If JSON parsing fails, return the original message
            return errorString;
          }
        }

        return errorString;
      }
    } catch (e) {
      debugPrint('❌ Error extracting error message: $e');
    }

    return 'Failed to create advertisement';
  }

  // Create text-only advertisement
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
        final errorMessage = responseData['message'] ?? 'Failed to create advertisement';
        throw Exception(errorMessage);
      }
    } else {
      final errorMessage = response.errorMessage ?? 'Failed to create advertisement';
      throw Exception(errorMessage);
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
          final errorMessage = jsonResponse['message'] ?? 'Failed to create advertisement';
          throw Exception(errorMessage);
        }
      } else {
        final jsonResponse = json.decode(responseData.body);
        final errorMessage = jsonResponse['message'] ?? 'HTTP ${response.statusCode}: Failed to upload ad';
        throw http.Response(responseData.body, response.statusCode);
      }
    } catch (e) {
      debugPrint('❌ Multipart upload error: $e');
      rethrow;
    }
  }

  // Helper method to add files to multipart request
  Future<void> _addFileToRequest(http.MultipartRequest request, String filePath, String fieldName) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found: $filePath');
      }

      final fileStream = http.ByteStream(file.openRead());
      final fileLength = await file.length();

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
      throw Exception('Failed to process $fieldName file: ${e.toString()}');
    }
  }

  // Helper method to get proper MIME type and file extension
  Map<String, String> _getFileInfo(String filePath) {
    final mimeType = lookupMimeType(filePath) ?? 'application/octet-stream';
    final fileName = filePath.split('/').last;

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
      'isActive': createdAd['isActive'] ?? true,
      'createdAt': createdAd['createdAt'] ?? '',
      'clicks': createdAd['clicks'] ?? 0,
      'views': createdAd['views'] ?? 0,
      'hasImage': createdAd['image'] != null,
      'hasVideo': createdAd['video'] != null,
    };

    activeAds.insert(0, newAd);
    activeAdsCount.value = activeAds.length;
    activeAds.refresh();

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
  Future<void> toggleAdStatus(String adId) async {
    try {
      final adIndex = activeAds.indexWhere((ad) => ad['id'] == adId);
      if (adIndex != -1) {
        final newStatus = !(activeAds[adIndex]['isActive'] ?? false);

        final providerAccessToken = await _sharedPrefService.getAccessToken();
        final response = await _networkCaller.putRequest(
          'https://d7001.sobhoy.com/api/v1/adds/$adId/status',
          body: {'isActive': newStatus},
          headers: {'Authorization': 'Bearer $providerAccessToken'},
        );

        if (response.isSuccess) {
          activeAds[adIndex]['isActive'] = newStatus;
          activeAds.refresh();
          activeAdsCount.value = activeAds.where((ad) => ad['isActive'] == true).length;

          Get.snackbar(
            'Success',
            newStatus ? 'Advertisement resumed' : 'Advertisement paused',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          throw Exception(response.errorMessage ?? 'Failed to update ad status');
        }
      }
    } catch (e) {
      debugPrint('❌ Error toggling ad status: $e');
      Get.snackbar(
        'Error',
        'Failed to update advertisement status',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Delete advertisement
  Future<void> deleteAd(String adId) async {
    try {
      final providerAccessToken = await _sharedPrefService.getAccessToken();
      final response = await _networkCaller.deleteRequest(
        'https://d7001.sobhoy.com/api/v1/adds/$adId',
        headers: {'Authorization': 'Bearer $providerAccessToken'},
      );

      if (response.isSuccess) {
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
      } else {
        throw Exception(response.errorMessage ?? 'Failed to delete advertisement');
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

  // Get total views for UI
  int get totalAdViews {
    return activeAds.fold(0, (int sum, ad) => sum + (ad['views'] as int));
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

    if (selectedAdImage.value == null && selectedAdVideo.value == null) {
      Get.snackbar(
        'Error',
        'Please select an image or video for your advertisement',
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

  // Refresh all data
  Future<void> refreshData() async {
    try {
      isLoading.value = true;
      await Future.wait([
        fetchBusinessProfile(),
        checkSubscriptionStatus(),
        fetchAds(),
      ]);
    } catch (e) {
      debugPrint('❌ Error refreshing data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Navigate to subscription page
  void navigateToSubscription() {
    // Implement navigation to subscription page
    Get.snackbar(
      'Subscription Required',
      'Redirecting to subscription page...',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
    // Get.to(() => SubscriptionPage());
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

class SubscriptionInfo {
  final String id;
  final String planName;
  final double price;
  final String billingCycle;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final List<String> features;

  SubscriptionInfo({
    required this.id,
    required this.planName,
    required this.price,
    required this.billingCycle,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.features,
  });

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) {
    return SubscriptionInfo(
      id: json['_id'] ?? '',
      planName: json['planName'] ?? 'Free Plan',
      price: (json['price'] ?? 0).toDouble(),
      billingCycle: json['billingCycle'] ?? 'monthly',
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toString()),
      endDate: DateTime.parse(json['endDate'] ?? DateTime.now().add(Duration(days: 30)).toString()),
      isActive: json['isActive'] ?? false,
      features: List<String>.from(json['features'] ?? []),
    );
  }
}
