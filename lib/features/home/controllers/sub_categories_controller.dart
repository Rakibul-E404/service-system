/**

import 'package:get/get.dart';

class SubCategoriesController extends GetxController {
 }

 */





import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/network/network_response.dart';
import '../../../core/utils/api/app_url.dart';
import '../../../core/utils/token_service/token_storage_service.dart';
import '../model/sub_category_model.dart';

class SubCategoriesController extends GetxController {
 final NetworkCaller _networkCaller = NetworkCaller();
 final SharedPrefService _sharedPrefService = SharedPrefService();

 // Observable lists
 final RxList<SubCategoryModel> subCategories = <SubCategoryModel>[].obs;

 // Loading states
 final RxBool isLoadingSubCategories = false.obs;

 // Error message
 final RxString errorMessage = ''.obs;

 // Store category info
 final RxString categoryId = ''.obs;
 final RxString categoryName = ''.obs;

 /// Initialize with category data from arguments
 @override
 void onInit() {
  super.onInit();

  // Get arguments passed from previous screen
  final Map<String, dynamic>? args = Get.arguments as Map<String, dynamic>?;

  if (args != null) {
   categoryId.value = args['categoryId'] ?? '';
   categoryName.value = args['categoryName'] ?? '';

   debugPrint('📌 Initialized with Category: ${categoryName.value}');
   debugPrint('📌 Category ID: ${categoryId.value}');

   // Fetch subcategories
   if (categoryId.value.isNotEmpty) {
    fetchSubCategories();
   } else {
    errorMessage.value = 'Invalid category ID';
   }
  } else {
   errorMessage.value = 'No category data provided';
   debugPrint('❌ No arguments received');
  }
 }

 /// Fetch subcategories for the given category ID
 Future<void> fetchSubCategories() async {
  isLoadingSubCategories.value = true;
  errorMessage.value = '';
  subCategories.clear();

  try {
   debugPrint('🔄 Starting subcategory fetch...');
   debugPrint('📍 Category ID: ${categoryId.value}');

   // Get the URL for subcategories
   final String url = AppUrl.getSubCategoriesUrl(categoryId.value);
   debugPrint('📍 URL: $url');

   // Fetch the Bearer token
   final String? accessToken = await _sharedPrefService.getAccessToken();

   if (accessToken == null || accessToken.isEmpty) {
    errorMessage.value = 'No access token available';
    debugPrint('❌ No access token found');
    return;
   }

   debugPrint('🔑 Using Authorization Token: ${accessToken.substring(0, 20)}...');

   final NetworkResponse response = await _networkCaller.getRequest(
    url,
    headers: <String, String>{
     'Authorization': 'Bearer $accessToken',
    },
   );

   debugPrint('✅ Response received');
   debugPrint('📊 Success: ${response.isSuccess}');
   debugPrint('📄 Status Code: ${response.statusCode}');
   debugPrint('📦 JSON Response: ${response.jsonResponse}');

   if (response.isSuccess && response.jsonResponse != null) {
    final SubCategoryResponse subCategoryResponse =
    SubCategoryResponse.fromJson(response.jsonResponse!);
    subCategories.value = subCategoryResponse.subCategories;
    debugPrint('✨ SubCategories loaded successfully: ${subCategories.length} items');

    // Print each subcategory for debugging
    for (var subCategory in subCategories) {
     debugPrint('   📁 ${subCategory.name} - ${subCategory.fullImageUrl}');
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

 /// Refresh subcategories
 Future<void> refreshSubCategories() async {
  await fetchSubCategories();
 }

 @override
 void dispose() {
  subCategories.clear();
  super.dispose();
 }
}