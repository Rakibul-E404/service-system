/**
import 'package:get/get.dart';
import '../controllers/splash_screen_controller.dart';

class SplashScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashScreenController>(
      () => SplashScreenController()
    );
  }
}
*/






import 'package:get/get.dart';
import '../controllers/splash_screen_controller.dart';

class SplashScreenBinding extends Bindings {
  @override
  void dependencies() {
    // Lazy load SplashScreenController when it's needed
    Get.lazyPut<SplashScreenController>(
          () => SplashScreenController(),
      fenix: true,  // Keeps the controller alive even after the splash screen is destroyed
    );
  }
}

