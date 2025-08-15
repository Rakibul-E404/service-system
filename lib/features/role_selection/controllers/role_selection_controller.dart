import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_constants.dart';
import 'package:manx_mate/core/routes/app_routes.dart';

import '../../../core/data/secured_storage.dart';
import '../../../core/utils/custom_snack_bar.dart';

class RoleSelectionController extends GetxController {
  RxString selectedRole = ''.obs;

  void selectRole(String role) {
    selectedRole.value = role;
  }

  Future<void> continueWithRole() async {
    // save it to the secured storage

    SecureStorageService().write(AppConstants.roleType, selectedRole.value);

    /// [final savedRole = await SecureStorageService().read(AppConstants.roleType);] is the method to fetch the saved role

    Get.toNamed(AppRoutes.loginRoute);
  }

  void continueWithoutRole() {
    ToastManager.show(
      icon: const Icon(CupertinoIcons.info, color: Colors.white),
      iconColor: Colors.white,
      message: " No Role Selected ! ",
      backgroundColor: Colors.red.shade700,
      animationDuration: const Duration(milliseconds: 200),
      animationCurve: Curves.easeInSine,
      duration: const Duration(seconds: 1),
    );
  }
}
