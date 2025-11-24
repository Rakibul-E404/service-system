



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
  _initializeWithArguments();
 }

 void _initializeWithArguments() {
  final dynamic args = Get.arguments;

  debugPrint('🔍 Received arguments type: ${args.runtimeType}');
  debugPrint('🔍 Arguments value: $args');

  if (args != null && args is Map<String, dynamic>) {
   categoryId.value = args['categoryId']?.toString() ?? '';
   categoryName.value = args['categoryName']?.toString() ?? '';

   debugPrint('📌 Initialized with Category: ${categoryName.value}');
   debugPrint('📌 Category ID: ${categoryId.value}');

   if (categoryId.value.isNotEmpty) {
    fetchSubCategories();
   } else {
    errorMessage.value = 'Invalid category ID';
    debugPrint('❌ Category ID is empty');
   }
  } else {
   errorMessage.value = 'No category data provided';
   debugPrint('❌ No arguments received or invalid format');
  }
 }

 /// Fetch subcategories for the given category ID (No authentication required)
 Future<void> fetchSubCategories() async {
  isLoadingSubCategories.value = true;
  errorMessage.value = '';
  subCategories.clear();

  try {
   debugPrint('🔄 Starting subcategory fetch...');
   debugPrint('📍 Category ID: ${categoryId.value}');

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
      debugPrint('   📁 ${subCategory.name} - ${subCategory.fullImageUrl}');
     }

     if (subCategories.isEmpty) {
      errorMessage.value = 'No subcategories found for this category';
     }
    } catch (parseError) {
     errorMessage.value = 'Failed to parse subcategories';
     debugPrint('💥 Parse error: $parseError');
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

 @override
 void dispose() {
  subCategories.clear();
  super.dispose();
 }
}

