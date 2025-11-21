/**
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
    // Save it to the secured storage
    await SecureStorageService().write(AppConstants.roleType, selectedRole.value);

    /// Navigate to signup and pass the role
    Get.toNamed(
      // AppRoutes.signUpRoute,
      AppRoutes.loginRoute,
      arguments: {'role': selectedRole.value},
    );
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
}*/








///
///
///
///
/// todo::: adding the skip button functionality
///
///
///
///
///


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_constants.dart';
import '../../../core/data/secured_storage.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/custom_snack_bar.dart';

class RoleSelectionController extends GetxController {
  RxString selectedRole = ''.obs;

  void selectRole(String role) {
    selectedRole.value = role;
  }

  Future<void> continueWithRole() async {
    // Save it to the secured storage
    await SecureStorageService().write(AppConstants.roleType, selectedRole.value);

    /// Navigate to signup and pass the role
    Get.toNamed(
      AppRoutes.loginRoute,
      arguments: {'role': selectedRole.value}, // Make sure role is passed here
    );
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