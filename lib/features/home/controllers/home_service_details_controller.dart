


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../core/network/network_caller.dart';
import '../../../core/network/network_response.dart';
import '../../../core/utils/api/app_url.dart';
import '../../../provider_model.dart';

class HomeServiceDetailsController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();

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

    debugPrint('🔍 HomeServiceDetailsController - Received arguments: $args');

    if (args != null && args is Map<String, dynamic>) {
      // Get authorId from either 'author' map or direct 'authorId' field
      final dynamic authorData = args['author'];
      final String? authorId = authorData is Map<String, dynamic>
          ? authorData['_id']?.toString()
          : args['authorId']?.toString();

      debugPrint('🔍 Extracted authorId: $authorId');

      if (authorId != null && authorId.isNotEmpty) {
        debugPrint('✅ Found authorId: $authorId - Calling fetchProviderDetails');
        fetchProviderDetails(authorId);
      } else {
        debugPrint('⚠️ No authorId found in arguments');
        // Create basic provider from service data
        _createBasicProviderFromServiceData(args);
      }
    } else {
      debugPrint('⚠️ Arguments are null or not a Map');
      providerErrorMessage.value = 'No provider information available';
    }
  }

  /// Create basic provider info from service data when authorId is not available
  void _createBasicProviderFromServiceData(Map<String, dynamic> serviceData) {
    debugPrint('🛠️ Creating basic provider from service data');

    final basicProvider = ProviderModel(
      id: 'unknown',
      name: serviceData['author'] is Map
          ? (serviceData['author']['name']?.toString() ?? 'Service Provider')
          : 'Service Provider',
      description: serviceData['serviceDescription']?.toString() ?? 'Professional service provider',
      location: serviceData['serviceLocation']?.toString() ?? 'Location not specified',
      phone: 'Contact for details',
      image: serviceData['serviceImage']?.toString() ?? '',
      rating: (serviceData['serviceRating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: 0,
      isAvailable: true,
      isProfileComplete: false,
      createdAt: DateTime.now().toString(),
    );

    providerData.value = basicProvider;
    isLoadingProvider.value = false;

    debugPrint('✅ Basic provider created: ${basicProvider.name}');
  }

  /// Fetch provider/business profile details (with fallback when no auth)
  Future<void> fetchProviderDetails(String authorId) async {
    debugPrint('🎯 FETCH PROVIDER DETAILS STARTED');
    debugPrint('📥 authorId: $authorId');

    isLoadingProvider.value = true;
    providerErrorMessage.value = '';
    providerData.value = null;

    try {
      final String url = AppUrl.getBusinessProfileUrl(authorId);
      debugPrint('🌐 API URL: $url');

      final NetworkResponse response = await _networkCaller.getRequest(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
      );

      debugPrint('📡 API Response - Status: ${response.statusCode}, Success: ${response.isSuccess}');

      if (response.isSuccess && response.jsonResponse != null) {
        _handleSuccessResponse(response.jsonResponse!);
      } else {
        // If API fails, create limited provider info
        debugPrint('❌ API call failed, creating limited provider info');
        _createLimitedProvider(authorId);
      }
    } catch (e, stackTrace) {
      debugPrint('💥 Exception occurred: $e');
      // On exception, still create limited provider info
      _createLimitedProvider(authorId);
    } finally {
      isLoadingProvider.value = false;
      debugPrint('🏁 FETCH PROVIDER COMPLETED');
    }
  }

  /// Create limited provider information when API is not accessible
  void _createLimitedProvider(String authorId) {
    debugPrint('🛡️ Creating limited provider data');

    final limitedProvider = ProviderModel(
      id: authorId,
      name: 'Service Provider',
      description: 'Professional service provider dedicated to quality work. Contact for more details about services and availability.',
      location: 'Contact for location details',
      phone: 'Available upon request',
      image: '',
      rating: 0.0,
      ratingCount: 0,
      isAvailable: true,
      isProfileComplete: false,
      createdAt: DateTime.now().toString(),
    );

    providerData.value = limitedProvider;
    providerErrorMessage.value = 'Basic provider information shown. Some details may be limited.';

    debugPrint('✅ Limited provider data created for ID: $authorId');
  }

  /// Handle successful API response
  void _handleSuccessResponse(Map<String, dynamic> responseData) {
    try {
      debugPrint('🔍 Response structure - success: ${responseData['success']}');

      if (!responseData.containsKey('data')) {
        providerErrorMessage.value = 'Invalid response format';
        debugPrint('❌ Missing "data" key in response');
        return;
      }

      final dynamic providerDataField = responseData['data'];
      debugPrint('   - data type: ${providerDataField.runtimeType}');

      if (providerDataField is! Map<String, dynamic>) {
        providerErrorMessage.value = 'Invalid provider data format';
        debugPrint('❌ Provider data is not a Map');
        return;
      }

      _parseProviderData(providerDataField);
    } catch (parseError, stackTrace) {
      providerErrorMessage.value = 'Failed to parse provider data';
      debugPrint('💥 Parse Error: $parseError');
    }
  }

  /// Parse and set provider data
  void _parseProviderData(Map<String, dynamic> providerDataField) {
    debugPrint('🎨 Parsing provider data...');

    final ProviderModel provider = ProviderModel.fromJson(providerDataField);
    providerData.value = provider;

    debugPrint('✅ Successfully loaded provider: ${provider.name}');
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




///
///
///
/// todo::: fixing to show the provider image
///
///
///



