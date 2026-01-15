import 'package:flutter/cupertino.dart' as developer show debugPrint;
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
  final RxBool isRetrying = false.obs;

  // Error message
  final RxString errorMessage = ''.obs;

  // Store category info
  final RxString categoryId = ''.obs;
  final RxString categoryName = ''.obs;

  // Track retry attempts
  int retryCount = 0;
  final int maxRetries = 3;

  @override
  void onInit() {
    super.onInit();
    developer.debugPrint('🔄 SubCategoriesController onInit() called');
    _initializeWithArguments();
  }

  @override
  void onReady() {
    super.onReady();
    developer.debugPrint('✅ SubCategoriesController onReady() called');
  }

  void _initializeWithArguments() {
    final dynamic args = Get.arguments;

    developer.debugPrint('🔍 Received arguments type: ${args.runtimeType}');
    developer.debugPrint('🔍 Arguments value: $args');

    if (args != null && args is Map<String, dynamic>) {
      _processArguments(args);
    } else {
      errorMessage.value = 'No category data provided';
      developer.debugPrint('❌ No arguments received or invalid format');
    }
  }

  void _processArguments(Map<String, dynamic> args) {
    final String newCategoryId = args['categoryId']?.toString() ?? '';
    final String newCategoryName = args['categoryName']?.toString() ?? '';

    // Check if this is a different category than what we're currently showing
    final bool isDifferentCategory = categoryId.value != newCategoryId;

    developer.debugPrint('📊 Processing arguments for category:');
    developer.debugPrint('   - Current Category ID: ${categoryId.value}');
    developer.debugPrint('   - New Category ID: $newCategoryId');
    developer.debugPrint('   - Current Category Name: ${categoryName.value}');
    developer.debugPrint('   - New Category Name: $newCategoryName');
    developer.debugPrint('   - Is Different Category: $isDifferentCategory');

    // Always update the stored values
    categoryId.value = newCategoryId;
    categoryName.value = newCategoryName;

    developer.debugPrint('📌 Updated to Category: ${categoryName.value}');
    developer.debugPrint('📌 Category ID: ${categoryId.value}');

    if (categoryId.value.isNotEmpty) {
      // Reset retry count for new category
      retryCount = 0;

      // Always fetch subcategories when category changes
      if (isDifferentCategory) {
        developer.debugPrint('🔄 Category changed, fetching new subcategories...');
        fetchSubCategories();
      } else if (subCategories.isEmpty) {
        developer.debugPrint('🔄 Same category but no data, fetching subcategories...');
        fetchSubCategories();
      } else {
        developer.debugPrint('⏭️ Same category with existing data, skipping fetch');
      }
    } else {
      errorMessage.value = 'Invalid category ID';
      developer.debugPrint('❌ Category ID is empty');
    }
  }

  /// Public method to refresh with new category
  void refreshWithNewCategory(String newCategoryId, String newCategoryName) {
    developer.debugPrint('🎯 Refreshing with new category: $newCategoryName ($newCategoryId)');

    // Reset retry count
    retryCount = 0;

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
    if (isLoadingSubCategories.value && !isRetrying.value) {
      developer.debugPrint('⏳ Already loading subcategories, skipping duplicate call');
      return;
    }

    isLoadingSubCategories.value = true;
    errorMessage.value = '';
    isRetrying.value = retryCount > 0;

    try {
      developer.debugPrint('🔄 Starting subcategory fetch...');
      developer.debugPrint('📍 Category ID: ${categoryId.value}');
      developer.debugPrint('📍 Category Name: ${categoryName.value}');
      developer.debugPrint('📍 Retry attempt: ${retryCount + 1}/$maxRetries');

      final String url = AppUrl.getSubCategoriesUrl(categoryId.value);
      developer.debugPrint('📍 URL: $url');

      final NetworkResponse response = await _networkCaller.getRequest(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
      );

      developer.debugPrint('✅ Response received');
      developer.debugPrint('📊 Success: ${response.isSuccess}');
      developer.debugPrint('📄 Status Code: ${response.statusCode}');
      developer.debugPrint('📄 Response Body: ${response.jsonResponse}');
      // developer.debugPrint('📄 Raw Response: ${response.responseString}');

      // Handle specific HTTP status codes
      if (response.statusCode == 502) {
        errorMessage.value = 'Server is temporarily unavailable (502 Bad Gateway).\nPlease try again in a moment.';
        developer.debugPrint('❌ 502 Bad Gateway error');

        // Auto-retry after delay if we haven't exceeded max retries
        if (retryCount < maxRetries) {
          retryCount++;
          developer.debugPrint('⏰ Auto-retry scheduled (attempt $retryCount)');

          // Delay before retry (2 seconds for first retry, longer for subsequent)
          final int delaySeconds = retryCount * 2;
          Future.delayed(Duration(seconds: delaySeconds), () {
            if (categoryId.value == categoryId.value) { // Still same category
              developer.debugPrint('🔄 Auto-retrying...');
              fetchSubCategories();
            }
          });
        }
        return;
      }

      if (response.statusCode == 404) {
        errorMessage.value = 'Category not found (404).\nPlease go back and try another category.';
        developer.debugPrint('❌ 404 Not Found error');
        return;
      }

      if (response.statusCode == 500) {
        errorMessage.value = 'Internal server error (500).\nPlease try again later.';
        developer.debugPrint('❌ 500 Internal Server Error');
        return;
      }

      if (response.isSuccess && response.jsonResponse != null) {
        try {
          // Reset retry count on success
          retryCount = 0;

          // Check response structure
          final Map<String, dynamic> responseData = response.jsonResponse!;

          if (responseData['success'] == true) {
            if (responseData['data'] != null) {
              final List<dynamic> dataList = responseData['data'] is List
                  ? responseData['data']
                  : [];

              if (dataList.isNotEmpty) {
                subCategories.value = dataList
                    .map((json) => SubCategoryModel.fromJson(json as Map<String, dynamic>))
                    .toList();

                developer.debugPrint('✨ SubCategories loaded successfully: ${subCategories.length} items');

                for (var subCategory in subCategories) {
                  developer.debugPrint('   📁 ${subCategory.name} - ${subCategory.categoryId}');
                }
              } else {
                errorMessage.value = 'No subcategories available for this category';
                developer.debugPrint('⚠️ No subcategories found in data array');
              }
            } else {
              errorMessage.value = 'Invalid response format from server';
              developer.debugPrint('⚠️ No data field in response');
            }
          } else {
            errorMessage.value = responseData['message']?.toString() ??
                'Failed to load subcategories';
            developer.debugPrint('⚠️ API returned success: false');
          }
        } catch (parseError, stackTrace) {
          errorMessage.value = 'Error parsing server response';
          developer.debugPrint('💥 Parse error: $parseError');
          developer.debugPrint('💥 Stack trace: $stackTrace');
          developer.debugPrint('💥 Raw response: ${response.jsonResponse}');
        }
      } else {
        // Handle other errors
        if (response.errorMessage?.contains('SocketException') == true ||
            response.errorMessage?.contains('Network is unreachable') == true) {
          errorMessage.value = 'Network connection failed.\nPlease check your internet connection.';
        } else if (response.errorMessage?.contains('FormatException') == true) {
          errorMessage.value = 'Invalid response from server.\nPlease try again.';
        } else {
          errorMessage.value = response.errorMessage ??
              'Failed to load subcategories. Status: ${response.statusCode}';
        }
        developer.debugPrint('⚠️ Error message set: ${errorMessage.value}');
      }
    } catch (e, stackTrace) {
      errorMessage.value = 'Unexpected error occurred';
      developer.debugPrint('💥 Exception caught: $e');
      developer.debugPrint('📚 Stack trace: $stackTrace');
    } finally {
      isLoadingSubCategories.value = false;
      isRetrying.value = false;
      developer.debugPrint('🏁 Loading finished. Total subcategories: ${subCategories.length}');
      developer.debugPrint('🏁 Error message: ${errorMessage.value}');
    }
  }

  /// Manual retry for user
  Future<void> retry() async {
    if (categoryId.value.isNotEmpty && retryCount < maxRetries) {
      developer.debugPrint('🔄 Manual retry initiated by user');
      retryCount++;
      await fetchSubCategories();
    } else if (retryCount >= maxRetries) {
      errorMessage.value = 'Too many failed attempts.\nPlease go back and try again.';
      developer.debugPrint('🚫 Max retries exceeded');
    }
  }

  /// Clear all data
  void clearData() {
    subCategories.clear();
    errorMessage.value = '';
    categoryId.value = '';
    categoryName.value = '';
    isLoadingSubCategories.value = false;
    isRetrying.value = false;
    retryCount = 0;
  }

  @override
  void onClose() {
    developer.debugPrint('👋 SubCategoriesController onClose() called');
    clearData();
    super.onClose();
  }
}