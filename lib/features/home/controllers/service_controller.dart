// /**
// import 'package:flutter/cupertino.dart';
// import 'package:get/get.dart';
// import '../../../core/network/network_caller.dart';
// import '../../../core/network/network_response.dart';
// import '../../../core/utils/api/app_url.dart';
// import '../model/service_model.dart';
//
// class ServicesController extends GetxController {
//   final NetworkCaller _networkCaller = NetworkCaller();
//
//   // Observable lists
//   final RxList<ServiceModel> services = <ServiceModel>[].obs;
//
//   // Loading states
//   final RxBool isLoadingServices = false.obs;
//
//   // Error message
//   final RxString servicesErrorMessage = ''.obs;
//
//   // Store current subcategory info
//   final RxString currentSubCategoryId = ''.obs;
//   final RxString currentSubCategoryName = ''.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     _initializeWithArguments();
//   }
//
//   void _initializeWithArguments() {
//     final dynamic args = Get.arguments;
//
//     debugPrint('🔍 ServicesController - Received arguments type: ${args.runtimeType}');
//     debugPrint('🔍 ServicesController - Arguments value: $args');
//
//     if (args != null && args is Map<String, dynamic>) {
//       final String subCategoryId = args['subCategoryId']?.toString() ?? '';
//       final String subCategoryName = args['subCategoryName']?.toString() ?? '';
//
//       if (subCategoryId.isNotEmpty && subCategoryName.isNotEmpty) {
//         fetchServicesBySubCategory(subCategoryId, subCategoryName);
//       } else {
//         servicesErrorMessage.value = 'Invalid subcategory data provided';
//         debugPrint('❌ ServicesController - Subcategory ID or Name is empty');
//       }
//     } else {
//       servicesErrorMessage.value = 'No subcategory data provided';
//       debugPrint('❌ ServicesController - No arguments received or invalid format');
//     }
//   }
//
//   /// Fetch services for a specific subcategory (No authentication required)
//   Future<void> fetchServicesBySubCategory(String subCategoryId, String subCategoryName) async {
//     debugPrint('🎯 ========== FETCH SERVICES STARTED ==========');
//     debugPrint('📥 subCategoryId: $subCategoryId');
//     debugPrint('📥 subCategoryName: $subCategoryName');
//
//     // Store current subcategory info
//     currentSubCategoryId.value = subCategoryId;
//     currentSubCategoryName.value = subCategoryName;
//
//     isLoadingServices.value = true;
//     servicesErrorMessage.value = '';
//     services.clear();
//
//     try {
//       debugPrint('🌐 Making API call...');
//       final String url = AppUrl.getServicesBySubCategoryUrl(subCategoryId);
//       debugPrint('   - URL: $url');
//
//       final NetworkResponse response = await _networkCaller.getRequest(
//         url,
//         headers: <String, String>{
//           'Content-Type': 'application/json',
//         },
//       );
//
//       debugPrint('📡 API Response Received:');
//       debugPrint('   - isSuccess: ${response.isSuccess}');
//       debugPrint('   - statusCode: ${response.statusCode}');
//       debugPrint('   - Response type: ${response.jsonResponse?.runtimeType}');
//
//       if (response.isSuccess && response.jsonResponse != null) {
//         _handleSuccessResponse(response.jsonResponse!, subCategoryName);
//       } else {
//         servicesErrorMessage.value = response.errorMessage ?? 'Failed to fetch services';
//         debugPrint('❌ API request failed');
//         debugPrint('   - Status: ${response.statusCode}');
//         debugPrint('   - Error: ${response.errorMessage}');
//       }
//     } catch (e, stackTrace) {
//       servicesErrorMessage.value = 'Network error: ${e.toString()}';
//       debugPrint('💥 Network Exception: $e');
//       debugPrint('📚 StackTrace: $stackTrace');
//     } finally {
//       isLoadingServices.value = false;
//       debugPrint('🏁 ========== FETCH COMPLETED ==========');
//       debugPrint('   - isLoadingServices: ${isLoadingServices.value}');
//       debugPrint('   - services.length: ${services.length}');
//       debugPrint('   - errorMessage: "${servicesErrorMessage.value}"');
//       debugPrint('==========================================\n');
//     }
//   }
//
//   /// Handle successful API response
//   void _handleSuccessResponse(Map<String, dynamic> responseData, String subCategoryName) {
//     try {
//       debugPrint('🔄 Parsing response...');
//       debugPrint('   - Top-level keys: ${responseData.keys.toList()}');
//
//       // Handle different response structures
//       dynamic servicesData;
//
//       if (responseData.containsKey('data')) {
//         final dynamic dataField = responseData['data'];
//         debugPrint('   - data field type: ${dataField.runtimeType}');
//
//         if (dataField is Map<String, dynamic> && dataField.containsKey('data')) {
//           // Nested structure: {data: {data: []}}
//           servicesData = dataField['data'];
//         } else if (dataField is List) {
//           // Direct structure: {data: []}
//           servicesData = dataField;
//         } else {
//           servicesErrorMessage.value = 'Invalid response format';
//           debugPrint('❌ Unexpected data field structure');
//           return;
//         }
//       } else if (responseData.containsKey('services')) {
//         // Alternative structure: {services: []}
//         servicesData = responseData['services'];
//       } else {
//         servicesErrorMessage.value = 'Invalid response format: missing data key';
//         debugPrint('❌ No data or services key found in response');
//         debugPrint('   - Available keys: ${responseData.keys.toList()}');
//         return;
//       }
//
//       debugPrint('   - services data type: ${servicesData.runtimeType}');
//
//       if (servicesData is! List) {
//         servicesErrorMessage.value = 'Invalid response format: services data is not a list';
//         debugPrint('❌ Services data is not a List');
//         return;
//       }
//
//       final List<dynamic> servicesList = servicesData;
//       debugPrint('   - Services list length: ${servicesList.length}');
//
//       if (servicesList.isEmpty) {
//         servicesErrorMessage.value = 'No services found for "$subCategoryName"';
//         debugPrint('📭 Empty services list received');
//         return;
//       }
//
//       _parseServicesList(servicesList);
//     } catch (parseError, stackTrace) {
//       servicesErrorMessage.value = 'Failed to parse response: ${parseError.toString()}';
//       debugPrint('💥 Parse Error: $parseError');
//       debugPrint('📚 StackTrace: $stackTrace');
//     }
//   }
//
//   /// Parse the list of services
//   void _parseServicesList(List<dynamic> servicesList) {
//     final List<ServiceModel> parsedServices = [];
//     int successCount = 0;
//     int failCount = 0;
//
//     for (int i = 0; i < servicesList.length; i++) {
//       debugPrint('🔍 Processing service $i/${servicesList.length}...');
//
//       final dynamic serviceData = servicesList[i];
//
//       if (serviceData is! Map<String, dynamic>) {
//         debugPrint('   ⚠️ Service $i is not a Map, skipping');
//         failCount++;
//         continue;
//       }
//
//       try {
//         debugPrint('   - Service keys: ${serviceData.keys.toList()}');
//         final service = ServiceModel.fromJson(serviceData);
//         parsedServices.add(service);
//         successCount++;
//         debugPrint('   ✅ Successfully parsed: ${service.name}');
//         debugPrint('     - ID: ${service.id}');
//         debugPrint('     - Image: ${service.fullImageUrl}');
//         debugPrint('     - Author ID: ${service.authorId}');
//       } catch (e, stackTrace) {
//         failCount++;
//         debugPrint('   ❌ Failed to parse service $i: $e');
//         debugPrint('   📚 StackTrace: $stackTrace');
//       }
//     }
//
//     debugPrint('📊 Parsing complete:');
//     debugPrint('   - Success: $successCount');
//     debugPrint('   - Failed: $failCount');
//     debugPrint('   - Total parsed: ${parsedServices.length}');
//
//     if (parsedServices.isEmpty) {
//       servicesErrorMessage.value = 'Failed to parse any services from the response';
//       debugPrint('❌ No services successfully parsed');
//     } else {
//       services.value = parsedServices;
//       debugPrint('✅ Services assigned to observable list');
//       debugPrint('   - Final services count: ${services.length}');
//
//       // Log all parsed services for verification
//       for (int i = 0; i < services.length; i++) {
//         final service = services[i];
//         debugPrint('   $i. ${service.name} - ${service.location} - ${service.id}');
//       }
//     }
//   }
//
//   /// Retry fetching services with current subcategory
//   void retryServices() {
//     if (currentSubCategoryId.value.isNotEmpty && currentSubCategoryName.value.isNotEmpty) {
//       fetchServicesBySubCategory(currentSubCategoryId.value, currentSubCategoryName.value);
//     }
//   }
//
//   /// Retry fetching services with specific subcategory
//   void retryServicesWithParams(String subCategoryId, String subCategoryName) {
//     fetchServicesBySubCategory(subCategoryId, subCategoryName);
//   }
//
//   /// Clear services data
//   void clearServices() {
//     services.clear();
//     servicesErrorMessage.value = '';
//     currentSubCategoryId.value = '';
//     currentSubCategoryName.value = '';
//   }
//
//   @override
//   void dispose() {
//     clearServices();
//     super.dispose();
//   }
// }*/
//
//
//
//
//
// import 'package:flutter/cupertino.dart';
// import 'package:get/get.dart';
// import '../../../core/network/network_caller.dart';
// import '../../../core/network/network_response.dart';
// import '../../../core/utils/api/app_url.dart';
// import '../../../core/utils/token_service/token_storage_service.dart';
// import '../model/service_model.dart';
//
// class ServicesController extends GetxController {
//   final NetworkCaller _networkCaller = NetworkCaller();
//   final SharedPrefService _sharedPrefService = SharedPrefService();
//
//   // Observable lists
//   final RxList<ServiceModel> services = <ServiceModel>[].obs;
//
//   // Loading states
//   final RxBool isLoadingServices = false.obs;
//
//   // Error message
//   final RxString servicesErrorMessage = ''.obs;
//
//   // Store current subcategory info
//   final RxString currentSubCategoryId = ''.obs;
//   final RxString currentSubCategoryName = ''.obs;
//
//   // Guest mode state
//   final RxBool isGuestMode = true.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     _checkLoginStatus();
//     _initializeWithArguments();
//   }
//
//   /// Check if user is logged in
//   Future<void> _checkLoginStatus() async {
//     try {
//       final bool loggedIn = await _sharedPrefService.isLoggedIn();
//       isGuestMode.value = !loggedIn;
//       debugPrint('🔐 User logged in: $loggedIn');
//       debugPrint('🔐 Guest Mode: ${isGuestMode.value}');
//     } catch (e) {
//       debugPrint('❌ Error checking login status: $e');
//       isGuestMode.value = true; // Default to guest mode on error
//     }
//   }
//
//   void _initializeWithArguments() {
//     final dynamic args = Get.arguments;
//
//     debugPrint('🔍 ServicesController - Received arguments type: ${args.runtimeType}');
//     debugPrint('🔍 ServicesController - Arguments value: $args');
//
//     if (args != null && args is Map<String, dynamic>) {
//       final String subCategoryId = args['subCategoryId']?.toString() ?? '';
//       final String subCategoryName = args['subCategoryName']?.toString() ?? '';
//
//       if (subCategoryId.isNotEmpty && subCategoryName.isNotEmpty) {
//         fetchServicesBySubCategory(subCategoryId, subCategoryName);
//       } else {
//         servicesErrorMessage.value = 'Invalid subcategory data provided';
//         debugPrint('❌ ServicesController - Subcategory ID or Name is empty');
//       }
//     } else {
//       servicesErrorMessage.value = 'No subcategory data provided';
//       debugPrint('❌ ServicesController - No arguments received or invalid format');
//     }
//   }
//
//   /// Fetch services for a specific subcategory (No authentication required)
//   Future<void> fetchServicesBySubCategory(String subCategoryId, String subCategoryName) async {
//     debugPrint('🎯 ========== FETCH SERVICES STARTED ==========');
//     debugPrint('📥 subCategoryId: $subCategoryId');
//     debugPrint('📥 subCategoryName: $subCategoryName');
//
//     // Store current subcategory info
//     currentSubCategoryId.value = subCategoryId;
//     currentSubCategoryName.value = subCategoryName;
//
//     isLoadingServices.value = true;
//     servicesErrorMessage.value = '';
//     services.clear();
//
//     try {
//       debugPrint('🌐 Making API call...');
//       final String url = AppUrl.getServicesBySubCategoryUrl(subCategoryId);
//       debugPrint('   - URL: $url');
//
//       final NetworkResponse response = await _networkCaller.getRequest(
//         url,
//         headers: <String, String>{
//           'Content-Type': 'application/json',
//         },
//       );
//
//       debugPrint('📡 API Response Received:');
//       debugPrint('   - isSuccess: ${response.isSuccess}');
//       debugPrint('   - statusCode: ${response.statusCode}');
//       debugPrint('   - Response type: ${response.jsonResponse?.runtimeType}');
//
//       if (response.isSuccess && response.jsonResponse != null) {
//         _handleSuccessResponse(response.jsonResponse!, subCategoryName);
//       } else {
//         servicesErrorMessage.value = response.errorMessage ?? 'Failed to fetch services';
//         debugPrint('❌ API request failed');
//         debugPrint('   - Status: ${response.statusCode}');
//         debugPrint('   - Error: ${response.errorMessage}');
//       }
//     } catch (e, stackTrace) {
//       servicesErrorMessage.value = 'Network error: ${e.toString()}';
//       debugPrint('💥 Network Exception: $e');
//       debugPrint('📚 StackTrace: $stackTrace');
//     } finally {
//       isLoadingServices.value = false;
//       debugPrint('🏁 ========== FETCH COMPLETED ==========');
//       debugPrint('   - isLoadingServices: ${isLoadingServices.value}');
//       debugPrint('   - services.length: ${services.length}');
//       debugPrint('   - errorMessage: "${servicesErrorMessage.value}"');
//       debugPrint('==========================================\n');
//     }
//   }
//
//   /// Handle successful API response
//   void _handleSuccessResponse(Map<String, dynamic> responseData, String subCategoryName) {
//     try {
//       debugPrint('🔄 Parsing response...');
//       debugPrint('   - Top-level keys: ${responseData.keys.toList()}');
//
//       // Handle different response structures
//       dynamic servicesData;
//
//       if (responseData.containsKey('data')) {
//         final dynamic dataField = responseData['data'];
//         debugPrint('   - data field type: ${dataField.runtimeType}');
//
//         if (dataField is Map<String, dynamic> && dataField.containsKey('data')) {
//           // Nested structure: {data: {data: []}}
//           servicesData = dataField['data'];
//         } else if (dataField is List) {
//           // Direct structure: {data: []}
//           servicesData = dataField;
//         } else {
//           servicesErrorMessage.value = 'Invalid response format';
//           debugPrint('❌ Unexpected data field structure');
//           return;
//         }
//       } else if (responseData.containsKey('services')) {
//         // Alternative structure: {services: []}
//         servicesData = responseData['services'];
//       } else {
//         servicesErrorMessage.value = 'Invalid response format: missing data key';
//         debugPrint('❌ No data or services key found in response');
//         debugPrint('   - Available keys: ${responseData.keys.toList()}');
//         return;
//       }
//
//       debugPrint('   - services data type: ${servicesData.runtimeType}');
//
//       if (servicesData is! List) {
//         servicesErrorMessage.value = 'Invalid response format: services data is not a list';
//         debugPrint('❌ Services data is not a List');
//         return;
//       }
//
//       final List<dynamic> servicesList = servicesData;
//       debugPrint('   - Services list length: ${servicesList.length}');
//
//       if (servicesList.isEmpty) {
//         servicesErrorMessage.value = 'No services found for "$subCategoryName"';
//         debugPrint('📭 Empty services list received');
//         return;
//       }
//
//       _parseServicesList(servicesList);
//     } catch (parseError, stackTrace) {
//       servicesErrorMessage.value = 'Failed to parse response: ${parseError.toString()}';
//       debugPrint('💥 Parse Error: $parseError');
//       debugPrint('📚 StackTrace: $stackTrace');
//     }
//   }
//
//   /// Parse the list of services
//   void _parseServicesList(List<dynamic> servicesList) {
//     final List<ServiceModel> parsedServices = [];
//     int successCount = 0;
//     int failCount = 0;
//
//     for (int i = 0; i < servicesList.length; i++) {
//       debugPrint('🔍 Processing service $i/${servicesList.length}...');
//
//       final dynamic serviceData = servicesList[i];
//
//       if (serviceData is! Map<String, dynamic>) {
//         debugPrint('   ⚠️ Service $i is not a Map, skipping');
//         failCount++;
//         continue;
//       }
//
//       try {
//         debugPrint('   - Service keys: ${serviceData.keys.toList()}');
//         final service = ServiceModel.fromJson(serviceData);
//         parsedServices.add(service);
//         successCount++;
//         debugPrint('   ✅ Successfully parsed: ${service.name}');
//         debugPrint('     - ID: ${service.id}');
//         debugPrint('     - Image: ${service.fullImageUrl}');
//         debugPrint('     - Author ID: ${service.authorId}');
//       } catch (e, stackTrace) {
//         failCount++;
//         debugPrint('   ❌ Failed to parse service $i: $e');
//         debugPrint('   📚 StackTrace: $stackTrace');
//       }
//     }
//
//     debugPrint('📊 Parsing complete:');
//     debugPrint('   - Success: $successCount');
//     debugPrint('   - Failed: $failCount');
//     debugPrint('   - Total parsed: ${parsedServices.length}');
//
//     if (parsedServices.isEmpty) {
//       servicesErrorMessage.value = 'Failed to parse any services from the response';
//       debugPrint('❌ No services successfully parsed');
//     } else {
//       services.value = parsedServices;
//       debugPrint('✅ Services assigned to observable list');
//       debugPrint('   - Final services count: ${services.length}');
//
//       // Log all parsed services for verification
//       for (int i = 0; i < services.length; i++) {
//         final service = services[i];
//         debugPrint('   $i. ${service.name} - ${service.location} - ${service.id}');
//       }
//     }
//   }
//
//   /// Retry fetching services with current subcategory
//   void retryServices() {
//     if (currentSubCategoryId.value.isNotEmpty && currentSubCategoryName.value.isNotEmpty) {
//       fetchServicesBySubCategory(currentSubCategoryId.value, currentSubCategoryName.value);
//     }
//   }
//
//   /// Retry fetching services with specific subcategory
//   void retryServicesWithParams(String subCategoryId, String subCategoryName) {
//     fetchServicesBySubCategory(subCategoryId, subCategoryName);
//   }
//
//   /// Refresh login status (call this after user logs in)
//   Future<void> refreshLoginStatus() async {
//     await _checkLoginStatus();
//   }
//
//   /// Clear services data
//   void clearServices() {
//     services.clear();
//     servicesErrorMessage.value = '';
//     currentSubCategoryId.value = '';
//     currentSubCategoryName.value = '';
//   }
//
//   @override
//   void dispose() {
//     clearServices();
//     super.dispose();
//   }
// }
//









