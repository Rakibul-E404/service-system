
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/network/network_response.dart';
import '../../../core/utils/api/app_url.dart';
import '../../../core/utils/logger_utils.dart';
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

  /// Fetch favorites from API and populate serviceToFavoriteId map
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

      final String url = '${AppUrl.baseUrl}/favorite/?page=${currentPage.value}&limit=10';
      final Map<String, String> headers = {'Authorization': 'Bearer $accessToken'};

      final NetworkResponse response = await _networkCaller.getRequest(url, headers: headers);
      LoggerUtils.debug(response.jsonResponse);

      if (response.isSuccess && response.jsonResponse != null) {
        final Map<String, dynamic>? dataObject = response.jsonResponse!['data'];
        if (dataObject == null) {
          errorMessage.value = 'Invalid response format';
          return;
        }

        final List<dynamic> dataList = dataObject['data'] ?? [];
        if (dataList.isEmpty) {
          hasMoreData.value = false;
        } else {
          final List<FavoriteModel> newFavorites = dataList
              .map((json) => FavoriteModel.fromJson(json as Map<String, dynamic>))
              .toList();

          // Populate maps to reflect server state
          for (var fav in newFavorites) {
            final serviceId = fav.providerService?.id;
            if (serviceId != null) {
              favoriteStatus[serviceId] = true;
              // fav.id is server favorite id
              if (fav.id != null) {
                serviceToFavoriteId[serviceId] = fav.id;
              }
            }
          }

          favorites.addAll(newFavorites);
          currentPage.value++;
        }
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to load favorites';
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // /// Toggle favorite status for a service.
  // /// Adds (POST) when not favorited; removes (DELETE) when favorited.
  // Future<void> toggleFavorite(String serviceId) async {
  //   debugPrint('🎯 ========== TOGGLE FAVORITE ==========');
  //   debugPrint('📥 serviceId: $serviceId');
  //
  //   // Prevent concurrent operations for same service
  //   if (loadingStatus[serviceId] == true) {
  //     debugPrint('⏳ Operation already in progress for $serviceId, ignoring tap.');
  //     return;
  //   }
  //   // Lock the service
  //   loadingStatus[serviceId] = true;
  //
  //   try {
  //     final String? accessToken = await _sharedPrefService.getAccessToken();
  //     if (accessToken == null || accessToken.isEmpty) {
  //       debugPrint('❌ No access token available');
  //       Get.snackbar(
  //         'Error',
  //         'Please login to add favorites',
  //         snackPosition: SnackPosition.BOTTOM,
  //         backgroundColor: Colors.red.withOpacity(0.8),
  //         colorText: Colors.white,
  //       );
  //       return;
  //     }
  //
  //     final bool currentlyFavorited = favoriteStatus[serviceId] ?? false;
  //
  //     if (!currentlyFavorited) {
  //       // --- Add favorite (POST) using the new endpoint ---
  //       final String url = AppUrl.addFavoriteUrl(serviceId);
  //       debugPrint('🌐 POST to: $url');
  //
  //       final NetworkResponse response = await _networkCaller.postRequest(
  //         url,
  //         body: {}, // API expects body, send empty object
  //         headers: <String, String>{'Authorization': 'Bearer $accessToken'},
  //       );
  //
  //       debugPrint('📡 POST response: isSuccess=${response.isSuccess} status=${response.statusCode}');
  //
  //       if (response.isSuccess && response.jsonResponse != null) {
  //         // Try to extract the created favorite id from response
  //         String? createdFavoriteId;
  //         try {
  //           // Many APIs return created object in data or data['data'], handle commonly used shapes
  //           final resp = response.jsonResponse!;
  //           if (resp['data'] is Map && resp['data']['id'] != null) {
  //             createdFavoriteId = resp['data']['id'].toString();
  //           } else if (resp['data'] is Map && resp['data']['data'] is Map && resp['data']['data']['id'] != null) {
  //             createdFavoriteId = resp['data']['data']['id'].toString();
  //           } else if (resp['id'] != null) {
  //             createdFavoriteId = resp['id'].toString();
  //           }
  //         } catch (_) {
  //           // ignore parse errors; createdFavoriteId may remain null
  //         }
  //
  //         // Update local state instantly for the UI
  //         favoriteStatus[serviceId] = true;
  //         if (createdFavoriteId != null) {
  //           serviceToFavoriteId[serviceId] = createdFavoriteId;
  //           debugPrint('🆔 Stored favoriteId for $serviceId -> $createdFavoriteId');
  //         }
  //
  //         // Instant feedback on UI
  //         updateFavoriteUI(serviceId, true);
  //
  //         Get.snackbar(
  //           'Success',
  //           'Added to favorites',
  //           snackPosition: SnackPosition.BOTTOM,
  //           backgroundColor: Colors.green.withOpacity(0.8),
  //           colorText: Colors.white,
  //           duration: const Duration(seconds: 2),
  //         );
  //       } else {
  //         debugPrint('❌ POST failed: ${response.errorMessage}');
  //         Get.snackbar(
  //           'Error',
  //           response.errorMessage ?? 'Failed to add favorite',
  //           snackPosition: SnackPosition.BOTTOM,
  //           backgroundColor: Colors.red.withOpacity(0.8),
  //           colorText: Colors.white,
  //         );
  //       }
  //     } else {
  //       // --- Remove favorite (DELETE) ---
  //       final String? favoriteId = serviceToFavoriteId[serviceId];
  //       if (favoriteId == null || favoriteId.isEmpty) {
  //         // We do not have favoriteId — fall back to refreshing list and informing user
  //         debugPrint('⚠️ No favoriteId found for $serviceId; refreshing from server and aborting delete.');
  //         await refreshFavorites();
  //         Get.snackbar(
  //           'Info',
  //           'Could not remove favorite immediately. Refreshed list.',
  //           snackPosition: SnackPosition.BOTTOM,
  //           backgroundColor: Colors.orange.withOpacity(0.8),
  //           colorText: Colors.white,
  //         );
  //         return;
  //       }
  //
  //       final String url = '${AppUrl.baseUrl}/favorite/$favoriteId';
  //       debugPrint('🌐 DELETE to: $url');
  //
  //       final NetworkResponse response = await _networkCaller.deleteRequest(
  //         url,
  //         headers: <String, String>{'Authorization': 'Bearer $accessToken'},
  //       );
  //
  //       debugPrint('📡 DELETE response: isSuccess=${response.isSuccess} status=${response.statusCode}');
  //
  //       if (response.isSuccess) {
  //         // Update local state instantly (remove from favorite)
  //         favoriteStatus[serviceId] = false;
  //         serviceToFavoriteId.remove(serviceId);
  //
  //         // Instant feedback on UI
  //         updateFavoriteUI(serviceId, false);
  //
  //         Get.snackbar(
  //           'Success',
  //           'Removed from favorites',
  //           snackPosition: SnackPosition.BOTTOM,
  //           backgroundColor: Colors.green.withOpacity(0.8),
  //           colorText: Colors.white,
  //           duration: const Duration(seconds: 2),
  //         );
  //       } else {
  //         debugPrint('❌ DELETE failed: ${response.errorMessage}');
  //         Get.snackbar(
  //           'Error',
  //           response.errorMessage ?? 'Failed to remove favorite',
  //           snackPosition: SnackPosition.BOTTOM,
  //           backgroundColor: Colors.red.withOpacity(0.8),
  //           colorText: Colors.white,
  //         );
  //       }
  //     }
  //   } catch (e, stackTrace) {
  //     debugPrint('💥 Exception in toggleFavorite: $e');
  //     debugPrint('📚 StackTrace: $stackTrace');
  //     Get.snackbar(
  //       'Error',
  //       'Something went wrong',
  //       snackPosition: SnackPosition.BOTTOM,
  //       backgroundColor: Colors.red.withOpacity(0.8),
  //       colorText: Colors.white,
  //     );
  //   } finally {
  //     loadingStatus[serviceId] = false;
  //     debugPrint('🏁 ========== TOGGLE COMPLETE ==========');
  //   }
  // }
  /// Toggle favorite status for a service.
  /// Adds (POST) when not favorited; removes (DELETE) when favorited.
  Future<void> toggleFavorite(String serviceId) async {
    debugPrint('🎯 ========== TOGGLE FAVORITE ==========');
    debugPrint('📥 serviceId: $serviceId');

    // Prevent concurrent operations for same service
    if (loadingStatus[serviceId] == true) {
      debugPrint('⏳ Operation already in progress for $serviceId, ignoring tap.');
      return;
    }
    // Lock the service
    loadingStatus[serviceId] = true;

    try {
      final String? accessToken = await _sharedPrefService.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        debugPrint('❌ No access token available');
        Get.snackbar(
          'Error',
          'Please login to add favorites',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
        return;
      }

      final bool currentlyFavorited = favoriteStatus[serviceId] ?? false;

      if (!currentlyFavorited) {
        // --- Add favorite (POST) ---
        // Use AppUrl.addFavoriteUrl as requested
        final String url = AppUrl.addFavoriteUrl(serviceId);
        debugPrint('🌐 POST to: $url');

        final NetworkResponse response = await _networkCaller.postRequest(
          url,
          body: {}, // API expects body, send empty object
          headers: <String, String>{'Authorization': 'Bearer $accessToken'},
        );

        debugPrint('📡 POST response: isSuccess=${response.isSuccess} status=${response.statusCode}');

        if (response.isSuccess && response.jsonResponse != null) {
          // Try to extract the created favorite id from response
          String? createdFavoriteId;
          try {
            final resp = response.jsonResponse!;
            debugPrint('📊 Response data: $resp');

            if (resp['data'] is Map && resp['data']['_id'] != null) {
              createdFavoriteId = resp['data']['_id'].toString();
              debugPrint('✅ Extracted favoriteId from data._id: $createdFavoriteId');
            } else if (resp['_id'] != null) {
              createdFavoriteId = resp['_id'].toString();
              debugPrint('✅ Extracted favoriteId from _id: $createdFavoriteId');
            }
          } catch (e) {
            debugPrint('❌ Error parsing response: $e');
          }

          // Update local state instantly for the UI
          favoriteStatus[serviceId] = true;
          if (createdFavoriteId != null) {
            serviceToFavoriteId[serviceId] = createdFavoriteId;
            debugPrint('🆔 Stored favoriteId for $serviceId -> $createdFavoriteId');
          }

          // Instant feedback on UI
          updateFavoriteUI(serviceId, true);

          Get.snackbar(
            'Success',
            'Added to favorites',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.8),
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        } else {
          debugPrint('❌ POST failed: ${response.errorMessage}');
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
        final String? favoriteId = serviceToFavoriteId[serviceId];
        if (favoriteId == null || favoriteId.isEmpty) {
          // We do not have favoriteId — fall back to refreshing list and informing user
          debugPrint('⚠️ No favoriteId found for $serviceId; refreshing from server and aborting delete.');
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

        // For DELETE, use the base URL with favoriteId
        final String url = '${AppUrl.baseUrl}/favorite/$favoriteId';
        debugPrint('🌐 DELETE to: $url');

        final NetworkResponse response = await _networkCaller.deleteRequest(
          url,
          headers: <String, String>{'Authorization': 'Bearer $accessToken'},
        );

        debugPrint('📡 DELETE response: isSuccess=${response.isSuccess} status=${response.statusCode}');

        if (response.isSuccess) {
          // Update local state instantly (remove from favorite)
          favoriteStatus[serviceId] = false;
          serviceToFavoriteId.remove(serviceId);

          // Instant feedback on UI
          updateFavoriteUI(serviceId, false);

          Get.snackbar(
            'Success',
            'Removed from favorites',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.8),
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        } else {
          debugPrint('❌ DELETE failed: ${response.errorMessage}');
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
      debugPrint('💥 Exception in toggleFavorite: $e');
      debugPrint('📚 StackTrace: $stackTrace');
      Get.snackbar(
        'Error',
        'Something went wrong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      loadingStatus[serviceId] = false;
      debugPrint('🏁 ========== TOGGLE COMPLETE ==========');
    }
  }


  /// Function to update the UI immediately
  void updateFavoriteUI(String serviceId, bool isFavorited) {
    // Update the local favorite status instantly
    favoriteStatus[serviceId] = isFavorited;

    // Optionally, you can update the favorite list if the service is shown there
    final int index = favorites.indexWhere((f) => f.providerService?.id == serviceId);
    if (index != -1) {
      favorites[index].isDeleted = !isFavorited; // Update the UI item status as deleted or not
      favorites.refresh();
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

  /// Remove favorite by ID and update UI instantly (keeps compatibility)
  Future<bool> removeFavorite(String favoriteId) async {
    try {
      final String? accessToken = await _sharedPrefService.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        return false;
      }

      final String url = '${AppUrl.baseUrl}/favorite/$favoriteId';
      final Map<String, String> headers = {'Authorization': 'Bearer $accessToken'};

      final NetworkResponse response = await _networkCaller.deleteRequest(url, headers: headers);
      if (response.isSuccess) {
        final int index = favorites.indexWhere((fav) => fav.id == favoriteId);
        if (index != -1) {
          final serviceId = favorites[index].providerService?.id;
          favorites[index].isDeleted = true;
          if (serviceId != null) {
            favoriteStatus[serviceId] = false;
            serviceToFavoriteId.remove(serviceId);
          }
          favorites.refresh();
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Refresh favorites
  Future<void> refreshFavorites() async {
    await fetchFavorites(refresh: true);
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
    fetchFavorites();
  }

  @override
  void dispose() {
    clearFavorites();
    super.dispose();
  }
}












