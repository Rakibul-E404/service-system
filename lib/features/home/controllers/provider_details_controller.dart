// import 'package:get/get.dart';
//
// class ProviderDetailsController extends GetxController {
//
// }


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/network/network_response.dart';
import '../../../core/utils/api/app_url.dart';
import '../../../core/utils/token_service/token_storage_service.dart';
import '../../../provider_model.dart';

class ProviderDetailsController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();
  final SharedPrefService _sharedPrefService = SharedPrefService();

  // Provider data
  final Rx<ProviderModel?> providerData = Rx<ProviderModel?>(null);
  final RxBool isLoadingProvider = false.obs;
  final RxString providerErrorMessage = ''.obs;

  String? authId;

  @override
  void onInit() {
    super.onInit();
    _initializeWithArguments();
  }

  void _initializeWithArguments() {
    final dynamic args = Get.arguments;

    debugPrint('🔍 ProviderDetailsController - Received arguments type: ${args.runtimeType}');
    debugPrint('🔍 ProviderDetailsController - Arguments value: $args');

    if (args != null && args is Map<String, dynamic>) {
      // Check if provider data is already provided
      if (args.containsKey('provider') && args['provider'] != null) {
        final providerJson = args['provider'];
        if (providerJson is Map<String, dynamic>) {
          debugPrint('✅ Provider data found in arguments - Using directly');
          _parseProviderData(providerJson);

          // Extract authId for potential refresh
          authId = args['authId']?.toString() ??
              providerJson['_id']?.toString() ??
              providerJson['id']?.toString();

          debugPrint('✅ Provider loaded from arguments: ${providerData.value?.name}');
          return; // Don't make API call if we have the data
        }
      }

      // If no provider data in arguments, get authId and fetch from API
      authId = args['authId']?.toString() ??
          args['authorId']?.toString() ??
          args['_id']?.toString();

      debugPrint('🔍 Extracted authId: $authId');

      if (authId != null && authId!.isNotEmpty) {
        debugPrint('✅ Found authId: $authId - Calling fetchProviderDetails');
        fetchProviderDetails(authId!);
      } else {
        debugPrint('⚠️ No authId found in arguments');
        providerErrorMessage.value = 'No provider information available';
      }
    } else {
      debugPrint('⚠️ Arguments are null or not a Map');
      providerErrorMessage.value = 'Invalid navigation data';
    }
  }

  /// Fetch provider/business profile details
  Future<void> fetchProviderDetails(String authId) async {
    debugPrint('🎯 ========== FETCH PROVIDER DETAILS STARTED ==========');
    debugPrint('📥 authId: $authId');

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

      final String url = AppUrl.getBusinessProfileUrl(authId);
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
          _handleRestrictedAccess(authId);
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

  /// Handle restricted access (403) - Create a limited provider object
  void _handleRestrictedAccess(String authId) {
    debugPrint('🛡️ Creating limited provider data for restricted access');

    final limitedProvider = ProviderModel(
      id: authId,
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

    debugPrint('✅ Limited provider data created for ID: $authId');
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
    } else if (response.statusCode == 400) {
      // Handle validation errors from backend
      providerErrorMessage.value = 'Invalid provider data on server. Please contact support.';
      debugPrint('⚠️ Server validation error (400) - Provider data has issues');
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

  /// Parse and set provider data
  void _parseProviderData(Map<String, dynamic> providerDataField) {
    debugPrint('🎨 Parsing provider data...');
    debugPrint('   - _id: ${providerDataField['_id']}');
    debugPrint('   - name: "${providerDataField['name']}"');
    debugPrint('   - phone: ${providerDataField['phone']}');
    debugPrint('   - location: ${providerDataField['location']}');
    debugPrint('   - rating: ${providerDataField['rating']}');
    debugPrint('   - ratingCount: ${providerDataField['ratingCount']}');

    final ProviderModel provider = ProviderModel.fromJson(providerDataField);
    providerData.value = provider;

    debugPrint('✅ Successfully loaded provider:');
    debugPrint('   - ID: ${provider.id}');
    debugPrint('   - Name: "${provider.name}"');
    debugPrint('   - Location: ${provider.location}');
    debugPrint('   - Rating: ${provider.rating}');
    debugPrint('   - Full Image URL: ${provider.fullImageUrl}');
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
  void retryFetchProvider() {
    if (authId != null && authId!.isNotEmpty) {
      debugPrint('🔄 Retrying fetch for authId: $authId');
      fetchProviderDetails(authId!);
    }
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