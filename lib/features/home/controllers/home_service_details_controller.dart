/**

import 'package:get/get.dart';

class HomeServiceDetailsController extends GetxController {
  Rx<DateTime> dateTimePick = DateTime.now().obs;
}
*/



///
///
///
///
/// todo::: adding the author info
///
///
///
///
///




// import 'package:flutter/cupertino.dart';
// import 'package:get/get.dart';
// import '../../../core/network/network_caller.dart';
// import '../../../core/network/network_response.dart';
// import '../../../core/utils/api/app_url.dart';
// import '../../../core/utils/token_service/token_storage_service.dart';
// import '../../../provider_model.dart';
//
// class HomeServiceDetailsController extends GetxController {
//   final NetworkCaller _networkCaller = NetworkCaller();
//   final SharedPrefService _sharedPrefService = SharedPrefService();
//
//   Rx<DateTime> dateTimePick = DateTime.now().obs;
//
//   // Provider data
//   final Rx<ProviderModel?> providerData = Rx<ProviderModel?>(null);
//   final RxBool isLoadingProvider = false.obs;
//   final RxString providerErrorMessage = ''.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     _initializeWithArguments();
//   }
//
//   void _initializeWithArguments() {
//     final dynamic args = Get.arguments;
//
//     debugPrint('🔍 HomeServiceDetailsController - Received arguments type: ${args.runtimeType}');
//     debugPrint('🔍 HomeServiceDetailsController - Arguments value: $args');
//
//     if (args != null && args is Map<String, dynamic>) {
//       // Get authorId from either 'author' map or direct 'authorId' field
//       final dynamic authorData = args['author'];
//       final String? authorId = authorData is Map<String, dynamic>
//           ? authorData['_id']?.toString()
//           : args['authorId']?.toString();
//
//       debugPrint('🔍 Extracted authorId: $authorId');
//       debugPrint('🔍 authorData type: ${authorData.runtimeType}');
//       debugPrint('🔍 authorData value: $authorData');
//
//       if (authorId != null && authorId.isNotEmpty) {
//         debugPrint('✅ Found authorId: $authorId - Calling fetchProviderDetails');
//         fetchProviderDetails(authorId);
//       } else {
//         debugPrint('⚠️ No authorId found in arguments');
//         providerErrorMessage.value = 'No provider information available';
//       }
//     } else {
//       debugPrint('⚠️ Arguments are null or not a Map');
//       providerErrorMessage.value = 'Invalid navigation data';
//     }
//   }
//
//   /// Fetch provider/business profile details
//   Future<void> fetchProviderDetails(String authorId) async {
//     debugPrint('🎯 ========== FETCH PROVIDER DETAILS STARTED ==========');
//     debugPrint('📥 authorId: $authorId');
//
//     isLoadingProvider.value = true;
//     providerErrorMessage.value = '';
//     providerData.value = null;
//
//     try {
//       final String url = AppUrl.getBusinessProfileUrl(authorId);
//       debugPrint('🌐 API URL: $url');
//
//       final String? accessToken = await _sharedPrefService.getAccessToken();
//       debugPrint('🔑 Access Token: ${accessToken != null ? 'Available (${accessToken.length} chars)' : 'NULL'}');
//
//       if (accessToken == null || accessToken.isEmpty) {
//         providerErrorMessage.value = 'Authentication required';
//         debugPrint('❌ No access token available');
//         isLoadingProvider.value = false;
//         return;
//       }
//
//       final NetworkResponse response = await _networkCaller.getRequest(
//         url,
//         headers: <String, String>{
//           'Authorization': 'Bearer $accessToken',
//         },
//       );
//
//       debugPrint('📡 API Response:');
//       debugPrint('   - isSuccess: ${response.isSuccess}');
//       debugPrint('   - statusCode: ${response.statusCode}');
//       debugPrint('   - Full Response: ${response.jsonResponse}');
//
//       if (response.isSuccess && response.jsonResponse != null) {
//         try {
//           final Map<String, dynamic> responseData = response.jsonResponse!;
//
//           debugPrint('🔍 Response structure:');
//           debugPrint('   - success: ${responseData['success']}');
//           debugPrint('   - code: ${responseData['code']}');
//           debugPrint('   - message: ${responseData['message']}');
//           debugPrint('   - data exists: ${responseData.containsKey('data')}');
//
//           if (!responseData.containsKey('data')) {
//             providerErrorMessage.value = 'Invalid response format: missing "data" key';
//             debugPrint('❌ Missing "data" key in response');
//             debugPrint('   - Available keys: ${responseData.keys.toList()}');
//             return;
//           }
//
//           final dynamic providerDataField = responseData['data'];
//           debugPrint('   - data type: ${providerDataField.runtimeType}');
//           debugPrint('   - data content: $providerDataField');
//
//           if (providerDataField is! Map<String, dynamic>) {
//             providerErrorMessage.value = 'Invalid provider data format';
//             debugPrint('❌ Provider data is not a Map, it is: ${providerDataField.runtimeType}');
//             return;
//           }
//
//           debugPrint('🎨 Parsing provider data...');
//           debugPrint('   - _id: ${providerDataField['_id']}');
//           debugPrint('   - name: "${providerDataField['name']}"');
//           debugPrint('   - name length: ${providerDataField['name']?.toString().length}');
//           debugPrint('   - phone: ${providerDataField['phone']}');
//           debugPrint('   - location: ${providerDataField['location']}');
//           debugPrint('   - rating: ${providerDataField['rating']}');
//
//           final provider = ProviderModel.fromJson(providerDataField);
//           providerData.value = provider;
//
//           debugPrint('✅ Successfully loaded provider:');
//           debugPrint('   - ID: ${provider.id}');
//           debugPrint('   - Name: "${provider.name}"');
//           debugPrint('   - Location: ${provider.location}');
//           debugPrint('   - Rating: ${provider.rating}');
//           debugPrint('   - Phone: ${provider.phone}');
//           debugPrint('   - Description: ${provider.description}');
//           debugPrint('   - Image: ${provider.image}');
//           debugPrint('   - Full Image URL: ${provider.fullImageUrl}');
//
//         } catch (parseError, stackTrace) {
//           providerErrorMessage.value = 'Failed to parse provider data: ${parseError.toString()}';
//           debugPrint('💥 Parse Error: $parseError');
//           debugPrint('📚 StackTrace: $stackTrace');
//         }
//       } else {
//         providerErrorMessage.value = response.errorMessage ?? 'Failed to load provider details';
//         debugPrint('❌ API request failed');
//         debugPrint('   - Status: ${response.statusCode}');
//         debugPrint('   - Error: ${response.errorMessage}');
//       }
//     } catch (e, stackTrace) {
//       providerErrorMessage.value = 'Network error: ${e.toString()}';
//       debugPrint('💥 Network Exception: $e');
//       debugPrint('📚 StackTrace: $stackTrace');
//     } finally {
//       isLoadingProvider.value = false;
//       debugPrint('🏁 ========== FETCH PROVIDER COMPLETED ==========');
//       debugPrint('   - isLoadingProvider: ${isLoadingProvider.value}');
//       debugPrint('   - providerData name: ${providerData.value?.name ?? 'NULL'}');
//       debugPrint('   - errorMessage: "${providerErrorMessage.value}"');
//       debugPrint('==========================================\n');
//     }
//   }
//
//   /// Retry fetching provider details
//   void retryFetchProvider(String authorId) {
//     debugPrint('🔄 Retrying fetch for authorId: $authorId');
//     fetchProviderDetails(authorId);
//   }
//
//   @override
//   void onClose() {
//     providerData.value = null;
//     super.onClose();
//   }
// }



