

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/network/network_response.dart';
import '../../../core/utils/api/app_url.dart';
import '../../../core/utils/token_service/token_storage_service.dart';
import '../model/sub_category_model.dart';
import '../model/service_model.dart'; // Add this import

class SubCategoriesController extends GetxController {
 final NetworkCaller _networkCaller = NetworkCaller();
 final SharedPrefService _sharedPrefService = SharedPrefService();

 // Observable lists
 final RxList<SubCategoryModel> subCategories = <SubCategoryModel>[].obs;
 final RxList<ServiceModel> services = <ServiceModel>[].obs; // Add services list

 // Loading states
 final RxBool isLoadingSubCategories = false.obs;
 final RxBool isLoadingServices = false.obs; // Add services loading state

 // Error message
 final RxString errorMessage = ''.obs;
 final RxString servicesErrorMessage = ''.obs; // Separate error for services

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

 /// Fetch subcategories for the given category ID
 Future<void> fetchSubCategories() async {
  isLoadingSubCategories.value = true;
  errorMessage.value = '';
  subCategories.clear();

  try {
   debugPrint('🔄 Starting subcategory fetch...');
   debugPrint('📍 Category ID: ${categoryId.value}');

   final String url = AppUrl.getSubCategoriesUrl(categoryId.value);
   debugPrint('📍 URL: $url');

   final String? accessToken = await _sharedPrefService.getAccessToken();

   if (accessToken == null || accessToken.isEmpty) {
    errorMessage.value = 'No access token available';
    debugPrint('❌ No access token found');
    return;
   }

   final NetworkResponse response = await _networkCaller.getRequest(
    url,
    headers: <String, String>{
     'Authorization': 'Bearer $accessToken',
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

 /// Fetch services for a specific subcategory

// In your SubCategoriesController - update the fetchServicesBySubCategory method
/* Future<void> fetchServicesBySubCategory(String subCategoryId, String subCategoryName) async {
  debugPrint('🎯 ========== '
      'FETCH SERVICES STARTED '
      '==========');
  debugPrint('-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- subCategoryId: $subCategoryId');
  debugPrint('-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-- subCategoryName: $subCategoryName');

  isLoadingServices.value = true;
  servicesErrorMessage.value = '';
  services.clear();

  try {
   debugPrint('🌐 Making API call...');
   final String url = AppUrl.getServicesBySubCategoryUrl(subCategoryId);
   debugPrint('   - URL: $url');

   final String? accessToken = await _sharedPrefService.getAccessToken();
   debugPrint('   - Access Token: ${accessToken != null ? 'Available (${accessToken.length} chars)' : 'NULL'}');

   if (accessToken == null || accessToken.isEmpty) {
    servicesErrorMessage.value = 'No access token available';
    debugPrint('❌ No access token - stopping fetch');
    isLoadingServices.value = false;
    return;
   }

   final NetworkResponse response = await _networkCaller.getRequest(
    url,
    headers: <String, String>{
     'Authorization': 'Bearer $accessToken',
    },
   );

   debugPrint('📡 API Response Received:');
   debugPrint('======- isSuccess: ${response.isSuccess}');
   debugPrint('======- statusCode: ${response.statusCode}');
   debugPrint('======- Response type: ${response.jsonResponse?.runtimeType}');

   if (response.isSuccess && response.jsonResponse != null) {
    try {
     debugPrint('🔄 Parsing response...');
     final Map<String, dynamic> responseData = response.jsonResponse!;
     debugPrint('   - Top-level keys: ${responseData.keys.toList()}');

     // Check if we have the expected structure
     if (!responseData.containsKey('data')) {
      servicesErrorMessage.value = 'Invalid response format: missing "data" key';
      debugPrint('❌ Missing "data" key in response');
      debugPrint('   - Available keys: ${responseData.keys.toList()}');
      return;
     }

     final dynamic dataField = responseData['data'];
     debugPrint('   - data field type: ${dataField.runtimeType}');

     if (dataField is! Map<String, dynamic>) {
      servicesErrorMessage.value = 'Invalid response format: "data" is not a map';
      debugPrint('❌ "data" field is not a Map');
      return;
     }

     final Map<String, dynamic> data = dataField;
     debugPrint('   - Inner data keys: ${data.keys.toList()}');

     if (!data.containsKey('data')) {
      servicesErrorMessage.value = 'Invalid response format: missing nested "data" key';
      debugPrint('❌ Missing nested "data" key');
      debugPrint('   - Available keys in data: ${data.keys.toList()}');
      return;
     }

     final dynamic servicesDataField = data['data'];
     debugPrint('   - services data field type: ${servicesDataField.runtimeType}');

     if (servicesDataField is! List) {
      servicesErrorMessage.value = 'Invalid response format: services data is not a list';
      debugPrint('❌ Services data is not a List');
      return;
     }

     final List<dynamic> servicesData = servicesDataField;
     debugPrint('   - Services list length: ${servicesData.length}');

     if (servicesData.isEmpty) {
      servicesErrorMessage.value = 'No services found for "$subCategoryName"';
      debugPrint('📭 Empty services list received');
      return;
     }

     final List<ServiceModel> parsedServices = [];
     int successCount = 0;
     int failCount = 0;

     for (int i = 0; i < servicesData.length; i++) {
      debugPrint('🔍 Processing service $i/${servicesData.length}...');

      final dynamic serviceData = servicesData[i];

      if (serviceData is! Map<String, dynamic>) {
       debugPrint('   ⚠️ Service $i is not a Map, skipping');
       failCount++;
       continue;
      }

      try {
       debugPrint('   - Service data: $serviceData');
       final service = ServiceModel.fromJson(serviceData);
       parsedServices.add(service);
       successCount++;
       debugPrint('   ✅ Successfully parsed: ${service.name}');
      } catch (e, stackTrace) {
       failCount++;
       debugPrint('   ❌ Failed to parse service $i: $e');
       debugPrint('   📚 StackTrace: $stackTrace');
       debugPrint('   📄 Problem data: $serviceData');
      }
     }

     debugPrint('📊 Parsing complete:');
     debugPrint('   - Success: $successCount');
     debugPrint('   - Failed: $failCount');
     debugPrint('   - Total parsed: ${parsedServices.length}');

     if (parsedServices.isEmpty) {
      servicesErrorMessage.value = 'Failed to parse any services from the response';
      debugPrint('❌ No services successfully parsed');
     } else {
      // This is the critical line - make sure we're assigning to the observable
      services.value = parsedServices;
      debugPrint('✅ Services assigned to observable list');
      debugPrint('   - services.length: ${services.length}');
      debugPrint('   - services.value.length: ${services.value.length}');

      // Verify assignment worked
      debugPrint('🔍 Verification:');
      for (int i = 0; i < services.length; i++) {
       debugPrint('   $i. ${services[i].name} - ${services[i].location}');
      }
     }

    } catch (parseError, stackTrace) {
     servicesErrorMessage.value = 'Failed to parse response: ${parseError.toString()}';
     debugPrint('💥 Parse Error: $parseError');
     debugPrint('📚 StackTrace: $stackTrace');
    }
   } else {
    servicesErrorMessage.value = response.errorMessage ?? 'Failed to fetch services';
    debugPrint('❌ API request failed');
    debugPrint('   - Status: ${response.statusCode}');
    debugPrint('   - Error: ${response.errorMessage}');
   }
  } catch (e, stackTrace) {
   servicesErrorMessage.value = 'Network error: ${e.toString()}';
   debugPrint('💥 Network Exception: $e');
   debugPrint('📚 StackTrace: $stackTrace');
  } finally {
   isLoadingServices.value = false;
   debugPrint('🏁 ========== FETCH COMPLETED ==========');
   debugPrint('   - isLoadingServices: ${isLoadingServices.value}');
   debugPrint('   - services.length: ${services.length}');
   debugPrint('   - errorMessage: "${servicesErrorMessage.value}"');
   debugPrint('==========================================\n');
  }
 }*/

 Future<void> fetchServicesBySubCategory(String subCategoryId, String subCategoryName) async {
  debugPrint('🎯 ========== FETCH SERVICES STARTED ==========');
  debugPrint('-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- subCategoryId: $subCategoryId');
  debugPrint('-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-- subCategoryName: $subCategoryName');

  isLoadingServices.value = true;
  servicesErrorMessage.value = '';
  services.clear();

  try {
   debugPrint('🌐 Making API call...');
   final String url = AppUrl.getServicesBySubCategoryUrl(subCategoryId);
   debugPrint('   - URL: $url');

   final String? accessToken = await _sharedPrefService.getAccessToken();
   debugPrint('   - Access Token: ${accessToken != null ? 'Available (${accessToken.length} chars)' : 'NULL'}');

   if (accessToken == null || accessToken.isEmpty) {
    servicesErrorMessage.value = 'No access token available';
    debugPrint('❌ No access token - stopping fetch');
    isLoadingServices.value = false;
    return;
   }

   final NetworkResponse response = await _networkCaller.getRequest(
    url,
    headers: <String, String>{
     'Authorization': 'Bearer $accessToken',
    },
   );

   debugPrint('📡 API Response Received:');
   debugPrint('======- isSuccess: ${response.isSuccess}');
   debugPrint('======- statusCode: ${response.statusCode}');
   debugPrint('======- Response type: ${response.jsonResponse?.runtimeType}');

   if (response.isSuccess && response.jsonResponse != null) {
    try {
     debugPrint('🔄 Parsing response...');
     final Map<String, dynamic> responseData = response.jsonResponse!;
     debugPrint('   - Top-level keys: ${responseData.keys.toList()}');

     if (!responseData.containsKey('data')) {
      servicesErrorMessage.value = 'Invalid response format: missing "data" key';
      debugPrint('❌ Missing "data" key in response');
      debugPrint('   - Available keys: ${responseData.keys.toList()}');
      return;
     }

     final dynamic dataField = responseData['data'];
     debugPrint('   - data field type: ${dataField.runtimeType}');

     if (dataField is! Map<String, dynamic>) {
      servicesErrorMessage.value = 'Invalid response format: "data" is not a map';
      debugPrint('❌ "data" field is not a Map');
      return;
     }

     final Map<String, dynamic> data = dataField;
     debugPrint('   - Inner data keys: ${data.keys.toList()}');

     if (!data.containsKey('data')) {
      servicesErrorMessage.value = 'Invalid response format: missing nested "data" key';
      debugPrint('❌ Missing nested "data" key');
      debugPrint('   - Available keys in data: ${data.keys.toList()}');
      return;
     }

     final dynamic servicesDataField = data['data'];
     debugPrint('   - services data field type: ${servicesDataField.runtimeType}');

     if (servicesDataField is! List) {
      servicesErrorMessage.value = 'Invalid response format: services data is not a list';
      debugPrint('❌ Services data is not a List');
      return;
     }

     final List<dynamic> servicesData = servicesDataField;
     debugPrint('   - Services list length: ${servicesData.length}');

     if (servicesData.isEmpty) {
      servicesErrorMessage.value = 'No services found for "$subCategoryName"';
      debugPrint('📭 Empty services list received');
      return;
     }

     final List<ServiceModel> parsedServices = [];
     int successCount = 0;
     int failCount = 0;

     for (int i = 0; i < servicesData.length; i++) {
      debugPrint('🔍 Processing service $i/${servicesData.length}...');

      final dynamic serviceData = servicesData[i];

      if (serviceData is! Map<String, dynamic>) {
       debugPrint('   ⚠️ Service $i is not a Map, skipping');
       failCount++;
       continue;
      }

      try {
       debugPrint('   - Service data: $serviceData');
       final service = ServiceModel.fromJson(serviceData);
       parsedServices.add(service);
       successCount++;
       debugPrint('   ✅ Successfully parsed: ${service.name}');
      } catch (e, stackTrace) {
       failCount++;
       debugPrint('   ❌ Failed to parse service $i: $e');
       debugPrint('   📚 StackTrace: $stackTrace');
       debugPrint('   📄 Problem data: $serviceData');
      }
     }

     debugPrint('📊 Parsing complete:');
     debugPrint('   - Success: $successCount');
     debugPrint('   - Failed: $failCount');
     debugPrint('   - Total parsed: ${parsedServices.length}');

     if (parsedServices.isEmpty) {
      servicesErrorMessage.value = 'Failed to parse any services from the response';
      debugPrint('❌ No services successfully parsed');
     } else {
      services.value = parsedServices;
      debugPrint('✅ Services assigned to observable list');
      debugPrint('   - services.length: ${services.length}');
      debugPrint('   - services.value.length: ${services.value.length}');

      // Verify assignment worked
      debugPrint('🔍 Verification:');
      for (int i = 0; i < services.length; i++) {
       debugPrint('   $i. ${services[i].name} - ${services[i].location}');
      }
     }

    } catch (parseError, stackTrace) {
     servicesErrorMessage.value = 'Failed to parse response: ${parseError.toString()}';
     debugPrint('💥 Parse Error: $parseError');
     debugPrint('📚 StackTrace: $stackTrace');
    }
   } else {
    servicesErrorMessage.value = response.errorMessage ?? 'Failed to fetch services';
    debugPrint('❌ API request failed');
    debugPrint('   - Status: ${response.statusCode}');
    debugPrint('   - Error: ${response.errorMessage}');
   }
  } catch (e, stackTrace) {
   servicesErrorMessage.value = 'Network error: ${e.toString()}';
   debugPrint('💥 Network Exception: $e');
   debugPrint('📚 StackTrace: $stackTrace');
  } finally {
   isLoadingServices.value = false;
   debugPrint('🏁 ========== FETCH COMPLETED ==========');
   debugPrint('   - isLoadingServices: ${isLoadingServices.value}');
   debugPrint('   - services.length: ${services.length}');
   debugPrint('   - errorMessage: "${servicesErrorMessage.value}"');
   debugPrint('==========================================\n');
  }
 }



 /// Retry fetching subcategories
 void retry() {
  if (categoryId.value.isNotEmpty) {
   fetchSubCategories();
  }
 }

 /// Retry fetching services
 void retryServices(String subCategoryId, String subCategoryName) {
  fetchServicesBySubCategory(subCategoryId, subCategoryName);
 }

 @override
 void dispose() {
  subCategories.clear();
  services.clear();
  super.dispose();
 }
}











