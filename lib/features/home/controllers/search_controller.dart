/**


import 'package:get/get.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/network/network_response.dart';
import '../../../core/utils/api/app_url.dart';
import '../../../core/utils/token_service/token_storage_service.dart';

class HomeSearchController extends GetxController {
  RxList<dynamic> services = <dynamic>[].obs;
  RxList<dynamic> filteredServices = <dynamic>[].obs;
  RxBool isLoading = false.obs;
  RxString error = ''.obs;

  final SharedPrefService _sharedPrefService = SharedPrefService();

  @override
  void onInit() {
    super.onInit();
    fetchServices();
  }

  Future<void> fetchServices() async {
    isLoading.value = true;
    error.value = '';

    String? accessToken = await _sharedPrefService.getAccessToken();
    Map<String, String> headers = {};
    if (accessToken != null && accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    NetworkResponse response =
    await NetworkCaller().getRequest(AppUrl.allService, headers: headers);

    if (response.isSuccess) {
      final data = response.jsonResponse?['data']['data'];
      if (data is List) {
        services.value = data;
        filteredServices.value = List.from(data); // Initialize filtered list
      } else {
        services.clear();
        filteredServices.clear();
        error.value = 'No services found';
      }
    } else {
      error.value = response.errorMessage ?? 'Failed to fetch services';
      services.clear();
      filteredServices.clear();
    }
    isLoading.value = false;
  }

  void searchServices({String keyword = '', String location = ''}) {
    if (services.isEmpty) return;

    List<dynamic> results = List.from(services);

    // Filter by keyword (search in name and description)
    if (keyword.isNotEmpty) {
      results = results.where((service) {
        final name = service['name']?.toString().toLowerCase() ?? '';
        final description = service['description']?.toString().toLowerCase() ?? '';
        return name.contains(keyword.toLowerCase()) ||
            description.contains(keyword.toLowerCase());
      }).toList();
    }

    // Filter by location
    if (location.isNotEmpty) {
      results = results.where((service) {
        final serviceLocation = service['location']?.toString().toLowerCase() ?? '';
        return serviceLocation.contains(location.toLowerCase());
      }).toList();
    }

    filteredServices.value = results;
  }

  void clearFilters() {
    filteredServices.value = List.from(services);
  }
}*/












///
///
///
///
/// todo:: fixing the issue
///
///
///
///




import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/network/network_response.dart';
import '../../../core/utils/api/app_url.dart';
import '../../../core/utils/token_service/token_storage_service.dart';

class HomeSearchController extends GetxController {
  // Reactive variables
  final RxList<dynamic> _services = <dynamic>[].obs;
  final RxList<dynamic> _filteredServices = <dynamic>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  // Getters
  List<dynamic> get services => _services.value;
  List<dynamic> get filteredServices => _filteredServices.value;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;

  final SharedPrefService _sharedPrefService = SharedPrefService();

  @override
  void onInit() {
    super.onInit();
    fetchServices();
  }

  Future<void> fetchServices() async {
    _isLoading.value = true;
    _error.value = '';

    String? accessToken = await _sharedPrefService.getAccessToken();
    Map<String, String> headers = {};
    if (accessToken != null && accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    try {
      NetworkResponse response =
      await NetworkCaller().getRequest(AppUrl.allService, headers: headers);

      if (response.isSuccess && response.jsonResponse != null) {
        final data = response.jsonResponse!['data']?['data'];
        if (data is List && data.isNotEmpty) {
          _services.value = data;
          _filteredServices.value = List.from(data); // Initialize filtered list
          debugPrint('✅ Services loaded: ${data.length} items');
        } else {
          _services.clear();
          _filteredServices.clear();
          _error.value = 'No services found';
        }
      } else {
        _error.value = response.errorMessage ?? 'Failed to fetch services';
        _services.clear();
        _filteredServices.clear();
      }
    } catch (e) {
      _error.value = 'Error: ${e.toString()}';
      _services.clear();
      _filteredServices.clear();
    } finally {
      _isLoading.value = false;
      update(); // IMPORTANT: Add this to trigger GetBuilder rebuilds
    }
  }

  void searchServices({String keyword = '', String location = ''}) {
    if (_services.isEmpty) return;

    List<dynamic> results = List.from(_services.value);

    // Filter by keyword (search in name and description)
    if (keyword.isNotEmpty) {
      results = results.where((service) {
        final name = service['name']?.toString().toLowerCase() ?? '';
        final description = service['description']?.toString().toLowerCase() ?? '';
        final subCategory = service['subCategory']?.toString().toLowerCase() ?? '';

        return name.contains(keyword.toLowerCase()) ||
            description.contains(keyword.toLowerCase()) ||
            subCategory.contains(keyword.toLowerCase());
      }).toList();
    }

    // Filter by location
    if (location.isNotEmpty) {
      results = results.where((service) {
        final serviceLocation = service['location']?.toString().toLowerCase() ?? '';
        return serviceLocation.contains(location.toLowerCase());
      }).toList();
    }

    _filteredServices.value = results;
    update(); // IMPORTANT: Add this to trigger GetBuilder rebuilds
  }

  void clearFilters() {
    _filteredServices.value = List.from(_services.value);
    update(); // IMPORTANT: Add this to trigger GetBuilder rebuilds
  }
}


