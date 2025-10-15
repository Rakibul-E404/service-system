import 'package:get/get.dart';
import '../controllers/privacy_policy_screen_controller.dart';
import '../controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    // Add ProfileController
    Get.lazyPut<ProfileController>(
          () => ProfileController(),
    );

    // Add PrivacyPolicyTemplateController
    Get.lazyPut<PrivacyPolicyTemplateController>(
          () => PrivacyPolicyTemplateController(),
    );
  }
}