
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../controllers/change_password_controller.dart';
import '../controllers/reset_password_controller.dart';
import '../controllers/sign_in_controller.dart';
import '../controllers/sign_up_controller.dart';
import '../controllers/taking_email_controller.dart';
import '../controllers/verify_email_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignInController>(
      () => SignInController()
    );

    Get.lazyPut<SignUpController>(
      () => SignUpController()
    );

    Get.lazyPut<ResetPasswordController>(
      () => ResetPasswordController()
    );

    Get.lazyPut<ForgotPasswordController>(
      () => ForgotPasswordController()
    );

    Get.lazyPut<VerifyEmailController>(
      () => VerifyEmailController()
    );

    Get.lazyPut<ChangePasswordController>(
      () => ChangePasswordController()
    );
  }
}
