import 'package:get/get.dart';
import '../controllers/mainbottomnav_controller.dart';

class MainBottomNavBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainBottomNavController>(
      () => MainBottomNavController()
    );
  }
}
