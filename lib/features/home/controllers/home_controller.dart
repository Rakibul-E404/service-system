import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/network/network_response.dart';
import '../../../core/utils/api/app_url.dart';
import '../model/categor_model.dart';

class HomeController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();

  // Bearer token
  static const String bearerToken = 'adminAccessToken';

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
      debugPrint('🔑 Using Authorization Token');

      final NetworkResponse response = await _networkCaller.getRequest(
        AppUrl.allCategory,
        headers: <String, String>{
          'Authorization':
              'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2OGM1M2VlYTNlOThmY2UzZjM5ZjQ3YTEiLCJpYXQiOjE3NjA1MjgwODAsImV4cCI6MzUyMTA1Njc2MCwidHlwZSI6ImFjY2VzcyJ9.h5UcEyLYakOFkuof0dM7fBG5fmChnpGNxaisFxmpnMA',
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
  ///
  /// Resets loading states, clears existing data, and triggers initial fetch
  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  /// [dispose] Lifecycle method called when the controller is destroyed.
  ///
  /// Cleans up by resetting loading states and clearing lists
  @override
  void dispose() {
    categories.clear();
    super.dispose();
  }
}



