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

  @override
  void onInit() {
    super.onInit();
    _initializeWithArguments();
  }

  void _initializeWithArguments() {
    final dynamic args = Get.arguments;

    debugPrint('🔍 ServicesController - Received arguments type: ${args.runtimeType}');
    debugPrint('🔍 ServicesController - Arguments value: $args');

    if (args != null && args is Map<String, dynamic>) {
      final String subCategoryId = args['subCategoryId']?.toString() ?? '';
      final String subCategoryName = args['subCategoryName']?.toString() ?? '';

      if (subCategoryId.isNotEmpty && subCategoryName.isNotEmpty) {
        fetchServicesBySubCategory(subCategoryId, subCategoryName);
      } else {
        servicesErrorMessage.value = 'Invalid subcategory data provided';
        debugPrint('❌ ServicesController - Subcategory ID or Name is empty');
      }
    } else {
      servicesErrorMessage.value = 'No subcategory data provided';
      debugPrint('❌ ServicesController - No arguments received or invalid format');
    }
  }

  /// Fetch services for a specific subcategory
  Future<void> fetchServicesBySubCategory(String subCategoryId, String subCategoryName) async {
    debugPrint('🎯 ========== FETCH SERVICES STARTED ==========');
    debugPrint('-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- subCategoryId: $subCategoryId');
    debugPrint('-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-- subCategoryName: $subCategoryName');

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

  /// Clear services data
  void clearServices() {
    services.clear();
    servicesErrorMessage.value = '';
    currentSubCategoryId.value = '';
    currentSubCategoryName.value = '';
  }

  @override
  void dispose() {
    services.clear();
    super.dispose();
  }
}