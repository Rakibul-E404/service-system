/**
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/network/network_response.dart';
import '../../../core/utils/api/app_url.dart';
import '../../../model/featured_provider_model.dart';

class FeaturedProviderController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();

  // Observable lists
  final RxList<FeaturedProviderModel> featuredProviders = <FeaturedProviderModel>[].obs;

  // Loading states
  final RxBool isLoading = false.obs;

  // Error message
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFeaturedProviders();
  }

  /// Fetch featured providers from API
  Future<void> fetchFeaturedProviders() async {
    // Prevent duplicate calls
    if (isLoading.value) {
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    featuredProviders.clear();

    try {
      debugPrint('🔄 Fetching featured providers...');
      final String url = AppUrl.featuredProviders;
      debugPrint('📍 URL: $url');
      debugPrint('📍 Image Base URL: ${AppUrl.imageBaseUrl}');

      final NetworkResponse response = await _networkCaller.getRequest(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
      );

      debugPrint('✅ Response received');
      debugPrint('📊 Success: ${response.isSuccess}');
      debugPrint('📄 Status Code: ${response.statusCode}');

      if (response.isSuccess && response.jsonResponse != null) {
        try {
          final FeaturedProviderResponse providerResponse =
          FeaturedProviderResponse.fromJson(response.jsonResponse!);

          // Log image URLs for debugging
          for (var provider in providerResponse.providers) {
            debugPrint('📷 Provider: ${provider.name}');
            debugPrint('   📁 Image path: ${provider.image}');
            debugPrint('   🔗 Full URL: ${_getFullImageUrl(provider.image)}');
          }

          featuredProviders.value = providerResponse.providers;
          debugPrint('✨ Featured providers loaded successfully: ${featuredProviders.length} items');

          if (featuredProviders.isEmpty) {
            errorMessage.value = 'No featured providers available';
            debugPrint('⚠️ No featured providers found');
          }
        } catch (parseError) {
          errorMessage.value = 'Failed to parse featured providers';
          debugPrint('💥 Parse error: $parseError');
          debugPrint('💥 Response data: ${response.jsonResponse}');
        }
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to fetch featured providers';
        debugPrint('⚠️ Error message set: ${errorMessage.value}');
      }
    } catch (e, stackTrace) {
      errorMessage.value = 'Error: ${e.toString()}';
      debugPrint('💥 Exception caught: $e');
      debugPrint('📚 Stack trace: $stackTrace');
    } finally {
      isLoading.value = false;
      debugPrint('🏁 Loading finished. Total providers: ${featuredProviders.length}');
    }
  }

  /// Helper method to construct full image URL
  String _getFullImageUrl(String imagePath) {
    if (imagePath.isEmpty) return '';

    // If image already has full URL, return it
    if (imagePath.startsWith('http')) return imagePath;

    // Remove leading slash if present
    String cleanImagePath = imagePath;
    if (cleanImagePath.startsWith('/')) {
      cleanImagePath = cleanImagePath.substring(1);
    }

    // Construct full URL using AppUrl.imageBaseUrl
    return '${AppUrl.imageBaseUrl}/$cleanImagePath';
  }

  /// Get full image URL for a provider
  String getProviderImageUrl(FeaturedProviderModel provider) {
    return _getFullImageUrl(provider.image);
  }

  /// Get full image URL by image path
  String getImageUrl(String imagePath) {
    return _getFullImageUrl(imagePath);
  }

  /// Retry fetching featured providers
  void retry() {
    fetchFeaturedProviders();
  }

  /// Clear all data
  void clearData() {
    featuredProviders.clear();
    errorMessage.value = '';
    isLoading.value = false;
  }

  @override
  void onClose() {
    debugPrint('👋 FeaturedProviderController onClose() called');
    clearData();
    super.onClose();
  }
}*/











import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/network/network_response.dart';
import '../../../core/utils/api/app_url.dart';
import '../../../model/featured_provider_model.dart';


