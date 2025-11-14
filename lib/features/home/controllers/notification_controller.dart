/**
import 'package:get/get.dart';

class NotificationController extends GetxController {}*/











import 'package:get/get.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/network/network_response.dart';
import '../../../core/utils/api/app_url.dart';
import '../../../core/utils/token_service/token_storage_service.dart';

class NotificationController extends GetxController {
  final SharedPrefService _sharedPrefService = SharedPrefService();
  final NetworkCaller _networkCaller = NetworkCaller();

  RxList<dynamic> notifications = RxList<dynamic>([]);

  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      String? token = await _sharedPrefService.getAccessToken();

      if (token == null || token.isEmpty) {
        errorMessage.value = 'Access token not found. Please login again.';
        isLoading.value = false;
        return;
      }

      Map<String, String> headers = {
        'Authorization': 'Bearer $token',
      };

      NetworkResponse response = await _networkCaller.getRequest(
        AppUrl.notificationUrl,
        headers: headers,
      );

      if (response.isSuccess) {
        final data = response.jsonResponse?['data']['data'];
        if (data != null && data is List) {
          notifications.value = data;
        } else {
          errorMessage.value = 'No notifications found.';
          notifications.clear();
        }
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to fetch notifications.';
        notifications.clear();
      }
    } catch (e) {
      errorMessage.value = 'Error fetching notifications: $e';
      notifications.clear();
    } finally {
      isLoading.value = false;
    }
  }
}
