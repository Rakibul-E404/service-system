import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/network/network_response.dart';
import '../../../core/utils/api/app_url.dart';
import '../../../core/utils/token_service/token_storage_service.dart';
import '../model/categor_model.dart';

class HomeController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();
  final SharedPrefService _sharedPrefService = SharedPrefService(); // Instantiate SharedPrefService

  // Observable lists
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;

  // Loading states
  final RxBool isLoadingCategories = false.obs;

  // Error message
  final RxString errorMessage = ''.obs;

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
          'Authorization': 'Bearer $accessToken',  // Use the dynamic token
        },
      );

      debugPrint('✅ Response received');
      debugPrint('📊 Success: ${response.isSuccess}');
      debugPrint('📄 Status Code: ${response.statusCode}');
      debugPrint('📦 JSON Response: ${response.jsonResponse}');
      debugPrint('❌ Error Message: ${response.errorMessage}');

      if (response.isSuccess && response.jsonResponse != null) {
        final CategoryResponse categoryResponse = CategoryResponse.fromJson(response.jsonResponse!);
        categories.value = categoryResponse.categories;
        debugPrint('✨ Categories loaded successfully: ${categories.length} items');

        // Print each category for debugging
        for (var category in categories) {
          debugPrint('   📁 ${category.name} - ${category.fullImageUrl}');
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