class FeaturedProviderController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();

  // Observable lists
  final RxList<FeaturedProviderModel> featuredProviders = <FeaturedProviderModel>[].obs;

  // Loading states
  final RxBool isLoading = false.obs;

  // Error message
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFeaturedProviders();
  }

  /// Fetch featured providers from API
  Future<void> fetchFeaturedProviders() async {
    // Prevent duplicate calls
    if (isLoading.value) {
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    featuredProviders.clear();

    try {
      debugPrint('🔄 Fetching featured providers...');
      final String url = AppUrl.featuredProviders;
      debugPrint('📍 API URL: $url');
      debugPrint('📍 Image Base URL: ${AppUrl.imageBaseUrl}');

      final NetworkResponse response = await _networkCaller.getRequest(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
      );

      debugPrint('✅ Response received');
      debugPrint('📊 Success: ${response.isSuccess}');
      debugPrint('📄 Status Code: ${response.statusCode}');

      if (response.isSuccess && response.jsonResponse != null) {
        try {
          final FeaturedProviderResponse providerResponse =
          FeaturedProviderResponse.fromJson(response.jsonResponse!);

          // Log image URLs for debugging
          for (var provider in providerResponse.providers) {
            final imageUrl = getProviderImageUrl(provider);
            debugPrint('📷 Provider: ${provider.name}');
            debugPrint('   📁 Image path from API: ${provider.image}');
            debugPrint('   🔗 Constructed Full URL: $imageUrl');
          }

          featuredProviders.value = providerResponse.providers;
          debugPrint('✨ Featured providers loaded successfully: ${featuredProviders.length} items');

          if (featuredProviders.isEmpty) {
            errorMessage.value = 'No featured providers available';
            debugPrint('⚠️ No featured providers found');
          }
        } catch (parseError) {
          errorMessage.value = 'Failed to parse featured providers';
          debugPrint('💥 Parse error: $parseError');
          debugPrint('💥 Response data: ${response.jsonResponse}');
        }
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to fetch featured providers';
        debugPrint('⚠️ Error message set: ${errorMessage.value}');
      }
    } catch (e, stackTrace) {
      errorMessage.value = 'Error: ${e.toString()}';
      debugPrint('💥 Exception caught: $e');
      debugPrint('📚 Stack trace: $stackTrace');
    } finally {
      isLoading.value = false;
      debugPrint('🏁 Loading finished. Total providers: ${featuredProviders.length}');
    }
  }

  /// Helper method to construct full image URL
  String getProviderImageUrl(FeaturedProviderModel provider) {
    if (provider.image.isEmpty) {
      debugPrint('⚠️ No image for provider: ${provider.name}');
      return '';
    }

    // If image already has full URL, return it
    if (provider.image.startsWith('http')) {
      return provider.image;
    }

    // Construct the full URL: AppUrl.imageBaseUrl + / + imagePath
    // imagePath includes folders like "business/" or "businessProfile/"
    String cleanImagePath = provider.image;

    // Remove leading slash if present
    if (cleanImagePath.startsWith('/')) {
      cleanImagePath = cleanImagePath.substring(1);
    }

    // Construct full URL
    final fullUrl = '${AppUrl.imageBaseUrl}/$cleanImagePath';
    debugPrint('🔗 URL Construction for ${provider.name}:');
    debugPrint('   Base: ${AppUrl.imageBaseUrl}');
    debugPrint('   Path: $cleanImagePath');
    debugPrint('   Result: $fullUrl');

    return fullUrl;
  }

  /// Get full image URL by image path
  String getImageUrl(String imagePath) {
    if (imagePath.isEmpty) return '';

    if (imagePath.startsWith('http')) return imagePath;

    String cleanImagePath = imagePath;
    if (cleanImagePath.startsWith('/')) {
      cleanImagePath = cleanImagePath.substring(1);
    }

    return '${AppUrl.imageBaseUrl}/$cleanImagePath';
  }

  /// Retry fetching featured providers
  void retry() {
    fetchFeaturedProviders();
  }

  /// Clear all data
  void clearData() {
    featuredProviders.clear();
    errorMessage.value = '';
    isLoading.value = false;
  }

  @override
  void onClose() {
    debugPrint('👋 FeaturedProviderController onClose() called');
    clearData();
    super.onClose();
  }
}