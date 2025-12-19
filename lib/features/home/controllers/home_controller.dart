/**

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:manx_mate/core/service/socket_service.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/network/network_response.dart';
import '../../../core/utils/api/app_url.dart';
import '../model/categor_model.dart';

class HomeController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();

  // Observable lists
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<dynamic> subcategories = <dynamic>[].obs;
  final RxList<Map<String, dynamic>> advertisements = <Map<String, dynamic>>[].obs;

  // Loading states
  final RxBool isLoadingCategories = false.obs;
  final RxBool isLoadingSubcategories = false.obs;
  final RxBool isLoadingAds = false.obs;

  // Error messages
  final RxString errorMessage = ''.obs;
  final RxString subcategoryErrorMessage = ''.obs;
  final RxString adsErrorMessage = ''.obs;

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
      debugPrint('📦 JSON Response: ${response.jsonResponse}');

      if (response.isSuccess && response.jsonResponse != null) {
        try {
          final responseData = response.jsonResponse!;

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
                    ? 'https://d7001.sobhoy.com/${ad['image']}'
                    : null,
                'profile': ad['profile']?.toString() ?? '',
              };
            }).toList();

            debugPrint('✨ Advertisements loaded successfully: ${advertisements.length} items');

            for (var ad in advertisements) {
              debugPrint('   📢 ${ad['title']} - ${ad['image']}');
            }

            if (advertisements.isEmpty) {
              adsErrorMessage.value = 'No advertisements available';
            }
          } else {
            adsErrorMessage.value = 'Invalid response structure';
            debugPrint('❌ Response missing data.data structure');
          }
        } catch (parseError, stackTrace) {
          adsErrorMessage.value = 'Failed to parse advertisements';
          debugPrint('💥 Parse error: $parseError');
          debugPrint('📚 Stack trace: $stackTrace');
        }
      } else {
        adsErrorMessage.value = response.errorMessage ?? 'Failed to fetch advertisements';
        debugPrint('⚠️ Error message: ${adsErrorMessage.value}');
      }
    } catch (e, stackTrace) {
      adsErrorMessage.value = 'Error: ${e.toString()}';
      debugPrint('💥 Exception caught: $e');
      debugPrint('📚 Stack trace: $stackTrace');
    } finally {
      isLoadingAds.value = false;
      debugPrint('🏁 Ads loading finished. Total: ${advertisements.length}');
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
      debugPrint('📍 URL: ${AppUrl.baseUrl}/category/$categoryId/subcategories');

      final String url = '${AppUrl.baseUrl}/category/$categoryId/subcategories';

      final NetworkResponse response = await _networkCaller.getRequest(
        url,
        // No headers - no authentication required
      );

      debugPrint('✅ Response received');
      debugPrint('📊 Success: ${response.isSuccess}');
      debugPrint('📄 Status Code: ${response.statusCode}');
      debugPrint('📦 JSON Response: ${response.jsonResponse}');

      if (response.isSuccess && response.jsonResponse != null) {
        try {
          final responseData = response.jsonResponse!;

          if (responseData['data'] != null &&
              responseData['data']['data'] != null) {

            final List<dynamic> subCatList = responseData['data']['data'];

            subcategories.value = subCatList.map((item) {
              return {
                '_id': item['_id']?.toString() ?? '',
                'name': item['name']?.toString() ?? 'Unnamed',
                'description': item['description']?.toString() ?? '',
                'image': item['image']?.toString() ?? '',
              };
            }).toList();

            debugPrint('✨ Subcategories loaded successfully: ${subcategories.length} items');

            for (var subcat in subcategories) {
              debugPrint('   📁 ${subcat['name']} (${subcat['_id']})');
            }

            if (subcategories.isEmpty) {
              subcategoryErrorMessage.value = 'No subcategories available for this category';
            }
          } else {
            subcategoryErrorMessage.value = 'Invalid response structure';
            debugPrint('❌ Response missing data.data structure');
          }
        } catch (parseError, stackTrace) {
          subcategoryErrorMessage.value = 'Failed to parse subcategories';
          debugPrint('💥 Parse error: $parseError');
          debugPrint('📚 Stack trace: $stackTrace');
        }
      } else {
        subcategoryErrorMessage.value =
            response.errorMessage ?? 'Failed to fetch subcategories';
        debugPrint('⚠️ Error message set: ${subcategoryErrorMessage.value}');
      }
    } catch (e, stackTrace) {
      subcategoryErrorMessage.value = 'Error: ${e.toString()}';
      debugPrint('💥 Exception caught: $e');
      debugPrint('📚 Stack trace: $stackTrace');
    } finally {
      isLoadingSubcategories.value = false;
      debugPrint('🏁 Subcategory loading finished. Total: ${subcategories.length}');
    }
  }

  /// Fetch all categories from API (without auth)
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
      debugPrint('📦 JSON Response: ${response.jsonResponse}');

      if (response.isSuccess && response.jsonResponse != null) {
        try {
          final CategoryResponse categoryResponse =
          CategoryResponse.fromJson(response.jsonResponse!);
          categories.value = categoryResponse.categories;
          debugPrint('✨ Categories loaded successfully: ${categories.length} items');

          for (var category in categories) {
            debugPrint('   📁 ${category.name} (${category.id}) - ${category.fullImageUrl}');
          }

          if (categories.isEmpty) {
            errorMessage.value = 'No categories available';
          }
        } catch (parseError, stackTrace) {
          errorMessage.value = 'Failed to parse categories';
          debugPrint('💥 Parse error: $parseError');
          debugPrint('📚 Stack trace: $stackTrace');
        }
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to fetch categories';
        debugPrint('⚠️ Error message set: ${errorMessage.value}');
      }
    } catch (e, stackTrace) {
      errorMessage.value = 'Error: ${e.toString()}';
      debugPrint('💥 Exception caught: $e');
      debugPrint('📚 Stack trace: $stackTrace');
    } finally {
      isLoadingCategories.value = false;
      debugPrint('🏁 Loading finished. Total categories: ${categories.length}');
    }
  }

  /// Retry fetching categories
  void retry() {
    fetchCategories();
  }

  /// Retry fetching subcategories
  void retrySubcategories(String categoryId) {
    fetchSubcategories(categoryId);
  }

  /// Retry fetching advertisements
  void retryAds() {
    fetchAdvertisements();
  }

  /// Clear subcategories
  void clearSubcategories() {
    subcategories.clear();
    subcategoryErrorMessage.value = '';
  }

  /// Refresh all data
  Future<void> refreshAll() async {
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
  void dispose() {
    categories.clear();
    subcategories.clear();
    advertisements.clear();
    super.dispose();
  }
}

*/








