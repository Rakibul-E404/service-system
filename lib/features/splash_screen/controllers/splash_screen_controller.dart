import 'package:get/get.dart';
import 'package:manx_mate/core/routes/app_routes.dart';
import 'package:manx_mate/core/utils/token_service/token_storage_service.dart';

class SplashScreenController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    navigateToNextScreen();
  }

  Future<void> navigateToNextScreen() async {
    // Delay for splash screen display
    await Future.delayed(const Duration(seconds: 2));

    // Check login status
    final SharedPrefService sharedPrefService = SharedPrefService();
    bool isLoggedIn = await sharedPrefService.isLoggedIn();

    if (isLoggedIn) {
      // Navigate to main screen if logged in
      print('✅ User is logged in - Navigating to MainBottomNav');
      Get.offNamed(AppRoutes.mainBottomNavPage);
    } else {
      // Navigate to role selection if not logged in
      print('❌ User is not logged in - Navigating to Role Selection');
      Get.offNamed(AppRoutes.roleSelectionRoute);
    }
  }
}
