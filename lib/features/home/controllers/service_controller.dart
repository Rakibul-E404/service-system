
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
  final RxBool isLoadingMore = false.obs;
  final RxBool isLoadingFavorites = false.obs;

  // Error message
  final RxString servicesErrorMessage = ''.obs;

  // Store current filter info
  final RxString currentCategoryId = ''.obs;
  final RxString currentSubCategoryId = ''.obs;
  final RxString currentSubCategoryName = ''.obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxBool hasMore = true.obs;
  final RxInt totalServices = 0.obs;

  // Guest mode state
  final RxBool isGuestMode = true.obs;

  // Store token for easy access
  final RxString _cachedToken = ''.obs;

  // Store favorite service IDs
  final RxSet<String> favoriteServiceIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('🔄 ServicesController onInit() called');
    _checkLoginStatus();
    _initializeWithArguments();
  }

  /// Check if user is logged in and get token
  Future<void> _checkLoginStatus() async {
    try {
      final bool loggedIn = await _sharedPrefService.isLoggedIn();
      isGuestMode.value = !loggedIn;

      // Get token if logged in
      if (loggedIn) {
        final String? token = await _sharedPrefService.getAccessToken();
        _cachedToken.value = token ?? '';
      } else {
        _cachedToken.value = '';
      }

      debugPrint('🔐 User logged in: $loggedIn');
      debugPrint('🔐 Guest Mode: ${isGuestMode.value}');
      debugPrint('🔐 Token cached: ${_cachedToken.value.isNotEmpty}');
    } catch (e) {
      debugPrint('❌ Error checking login status: $e');
      isGuestMode.value = true;
      _cachedToken.value = '';
    }
  }

  void _initializeWithArguments() {
    final dynamic args = Get.arguments;

    debugPrint('🔍 ServicesController - Received arguments type: ${args.runtimeType}');
    debugPrint('🔍 ServicesController - Arguments value: $args');

    if (args != null && args is Map<String, dynamic>) {
      final String categoryId = args['categoryId']?.toString() ?? '';
      final String subCategoryId = args['subCategoryId']?.toString() ?? '';
      final String subCategoryName = args['subCategoryName']?.toString() ?? '';

      // Store all values
      currentCategoryId.value = categoryId;
      currentSubCategoryId.value = subCategoryId;
      currentSubCategoryName.value = subCategoryName;

      debugPrint('📋 Stored categoryId: $categoryId');
      debugPrint('📋 Stored subCategory: $subCategoryName ($subCategoryId)');
    } else {
      debugPrint('ℹ️ ServicesController - No arguments received');
    }
  }

  /// Fetch favorite service IDs from API
  Future<void> fetchFavoriteServiceIds() async {
    // Only fetch if user is logged in (not guest mode)
    if (isGuestMode.value) {
      debugPrint('👤 User is in guest mode, skipping favorite fetch');
      return;
    }

    // Prevent duplicate calls if already loading
    if (isLoadingFavorites.value) {
      debugPrint('⏳ Already loading favorites, skipping duplicate call');
      return;
    }

    debugPrint('🎯 ========== FETCHING FAVORITE SERVICE IDs ==========');

    isLoadingFavorites.value = true;
    favoriteServiceIds.clear();

    try {
      final String url = AppUrl.allFavoritesId(); // Use the allFavoritesId endpoint
      debugPrint('🌐 Making API call to: $url');

      final NetworkResponse response = await _networkCaller.getRequest(
        url,
        headers: await _getHeaders(),
      );

      debugPrint('📡 Favorite IDs API Response:');
      debugPrint('   - isSuccess: ${response.isSuccess}');
      debugPrint('   - statusCode: ${response.statusCode}');

      if (response.isSuccess && response.jsonResponse != null) {
        _handleFavoriteIdsResponse(response.jsonResponse!);
      } else {
        debugPrint('❌ Failed to fetch favorite IDs');
        debugPrint('   - Status: ${response.statusCode}');
        debugPrint('   - Error: ${response.errorMessage}');
      }
    } catch (e, stackTrace) {
      debugPrint('💥 Error fetching favorite IDs: $e');
      debugPrint('📚 StackTrace: $stackTrace');
    } finally {
      isLoadingFavorites.value = false;
      debugPrint('🏁 ========== FAVORITE IDs FETCH COMPLETED ==========');
      debugPrint('   - Favorite IDs count: ${favoriteServiceIds.length}');
      debugPrint('   - IDs: ${favoriteServiceIds.toList()}');
      debugPrint('==================================================\n');
    }
  }

  /// Handle the response from allFavoritesId endpoint
  void _handleFavoriteIdsResponse(Map<String, dynamic> responseData) {
    try {
      debugPrint('🔄 Parsing favorite IDs response...');
      debugPrint('   - Top-level keys: ${responseData.keys.toList()}');

      // Check if response has 'data' key
      if (!responseData.containsKey('data')) {
        debugPrint('❌ No data key found in favorite IDs response');
        return;
      }

      final dynamic dataField = responseData['data'];
      debugPrint('   - data field type: ${dataField.runtimeType}');

      if (dataField is! List) {
        debugPrint('❌ Data field is not a List in favorite IDs response');
        return;
      }

      final List<dynamic> favoriteList = dataField;
      debugPrint('   - Favorite list length: ${favoriteList.length}');

      if (favoriteList.isEmpty) {
        debugPrint('📭 No favorites found');
        return;
      }

      // Extract service IDs from favorites
      for (int i = 0; i < favoriteList.length; i++) {
        final dynamic favoriteItem = favoriteList[i];
        debugPrint('   🔍 Processing favorite item $i: ${favoriteItem.runtimeType}');

        if (favoriteItem is Map<String, dynamic>) {
          // Check for serviceId or id field
          if (favoriteItem.containsKey('serviceId')) {
            final String? serviceId = favoriteItem['serviceId']?.toString();
            if (serviceId != null && serviceId.isNotEmpty) {
              favoriteServiceIds.add(serviceId);
              debugPrint('     ✅ Added serviceId: $serviceId');
            }
          } else if (favoriteItem.containsKey('id')) {
            final String? serviceId = favoriteItem['id']?.toString();
            if (serviceId != null && serviceId.isNotEmpty) {
              favoriteServiceIds.add(serviceId);
              debugPrint('     ✅ Added id: $serviceId');
            }
          } else {
            debugPrint('     ⚠️ No serviceId or id field found in item');
            debugPrint('     Item keys: ${favoriteItem.keys.toList()}');
          }
        } else if (favoriteItem is String) {
          // If the API returns just an array of IDs as strings
          favoriteServiceIds.add(favoriteItem);
          debugPrint('     ✅ Added string ID: $favoriteItem');
        } else {
          debugPrint('     ⚠️ Unexpected item type: ${favoriteItem.runtimeType}');
        }
      }

      debugPrint('📊 Successfully parsed ${favoriteServiceIds.length} favorite IDs');

    } catch (parseError, stackTrace) {
      debugPrint('💥 Parse Error in favorite IDs: $parseError');
      debugPrint('📚 StackTrace: $stackTrace');
    }
  }

  /// Check if a service is in favorites
  bool isServiceFavorited(String serviceId) {
    return favoriteServiceIds.contains(serviceId);
  }

  /// Add a service to favorites (local state)
  void addToFavorites(String serviceId) {
    favoriteServiceIds.add(serviceId);
    debugPrint('❤️ Added service $serviceId to local favorites');
  }

  /// Remove a service from favorites (local state)
  void removeFromFavorites(String serviceId) {
    favoriteServiceIds.remove(serviceId);
    debugPrint('💔 Removed service $serviceId from local favorites');
  }

  // ========== MAIN FETCH METHODS ==========

  /// Fetch services with both category and subcategory
  Future<void> fetchServicesByCategoryAndSubCategory(
      String categoryId,
      String subCategoryId,
      String subCategoryName,
      ) async {
    // Prevent duplicate calls if already loading
    if (isLoadingServices.value) {
      debugPrint('⏳ Already loading services, skipping duplicate call');
      return;
    }

    debugPrint('🎯 ========== FETCH SERVICES WITH CATEGORY & SUBCATEGORY ==========');
    debugPrint('📥 categoryId: $categoryId');
    debugPrint('📥 subCategoryId: $subCategoryId');
    debugPrint('📥 subCategoryName: $subCategoryName');

    // Reset state for new fetch
    isLoadingServices.value = true;
    isLoadingMore.value = false;
    servicesErrorMessage.value = '';
    services.clear();
    currentPage.value = 1;
    hasMore.value = true;
    totalServices.value = 0;

    // Store current parameters
    currentCategoryId.value = categoryId;
    currentSubCategoryId.value = subCategoryId;
    currentSubCategoryName.value = subCategoryName;

    try {
      debugPrint('🌐 Making API call...');
      final String url = AppUrl.serviceByCategorySubcategory(categoryId, subCategoryId, 1);
      debugPrint('   - URL: $url');

      final NetworkResponse response = await _networkCaller.getRequest(
        url,
        headers: await _getHeaders(),
      );

      debugPrint('📡 API Response Received:');
      debugPrint('   - isSuccess: ${response.isSuccess}');
      debugPrint('   - statusCode: ${response.statusCode}');

      if (response.isSuccess && response.jsonResponse != null) {
        _handleSuccessResponse(response.jsonResponse!, subCategoryName);

        // After loading services, fetch favorite IDs if user is logged in
        if (!isGuestMode.value) {
          await fetchFavoriteServiceIds();
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

  /// Fetch services with only subcategory (when category is not available)
  Future<void> fetchServicesBySubCategoryOnly(
      String subCategoryId,
      String subCategoryName,
      ) async {
    // Prevent duplicate calls if already loading
    if (isLoadingServices.value) {
      debugPrint('⏳ Already loading services, skipping duplicate call');
      return;
    }

    debugPrint('🎯 ========== FETCH SERVICES BY SUBCATEGORY ONLY ==========');
    debugPrint('📥 subCategoryId: $subCategoryId');
    debugPrint('📥 subCategoryName: $subCategoryName');

    // Reset state for new fetch
    isLoadingServices.value = true;
    isLoadingMore.value = false;
    servicesErrorMessage.value = '';
    services.clear();
    currentPage.value = 1;
    hasMore.value = true;
    totalServices.value = 0;

    // Store current parameters
    currentCategoryId.value = '';
    currentSubCategoryId.value = subCategoryId;
    currentSubCategoryName.value = subCategoryName;

    try {
      debugPrint('🌐 Making API call with only subcategory...');
      final String url = _buildSubCategoryOnlyUrl(subCategoryId, 1);
      debugPrint('   - URL: $url');

      final NetworkResponse response = await _networkCaller.getRequest(
        url,
        headers: await _getHeaders(),
      );

      debugPrint('📡 API Response Received:');
      debugPrint('   - isSuccess: ${response.isSuccess}');
      debugPrint('   - statusCode: ${response.statusCode}');

      if (response.isSuccess && response.jsonResponse != null) {
        _handleSuccessResponse(response.jsonResponse!, subCategoryName);

        // After loading services, fetch favorite IDs if user is logged in
        if (!isGuestMode.value) {
          await fetchFavoriteServiceIds();
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

  // ========== RETRY METHODS ==========

  /// Retry fetching services with both category and subcategory
  void retryServicesWithCategoryAndSubCategory(
      String categoryId,
      String subCategoryId,
      String subCategoryName,
      ) {
    debugPrint('🔄 Retrying fetch with category and subcategory...');
    fetchServicesByCategoryAndSubCategory(categoryId, subCategoryId, subCategoryName);
  }

  /// Retry fetching services with only subcategory
  void retryServicesWithSubCategoryOnly(
      String subCategoryId,
      String subCategoryName,
      ) {
    debugPrint('🔄 Retrying fetch with subcategory only...');
    fetchServicesBySubCategoryOnly(subCategoryId, subCategoryName);
  }

  // ========== LEGACY METHODS (for backward compatibility) ==========

  /// Legacy method - Fetch services for a specific subcategory
  Future<void> fetchServicesBySubCategory(String subCategoryId, String subCategoryName) async {
    await fetchServicesBySubCategoryOnly(subCategoryId, subCategoryName);
  }

  /// Legacy method - Retry fetching services with current subcategory
  void retryServices() {
    if (currentSubCategoryId.value.isNotEmpty && currentSubCategoryName.value.isNotEmpty) {
      if (currentCategoryId.value.isNotEmpty) {
        retryServicesWithCategoryAndSubCategory(
          currentCategoryId.value,
          currentSubCategoryId.value,
          currentSubCategoryName.value,
        );
      } else {
        retryServicesWithSubCategoryOnly(
          currentSubCategoryId.value,
          currentSubCategoryName.value,
        );
      }
    }
  }

  /// Legacy method - Retry fetching services with specific subcategory
  void retryServicesWithParams(String subCategoryId, String subCategoryName) {
    if (currentCategoryId.value.isNotEmpty) {
      retryServicesWithCategoryAndSubCategory(
        currentCategoryId.value,
        subCategoryId,
        subCategoryName,
      );
    } else {
      retryServicesWithSubCategoryOnly(subCategoryId, subCategoryName);
    }
  }

  // ========== PAGINATION METHODS ==========

  /// Load more services for pagination
  Future<void> loadMoreServices() async {
    if (isLoadingMore.value || !hasMore.value || isLoadingServices.value) {
      debugPrint('⏭️ Cannot load more - busy or no more data');
      return;
    }

    try {
      isLoadingMore.value = true;
      currentPage.value++;

      String url;
      if (currentCategoryId.value.isNotEmpty) {
        // Use both category and subcategory
        url = AppUrl.serviceByCategorySubcategory(
          currentCategoryId.value,
          currentSubCategoryId.value,
          currentPage.value,
        );
      } else {
        // Use only subcategory
        url = _buildSubCategoryOnlyUrl(currentSubCategoryId.value, currentPage.value);
      }

      debugPrint('📥 Loading more services - Page ${currentPage.value}');
      debugPrint('🌐 URL: $url');

      final NetworkResponse response = await _networkCaller.getRequest(
        url,
        headers: await _getHeaders(),
      );

      if (response.isSuccess && response.jsonResponse != null) {
        _handleLoadMoreResponse(response.jsonResponse!);
      } else {
        currentPage.value--; // Revert page on error
        debugPrint('❌ Failed to load more services');
      }
    } catch (e, stackTrace) {
      currentPage.value--; // Revert page on error
      debugPrint('💥 Error loading more services: $e');
      debugPrint('📚 StackTrace: $stackTrace');
    } finally {
      isLoadingMore.value = false;
    }
  }

  // ========== HELPER METHODS ==========

  /// Handle successful API response for initial load
  void _handleSuccessResponse(Map<String, dynamic> responseData, String subCategoryName) {
    try {
      debugPrint('🔄 Parsing response...');
      debugPrint('   - Top-level keys: ${responseData.keys.toList()}');

      if (!responseData.containsKey('data')) {
        servicesErrorMessage.value = 'Invalid response format: missing data key';
        debugPrint('❌ No data key found in response');
        return;
      }

      final dynamic dataField = responseData['data'];
      debugPrint('   - data field type: ${dataField.runtimeType}');

      if (dataField is! Map<String, dynamic>) {
        servicesErrorMessage.value = 'Invalid response format: data is not an object';
        debugPrint('❌ Data field is not a Map');
        return;
      }

      // Get services list
      if (!dataField.containsKey('data')) {
        servicesErrorMessage.value = 'Invalid response format: missing data.data key';
        debugPrint('❌ No data.data key found');
        return;
      }

      final dynamic servicesData = dataField['data'];
      debugPrint('   - services data type: ${servicesData.runtimeType}');

      if (servicesData is! List) {
        servicesErrorMessage.value = 'Invalid response format: services data is not a list';
        debugPrint('❌ Services data is not a List');
        return;
      }

      final List<dynamic> servicesList = servicesData;
      debugPrint('   - Services list length: ${servicesList.length}');

      // Get pagination info
      if (dataField.containsKey('pagination')) {
        final dynamic paginationData = dataField['pagination'];
        if (paginationData is Map<String, dynamic>) {
          _handlePaginationData(paginationData);
        }
      }

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

  /// Handle load more API response
  void _handleLoadMoreResponse(Map<String, dynamic> responseData) {
    try {
      debugPrint('🔄 Parsing load more response...');

      if (!responseData.containsKey('data')) {
        debugPrint('❌ No data key found in load more response');
        return;
      }

      final dynamic dataField = responseData['data'];
      if (dataField is! Map<String, dynamic>) {
        debugPrint('❌ Data field is not a Map in load more response');
        return;
      }

      // Get services list
      if (!dataField.containsKey('data')) {
        debugPrint('❌ No data.data key found in load more response');
        return;
      }

      final dynamic servicesData = dataField['data'];
      if (servicesData is! List) {
        debugPrint('❌ Services data is not a List in load more response');
        return;
      }

      final List<dynamic> servicesList = servicesData;
      debugPrint('   - Loaded ${servicesList.length} more services');

      // Get pagination info
      if (dataField.containsKey('pagination')) {
        final dynamic paginationData = dataField['pagination'];
        if (paginationData is Map<String, dynamic>) {
          _handlePaginationData(paginationData);
        }
      }

      _parseAndAddServicesList(servicesList);
    } catch (parseError, stackTrace) {
      debugPrint('💥 Parse Error in load more: $parseError');
      debugPrint('📚 StackTrace: $stackTrace');
    }
  }

  /// Parse pagination data
  void _handlePaginationData(Map<String, dynamic> paginationData) {
    try {
      debugPrint('📊 Pagination data:');
      debugPrint('   - Keys: ${paginationData.keys.toList()}');

      if (paginationData.containsKey('total')) {
        totalServices.value = paginationData['total'] is int
            ? paginationData['total']
            : int.tryParse(paginationData['total'].toString()) ?? 0;
      }

      if (paginationData.containsKey('page') && paginationData.containsKey('totalPages')) {
        final int currentPageNum = paginationData['page'] is int
            ? paginationData['page']
            : int.tryParse(paginationData['page'].toString()) ?? 1;

        final int totalPages = paginationData['totalPages'] is int
            ? paginationData['totalPages']
            : int.tryParse(paginationData['totalPages'].toString()) ?? 1;

        hasMore.value = currentPageNum < totalPages;

        debugPrint('   - Current Page: $currentPageNum');
        debugPrint('   - Total Pages: $totalPages');
        debugPrint('   - Has More: ${hasMore.value}');
        debugPrint('   - Total Services: ${totalServices.value}');
      }
    } catch (e) {
      debugPrint('❌ Error parsing pagination data: $e');
    }
  }

  /// Parse the list of services for initial load
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

        // Log the structure to understand it better
        if (serviceData.containsKey('profileDetails')) {
          final profile = serviceData['profileDetails'];
          debugPrint('   📦 Profile Details keys: ${profile is Map ? profile.keys.toList() : 'Not a Map'}');
          debugPrint('   📦 Profile Image: ${profile is Map ? profile['image'] : 'N/A'}');
          debugPrint('   📦 Profile Location: ${profile is Map ? profile['location'] : 'N/A'}');
          debugPrint('   📦 Profile Description: ${profile is Map ? profile['description'] : 'N/A'}');
        }

        final service = ServiceModel.fromJson(serviceData);
        parsedServices.add(service);
        successCount++;

        debugPrint('   ✅ Successfully parsed: ${service.name}');
        debugPrint('     - ID: ${service.id}');
        debugPrint('     - Full Image URL: ${service.fullImageUrl}');
        debugPrint('     - Author ID: ${service.authorId}');
        debugPrint('     - Location: ${service.location}');
        debugPrint('     - Rating: ${service.rating}');

        // Check if this service is in favorites
        if (favoriteServiceIds.contains(service.id)) {
          debugPrint('     ❤️ Service is in favorites!');
        }
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
        final isFav = favoriteServiceIds.contains(service.id);
        debugPrint('   $i. ${service.name} - ${service.location} - Rating: ${service.rating} - Fav: $isFav');
      }
    }
  }

  /// Parse and add services for load more
  void _parseAndAddServicesList(List<dynamic> servicesList) {
    final List<ServiceModel> parsedServices = [];
    int successCount = 0;
    int failCount = 0;

    for (int i = 0; i < servicesList.length; i++) {
      final dynamic serviceData = servicesList[i];

      if (serviceData is! Map<String, dynamic>) {
        failCount++;
        continue;
      }

      try {
        final service = ServiceModel.fromJson(serviceData);
        parsedServices.add(service);
        successCount++;
      } catch (e) {
        failCount++;
      }
    }

    debugPrint('📊 Load more parsing: Success: $successCount, Failed: $failCount');

    if (parsedServices.isNotEmpty) {
      services.addAll(parsedServices);
      debugPrint('✅ Added ${parsedServices.length} more services');
      debugPrint('   - Total services now: ${services.length}');
    }
  }

  /// Build URL for subcategory-only requests
  String _buildSubCategoryOnlyUrl(String subCategoryId, int page) {
    // Try to use the serviceBySubcategoryOnly method if it exists in AppUrl
    try {
      // Check if the method exists by calling it
      return AppUrl.serviceBySubcategoryOnly(subCategoryId, page);
    } catch (e) {
      // Fallback to building URL manually
      debugPrint('⚠️ Using fallback URL for subcategory-only request');
      return '${AppUrl.baseUrlV1}/${AppUrl.version1}/service/all?subCategory=$subCategoryId&page=$page&limit=10';
    }
  }

  /// Get headers with authentication
  Future<Map<String, String>> _getHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    // Add authorization header if user is logged in
    if (!isGuestMode.value && _cachedToken.value.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${_cachedToken.value}';
      debugPrint('🔐 Using cached token for authorization');
    } else {
      // Try to get fresh token if not cached
      final String? token = await _sharedPrefService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        _cachedToken.value = token;
        debugPrint('🔐 Using fresh token for authorization');
      } else {
        debugPrint('👤 No token available - using guest mode');
      }
    }

    return headers;
  }

  // ========== UTILITY METHODS ==========

  /// Refresh login status (call this after user logs in)
  Future<void> refreshLoginStatus() async {
    await _checkLoginStatus();
  }

  /// Clear services data
  void clearServices() {
    services.clear();
    servicesErrorMessage.value = '';
    currentCategoryId.value = '';
    currentSubCategoryId.value = '';
    currentSubCategoryName.value = '';
    currentPage.value = 1;
    hasMore.value = true;
    totalServices.value = 0;
    favoriteServiceIds.clear();
  }

  /// Refresh services with current parameters
  Future<void> refreshServices() async {
    if (currentCategoryId.value.isNotEmpty && currentSubCategoryId.value.isNotEmpty) {
      await fetchServicesByCategoryAndSubCategory(
        currentCategoryId.value,
        currentSubCategoryId.value,
        currentSubCategoryName.value,
      );
    } else if (currentSubCategoryId.value.isNotEmpty) {
      await fetchServicesBySubCategoryOnly(
        currentSubCategoryId.value,
        currentSubCategoryName.value,
      );
    }
  }

  /// Check if service exists
  bool hasService(String serviceId) {
    return services.any((service) => service.id == serviceId);
  }

  /// Get service by ID
  ServiceModel? getServiceById(String serviceId) {
    try {
      return services.firstWhere((service) => service.id == serviceId);
    } catch (e) {
      return null;
    }
  }

  /// Get current filter info
  String getCurrentFilterInfo() {
    if (currentCategoryId.value.isNotEmpty && currentSubCategoryId.value.isNotEmpty) {
      return 'Category: $currentCategoryId, SubCategory: ${currentSubCategoryName.value}';
    } else if (currentSubCategoryId.value.isNotEmpty) {
      return 'SubCategory: ${currentSubCategoryName.value}';
    } else {
      return 'No filter applied';
    }
  }

  /// Check if services are empty
  bool get isEmpty => services.isEmpty && !isLoadingServices.value;

  /// Check if has error
  bool get hasError => servicesErrorMessage.isNotEmpty && services.isEmpty;

  /// Get cached token (for other parts of the app if needed)
  String get token => _cachedToken.value;

  @override
  void onClose() {
    clearServices();
    super.onClose();
  }
}












