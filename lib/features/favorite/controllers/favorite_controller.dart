
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

  // Track favorite status for each service by ID
  final RxMap<String, bool> favoriteStatus = <String, bool>{}.obs;

  // Track loading state for each service (used as a mutex)
  final RxMap<String, bool> loadingStatus = <String, bool>{}.obs;

  // Map serviceId -> favoriteId (server side favorite entry id). Null if not present.
  final Map<String, String?> serviceToFavoriteId = {};

  /// Fetch favorites from API using AppUrl.getAllFavoritesUrl
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

      // Use AppUrl.getAllFavoritesUrl as requested
      final String url = AppUrl.getAllFavoritesUrl(currentPage.value);
      developer.debugPrint('🌐 GET favorites from: $url');

      final Map<String, String> headers = {'Authorization': 'Bearer $accessToken'};

      final NetworkResponse response = await _networkCaller.getRequest(url, headers: headers);
      developer.debugPrint('📡 Response status: ${response.statusCode}');

      if (response.isSuccess && response.jsonResponse != null) {
        final Map<String, dynamic> responseData = response.jsonResponse!;

        if (responseData['success'] == true && responseData['data'] != null) {
          final Map<String, dynamic> dataObject = responseData['data'];
          final List<dynamic> dataList = dataObject['data'] ?? [];

          if (dataList.isEmpty) {
            hasMoreData.value = false;
            developer.debugPrint('📭 No more favorites data');
          } else {
            // Parse favorites from the new JSON structure
            final List<FavoriteModel> newFavorites = [];

            for (var favData in dataList) {
              try {
                // Extract service ID from the profile data
                final String? serviceId = favData['profile']?['_id']?.toString();

                if (serviceId != null && serviceId.isNotEmpty) {
                  // Create ProviderService from the new JSON structure
                  final profileData = favData['profile'] as Map<String, dynamic>? ?? {};
                  final subCategoryData = favData['subCategory'] as Map<String, dynamic>? ?? {};

                  final providerService = ProviderService(
                    id: serviceId,
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
                    providerServiceId: serviceId,
                    providerService: providerService,
                    isDeleted: false,
                  );

                  newFavorites.add(favorite);

                  // Update favorite status maps
                  favoriteStatus[serviceId] = true;
                  serviceToFavoriteId[serviceId] = favorite.id;

                  developer.debugPrint('✅ Marked service $serviceId as favorited (favoriteId: ${favorite.id})');
                } else {
                  developer.debugPrint('⚠️ Skipping favorite item with no service ID');
                }
              } catch (e) {
                developer.debugPrint('❌ Error parsing favorite item: $e');
                developer.debugPrint('📋 Failed data: $favData');
              }
            }

            favorites.addAll(newFavorites);

            // Update pagination
            final pagination = dataObject['pagination'] as Map<String, dynamic>?;
            if (pagination != null) {
              final int totalPages = (pagination['totalPages'] as num?)?.toInt() ?? 1;
              final int currentPageNum = (pagination['page'] as num?)?.toInt() ?? currentPage.value;

              hasMoreData.value = currentPageNum < totalPages;
              currentPage.value = currentPageNum + 1;

              developer.debugPrint('📊 Pagination: Page $currentPageNum of $totalPages');
              developer.debugPrint('📊 Has more data: $hasMoreData');
            } else {
              // Fallback: increment page if we got data
              currentPage.value++;
              developer.debugPrint('📊 Using fallback pagination, new page: ${currentPage.value}');
            }

            developer.debugPrint('📊 Loaded ${newFavorites.length} favorites, total: ${favorites.length}');
          }
        } else {
          errorMessage.value = responseData['message']?.toString() ?? 'Failed to load favorites';
          developer.debugPrint('❌ API error: ${errorMessage.value}');
        }
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to load favorites';
        developer.debugPrint('❌ Network error: ${errorMessage.value}');
      }
    } catch (e, stackTrace) {
      errorMessage.value = 'Error: ${e.toString()}';
      developer.debugPrint('💥 Exception fetching favorites: $e');
      developer.debugPrint('📚 StackTrace: $stackTrace');
    } finally {
      isLoading.value = false;
    }
  }

  /// Check if a specific service is in favorites
  bool isServiceInFavorites(String serviceId) {
    // First check our local map
    if (favoriteStatus.containsKey(serviceId)) {
      return favoriteStatus[serviceId] == true;
    }

    // Also check in the favorites list
    return favorites.any((fav) =>
    fav.providerServiceId == serviceId ||
        fav.providerService?.id == serviceId
    );
  }

  /// Toggle favorite status for a service.
  /// Adds (POST) when not favorited; removes (DELETE) when favorited.
  Future<void> toggleFavorite(String serviceId) async {
    developer.debugPrint('🎯 ========== TOGGLE FAVORITE ==========');
    developer.debugPrint('📥 serviceId: $serviceId');

    // First, check if service is already in our local state
    bool currentlyFavorited = isServiceInFavorites(serviceId);
    developer.debugPrint('📊 Current favorite status for $serviceId: $currentlyFavorited');

    // Prevent concurrent operations for same service
    if (loadingStatus[serviceId] == true) {
      developer.debugPrint('⏳ Operation already in progress for $serviceId, ignoring tap.');
      return;
    }
    // Lock the service
    loadingStatus[serviceId] = true;

    try {
      final String? accessToken = await _sharedPrefService.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        developer.debugPrint('❌ No access token available');
        Get.snackbar(
          'Error',
          'Please login to add favorites',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
        return;
      }

      if (!currentlyFavorited) {
        // --- Add favorite (POST) ---
        final String url = AppUrl.addFavoriteUrl(serviceId);
        developer.debugPrint('🌐 POST to: $url');

        final NetworkResponse response = await _networkCaller.postRequest(
          url,
          body: {},
          headers: <String, String>{'Authorization': 'Bearer $accessToken'},
        );

        developer.debugPrint('📡 POST response: isSuccess=${response.isSuccess} status=${response.statusCode}');

        if (response.isSuccess && response.jsonResponse != null) {
          final resp = response.jsonResponse!;
          developer.debugPrint('📊 Response data: $resp');

          // Try to extract the created favorite id from response
          String? createdFavoriteId;
          try {
            if (resp['data'] is Map && resp['data']['_id'] != null) {
              createdFavoriteId = resp['data']['_id'].toString();
              developer.debugPrint('✅ Extracted favoriteId from data._id: $createdFavoriteId');
            } else if (resp['_id'] != null) {
              createdFavoriteId = resp['_id'].toString();
              developer.debugPrint('✅ Extracted favoriteId from _id: $createdFavoriteId');
            }
          } catch (e) {
            developer.debugPrint('❌ Error parsing response: $e');
          }

          // Update local state instantly for the UI
          favoriteStatus[serviceId] = true;
          if (createdFavoriteId != null) {
            serviceToFavoriteId[serviceId] = createdFavoriteId;
            developer.debugPrint('🆔 Stored favoriteId for $serviceId -> $createdFavoriteId');
          }

          // Refresh favorites list to get updated data
          await fetchFavorites(refresh: true);

          Get.snackbar(
            'Success',
            'Added to favorites',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.8),
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        } else {
          developer.debugPrint('❌ POST failed: ${response.errorMessage}');
          Get.snackbar(
            'Error',
            response.errorMessage ?? 'Failed to add favorite',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.8),
            colorText: Colors.white,
          );
        }
      } else {
        // --- Remove favorite (DELETE) ---
        String? favoriteId = serviceToFavoriteId[serviceId];

        if (favoriteId == null || favoriteId.isEmpty) {
          // Try to find favoriteId from favorites list
          final FavoriteModel? favorite = favorites.firstWhereOrNull(
                  (fav) => fav.providerServiceId == serviceId || fav.providerService?.id == serviceId
          );

          if (favorite != null && favorite.id.isNotEmpty) {
            favoriteId = favorite.id;
            developer.debugPrint('🔍 Found favoriteId from list: $favoriteId');
          } else {
            developer.debugPrint('⚠️ No favoriteId found for $serviceId; refreshing from server and aborting delete.');
            await refreshFavorites();
            Get.snackbar(
              'Info',
              'Could not remove favorite immediately. Refreshed list.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange.withOpacity(0.8),
              colorText: Colors.white,
            );
            return;
          }
        }

        // For DELETE, use the delete favorite URL
        final String url = AppUrl.deleteFavoriteUrl(favoriteId);
        developer.debugPrint('🌐 DELETE to: $url');

        final NetworkResponse response = await _networkCaller.deleteRequest(
          url,
          headers: <String, String>{'Authorization': 'Bearer $accessToken'},
        );

        developer.debugPrint('📡 DELETE response: isSuccess=${response.isSuccess} status=${response.statusCode}');

        if (response.isSuccess) {
          // Update local state instantly (remove from favorite)
          favoriteStatus[serviceId] = false;
          serviceToFavoriteId.remove(serviceId);

          // Refresh the favorites list to get updated data
          await fetchFavorites(refresh: true);

          Get.snackbar(
            'Success',
            'Removed from favorites',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.8),
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        } else {
          developer.debugPrint('❌ DELETE failed: ${response.errorMessage}');
          Get.snackbar(
            'Error',
            response.errorMessage ?? 'Failed to remove favorite',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.8),
            colorText: Colors.white,
          );
        }
      }
    } catch (e, stackTrace) {
      developer.debugPrint('💥 Exception in toggleFavorite: $e');
      developer.debugPrint('📚 StackTrace: $stackTrace');
      Get.snackbar(
        'Error',
        'Something went wrong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      loadingStatus[serviceId] = false;
      developer.debugPrint('🏁 ========== TOGGLE COMPLETE ==========');
    }
  }




  /// Check if a service is favorited
  bool isFavorited(String serviceId) {
    return favoriteStatus[serviceId] ?? false;
  }

  /// Check if a specific service favorite action is loading
  bool isFavoriteLoading(String serviceId) {
    return loadingStatus[serviceId] ?? false;
  }

  /// Remove favorite by ID and update UI instantly
  Future<bool> removeFavorite(String favoriteId) async {
    // 🔹 Find the service associated with this favoriteId before deleting
    final FavoriteModel? favoriteToRemove = favorites.firstWhereOrNull(
            (fav) => fav.id == favoriteId
    );

    final String? serviceId = favoriteToRemove?.providerServiceId ?? favoriteToRemove?.providerService?.id;

    // Lock the service if we found one
    if (serviceId != null) loadingStatus[serviceId] = true;

    try {
      final String? accessToken = await _sharedPrefService.getAccessToken();
      if (accessToken == null) return false;

      final String url = AppUrl.deleteFavoriteUrl(favoriteId);
      developer.debugPrint('🌐 DELETE favorite: $url');

      final NetworkResponse response = await _networkCaller.deleteRequest(
          url,
          headers: {'Authorization': 'Bearer $accessToken'}
      );

      if (response.isSuccess) {
        // 🔹 Update local list
        favorites.removeWhere((fav) => fav.id == favoriteId);

        // 🔹 Update status maps so hearts turn grey instantly on other screens
        if (serviceId != null) {
          favoriteStatus[serviceId] = false;
          serviceToFavoriteId.remove(serviceId);
        }

        favorites.refresh();
        developer.debugPrint('✅ Successfully deleted favorite $favoriteId');
        return true;
      } else {
        developer.debugPrint('❌ Delete failed: ${response.errorMessage}');
        return false;
      }
    } catch (e) {
      developer.debugPrint('❌ Error removing favorite: $e');
      return false;
    } finally {
      if (serviceId != null) loadingStatus[serviceId] = false;
    }
  }



  /// Refresh favorites
  Future<void> refreshFavorites() async {
    await fetchFavorites(refresh: true);
  }

  /// Load more favorites for pagination
  Future<void> loadMoreFavorites() async {
    if (!isLoading.value && hasMoreData.value) {
      await fetchFavorites();
    }
  }

  /// Set initial favorite status (useful when loading data)
  void setFavoriteStatus(String serviceId, bool isFavorited, {String? favoriteId}) {
    favoriteStatus[serviceId] = isFavorited;
    if (favoriteId != null) {
      serviceToFavoriteId[serviceId] = favoriteId;
    } else if (!isFavorited) {
      serviceToFavoriteId.remove(serviceId);
    }
  }

  /// Clear all favorite data
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
    // Don't auto-fetch on init, let the FavoriteScreen handle it based on login state
  }

  @override
  void onClose() {
    clearFavorites();
    super.onClose();
  }
}








