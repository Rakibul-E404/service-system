import 'package:get/get.dart';
import 'package:manx_mate/core/routes/app_routes.dart';

class SplashScreenController extends GetxController {
  Future<void> navigateToNextScreen() async {
    Future.delayed(Duration(seconds: 2), () {
      print('hello');
      Get.offNamed(AppRoutes.roleSelectionRoute);
    });
  }
}
