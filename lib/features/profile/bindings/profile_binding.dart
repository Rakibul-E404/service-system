import 'package:get/get.dart';
import 'package:manx_mate/features/profile/controllers/review_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/profile_information_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<ProfileInformationController>(() => ProfileInformationController());
    Get.lazyPut<MyReviewController>(() => MyReviewController());
  }
}
