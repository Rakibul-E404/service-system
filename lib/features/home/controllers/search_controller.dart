/**
import 'package:get/get.dart';

class HomeSearchController extends GetxController {
Rx<DateTime> dateTimePick = DateTime.now().obs;
}
*/










import 'package:get/get.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/network/network_response.dart';
import '../../../core/utils/api/app_url.dart';
import '../../../core/utils/token_service/token_storage_service.dart';

class HomeSearchController extends GetxController {
  RxList<dynamic> services = <dynamic>[].obs;
  RxBool isLoading = false.obs;
  RxString error = ''.obs;
  final SharedPrefService _sharedPrefService = SharedPrefService();

  @override
  void onInit() {
    super.onInit();
    fetchServices();
  }

  Future<void> fetchServices() async {
    isLoading.value = true;
    error.value = '';

    String? accessToken = await _sharedPrefService.getAccessToken();
    Map<String, String> headers = {};
    if (accessToken != null && accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    NetworkResponse response =
    await NetworkCaller().getRequest(AppUrl.allService, headers: headers);

    if (response.isSuccess) {
      final data = response.jsonResponse?['data']['data'];
      if (data is List) {
        services.value = data;
      } else {
        services.clear();
      }
    } else {
      error.value = response.errorMessage ?? 'Failed to fetch services';
      services.clear();
    }
    isLoading.value = false;
  }
}

