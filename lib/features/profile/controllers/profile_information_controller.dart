// Profile Controller
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class ProfileInformationController extends GetxController {
  RxBool isEditing = false.obs;
  RxString name = 'Ahsanul Hamid Mim'.obs;
  RxString email = 'supporib@gmail.com'.obs;
  RxString location = 'Cork, Ireland'.obs;

  // Text controllers for editing
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController locationController;

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController(text: name.value);
    emailController = TextEditingController(text: email.value);
    locationController = TextEditingController(text: location.value);
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    locationController.dispose();
    super.onClose();
  }

  void toggleEdit() {
    if (isEditing.value) {
      // Save changes
      name.value = nameController.text;
      email.value = emailController.text;
      location.value = locationController.text;

      // Get.snackbar(
      //   'Profile Updated',
      //   'Your information has been saved successfully',
      //   snackPosition: SnackPosition.BOTTOM,
      //   backgroundColor: Colors.green,
      //   colorText: Colors.white,
      //   duration: const Duration(seconds: 2),
      // );
    } else {
      // Enter edit mode - sync controllers with current values
      nameController.text = name.value;
      emailController.text = email.value;
      locationController.text = location.value;
    }
    isEditing.toggle();
  }

  void cancelEdit() {
    // Reset controllers to original values
    nameController.text = name.value;
    emailController.text = email.value;
    locationController.text = location.value;
    isEditing.value = false;
  }
}