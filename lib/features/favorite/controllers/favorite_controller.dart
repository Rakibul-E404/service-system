import 'package:get/get.dart';
import 'package:manx_mate/core/utils/logger_utils.dart';
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

  /// Fetch favorites from API
  Future<void> fetchFavorites({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      favorites.clear();
      hasMoreData.value = true;
    }

    if (!hasMoreData.value || isLoading.value) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final String? accessToken = await _sharedPrefService.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        errorMessage.value = 'Authentication required. Please login again.';
        isLoading.value = false;
        return;
      }

      final String url = '${AppUrl.baseUrl}/favorite/?page=${currentPage.value}&limit=10';

      final Map<String, String> headers = {'Authorization': 'Bearer $accessToken'};

      final NetworkResponse response = await _networkCaller.getRequest(url, headers: headers);
      LoggerUtils.debug(response.jsonResponse);

      if (response.isSuccess && response.jsonResponse != null) {
        // FIXED: Access nested data object
        final Map<String, dynamic>? dataObject = response.jsonResponse!['data'];

        if (dataObject == null) {
          errorMessage.value = 'Invalid response format';
          isLoading.value = false;
          return;
        }

        final List<dynamic> dataList = dataObject['data'] ?? [];

        if (dataList.isEmpty) {
          hasMoreData.value = false;
        } else {
          final List<FavoriteModel> newFavorites = dataList
              .map((json) => FavoriteModel.fromJson(json as Map<String, dynamic>))
              .toList();

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

  /// Remove favorite by ID
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
        favorites.removeWhere((fav) => fav.id == favoriteId);
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

  @override
  void onInit() {
    super.onInit();
    fetchFavorites();
  }

  @override
  void dispose() {
    favorites.clear();
    super.dispose();
  }
}
