
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/network/network_response.dart';
import '../../../core/utils/api/app_url.dart';
import '../../../core/utils/token_service/token_storage_service.dart';

class HomeSearchController extends GetxController {
  // Reactive data
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
          _filteredServices.value = List.from(data);
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
      update();
    }
  }

  /// 🔍 Search with optional filters: keyword, location, category, subcategory
  void searchServices({
    String keyword = '',
    String location = '',
    String category = '',
    String subcategory = '',
  }) {
    if (_services.isEmpty) return;

    List<dynamic> results = List.from(_services.value);

    // 🔤 Keyword: match in name, description, or subCategory
    if (keyword.isNotEmpty) {
      final term = keyword.toLowerCase();
      results = results.where((service) {
        final name = (service['name'] ?? '').toString().toLowerCase();
        final desc = (service['description'] ?? '').toString().toLowerCase();
        final subCat = (service['subCategory'] ?? '').toString().toLowerCase();
        return name.contains(term) || desc.contains(term) || subCat.contains(term);
      }).toList();
    }

    // 📍 Location filter (partial match)
    if (location.isNotEmpty && location != 'All Locations') {
      results = results.where((service) {
        final loc = (service['location'] ?? '').toString().toLowerCase();
        return loc.contains(location.toLowerCase());
      }).toList();
    }

    // 🏷️ Category filter (exact match)
    if (category.isNotEmpty && category != 'All Categories') {
      results = results.where((service) {
        return (service['category'] ?? '') == category;
      }).toList();
    }

    // 🔖 Subcategory filter (exact match)
    if (subcategory.isNotEmpty && subcategory != 'All Subcategories') {
      results = results.where((service) {
        return (service['subCategory'] ?? '') == subcategory;
      }).toList();
    }

    _filteredServices.value = results;
    update();
  }

  void clearFilters() {
    _filteredServices.value = List.from(_services.value);
    update();
  }
}