///
///
///
///
/// todo:: adding fix for json parsing error
///
///
///
///





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

  // Observable lists
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<dynamic> subcategories = <dynamic>[].obs;
  final RxList<Map<String, dynamic>> advertisements = <Map<String, dynamic>>[].obs;

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
                  ? 'https://d7001.sobhoy.com/${ad['image']}'
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
      debugPrint('📍 URL: ${AppUrl.baseUrl}/category/$categoryId/subcategories');

      final String url = '${AppUrl.baseUrl}/category/$categoryId/subcategories';
      final NetworkResponse response = await _networkCaller.getRequest(url);

      debugPrint('✅ Response received');
      debugPrint('📊 Success: ${response.isSuccess}');
      debugPrint('📄 Status Code: ${response.statusCode}');

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
          return;
        }

        if (responseData['data'] != null &&
            responseData['data']['data'] != null) {

          final List<dynamic> subCatList = responseData['data']['data'];

          subcategories.value = subCatList.map((item) {
            return {
              '_id': item['_id']?.toString() ?? '',
              'name': item['name']?.toString() ?? 'Unnamed',
              'description': item['description']?.toString() ?? '',
              'image': item['image']?.toString() ?? '',
            };
          }).toList();

          debugPrint('✨ Subcategories loaded successfully: ${subcategories.length} items');

          if (subcategories.isEmpty) {
            subcategoryErrorMessage.value = 'No subcategories available for this category';
          }
        } else {
          subcategoryErrorMessage.value = 'Invalid subcategory data format';
          debugPrint('❌ Response missing data.data structure');
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
  void dispose() {
    categories.clear();
    subcategories.clear();
    advertisements.clear();
    super.dispose();
  }
}