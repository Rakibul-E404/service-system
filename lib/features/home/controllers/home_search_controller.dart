import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/network/network_response.dart';
import '../../../core/utils/api/app_url.dart';
import '../../../core/utils/token_service/token_storage_service.dart';

class HomeSearchController extends GetxController {
  final RxList<dynamic> _services = <dynamic>[].obs;
  final RxList<dynamic> _filteredServices = <dynamic>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

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
          // Transform the data to match what SearchResultsGrid expects
          final transformedData = _transformServiceData(data);
          _services.value = transformedData;
          _filteredServices.value = List.from(transformedData);
          debugPrint('✅ Services loaded: ${transformedData.length} items');
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

  /// Transform API data to match SearchResultsGrid expected format
  List<Map<String, dynamic>> _transformServiceData(List<dynamic> apiData) {
    return apiData.map<Map<String, dynamic>>((service) {
      return {
        '_id': service['_id'] ?? '',
        'name': service['subCategory']?['name'] ?? 'Unnamed Service',
        'description': service['profileDetails']?['description'] ??
            service['subCategory']?['description'] ??
            'No description available',
        'location': service['profileDetails']?['location'] ?? 'Location not specified',
        'image': service['profileDetails']?['image'] ?? '',
        'rating': (service['averageRating']?.toDouble() ?? 0.0),
        'author': service['author'] ?? '',
        'authorData': service['profileDetails'] ?? {},
        'subCategory': service['subCategory'] ?? {},
        'isSponsored': service['isSponsored'] ?? false,
        'isSubscribed': service['isSubscribed'] ?? false,
        'accessibleBySubscription': service['accessibleBySubscription'] ?? [],
        'phone': service['profileDetails']?['phone'] ?? '',
        'region': service['profileDetails']?['region'] ?? '',
        // Add price if available in your API, otherwise use default
        'price': '99.99', // Default or fetch from actual data
      };
    }).toList();
  }

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
        final subCatName = (service['subCategory']?['name'] ?? '')
            .toString()
            .toLowerCase();
        final subCatDesc = (service['subCategory']?['description'] ?? '')
            .toString()
            .toLowerCase();
        return name.contains(term) ||
            desc.contains(term) ||
            subCatName.contains(term) ||
            subCatDesc.contains(term);
      }).toList();
    }

    // 📍 Location filter (partial match)
    if (location.isNotEmpty && location != 'All Locations') {
      results = results.where((service) {
        final loc = (service['location'] ?? '').toString().toLowerCase();
        return loc.contains(location.toLowerCase());
      }).toList();
    }

    // 🏷️ Category filter (exact match) - Update based on your actual category field
    if (category.isNotEmpty && category != 'All Categories') {
      results = results.where((service) {
        return (service['category'] ?? '') == category;
      }).toList();
    }

    // 🔖 Subcategory filter (exact match)
    if (subcategory.isNotEmpty && subcategory != 'All Subcategories') {
      results = results.where((service) {
        return (service['subCategory']?['name'] ?? '') == subcategory;
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