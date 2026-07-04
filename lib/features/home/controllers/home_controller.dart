import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:manx_mate/core/service/socket_service.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/network/network_response.dart';
import '../../../core/utils/api/app_url.dart';
import '../model/categor_model.dart';

class HomeController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();

  // PageController for horizontal pagination
  final PageController pageController = PageController();

  // Observable lists
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<dynamic> subcategories = <dynamic>[].obs;
  final RxList<Map<String, dynamic>> advertisements = <Map<String, dynamic>>[].obs;

  // Pagination
  final RxInt currentPage = 0.obs; // Added for horizontal pagination

  // Loading states
  final RxBool isLoadingCategories = false.obs;
  final RxBool isLoadingSubcategories = false.obs;
  final RxBool isLoadingAds = false.obs;

  // Error messages
  final RxString errorMessage = ''.obs;
  final RxString subcategoryErrorMessage = ''.obs;
  final RxString adsErrorMessage = ''.obs;

  /// Parse JSON safely with error handling
  dynamic _parseJsonSafely(dynamic jsonString) {
    try {
      if (jsonString is String) {
        // Try to parse as JSON
        return jsonDecode(jsonString);
      }
      return jsonString;
    } catch (e, stackTrace) {
      debugPrint('💥 JSON Parse Error: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      return null;
    }
  }

  /// Validate API response structure
  bool _validateResponseStructure(NetworkResponse response, {required String apiName}) {
    try {
      if (!response.isSuccess) {
        return false;
      }

      if (response.jsonResponse == null) {
        debugPrint('❌ $apiName: Response JSON is null');
        return false;
      }

      // Safely parse JSON
      final parsedResponse = _parseJsonSafely(response.jsonResponse);
      if (parsedResponse == null) {
        debugPrint('❌ $apiName: Failed to parse JSON response');
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('❌ $apiName: Error validating response: $e');
      return false;
    }
  }

  /// Fetch advertisements from API (without auth)
  Future<void> fetchAdvertisements() async {
    isLoadingAds.value = true;
    advertisements.clear();
    adsErrorMessage.value = '';

    try {
      debugPrint('🔄 Fetching advertisements (no auth)...');
      debugPrint('📍 URL: ${AppUrl.baseUrl}/adds/all');

      final NetworkResponse response = await _networkCaller.getRequest(
        '${AppUrl.baseUrl}/adds/all',
        // No headers - no authentication required
      );

      debugPrint('✅ Ads Response received');
      debugPrint('📊 Success: ${response.isSuccess}');
      debugPrint('📄 Status Code: ${response.statusCode}');

      // Check if response is valid
      if (!_validateResponseStructure(response, apiName: 'Advertisements')) {
        adsErrorMessage.value = 'Please try again.';
        debugPrint('❌ Invalid response structure for advertisements');
        return;
      }

      try {
        // Safely parse the JSON
        final responseData = _parseJsonSafely(response.jsonResponse);
        if (responseData == null) {
          adsErrorMessage.value = 'Failed to process server response';
          return;
        }

        if (responseData['success'] == true &&
            responseData['data'] != null &&
            responseData['data']['data'] != null) {

          final List<dynamic> adsList = responseData['data']['data'];

          advertisements.value = adsList.map<Map<String, dynamic>>((ad) {
            return {
              '_id': ad['_id']?.toString() ?? '',
              'author': ad['author']?.toString() ?? '',
              'title': ad['title']?.toString() ?? 'No Title',
              'description': ad['description']?.toString() ?? 'No Description',
              'image': ad['image'] != null
                  // ? 'https://d7001.sobhoy.com/${ad['image']}'
                  ? 'https://5003.dipudebnath.tech/${ad['image']}'
                  : null,
              'profile': ad['profile']?.toString() ?? '',
            };
          }).toList();

          debugPrint('✨ Advertisements loaded successfully: ${advertisements.length} items');

          if (advertisements.isEmpty) {
            adsErrorMessage.value = 'No advertisements available';
          }
        } else {
          adsErrorMessage.value = 'Invalid advertisement data format';
          debugPrint('❌ Response missing required data structure');
        }
      } catch (parseError, stackTrace) {
        adsErrorMessage.value = 'Failed to process advertisements data';
        debugPrint('💥 Parse error: $parseError');
        debugPrint('📚 Stack trace: $stackTrace');
      }
    } catch (e, stackTrace) {
      if (e is FormatException) {
        adsErrorMessage.value = 'Data format error. Please try again.';
        debugPrint('💥 FormatException: ${e.message}');
      } else {
        adsErrorMessage.value = 'Network error. Please check your connection.';
        debugPrint('💥 Exception caught: $e');
      }
      debugPrint('📚 Stack trace: $stackTrace');
    } finally {
      isLoadingAds.value = false;
      debugPrint('🏁 Ads loading finished. Total: ${advertisements.length}');
    }
  }

  /// Fetch all categories from API (without auth) with improved error handling
  Future<void> fetchCategories() async {
    isLoadingCategories.value = true;
    errorMessage.value = '';

    try {
      debugPrint('🔄 Starting category fetch (no auth)...');
      debugPrint('📍 URL: ${AppUrl.allCategory}');

      final NetworkResponse response = await _networkCaller.getRequest(
        AppUrl.allCategory,
        // No headers - no authentication required
      );

      debugPrint('✅ Response received');
      debugPrint('📊 Success: ${response.isSuccess}');
      debugPrint('📄 Status Code: ${response.statusCode}');

      // Check if response is valid
      if (!_validateResponseStructure(response, apiName: 'Categories')) {
        errorMessage.value = 'Please try again.';
        debugPrint('❌ Invalid response structure for categories');
        return;
      }

      try {
        // Safely parse the JSON
        final responseData = _parseJsonSafely(response.jsonResponse);
        if (responseData == null) {
          errorMessage.value = 'Failed to process server response';
          return;
        }

        final CategoryResponse categoryResponse =
        CategoryResponse.fromJson(responseData);
        categories.value = categoryResponse.categories;
        debugPrint('✨ Categories loaded successfully: ${categories.length} items');

        if (categories.isEmpty) {
          errorMessage.value = 'No categories available';
        }
      } catch (parseError, stackTrace) {
        errorMessage.value = 'Failed to load categories. Please try again.';
        debugPrint('💥 Parse error: $parseError');
        debugPrint('📚 Stack trace: $stackTrace');

        // Try to get error from response if available
        try {
          final responseData = _parseJsonSafely(response.jsonResponse);
          if (responseData != null && responseData['message'] != null) {
            errorMessage.value = responseData['message'].toString();
          }
        } catch (_) {
          // Ignore if we can't extract error message
        }
      }
    } catch (e, stackTrace) {
      if (e is FormatException) {
        errorMessage.value = 'Data format error. Please try again.';
        debugPrint('💥 FormatException: ${e.message}');
      } else if (e.toString().contains('Connection refused') ||
          e.toString().contains('Failed host lookup')) {
        errorMessage.value = 'Network error. Please check your internet connection.';
        debugPrint('💥 Network error: $e');
      } else {
        errorMessage.value = 'Something went wrong. Please try again.';
        debugPrint('💥 Exception caught: $e');
      }
      debugPrint('📚 Stack trace: $stackTrace');
    } finally {
      isLoadingCategories.value = false;
      debugPrint('🏁 Loading finished. Total categories: ${categories.length}');
    }
  }


  /// Fetch subcategories for a specific category (without auth)
  Future<void> fetchSubcategories(String categoryId) async {
    if (categoryId.isEmpty) {
      debugPrint('⚠️ Category ID is empty, cannot fetch subcategories');
      return;
    }

    isLoadingSubcategories.value = true;
    subcategories.clear();
    subcategoryErrorMessage.value = '';

    try {
      debugPrint('🔄 Fetching subcategories for category: $categoryId (no auth)');

      // Use the correct URL format
      final String url = AppUrl.allSubCategory(categoryId);
      debugPrint('📍 URL: $url');

      final NetworkResponse response = await _networkCaller.getRequest(url);

      debugPrint('✅ Response received');
      debugPrint('📊 Success: ${response.isSuccess}');
      debugPrint('📄 Status Code: ${response.statusCode}');
      debugPrint('📦 Response body: ${response.jsonResponse}');

      // Check if response is valid
      if (!_validateResponseStructure(response, apiName: 'Subcategories')) {
        subcategoryErrorMessage.value = 'Server returned invalid data format. Please try again.';
        debugPrint('❌ Invalid response structure for subcategories');
        return;
      }

      try {
        // Safely parse the JSON
        final responseData = _parseJsonSafely(response.jsonResponse);
        if (responseData == null) {
          subcategoryErrorMessage.value = 'Failed to process server response';
          debugPrint('❌ Failed to parse JSON response');
          return;
        }

        // Check if request was successful
        if (responseData['success'] != true) {
          subcategoryErrorMessage.value = responseData['message']?.toString() ?? 'Failed to load subcategories';
          debugPrint('❌ API returned error: ${responseData['message']}');
          return;
        }

        // Handle the data structure - based on your JSON example
        if (responseData['data'] != null) {
          final subCatData = responseData['data'];

          // Check if data is a List
          if (subCatData is List) {
            // Direct list structure: {"success": true, "data": [...]}
            final List<dynamic> subCatList = subCatData;

            subcategories.value = subCatList.map((item) {
              return {
                '_id': item['_id']?.toString() ?? '',
                'name': item['name']?.toString() ?? 'Unnamed',
                'description': item['description']?.toString() ?? '',
                'image': item['image']?.toString() ?? '',
              };
            }).toList();

            debugPrint('✨ Subcategories loaded (direct list): ${subcategories.length} items');
          }
          // Check if data has nested data field
          else if (subCatData is Map && subCatData['data'] != null && subCatData['data'] is List) {
            // Nested structure: {"success": true, "data": {"data": [...]}}
            final List<dynamic> subCatList = subCatData['data'];

            subcategories.value = subCatList.map((item) {
              return {
                '_id': item['_id']?.toString() ?? '',
                'name': item['name']?.toString() ?? 'Unnamed',
                'description': item['description']?.toString() ?? '',
                'image': item['image']?.toString() ?? '',
              };
            }).toList();

            debugPrint('✨ Subcategories loaded (nested structure): ${subcategories.length} items');
          }
          else {
            subcategoryErrorMessage.value = 'Invalid subcategory data format';
            debugPrint('❌ Unexpected data structure: $subCatData');
          }
        } else {
          subcategoryErrorMessage.value = 'No data found in response';
          debugPrint('❌ No data field in response');
        }
      } catch (parseError, stackTrace) {
        subcategoryErrorMessage.value = 'Failed to process subcategories data';
        debugPrint('💥 Parse error: $parseError');
        debugPrint('📚 Stack trace: $stackTrace');
      }
    } catch (e, stackTrace) {
      if (e is FormatException) {
        subcategoryErrorMessage.value = 'Data format error. Please try again.';
        debugPrint('💥 FormatException: ${e.message}');
      } else {
        subcategoryErrorMessage.value = 'Network error. Please try again.';
        debugPrint('💥 Exception caught: $e');
      }
      debugPrint('📚 Stack trace: $stackTrace');
    } finally {
      isLoadingSubcategories.value = false;
      debugPrint('🏁 Subcategory loading finished. Total: ${subcategories.length}');
    }
  }













  /// Retry fetching categories
  void retry() {
    errorMessage.value = '';
    fetchCategories();
  }

  /// Retry fetching subcategories
  void retrySubcategories(String categoryId) {
    subcategoryErrorMessage.value = '';
    fetchSubcategories(categoryId);
  }

  /// Retry fetching advertisements
  void retryAds() {
    adsErrorMessage.value = '';
    fetchAdvertisements();
  }

  /// Clear subcategories
  void clearSubcategories() {
    subcategories.clear();
    subcategoryErrorMessage.value = '';
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    // Clear errors before refreshing
    errorMessage.value = '';
    adsErrorMessage.value = '';
    subcategoryErrorMessage.value = '';
    currentPage.value = 0; // Reset to first page on refresh

    // Reset page controller to first page
    pageController.jumpToPage(0);

    await Future.wait([
      fetchCategories(),
      fetchAdvertisements(),
    ]);
  }

  @override
  void onInit() {
    super.onInit();
    SocketServices().init();
    fetchCategories();
    fetchAdvertisements(); // Fetch ads on init
  }

  @override
  void onClose() {
    // Dispose the page controller to prevent memory leaks
    pageController.dispose();
    super.onClose();
  }

  @override
  void dispose() {
    // Note: onClose is preferred over dispose in GetX for cleanup
    categories.clear();
    subcategories.clear();
    advertisements.clear();
    super.dispose();
  }
}