///-------todo:: upper is sightly working,
///
///



import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
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

  @override
  void onInit() {
    super.onInit();
    _initializeWithArguments();
  }

  void _initializeWithArguments() {
    final dynamic args = Get.arguments;

    debugPrint('🔍 HomeServiceDetailsController - Received arguments type: ${args.runtimeType}');
    debugPrint('🔍 HomeServiceDetailsController - Arguments value: $args');

    if (args != null && args is Map<String, dynamic>) {
      // Get authorId from either 'author' map or direct 'authorId' field
      final dynamic authorData = args['author'];
      final String? authorId = authorData is Map<String, dynamic>
          ? authorData['_id']?.toString()
          : args['authorId']?.toString();

      debugPrint('🔍 Extracted authorId: $authorId');
      debugPrint('🔍 authorData type: ${authorData.runtimeType}');
      debugPrint('🔍 authorData value: $authorData');

      if (authorId != null && authorId.isNotEmpty) {
        debugPrint('✅ Found authorId: $authorId - Calling fetchProviderDetails');
        fetchProviderDetails(authorId);
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

  /// Handle restricted access (403) - Create a limited provider object
  void _handleRestrictedAccess(String authorId) {
    debugPrint('🛡️ Creating limited provider data for restricted access');

    // Create a basic provider model with limited information
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

    // Specific handling for common status codes
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

  /// Parse and set provider data
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

    final provider = ProviderModel.fromJson(providerDataField);
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
    // You can optionally clear tokens here or redirect to login
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