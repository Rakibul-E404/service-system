import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_strings.dart';

import '../../../core/config/app_constants.dart';
import '../../../core/data/secured_storage.dart';

class MainBottomNavController extends GetxController {
  RxString? savedRole = ''.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    savedRole?.value = await SecureStorageService().read(AppConstants.roleType) ?? '';
  }

  @override
  void dispose() {
    super.dispose();
  }
}
