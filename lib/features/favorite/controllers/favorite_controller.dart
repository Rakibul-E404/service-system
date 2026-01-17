import 'package:flutter/cupertino.dart' as developer show debugPrint;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/network/network_response.dart';
import '../../../core/utils/api/app_url.dart';
import '../../../core/utils/token_service/token_storage_service.dart';
import '../screens/fav_model.dart';

class FavoriteController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();
  final SharedPrefService _sharedPrefService = SharedPrefService();

  final RxList<FavoriteModel> favorites = <FavoriteModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMoreData = true.obs;

  /// Track favorite status for each service by ID
  final RxMap<String, bool> favoriteStatus = <String, bool>{}.obs;

  /// Track loading state for each service (used as a mutex)
  final RxMap<String, bool> loadingStatus = <String, bool>{}.obs;

  /// Map serviceId -> favoriteId (server side favorite entry id). Null if not present.
  final Map<String, String?> serviceToFavoriteId = {};

  /// Fetch favorites from API
  Future<void> fetchFavorites({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      favorites.clear();
      hasMoreData.value = true;
      serviceToFavoriteId.clear();
      favoriteStatus.clear();
    }

    if (!hasMoreData.value || isLoading.value) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final String? accessToken = await _sharedPrefService.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        errorMessage.value = 'Authentication required. Please login again.';
        return;
      }

      final String url = AppUrl.getAllFavoritesUrl(currentPage.value);
      developer.debugPrint('🌐 GET favorites from: $url');

      final Map<String, String> headers = {'Authorization': 'Bearer $accessToken'};
      final NetworkResponse response = await _networkCaller.getRequest(url, headers: headers);

      if (response.isSuccess && response.jsonResponse != null) {
        final Map<String, dynamic> responseData = response.jsonResponse!;

        if (responseData['success'] == true && responseData['data'] != null) {
          final Map<String, dynamic> dataObject = responseData['data'];
          final List<dynamic> dataList = dataObject['data'] ?? [];

          if (dataList.isEmpty) {
            hasMoreData.value = false;
            developer.debugPrint('📭 No more favorites data');
          } else {
            final List<FavoriteModel> newFavorites = [];

            for (var favData in dataList) {
              try {
                // 🔴 CRITICAL: Extract the correct service ID from "service" field
                final String? serviceId = favData['service']?.toString();
                if (serviceId == null || serviceId.isEmpty) continue;

                final profileData = favData['profile'] as Map<String, dynamic>? ?? {};
                final subCategoryData = favData['subCategory'] as Map<String, dynamic>? ?? {};

                // Create ProviderService using the correct service ID
                final providerService = ProviderService(
                  id: serviceId, // 🔴 Correct service ID
                  title: profileData['businessName']?.toString() ?? 'No Title',
                  description: profileData['description']?.toString() ?? '',
                  image: profileData['image']?.toString(),
                  location: profileData['location']?.toString() ?? 'Unknown Location',
                  rating: (favData['averageRating'] as num?)?.toDouble(),
                  categoryName: subCategoryData['name']?.toString() ?? '',
                  subcategoryName: subCategoryData['name']?.toString() ?? '',
                  provider: Provider(
                    id: profileData['author']?.toString() ?? '',
                    name: profileData['businessName']?.toString() ?? 'Unknown Provider',
                  ),
                  totalRating: favData['totalReviews'] as int?,
                );

                // Create FavoriteModel
                final favorite = FavoriteModel(
                  id: favData['_id']?.toString() ?? '',
                  userId: profileData['author']?.toString(),
                  providerServiceId: serviceId, // 🔴 Correct service ID
                  providerService: providerService,
                  isDeleted: false,
                );

                newFavorites.add(favorite);

                // Update local maps
                favoriteStatus[serviceId] = true;
                serviceToFavoriteId[serviceId] = favorite.id;
              } catch (e) {
                developer.debugPrint('❌ Error parsing favorite item: $e');
              }
            }

            favorites.addAll(newFavorites);

            // Pagination handling
            final pagination = dataObject['pagination'] as Map<String, dynamic>?;
            if (pagination != null) {
              final int totalPages = (pagination['totalPages'] as num?)?.toInt() ?? 1;
              final int currentPageNum = (pagination['page'] as num?)?.toInt() ?? currentPage.value;

              hasMoreData.value = currentPageNum < totalPages;
              currentPage.value = currentPageNum + 1;
            } else {
              currentPage.value++;
            }
          }
        } else {
          errorMessage.value = responseData['message']?.toString() ?? 'Failed to load favorites';
        }
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to load favorites';
      }
    } catch (e, stackTrace) {
      errorMessage.value = 'Error: ${e.toString()}';
      developer.debugPrint('💥 Exception fetching favorites: $e');
      developer.debugPrint('📚 StackTrace: $stackTrace');
    } finally {
      isLoading.value = false;
    }
  }

  /// Check if a service is in favorites
  bool isServiceInFavorites(String serviceId) {
    return favoriteStatus[serviceId] ?? favorites.any(
          (fav) => fav.providerServiceId == serviceId || fav.providerService?.id == serviceId,
    );
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(String serviceId) async {
    if (loadingStatus[serviceId] == true) return;
    loadingStatus[serviceId] = true;

    try {
      final bool currentlyFavorited = isServiceInFavorites(serviceId);
      final String? accessToken = await _sharedPrefService.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) return;

      if (!currentlyFavorited) {
        // Add favorite
        final String url = AppUrl.addFavoriteUrl(serviceId);
        final NetworkResponse response = await _networkCaller.postRequest(
          url,
          body: {},
          headers: {'Authorization': 'Bearer $accessToken'},
        );

        if (response.isSuccess && response.jsonResponse != null) {
          final resp = response.jsonResponse!;
          String? createdFavoriteId = resp['data']?['_id']?.toString() ?? resp['_id']?.toString();
          favoriteStatus[serviceId] = true;
          if (createdFavoriteId != null) serviceToFavoriteId[serviceId] = createdFavoriteId;
          await fetchFavorites(refresh: true);
        }
      } else {
        // Remove favorite
        String? favoriteId = serviceToFavoriteId[serviceId] ?? favorites.firstWhereOrNull(
                (fav) => fav.providerServiceId == serviceId
        )?.id;

        if (favoriteId == null) {
          await fetchFavorites(refresh: true);
          return;
        }

        final String url = AppUrl.deleteFavoriteUrl(favoriteId);
        final NetworkResponse response = await _networkCaller.deleteRequest(
          url,
          headers: {'Authorization': 'Bearer $accessToken'},
        );

        if (response.isSuccess) {
          favoriteStatus[serviceId] = false;
          serviceToFavoriteId.remove(serviceId);
          favorites.removeWhere((fav) => fav.id == favoriteId);
          favorites.refresh();
        }
      }
    } catch (e) {
      developer.debugPrint('❌ Exception in toggleFavorite: $e');
    } finally {
      loadingStatus[serviceId] = false;
    }
  }

  bool isFavorited(String serviceId) => favoriteStatus[serviceId] ?? false;

  bool isFavoriteLoading(String serviceId) => loadingStatus[serviceId] ?? false;

  Future<bool> removeFavorite(String favoriteId) async {
    final FavoriteModel? favorite = favorites.firstWhereOrNull((fav) => fav.id == favoriteId);
    final String? serviceId = favorite?.providerServiceId ?? favorite?.providerService?.id;
    if (serviceId != null) loadingStatus[serviceId] = true;

    try {
      final String? accessToken = await _sharedPrefService.getAccessToken();
      if (accessToken == null) return false;

      final String url = AppUrl.deleteFavoriteUrl(favoriteId);
      final NetworkResponse response = await _networkCaller.deleteRequest(
        url,
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.isSuccess) {
        favorites.removeWhere((fav) => fav.id == favoriteId);
        if (serviceId != null) {
          favoriteStatus[serviceId] = false;
          serviceToFavoriteId.remove(serviceId);
        }
        favorites.refresh();
        return true;
      }
      return false;
    } catch (e) {
      developer.debugPrint('❌ Error removing favorite: $e');
      return false;
    } finally {
      if (serviceId != null) loadingStatus[serviceId] = false;
    }
  }

  Future<void> refreshFavorites() async => await fetchFavorites(refresh: true);
  Future<void> loadMoreFavorites() async {
    if (!isLoading.value && hasMoreData.value) await fetchFavorites();
  }

  void setFavoriteStatus(String serviceId, bool isFavorited, {String? favoriteId}) {
    favoriteStatus[serviceId] = isFavorited;
    if (favoriteId != null) {
      serviceToFavoriteId[serviceId] = favoriteId;
    } else if (!isFavorited) {
      serviceToFavoriteId.remove(serviceId);
    }
  }

  void clearFavorites() {
    favorites.clear();
    favoriteStatus.clear();
    loadingStatus.clear();
    serviceToFavoriteId.clear();
    currentPage.value = 1;
    hasMoreData.value = true;
  }

  @override
  void onInit() {
    super.onInit();
    developer.debugPrint('🎯 FavoriteController initialized');
  }

  @override
  void onClose() {
    clearFavorites();
    super.onClose();
  }
}


