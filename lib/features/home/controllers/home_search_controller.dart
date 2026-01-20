import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/network/network_caller.dart';
import 'package:manx_mate/core/network/network_response.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';
import 'package:manx_mate/core/utils/token_service/token_storage_service.dart';

class HomeSearchController extends GetxController {
  final RxList<dynamic> _services = <dynamic>[].obs;
  final RxList<dynamic> _filteredServices = <dynamic>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  // Pagination variables
  final RxInt _currentPage = 1.obs;
  final RxBool _hasMore = true.obs;
  final RxBool _isLoadingMore = false.obs;
  final RxInt _totalServices = 0.obs;

  // Current filter state
  String _currentCategoryId = '';
  String _currentSubCategoryId = '';
  String _currentKeyword = '';

  List<dynamic> get services => _services.value;
  List<dynamic> get filteredServices => _filteredServices.value;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  int get currentPage => _currentPage.value;
  bool get hasMore => _hasMore.value;
  bool get isLoadingMore => _isLoadingMore.value;
  int get totalServices => _totalServices.value;

  final SharedPrefService _sharedPrefService = SharedPrefService();

  @override
  void onInit() {
    super.onInit();
    fetchServices();
  }

  Future<void> fetchServices({
    bool refresh = false,
    String? categoryId,
    String? subCategoryId,
    String? keyword,
  }) async {
    if (refresh) {
      _currentPage.value = 1;
      _hasMore.value = true;
      _services.clear();
      _filteredServices.clear();
    }

    // Update current filters if provided
    if (categoryId != null) _currentCategoryId = categoryId;
    if (subCategoryId != null) _currentSubCategoryId = subCategoryId;
    if (keyword != null) _currentKeyword = keyword;

    if (_currentPage.value == 1) {
      _isLoading.value = true;
    } else {
      _isLoadingMore.value = true;
    }

    _error.value = '';

    String? accessToken = await _sharedPrefService.getAccessToken();
    Map<String, String> headers = {};
    if (accessToken != null && accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    try {
      // Build URL with filters
      final url = AppUrl.allService(
        categoryId: _currentCategoryId.isEmpty ? null : _currentCategoryId,
        subCategoryId: _currentSubCategoryId.isEmpty ? null : _currentSubCategoryId,
        page: _currentPage.value,
        limit: 10,
      );

      debugPrint('🌐 Fetching services from: $url');
      debugPrint('  - CategoryID: ${_currentCategoryId.isEmpty ? "None" : _currentCategoryId}');
      debugPrint('  - SubCategoryID: ${_currentSubCategoryId.isEmpty ? "None" : _currentSubCategoryId}');
      debugPrint('  - Keyword: ${_currentKeyword.isEmpty ? "None" : _currentKeyword}');

      NetworkResponse response = await NetworkCaller().getRequest(url, headers: headers);

      if (response.isSuccess && response.jsonResponse != null) {
        final data = response.jsonResponse!['data'];

        if (data != null) {
          final servicesData = data['data'] ?? [];
          final pagination = data['pagination'] ?? {};

          _totalServices.value = pagination['total'] ?? 0;
          final totalPages = pagination['totalPages'] ?? 1;
          _hasMore.value = _currentPage.value < totalPages;

          if (servicesData is List && servicesData.isNotEmpty) {
            final transformedData = _transformServiceData(servicesData);

            if (refresh || _currentPage.value == 1) {
              _services.value = transformedData;
              _filteredServices.value = _applyKeywordFilter(transformedData);
            } else {
              _services.addAll(transformedData);
              _filteredServices.addAll(_applyKeywordFilter(transformedData));
            }

            debugPrint('✅ Services loaded: ${_services.length} items (Page ${_currentPage.value})');
            debugPrint('   Filtered: ${_filteredServices.length} items');
          } else {
            if (_currentPage.value == 1) {
              _services.clear();
              _filteredServices.clear();
              _error.value = 'No services found';
            }
          }
        }
      } else {
        if (_currentPage.value == 1) {
          _error.value = response.errorMessage ?? 'Failed to fetch services';
          _services.clear();
          _filteredServices.clear();
        }
      }
    } catch (e) {
      if (_currentPage.value == 1) {
        _error.value = 'Error: ${e.toString()}';
        _services.clear();
        _filteredServices.clear();
      }
      debugPrint('❌ Error fetching services: $e');
    } finally {
      _isLoading.value = false;
      _isLoadingMore.value = false;
      update();
    }
  }

  Future<void> loadMoreServices() async {
    if (_isLoadingMore.value || !_hasMore.value) return;

    try {
      _currentPage.value++;
      await fetchServices();
    } catch (e) {
      _currentPage.value--;
      rethrow;
    }
  }

  /// Apply keyword filter locally (since API doesn't support keyword search)
  List<Map<String, dynamic>> _applyKeywordFilter(List<Map<String, dynamic>> services) {
    if (_currentKeyword.isEmpty) return services;

    final term = _currentKeyword.toLowerCase();
    return services.where((service) {
      final name = (service['name'] ?? '').toString().toLowerCase();
      final desc = (service['description'] ?? '').toString().toLowerCase();
      final subCatName = (service['subCategory']?['name'] ?? '').toString().toLowerCase();
      final subCatDesc = (service['subCategory']?['description'] ?? '').toString().toLowerCase();

      return name.contains(term) ||
          desc.contains(term) ||
          subCatName.contains(term) ||
          subCatDesc.contains(term);
    }).toList();
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
        'category': service['category'] ?? {},
        'isSponsored': service['isSponsored'] ?? false,
        'isSubscribed': service['isSubscribed'] ?? false,
        'accessibleBySubscription': service['accessibleBySubscription'] ?? [],
        'phone': service['profileDetails']?['phone'] ?? '',
        'region': service['profileDetails']?['region'] ?? '',
        'price': '99.99',
      };
    }).toList();
  }

  /// NEW: Search with category and subcategory IDs
  void searchServices({
    String keyword = '',
    String? categoryId,
    String? subCategoryId,
  }) {
    debugPrint('🔍 Search called with:');
    debugPrint('  - Keyword: $keyword');
    debugPrint('  - CategoryID: $categoryId');
    debugPrint('  - SubCategoryID: $subCategoryId');

    // Reset to page 1 for new search
    _currentPage.value = 1;
    _currentKeyword = keyword;

    // Fetch with new filters
    fetchServices(
      refresh: true,
      categoryId: categoryId ?? '',
      subCategoryId: subCategoryId ?? '',
      keyword: keyword,
    );
  }

  void clearFilters() {
    _currentPage.value = 1;
    _currentCategoryId = '';
    _currentSubCategoryId = '';
    _currentKeyword = '';

    fetchServices(refresh: true);
    update();
  }
}