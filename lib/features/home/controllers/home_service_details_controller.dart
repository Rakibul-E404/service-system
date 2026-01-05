import 'package:flutter/material.dart';
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

  // Store service data from arguments
  final Rx<Map<String, dynamic>> serviceData = Rx<Map<String, dynamic>>({});
  bool _isInitialized = false;

  @override
  void onInit() {
    super.onInit();
    _initializeWithArguments();
  }

  void _initializeWithArguments() {
    final dynamic args = Get.arguments;

    debugPrint('🔍 HomeServiceDetailsController - Received arguments: $args');

    // Store service data immediately
    if (args != null && args is Map<String, dynamic>) {
      serviceData.value = Map<String, dynamic>.from(args);
      debugPrint('✅ Service data stored: ${serviceData.value}');
    }

    // If we already have provider data, don't reinitialize
    if (_isInitialized && providerData.value != null) {
      debugPrint('✅ Already initialized with provider data, skipping reinitialization');
      return;
    }

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

    _isInitialized = true;
  }

  /// Get service information for UI
  Map<String, dynamic> get serviceInfo {
    return serviceData.value;
  }

  String get serviceId {
    return serviceData.value['serviceId']?.toString() ??
        serviceData.value['_id']?.toString() ?? '';
  }

  String get serviceTitle {
    return serviceData.value['serviceName']?.toString() ?? 'No Name';
  }

  String get serviceSubtitle {
    return serviceData.value['serviceDescription']?.toString() ?? 'No Description';
  }

  String get serviceLocation {
    return serviceData.value['serviceLocation']?.toString() ?? 'No Location';
  }

  double get serviceRating {
    return (serviceData.value['serviceRating'] as num?)?.toDouble() ?? 0.0;
  }

  String get serviceImage {
    final String serviceImagePath = serviceData.value['serviceImage']?.toString() ?? '';
    return _getFullImageUrl(serviceImagePath);
  }

  String get authorId {
    final dynamic authorData = serviceData.value['author'];
    return authorData is Map<String, dynamic>
        ? (authorData['_id']?.toString() ?? '')
        : (serviceData.value['authorId']?.toString() ?? '');
  }

  // Helper method to construct full image URL
  String _getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';

    // If already a full URL
    if (imagePath.startsWith('http')) return imagePath;

    // Remove 'public/' prefix if present
    String cleanPath = imagePath;
    if (cleanPath.startsWith('public/')) {
      cleanPath = cleanPath.substring(7);
    }

    // Construct full URL
    final fullUrl = '${AppUrl.imageBaseUrl}/$cleanPath';
    return fullUrl;
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

  /// Fetch provider/business profile details (with authentication)
  Future<void> fetchProviderDetails(String authorId) async {
    // Don't fetch if we already have data for this author
    if (providerData.value != null && providerData.value!.id == authorId) {
      debugPrint('✅ Already have provider data for: $authorId, skipping fetch');
      return;
    }

    debugPrint('🎯 FETCH PROVIDER DETAILS STARTED');
    debugPrint('📥 authorId: $authorId');

    isLoadingProvider.value = true;
    providerErrorMessage.value = '';

    try {
      // Check if user is logged in
      final bool isLoggedIn = await _sharedPrefService.isLoggedIn();
      debugPrint('🔐 User Login Status: $isLoggedIn');

      final String url = AppUrl.getBusinessProfileUrl(authorId);
      debugPrint('🌐 API URL: $url');

      // Prepare headers with authentication if logged in
      Map<String, String> headers = <String, String>{
        'Content-Type': 'application/json',
      };

      if (isLoggedIn) {
        final String? accessToken = await _sharedPrefService.getAccessToken();
        if (accessToken != null && accessToken.isNotEmpty) {
          headers['Authorization'] = 'Bearer $accessToken';
          debugPrint('🔑 Adding Authorization header with token');
        }
      }

      final NetworkResponse response = await _networkCaller.getRequest(
        url,
        headers: headers,
      );

      debugPrint('📡 API Response - Status: ${response.statusCode}, Success: ${response.isSuccess}');

      if (response.isSuccess && response.jsonResponse != null) {
        _handleSuccessResponse(response.jsonResponse!);
      } else {
        debugPrint('❌ API call failed, creating limited provider info');
        _createLimitedProvider(authorId);
      }
    } catch (e, stackTrace) {
      debugPrint('💥 Exception occurred: $e');
      debugPrint('📚 StackTrace: $stackTrace');
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
      debugPrint('🎉 API Response Success - Processing data...');

      // Handle different response structures
      dynamic dataToParse = responseData;

      if (responseData.containsKey('data')) {
        dataToParse = responseData['data'];
        debugPrint('   - data type: ${dataToParse.runtimeType}');

        // Handle nested data structure
        if (dataToParse is Map<String, dynamic> && dataToParse.containsKey('data')) {
          dataToParse = dataToParse['data'];
        }
      }

      if (dataToParse is Map<String, dynamic>) {
        _parseProviderData(dataToParse);
      } else if (dataToParse is List && dataToParse.isNotEmpty && dataToParse[0] is Map<String, dynamic>) {
        _parseProviderData(dataToParse[0] as Map<String, dynamic>);
      } else {
        providerErrorMessage.value = 'Unexpected data format from API';
        _createLimitedProvider('unknown');
      }
    } catch (parseError, stackTrace) {
      providerErrorMessage.value = 'Failed to parse provider data';
      _createLimitedProvider('unknown');
    }
  }

  /// Parse and set provider data with comprehensive field mapping
  void _parseProviderData(Map<String, dynamic> providerDataField) {
    debugPrint('🎨 Parsing provider data with fields:');

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

      // Handle rating
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

      final ProviderModel provider = ProviderModel.fromJson(cleanData);
      providerData.value = provider;
      providerErrorMessage.value = '';

      debugPrint('✅ Successfully created ProviderModel: ${provider.name}');

    } catch (e, stackTrace) {
      debugPrint('❌ Error creating ProviderModel: $e');
      providerErrorMessage.value = 'Failed to create provider model: ${e.toString()}';
      _createLimitedProvider(providerDataField['_id']?.toString() ?? 'unknown');
    }
  }

  /// Retry fetching provider details
  void retryFetchProvider(String authorId) {
    debugPrint('🔄 Retrying fetch for authorId: $authorId');
    fetchProviderDetails(authorId);
  }

  @override
  void onClose() {
    debugPrint('🔚 HomeServiceDetailsController onClose called');
    super.onClose();
  }
}