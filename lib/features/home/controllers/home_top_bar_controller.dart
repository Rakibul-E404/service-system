import 'package:get/get.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';
import 'package:manx_mate/core/network/network_caller.dart';
import 'package:manx_mate/core/network/network_response.dart';
import '../../../core/data/secured_storage.dart';

class HomeTopBarController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();
  final SecureStorageService _secureStorage = SecureStorageService();

  // Observable variables to store profile data
  RxString profileImageUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfileImage();
  }

  /// Fetch user profile image URL from the API
  Future<void> fetchUserProfileImage() async {
    try {
      final String? token = await _secureStorage.read('authToken');

      if (token == null || token.isEmpty) {
        return; // Handle token error if needed
      }

      final NetworkResponse response = await _networkCaller.getRequest(
        AppUrl.selfProfileUrl,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final Map<String, dynamic>? data = response.jsonResponse?['data'];
        final String image = data?['image'] ?? '';
        profileImageUrl.value = image;
      } else {
        // Handle failure (e.g., show a snackbar or error)
      }
    } catch (e) {
      // Handle any errors
    }
  }

  /// Get full image URL using AppUrl.getUserProfileImageUrl
  String getImageUrl() {
    if (profileImageUrl.value.isEmpty) return '';
    return AppUrl.getUserProfileImageUrl(profileImageUrl.value);
  }
}