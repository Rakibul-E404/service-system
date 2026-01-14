import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/network/network_response.dart';
import '../../../core/utils/api/app_url.dart';
import '../model/sub_category_model.dart';

class SubCategoriesController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();

  // Observable lists
  final RxList<SubCategoryModel> subCategories = <SubCategoryModel>[].obs;

  // Loading states
  final RxBool isLoadingSubCategories = false.obs;

  // Error message
  final RxString errorMessage = ''.obs;

  // Store category info
  final RxString categoryId = ''.obs;
  final RxString categoryName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('🔄 SubCategoriesController onInit() called');
    _initializeWithArguments();
  }

  @override
  void onReady() {
    super.onReady();
    debugPrint('✅ SubCategoriesController onReady() called');
  }

  void _initializeWithArguments() {
    final dynamic args = Get.arguments;

    debugPrint('🔍 Received arguments type: ${args.runtimeType}');
    debugPrint('🔍 Arguments value: $args');

    if (args != null && args is Map<String, dynamic>) {
      _processArguments(args);
    } else {
      errorMessage.value = 'No category data provided';
      debugPrint('❌ No arguments received or invalid format');
    }
  }

  void _processArguments(Map<String, dynamic> args) {
    final String newCategoryId = args['categoryId']?.toString() ?? '';
    final String newCategoryName = args['categoryName']?.toString() ?? '';

    // Check if this is a different category than what we're currently showing
    final bool isDifferentCategory = categoryId.value != newCategoryId;

    debugPrint('📊 Processing arguments for category:');
    debugPrint('   - Current Category ID: ${categoryId.value}');
    debugPrint('   - New Category ID: $newCategoryId');
    debugPrint('   - Current Category Name: ${categoryName.value}');
    debugPrint('   - New Category Name: $newCategoryName');
    debugPrint('   - Is Different Category: $isDifferentCategory');

    // Always update the stored values
    categoryId.value = newCategoryId;
    categoryName.value = newCategoryName;

    debugPrint('📌 Updated to Category: ${categoryName.value}');
    debugPrint('📌 Category ID: ${categoryId.value}');

    if (categoryId.value.isNotEmpty) {
      // Always fetch subcategories when category changes
      if (isDifferentCategory) {
        debugPrint('🔄 Category changed, fetching new subcategories...');
        fetchSubCategories();
      } else if (subCategories.isEmpty) {
        debugPrint('🔄 Same category but no data, fetching subcategories...');
        fetchSubCategories();
      } else {
        debugPrint('⏭️ Same category with existing data, skipping fetch');
      }
    } else {
      errorMessage.value = 'Invalid category ID';
      debugPrint('❌ Category ID is empty');
    }
  }

  /// Public method to refresh with new category
  void refreshWithNewCategory(String newCategoryId, String newCategoryName) {
    debugPrint('🎯 Refreshing with new category: $newCategoryName ($newCategoryId)');

    // Clear previous data
    subCategories.clear();
    errorMessage.value = '';

    // Update category info
    categoryId.value = newCategoryId;
    categoryName.value = newCategoryName;

    // Fetch new subcategories
    fetchSubCategories();
  }

  /// Fetch subcategories for the given category ID
  Future<void> fetchSubCategories() async {
    // Prevent duplicate calls
    if (isLoadingSubCategories.value) {
      debugPrint('⏳ Already loading subcategories, skipping duplicate call');
      return;
    }

    isLoadingSubCategories.value = true;
    errorMessage.value = '';

    // Clear existing subcategories
    subCategories.clear();

    try {
      debugPrint('🔄 Starting subcategory fetch...');
      debugPrint('📍 Category ID: ${categoryId.value}');
      debugPrint('📍 Category Name: ${categoryName.value}');

      final String url = AppUrl.getSubCategoriesUrl(categoryId.value);
      debugPrint('📍 URL: $url');

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
          final SubCategoryResponse subCategoryResponse =
          SubCategoryResponse.fromJson(response.jsonResponse!);
          subCategories.value = subCategoryResponse.subCategories;
          debugPrint('✨ SubCategories loaded successfully: ${subCategories.length} items');

          for (var subCategory in subCategories) {
            debugPrint('   📁 ${subCategory.name} - ${subCategory.categoryId}');
          }

          if (subCategories.isEmpty) {
            errorMessage.value = 'No subcategories found for this category';
            debugPrint('⚠️ No subcategories found');
          }
        } catch (parseError) {
          errorMessage.value = 'Failed to parse subcategories';
          debugPrint('💥 Parse error: $parseError');
          debugPrint('💥 Response data: ${response.jsonResponse}');
        }
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to fetch subcategories';
        debugPrint('⚠️ Error message set: ${errorMessage.value}');
      }
    } catch (e, stackTrace) {
      errorMessage.value = 'Error: ${e.toString()}';
      debugPrint('💥 Exception caught: $e');
      debugPrint('📚 Stack trace: $stackTrace');
    } finally {
      isLoadingSubCategories.value = false;
      debugPrint('🏁 Loading finished. Total subcategories: ${subCategories.length}');
    }
  }

  /// Retry fetching subcategories
  void retry() {
    if (categoryId.value.isNotEmpty) {
      fetchSubCategories();
    }
  }

  /// Clear all data
  void clearData() {
    subCategories.clear();
    errorMessage.value = '';
    categoryId.value = '';
    categoryName.value = '';
    isLoadingSubCategories.value = false;
  }

  @override
  void onClose() {
    debugPrint('👋 SubCategoriesController onClose() called');
    clearData();
    super.onClose();
  }
}