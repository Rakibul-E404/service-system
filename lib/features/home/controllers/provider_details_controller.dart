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
  bool _hasInitialized = false;
  bool _hasDataFromArguments = false;

  @override
  void onInit() {
    super.onInit();
    _initializeWithArguments();
  }

  void _initializeWithArguments() {
    final dynamic args = Get.arguments;

    debugPrint('🔍 ProviderDetailsController - Received arguments type: ${args.runtimeType}');
    debugPrint('🔍 ProviderDetailsController - Arguments value: $args');

    // If we already have data and this is not the first initialization, preserve it
    if (_hasInitialized && providerData.value != null) {
      debugPrint('🔄 Already initialized with data - preserving existing provider data');
      return;
    }

    if (args != null && args is Map<String, dynamic>) {
      // Extract authId from various possible keys
      authId = _extractAuthId(args);

      debugPrint('🔍 Extracted authId: $authId');

      // Check if provider data is already provided in arguments
      if (args.containsKey('provider') && args['provider'] != null) {
        final providerJson = args['provider'];
        if (providerJson is Map<String, dynamic>) {
          debugPrint('✅ Provider data found in arguments - parsing...');
          _parseProviderData(providerJson);
          _hasDataFromArguments = true;

          // Update authId from provider data if not already set
          authId ??= providerJson['_id']?.toString() ??
              providerJson['id']?.toString() ??
              providerJson['author']?.toString() ??
              providerJson['authId']?.toString();
        }
      }

      debugPrint('🔍 Final authId after processing: $authId');

      // Only fetch fresh data if we don't have good data from arguments
      if (authId != null && authId!.isNotEmpty && !_hasDataFromArguments) {
        debugPrint('🔄 No data from arguments, fetching fresh provider details from API for authId: $authId');
        fetchProviderDetails(authId!);
      } else if (_hasDataFromArguments) {
        debugPrint('✅ Using provider data from arguments, skipping API call');
        isLoadingProvider.value = false;
      } else {
        debugPrint('⚠️ No valid authId found and no provider data in arguments');
        if (providerData.value == null) {
          providerErrorMessage.value = 'No provider information available';
          isLoadingProvider.value = false;
        }
      }
    } else {
      debugPrint('⚠️ Arguments are null or not a Map');
      if (providerData.value == null) {
        providerErrorMessage.value = 'Invalid navigation data';
        isLoadingProvider.value = false;
      }
    }

    _hasInitialized = true;
  }

  /// Extract authId from various possible keys in arguments
  String? _extractAuthId(Map<String, dynamic> args) {
    // Try different possible keys for authId
    final possibleKeys = [
      'authId', 'authorId', '_id', 'id', 'author', 'providerId', 'userId'
    ];

    for (final key in possibleKeys) {
      if (args.containsKey(key) && args[key] != null) {
        final value = args[key].toString();
        if (value.isNotEmpty) {
          debugPrint('✅ Found authId in key: "$key" = "$value"');
          return value;
        }
      }
    }

    // Also check inside provider object if it exists
    if (args.containsKey('provider') && args['provider'] is Map<String, dynamic>) {
      final provider = args['provider'] as Map<String, dynamic>;
      for (final key in possibleKeys) {
        if (provider.containsKey(key) && provider[key] != null) {
          final value = provider[key].toString();
          if (value.isNotEmpty) {
            debugPrint('✅ Found authId in provider.$key = "$value"');
            return value;
          }
        }
      }
    }

    debugPrint('❌ Could not find authId in any known keys');
    return null;
  }

  /// Fetch provider/business profile details
  Future<void> fetchProviderDetails(String authId) async {
    debugPrint('🎯 ========== FETCH PROVIDER DETAILS STARTED ==========');
    debugPrint('📥 authId: $authId');

    // Only show loading if we don't have existing data
    if (providerData.value == null) {
      isLoadingProvider.value = true;
    }
    providerErrorMessage.value = '';

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

      debugPrint('📡 API Response Status: ${response.statusCode}');
      debugPrint('📡 API Response Success: ${response.isSuccess}');

      if (response.isSuccess && response.jsonResponse != null) {
        _handleSuccessResponse(response.jsonResponse!);
      } else {
        _handleErrorResponse(response);
      }
    } catch (e, stackTrace) {
      _handleException(e, stackTrace);
    } finally {
      isLoadingProvider.value = false;
      debugPrint('🏁 ========== FETCH PROVIDER COMPLETED ==========');
      debugPrint('   - isLoadingProvider: ${isLoadingProvider.value}');
      debugPrint('   - providerData: ${providerData.value != null ? "Loaded" : "NULL"}');
      debugPrint('   - errorMessage: "${providerErrorMessage.value}"');
      debugPrint('==========================================\n');
    }
  }

  /// Handle successful API response
  void _handleSuccessResponse(Map<String, dynamic> responseData) {
    try {
      debugPrint('🎉 API Response Success - Processing data...');
      debugPrint('   - success: ${responseData['success']}');
      debugPrint('   - code: ${responseData['code']}');
      debugPrint('   - message: ${responseData['message']}');
      debugPrint('   - has data key: ${responseData.containsKey('data')}');

      // Handle different response structures
      dynamic dataToParse = responseData;

      if (responseData.containsKey('data')) {
        dataToParse = responseData['data'];
        debugPrint('   - data type: ${dataToParse.runtimeType}');

        // Handle nested data structure
        if (dataToParse is Map<String, dynamic> && dataToParse.containsKey('data')) {
          dataToParse = dataToParse['data'];
          debugPrint('   - nested data type: ${dataToParse.runtimeType}');
        }
      }

      if (dataToParse is Map<String, dynamic>) {
        // Check if the API data is better than what we have from arguments
        if (_shouldUseApiData(dataToParse)) {
          _parseProviderData(dataToParse);
          providerErrorMessage.value = '';
          debugPrint('✅ Provider data parsed successfully from API');
        } else {
          debugPrint('ℹ️ API data is empty/incomplete - keeping data from arguments');
        }
      } else if (dataToParse is List && dataToParse.isNotEmpty && dataToParse[0] is Map<String, dynamic>) {
        // Handle case where data is a list
        if (_shouldUseApiData(dataToParse[0] as Map<String, dynamic>)) {
          _parseProviderData(dataToParse[0] as Map<String, dynamic>);
          providerErrorMessage.value = '';
          debugPrint('✅ Provider data parsed successfully from list response');
        } else {
          debugPrint('ℹ️ API list data is empty/incomplete - keeping data from arguments');
        }
      } else {
        providerErrorMessage.value = 'Unexpected data format from API';
        debugPrint('❌ Unexpected data format: ${dataToParse.runtimeType}');
        debugPrint('❌ Data content: $dataToParse');
      }
    } catch (parseError, stackTrace) {
      providerErrorMessage.value = 'Failed to parse provider data: ${parseError.toString()}';
      debugPrint('💥 Parse Error: $parseError');
      debugPrint('📚 StackTrace: $stackTrace');
      debugPrint('💥 Raw response data: $responseData');
    }
  }

  /// Check if API data should be used (has better/more complete data)
  bool _shouldUseApiData(Map<String, dynamic> apiData) {
    // If we don't have data from arguments, always use API data
    if (!_hasDataFromArguments) return true;

    // Check if API data has meaningful content
    final hasName = (apiData['name']?.toString().isNotEmpty ?? false) ||
        (apiData['businessName']?.toString().isNotEmpty ?? false);
    final hasDescription = apiData['description']?.toString().isNotEmpty ?? false;
    final hasPhone = apiData['phone']?.toString().isNotEmpty ?? false;

    debugPrint('🔍 API Data Quality Check:');
    debugPrint('   - Has name: $hasName');
    debugPrint('   - Has description: $hasDescription');
    debugPrint('   - Has phone: $hasPhone');
    debugPrint('   - Use API data: ${hasName || hasDescription || hasPhone}');

    return hasName || hasDescription || hasPhone;
  }

  /// Parse and set provider data with comprehensive field mapping
  void _parseProviderData(Map<String, dynamic> providerDataField) {
    debugPrint('🎨 Parsing provider data with fields:');
    providerDataField.forEach((key, value) {
      debugPrint('   - $key: $value (${value.runtimeType})');
    });

    try {
      // Create a clean map with proper field mapping
      final Map<String, dynamic> cleanData = {};

      // Map all possible field names to standard ones
      cleanData['_id'] = providerDataField['_id'] ??
          providerDataField['id'] ??
          providerDataField['author'] ??
          providerDataField['authId'] ??
          providerDataField['providerId'] ??
          '';

      cleanData['name'] = providerDataField['name'] ??
          providerDataField['businessName'] ??
          providerDataField['title'] ??
          providerDataField['username'] ??
          'Unknown Provider';

      cleanData['phone'] = providerDataField['phone'] ??
          providerDataField['phoneNumber'] ??
          providerDataField['contact'] ??
          providerDataField['mobile'] ??
          '';

      cleanData['location'] = providerDataField['location'] ??
          providerDataField['address'] ??
          providerDataField['city'] ??
          providerDataField['area'] ??
          '';

      cleanData['description'] = providerDataField['description'] ??
          providerDataField['bio'] ??
          providerDataField['about'] ??
          providerDataField['serviceDescription'] ??
          '';

      cleanData['image'] = providerDataField['image'] ??
          providerDataField['profileImage'] ??
          providerDataField['avatar'] ??
          providerDataField['photo'] ??
          '';

      cleanData['isAvailable'] = providerDataField['isAvailable'] ??
          providerDataField['available'] ??
          providerDataField['status'] == 'available' ??
          true;

      cleanData['isProfileComplete'] = providerDataField['isProfileComplete'] ??
          providerDataField['profileComplete'] ??
          providerDataField['complete'] ??
          false;

      // Handle rating - could be int, double, or string
      dynamic rating = providerDataField['rating'] ??
          providerDataField['rate'] ??
          providerDataField['stars'] ??
          0.0;

      if (rating is String) {
        cleanData['rating'] = double.tryParse(rating) ?? 0.0;
      } else if (rating is int) {
        cleanData['rating'] = rating.toDouble();
      } else {
        cleanData['rating'] = rating ?? 0.0;
      }

      // Handle rating count
      dynamic ratingCount = providerDataField['ratingCount'] ??
          providerDataField['reviewCount'] ??
          providerDataField['totalRatings'] ??
          providerDataField['reviews'] ??
          0;

      if (ratingCount is String) {
        cleanData['ratingCount'] = int.tryParse(ratingCount) ?? 0;
      } else {
        cleanData['ratingCount'] = ratingCount ?? 0;
      }

      debugPrint('🧹 Cleaned data for ProviderModel:');
      cleanData.forEach((key, value) {
        debugPrint('   - $key: $value (${value.runtimeType})');
      });

      final ProviderModel provider = ProviderModel.fromJson(cleanData);
      providerData.value = provider;

      debugPrint('✅ Successfully created ProviderModel:');
      debugPrint('   - ID: ${provider.id}');
      debugPrint('   - Name: "${provider.name}"');
      debugPrint('   - Phone: "${provider.phone}"');
      debugPrint('   - Description: "${provider.description}"');
      debugPrint('   - Location: "${provider.location}"');
      debugPrint('   - Rating: ${provider.rating}');
      debugPrint('   - Rating Count: ${provider.ratingCount}');
      debugPrint('   - Available: ${provider.isAvailable}');
      debugPrint('   - Profile Complete: ${provider.isProfileComplete}');
      debugPrint('   - Image URL: ${provider.fullImageUrl}');

    } catch (e, stackTrace) {
      debugPrint('❌ Error creating ProviderModel: $e');
      debugPrint('📚 StackTrace: $stackTrace');
      debugPrint('❌ Raw data that failed: $providerDataField');
      providerErrorMessage.value = 'Failed to create provider model: ${e.toString()}';
    }
  }

  /// Handle API error response
  void _handleErrorResponse(NetworkResponse response) {
    debugPrint('❌ API request failed');
    debugPrint('   - Status: ${response.statusCode}');
    debugPrint('   - Error: ${response.errorMessage}');
    debugPrint('   - Response: ${response.jsonResponse}');

    if (response.statusCode == 404) {
      providerErrorMessage.value = 'Provider not found';
    } else if (response.statusCode == 401) {
      providerErrorMessage.value = 'Authentication failed - please login again';
      _handleUnauthorized();
    } else if (response.statusCode == 403) {
      providerErrorMessage.value = 'Access denied - you cannot view this provider';
    } else if (response.statusCode == 400) {
      providerErrorMessage.value = 'Invalid request data';
    } else if (response.statusCode == 500) {
      providerErrorMessage.value = 'Server error - please try again later';
    } else {
      final errorMessage = response.jsonResponse?['message'] ??
          response.errorMessage ??
          'Failed to load provider details';
      providerErrorMessage.value = errorMessage;
    }
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
    } else {
      debugPrint('❌ Cannot retry - no authId available');
    }
  }

  /// Clear provider data - only called when back button is pressed
  void clearProviderData() {
    debugPrint('🗑️ Clearing provider data - back button pressed');
    providerData.value = null;
    providerErrorMessage.value = '';
    _hasInitialized = false;
    _hasDataFromArguments = false;
    authId = null;
  }

  /// Manual refresh - force update data
  Future<void> refreshProviderData() async {
    if (authId != null && authId!.isNotEmpty) {
      debugPrint('🔄 Manual refresh requested for authId: $authId');
      await fetchProviderDetails(authId!);
    } else {
      debugPrint('❌ Cannot refresh - no authId available');
    }
  }

  @override
  void onClose() {
    debugPrint('🔚 ProviderDetailsController onClose called');
    super.onClose();
  }

  /// Call this method when back button is pressed to clear data
  void onBackPressed() {
    clearProviderData();
  }
}