///
///
///
/// todo::: fixing the issue
///
///
///





import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/network/network_response.dart';
import '../../../core/utils/api/app_url.dart';
import '../../../core/utils/token_service/token_storage_service.dart';
import '../model/service_model.dart';

class ServicesController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();
  final SharedPrefService _sharedPrefService = SharedPrefService();

  // Observable lists
  final RxList<ServiceModel> services = <ServiceModel>[].obs;

  // Loading states
  final RxBool isLoadingServices = false.obs;

  // Error message
  final RxString servicesErrorMessage = ''.obs;

  // Store current subcategory info
  final RxString currentSubCategoryId = ''.obs;
  final RxString currentSubCategoryName = ''.obs;

  // Guest mode state
  final RxBool isGuestMode = true.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('🔄 ServicesController onInit() called');
    _checkLoginStatus();
    _initializeWithArguments();
  }

  /// Check if user is logged in
  Future<void> _checkLoginStatus() async {
    try {
      final bool loggedIn = await _sharedPrefService.isLoggedIn();
      isGuestMode.value = !loggedIn;
      debugPrint('🔐 User logged in: $loggedIn');
      debugPrint('🔐 Guest Mode: ${isGuestMode.value}');
    } catch (e) {
      debugPrint('❌ Error checking login status: $e');
      isGuestMode.value = true; // Default to guest mode on error
    }
  }

  void _initializeWithArguments() {
    final dynamic args = Get.arguments;

    debugPrint('🔍 ServicesController - Received arguments type: ${args.runtimeType}');
    debugPrint('🔍 ServicesController - Arguments value: $args');

    if (args != null && args is Map<String, dynamic>) {
      final String subCategoryId = args['subCategoryId']?.toString() ?? '';
      final String subCategoryName = args['subCategoryName']?.toString() ?? '';

      if (subCategoryId.isNotEmpty && subCategoryName.isNotEmpty) {
        // Store values but don't fetch yet - let the UI handle it
        currentSubCategoryId.value = subCategoryId;
        currentSubCategoryName.value = subCategoryName;
        debugPrint('📋 Stored subCategory: $subCategoryName ($subCategoryId)');
      } else {
        servicesErrorMessage.value = 'Invalid subcategory data provided';
        debugPrint('❌ ServicesController - Subcategory ID or Name is empty');
      }
    } else {
      servicesErrorMessage.value = 'No subcategory data provided';
      debugPrint('❌ ServicesController - No arguments received or invalid format');
    }
  }

  /// Fetch services for a specific subcategory (No authentication required)
  Future<void> fetchServicesBySubCategory(String subCategoryId, String subCategoryName) async {
    // Prevent duplicate calls if already loading
    if (isLoadingServices.value) {
      debugPrint('⏳ Already loading services, skipping duplicate call');
      return;
    }

    debugPrint('🎯 ========== FETCH SERVICES STARTED ==========');
    debugPrint('📥 subCategoryId: $subCategoryId');
    debugPrint('📥 subCategoryName: $subCategoryName');

    // Store current subcategory info
    currentSubCategoryId.value = subCategoryId;
    currentSubCategoryName.value = subCategoryName;

    isLoadingServices.value = true;
    servicesErrorMessage.value = '';
    services.clear();

    try {
      debugPrint('🌐 Making API call...');
      final String url = AppUrl.getServicesBySubCategoryUrl(subCategoryId);
      debugPrint('   - URL: $url');

      final NetworkResponse response = await _networkCaller.getRequest(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
      );

      debugPrint('📡 API Response Received:');
      debugPrint('   - isSuccess: ${response.isSuccess}');
      debugPrint('   - statusCode: ${response.statusCode}');

      if (response.isSuccess && response.jsonResponse != null) {
        _handleSuccessResponse(response.jsonResponse!, subCategoryName);
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

  /// Handle successful API response
  void _handleSuccessResponse(Map<String, dynamic> responseData, String subCategoryName) {
    try {
      debugPrint('🔄 Parsing response...');
      debugPrint('   - Top-level keys: ${responseData.keys.toList()}');

      // Handle different response structures
      dynamic servicesData;

      if (responseData.containsKey('data')) {
        final dynamic dataField = responseData['data'];
        debugPrint('   - data field type: ${dataField.runtimeType}');

        if (dataField is Map<String, dynamic> && dataField.containsKey('data')) {
          // Nested structure: {data: {data: []}}
          servicesData = dataField['data'];
        } else if (dataField is List) {
          // Direct structure: {data: []}
          servicesData = dataField;
        } else {
          servicesErrorMessage.value = 'Invalid response format';
          debugPrint('❌ Unexpected data field structure');
          return;
        }
      } else if (responseData.containsKey('services')) {
        // Alternative structure: {services: []}
        servicesData = responseData['services'];
      } else {
        servicesErrorMessage.value = 'Invalid response format: missing data key';
        debugPrint('❌ No data or services key found in response');
        debugPrint('   - Available keys: ${responseData.keys.toList()}');
        return;
      }

      debugPrint('   - services data type: ${servicesData.runtimeType}');

      if (servicesData is! List) {
        servicesErrorMessage.value = 'Invalid response format: services data is not a list';
        debugPrint('❌ Services data is not a List');
        return;
      }

      final List<dynamic> servicesList = servicesData;
      debugPrint('   - Services list length: ${servicesList.length}');

      if (servicesList.isEmpty) {
        servicesErrorMessage.value = 'No services found for "$subCategoryName"';
        debugPrint('📭 Empty services list received');
        return;
      }

      _parseServicesList(servicesList);
    } catch (parseError, stackTrace) {
      servicesErrorMessage.value = 'Failed to parse response: ${parseError.toString()}';
      debugPrint('💥 Parse Error: $parseError');
      debugPrint('📚 StackTrace: $stackTrace');
    }
  }

  /// Parse the list of services
  void _parseServicesList(List<dynamic> servicesList) {
    final List<ServiceModel> parsedServices = [];
    int successCount = 0;
    int failCount = 0;

    for (int i = 0; i < servicesList.length; i++) {
      debugPrint('🔍 Processing service $i/${servicesList.length}...');

      final dynamic serviceData = servicesList[i];

      if (serviceData is! Map<String, dynamic>) {
        debugPrint('   ⚠️ Service $i is not a Map, skipping');
        failCount++;
        continue;
      }

      try {
        debugPrint('   - Service keys: ${serviceData.keys.toList()}');
        final service = ServiceModel.fromJson(serviceData);
        parsedServices.add(service);
        successCount++;
        debugPrint('   ✅ Successfully parsed: ${service.name}');
        debugPrint('     - ID: ${service.id}');
        debugPrint('     - Image: ${service.fullImageUrl}');
        debugPrint('     - Author ID: ${service.authorId}');
      } catch (e, stackTrace) {
        failCount++;
        debugPrint('   ❌ Failed to parse service $i: $e');
        debugPrint('   📚 StackTrace: $stackTrace');
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
      debugPrint('   - Final services count: ${services.length}');

      // Log all parsed services for verification
      for (int i = 0; i < services.length; i++) {
        final service = services[i];
        debugPrint('   $i. ${service.name} - ${service.location} - ${service.id}');
      }
    }
  }

  /// Retry fetching services with current subcategory
  void retryServices() {
    if (currentSubCategoryId.value.isNotEmpty && currentSubCategoryName.value.isNotEmpty) {
      fetchServicesBySubCategory(currentSubCategoryId.value, currentSubCategoryName.value);
    }
  }

  /// Retry fetching services with specific subcategory
  void retryServicesWithParams(String subCategoryId, String subCategoryName) {
    fetchServicesBySubCategory(subCategoryId, subCategoryName);
  }

  /// Refresh login status (call this after user logs in)
  Future<void> refreshLoginStatus() async {
    await _checkLoginStatus();
  }

  /// Clear services data
  void clearServices() {
    services.clear();
    servicesErrorMessage.value = '';
    currentSubCategoryId.value = '';
    currentSubCategoryName.value = '';
  }

  @override
  void onClose() {
    clearServices();
    super.onClose();
  }
}