import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../core/network/network_caller.dart';
import '../../../core/network/network_response.dart';
import '../../../core/utils/api/app_url.dart';
import '../../../core/utils/token_service/token_storage_service.dart';
import '../../../provider_model.dart';

class HomeServiceDetailsController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();
  final SharedPrefService _sharedPrefService = SharedPrefService();

  Rx<DateTime> dateTimePick = DateTime.now().obs;

  // Provider data
  final Rx<ProviderModel?> providerData = Rx<ProviderModel?>(null);
  final RxBool isLoadingProvider = false.obs;
  final RxString providerErrorMessage = ''.obs;

  // Favorite functionality properties
  final RxBool isFavorite = false.obs;
  final RxBool isLoadingFavorite = false.obs;
  String? serviceId;

  @override
  void onInit() {
    super.onInit();
    _initializeWithArguments();
  }

  // void _initializeWithArguments() {
  //   final dynamic args = Get.arguments;
  //
  //   debugPrint('🔍 HomeServiceDetailsController - Received arguments type: ${args.runtimeType}');
  //   debugPrint('🔍 HomeServiceDetailsController - Arguments value: $args');
  //
  //   if (args != null && args is Map<String, dynamic>) {
  //     // Retrieve serviceId for favorite functionality
  //     serviceId = args['serviceId']?.toString();
  //
  //     // Get authorId from either 'author' map or direct 'authorId' field
  //     final dynamic authorData = args['author'];
  //     final String? authorId = authorData is Map<String, dynamic>
  //         ? authorData['_id']?.toString()
  //         : args['authorId']?.toString();
  //
  //     debugPrint('🔍 Extracted authorId: $authorId');
  //     debugPrint('🔍 authorData type: ${authorData.runtimeType}');
  //     debugPrint('🔍 authorData value: $authorData');
  //
  //     if (authorId != null && authorId.isNotEmpty) {
  //       debugPrint('✅ Found authorId: $authorId - Calling fetchProviderDetails');
  //       fetchProviderDetails(authorId);
  //
  //       // Also check initial favorite status if serviceId exists
  //       if (serviceId != null && serviceId!.isNotEmpty) {
  //         checkFavoriteStatus(serviceId!);
  //       }
  //     } else {
  //       debugPrint('⚠️ No authorId found in arguments');
  //       providerErrorMessage.value = 'No provider information available';
  //     }
  //   } else {
  //     debugPrint('⚠️ Arguments are null or not a Map');
  //     providerErrorMessage.value = 'Invalid navigation data';
  //   }
  // }



  void _initializeWithArguments() {
    final dynamic args = Get.arguments;

    debugPrint('🔍 HomeServiceDetailsController - Received arguments type: ${args.runtimeType}');
    debugPrint('🔍 HomeServiceDetailsController - Arguments value: $args');

    if (args != null && args is Map<String, dynamic>) {
      // Retrieve serviceId for favorite functionality
      serviceId = args['serviceId']?.toString() ?? args['_id']?.toString();

      // Get authorId from either 'author' map or direct 'authorId' field
      final dynamic authorData = args['author'];
      final String? authorId = authorData is Map<String, dynamic>
          ? authorData['_id']?.toString()
          : args['authorId']?.toString();

      debugPrint('🔍 Extracted authorId: $authorId');
      debugPrint('🔍 Extracted serviceId: $serviceId');
      debugPrint('🔍 authorData type: ${authorData.runtimeType}');
      debugPrint('🔍 authorData value: $authorData');

      if (authorId != null && authorId.isNotEmpty) {
        debugPrint('✅ Found authorId: $authorId - Calling fetchProviderDetails');
        fetchProviderDetails(authorId);

        // REMOVE THIS LINE - favorite status will be checked from the page
        // if (serviceId != null && serviceId!.isNotEmpty) {
        //   checkFavoriteStatus(serviceId!);
        // }
      } else {
        debugPrint('⚠️ No authorId found in arguments');
        providerErrorMessage.value = 'No provider information available';
      }
    } else {
      debugPrint('⚠️ Arguments are null or not a Map');
      providerErrorMessage.value = 'Invalid navigation data';
    }
  }


  /// Fetch provider/business profile details
  Future<void> fetchProviderDetails(String authorId) async {
    debugPrint('🎯 ========== FETCH PROVIDER DETAILS STARTED ==========');
    debugPrint('📥 authorId: $authorId');

    isLoadingProvider.value = true;
    providerErrorMessage.value = '';
    providerData.value = null;

    try {
      // Check if user is logged in first
      final bool isLoggedIn = await _sharedPrefService.isLoggedIn();
      debugPrint('🔐 User Login Status: $isLoggedIn');

      if (!isLoggedIn) {
        providerErrorMessage.value = 'Please login to view provider details';
        debugPrint('❌ User not logged in');
        isLoadingProvider.value = false;
        return;
      }

      // Get access token
      final String? accessToken = await _sharedPrefService.getAccessToken();
      debugPrint('🔑 Access Token: ${accessToken != null ? 'Available (${accessToken.length} chars)' : 'NULL'}');

      if (accessToken == null || accessToken.isEmpty) {
        providerErrorMessage.value = 'Authentication required. Please login again.';
        debugPrint('❌ No access token available');
        isLoadingProvider.value = false;
        return;
      }

      final String url = AppUrl.getBusinessProfileUrl(authorId);
      debugPrint('🌐 API URL: $url');

      final NetworkResponse response = await _networkCaller.getRequest(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('📡 API Response:');
      debugPrint('   - isSuccess: ${response.isSuccess}');
      debugPrint('   - statusCode: ${response.statusCode}');
      debugPrint('   - Full Response: ${response.jsonResponse}');

      if (response.isSuccess && response.jsonResponse != null) {
        _handleSuccessResponse(response.jsonResponse!);
      } else {
        // Special handling for 403 - show limited provider info
        if (response.statusCode == 403) {
          debugPrint('🚫 403 Forbidden - Provider details are restricted');
          _handleRestrictedAccess(authorId);
        } else {
          _handleErrorResponse(response);
        }
      }
    } catch (e, stackTrace) {
      _handleException(e, stackTrace);
    } finally {
      isLoadingProvider.value = false;
      debugPrint('🏁 ========== FETCH PROVIDER COMPLETED ==========');
      debugPrint('   - isLoadingProvider: ${isLoadingProvider.value}');
      debugPrint('   - providerData name: ${providerData.value?.name ?? 'NULL'}');
      debugPrint('   - errorMessage: "${providerErrorMessage.value}"');
      debugPrint('==========================================\n');
    }
  }

  /// Check if service is already favorited
  Future<void> checkFavoriteStatus(String serviceId) async {
    if (serviceId.isEmpty) return;

    try {
      debugPrint('🔍 Checking favorite status for: $serviceId');

      // Check if user is logged in first
      final bool isLoggedIn = await _sharedPrefService.isLoggedIn();
      if (!isLoggedIn) {
        debugPrint('   - User not logged in, skipping favorite status check');
        isFavorite.value = false;
        return;
      }

      final String url = '${AppUrl.baseUrl}/favorite/$serviceId/status';
      final String? accessToken = await _sharedPrefService.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        debugPrint('   - No access token, skipping favorite status check');
        isFavorite.value = false;
        return;
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      ).timeout(const Duration(seconds: 10));

      debugPrint('   - Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        bool isFav = false;
        if (responseData['data'] != null && responseData['data'] is Map) {
          isFav = responseData['data']['isFavorite'] ?? false;
        } else if (responseData['isFavorite'] != null) {
          isFav = responseData['isFavorite'];
        } else {
          isFav = responseData['success'] == true;
        }

        isFavorite.value = isFav;
        debugPrint('   - Favorite status: $isFav');
      } else if (response.statusCode == 404) {
        isFavorite.value = false;
        debugPrint('   - Service not favorited (404)');
      } else {
        debugPrint('   - Failed to check favorite status: ${response.statusCode}');
        isFavorite.value = false;
      }
    } catch (e) {
      debugPrint('   - Error checking favorite status: $e');
      isFavorite.value = false;
    }
  }

  /// Toggle favorite status for a service
  Future<void> toggleFavorite(Map<String, dynamic> serviceData) async {
    if (isLoadingFavorite.value) return;

    final String localServiceId = serviceData['_id']?.toString() ??
        serviceData['serviceId']?.toString() ??
        this.serviceId ?? '';

    debugPrint('❤️ ========== TOGGLE FAVORITE STARTED ==========');
    debugPrint('   - Service ID: $localServiceId');
    debugPrint('   - Service Data: $serviceData');

    if (localServiceId.isEmpty) {
      Get.snackbar(
        'Error',
        'Service ID not found',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final bool isLoggedIn = await _sharedPrefService.isLoggedIn();
    if (!isLoggedIn) {
      Get.snackbar(
        'Login Required',
        'Please login to add favorites',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    isLoadingFavorite.value = true;

    try {
      final String url = '${AppUrl.baseUrl}/favorite/$localServiceId';

      final String? accessToken = await _sharedPrefService.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        Get.snackbar(
          'Authentication Error',
          'Please login again',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isLoadingFavorite.value = false;
        return;
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      ).timeout(const Duration(seconds: 30));

      debugPrint('📡 API Response:');
      debugPrint('   - Status Code: ${response.statusCode}');
      debugPrint('   - Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true ||
            responseData['status'] == 'success' ||
            responseData['isFavorite'] != null) {

          isFavorite.value = !isFavorite.value;

          Get.snackbar(
            'Success',
            isFavorite.value ? 'Added to favorites' : 'Removed from favorites',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );

          debugPrint('✅ Favorite updated successfully');
          debugPrint('   - New favorite status: ${isFavorite.value}');
        } else {
          final String errorMsg = responseData['message'] ??
              responseData['error'] ??
              'Unknown error occurred';
          throw Exception(errorMsg);
        }
      } else if (response.statusCode == 401) {
        await _sharedPrefService.clearAll();
        throw Exception('Session expired. Please login again.');
      } else if (response.statusCode == 404) {
        throw Exception('Service not found.');
      } else if (response.statusCode == 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        final Map<String, dynamic>? errorData = json.decode(response.body);
        final String errorMsg = errorData?['message'] ??
            errorData?['error'] ??
            'Failed with status code: ${response.statusCode}';
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('❌ Favorite API Error: $e');

      String errorMessage = 'Failed to update favorite';
      if (e is Exception) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      }

      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoadingFavorite.value = false;
      debugPrint('🏁 Toggle favorite completed');
    }
  }

  /// Handle restricted access (403) - Create a limited provider object
  void _handleRestrictedAccess(String authorId) {
    debugPrint('🛡️ Creating limited provider data for restricted access');

    final limitedProvider = ProviderModel(
      id: authorId,
      name: 'Service Provider',
      description: 'Professional service provider. Contact for more details.',
      location: 'Location not specified',
      phone: 'Contact for phone number',
      image: '',
      rating: 0.0,
      ratingCount: 0,
      isAvailable: true,
      isProfileComplete: false,
      createdAt: DateTime.now().toString(),
    );

    providerData.value = limitedProvider;
    providerErrorMessage.value = 'Limited provider information available. Some details are restricted.';

    debugPrint('✅ Limited provider data created for ID: $authorId');
  }

  /// Handle API error response
  void _handleErrorResponse(NetworkResponse response) {
    debugPrint('❌ API request failed');
    debugPrint('   - Status: ${response.statusCode}');
    debugPrint('   - Error: ${response.errorMessage}');

    if (response.statusCode == 404) {
      providerErrorMessage.value = 'Provider not found';
    } else if (response.statusCode == 401) {
      providerErrorMessage.value = 'Authentication failed - please login again';
      _handleUnauthorized();
    } else if (response.statusCode == 500) {
      providerErrorMessage.value = 'Server error - please try again later';
    } else {
      providerErrorMessage.value = response.errorMessage ?? 'Failed to load provider details';
    }
  }

  /// Handle successful API response
  void _handleSuccessResponse(Map<String, dynamic> responseData) {
    try {
      debugPrint('🔍 Response structure:');
      debugPrint('   - success: ${responseData['success']}');
      debugPrint('   - code: ${responseData['code']}');
      debugPrint('   - message: ${responseData['message']}');
      debugPrint('   - data exists: ${responseData.containsKey('data')}');

      if (!responseData.containsKey('data')) {
        providerErrorMessage.value = 'Invalid response format: missing "data" key';
        debugPrint('❌ Missing "data" key in response');
        debugPrint('   - Available keys: ${responseData.keys.toList()}');
        return;
      }

      final dynamic providerDataField = responseData['data'];
      debugPrint('   - data type: ${providerDataField.runtimeType}');
      debugPrint('   - data content: $providerDataField');

      if (providerDataField is! Map<String, dynamic>) {
        providerErrorMessage.value = 'Invalid provider data format';
        debugPrint('❌ Provider data is not a Map, it is: ${providerDataField.runtimeType}');
        return;
      }

      _parseProviderData(providerDataField);
    } catch (parseError, stackTrace) {
      providerErrorMessage.value = 'Failed to parse provider data: ${parseError.toString()}';
      debugPrint('💥 Parse Error: $parseError');
      debugPrint('📚 StackTrace: $stackTrace');
    }
  }

  /// ---------------------------
  /// Parse and set provider data
  /// ---------------------------
  void _parseProviderData(Map<String, dynamic> providerDataField) {
    debugPrint('🎨 Parsing provider data...');
    debugPrint('   - _id: ${providerDataField['_id']}');
    debugPrint('   - name: "${providerDataField['name']}"');
    debugPrint('   - name length: ${providerDataField['name']?.toString().length}');
    debugPrint('   - phone: ${providerDataField['phone']}');
    debugPrint('   - location: ${providerDataField['location']}');
    debugPrint('   - rating: ${providerDataField['rating']}');
    debugPrint('   - ratingCount: ${providerDataField['ratingCount']}');
    debugPrint('   - description: ${providerDataField['description']}');
    debugPrint('   - image: ${providerDataField['image']}');
    debugPrint('   - isAvailable: ${providerDataField['isAvailable']}');
    debugPrint('   - isProfileComplete: ${providerDataField['isProfileComplete']}');

    final ProviderModel provider = ProviderModel.fromJson(providerDataField);
    providerData.value = provider;

    debugPrint('✅ Successfully loaded provider:');
    debugPrint('   - ID: ${provider.id}');
    debugPrint('   - Name: "${provider.name}"');
    debugPrint('   - Location: ${provider.location}');
    debugPrint('   - Rating: ${provider.rating}');
    debugPrint('   - Rating Count: ${provider.ratingCount}');
    debugPrint('   - Phone: ${provider.phone}');
    debugPrint('   - Description: ${provider.description}');
    debugPrint('   - Image: ${provider.image}');
    debugPrint('   - Full Image URL: ${provider.fullImageUrl}');
    debugPrint('   - Available: ${provider.isAvailable}');
    debugPrint('   - Profile Complete: ${provider.isProfileComplete}');
  }

  /// Handle unauthorized access (401)
  void _handleUnauthorized() {
    debugPrint('🚨 Unauthorized access - clearing tokens');
    // Optionally clear tokens or navigate to login screen
    // _sharedPrefService.clearAll();
  }

  /// Handle network exceptions
  void _handleException(dynamic e, StackTrace stackTrace) {
    providerErrorMessage.value = 'Network error: ${e.toString()}';
    debugPrint('💥 Network Exception: $e');
    debugPrint('📚 StackTrace: $stackTrace');
  }

  /// Retry fetching provider details
  void retryFetchProvider(String authorId) {
    debugPrint('🔄 Retrying fetch for authorId: $authorId');
    fetchProviderDetails(authorId);
  }

  /// Clear provider data
  void clearProviderData() {
    providerData.value = null;
    providerErrorMessage.value = '';
  }

  @override
  void onClose() {
    clearProviderData();
    super.onClose();
  }
}




