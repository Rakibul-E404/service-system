import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/network/network_response.dart';
import '../../../core/utils/api/app_url.dart';
import '../../../core/utils/token_service/token_storage_service.dart';
import '../model/categor_model.dart';

class HomeController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();
  final SharedPrefService _sharedPrefService = SharedPrefService();

  // Observable lists
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;

  // Loading states
  final RxBool isLoadingCategories = false.obs;

  // Error message
  final RxString errorMessage = ''.obs;



  final RxList<dynamic> subcategories = <dynamic>[].obs; // Replace with your SubCategoryModel
  final RxBool isLoadingSubcategories = false.obs;

  /// Fetch subcategories for a specific category
  Future<void> fetchSubcategories(String categoryId) async {
    isLoadingSubcategories.value = true;
    subcategories.clear();

    try {
      debugPrint('🔄 Fetching subcategories for category: $categoryId');

      final String? accessToken = await _sharedPrefService.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        debugPrint('❌ No access token found');
        return;
      }

      // Update this URL to your subcategory endpoint
      final String url = '${AppUrl.baseUrl}/subcategories/$categoryId'; // Adjust as needed

      final NetworkResponse response = await _networkCaller.getRequest(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.isSuccess && response.jsonResponse != null) {
        // Parse subcategories based on your response structure
        // Example:
        // final List<dynamic> data = response.jsonResponse!['data'];
        // subcategories.value = data.map((json) => SubCategoryModel.fromJson(json)).toList();

        debugPrint('✨ Subcategories loaded: ${subcategories.length} items');
      } else {
        debugPrint('⚠️ Failed to fetch subcategories');
      }
    } catch (e) {
      debugPrint('💥 Exception fetching subcategories: $e');
    } finally {
      isLoadingSubcategories.value = false;
    }
  }



  /// Fetch all categories from API
  Future<void> fetchCategories() async {
    isLoadingCategories.value = true;
    errorMessage.value = '';

    try {
      debugPrint('🔄 Starting category fetch...');
      debugPrint('📍 URL: ${AppUrl.allCategory}');

      // Fetch the Bearer token dynamically from SharedPreferences
      final String? accessToken = await _sharedPrefService.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        errorMessage.value = 'No access token available';
        debugPrint('❌ No access token found');
        return;
      }

      debugPrint('🔑 Using Authorization Token: ${accessToken.substring(0, 20)}...');

      final NetworkResponse response = await _networkCaller.getRequest(
        AppUrl.allCategory,
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
        },
      );

      debugPrint('✅ Response received');
      debugPrint('📊 Success: ${response.isSuccess}');
      debugPrint('📄 Status Code: ${response.statusCode}');
      debugPrint('📦 JSON Response: ${response.jsonResponse}');

      // Additional debugging for nested data structure
      if (response.jsonResponse != null && response.jsonResponse!['data'] != null) {
        var outerData = response.jsonResponse!['data'];
        debugPrint('📦 Outer Data Type: ${outerData.runtimeType}');

        if (outerData is Map<String, dynamic> && outerData['data'] != null) {
          debugPrint('📦 Inner Data Type: ${outerData['data'].runtimeType}');
          debugPrint('📦 Inner Data Length: ${outerData['data'] is List ? (outerData['data'] as List).length : 0}');
        }
      }

      if (response.isSuccess && response.jsonResponse != null) {
        try {
          final CategoryResponse categoryResponse = CategoryResponse.fromJson(response.jsonResponse!);
          categories.value = categoryResponse.categories;
          debugPrint('✨ Categories loaded successfully: ${categories.length} items');

          // Print each category for debugging
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

  /// [onInit] Lifecycle method called when the controller is initialized.
  /// Resets loading states, clears existing data, and triggers initial fetch
  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  /// [dispose] Lifecycle method called when the controller is destroyed.
  /// Cleans up by resetting loading states and clearing lists
  @override
  void dispose() {
    categories.clear();
    super.dispose();
  }
}