import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/config/app_colors.dart';

class ReminderController extends GetxController {
  // Observables to manage the state of the switch
  RxBool isReminderOn = false.obs;

  // Method to toggle the reminder state
  void toggleReminder(bool value) {
    isReminderOn.value = value;
  }
}

class ReminderSwitch extends StatelessWidget {
  final String label;
  final VoidCallback onChange;

  // Constructor to pass the label
  const ReminderSwitch({Key? key, required this.label, required this.onChange}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the instance of ReminderController
    final ReminderController controller = Get.find();

    return Obx(() {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(child: Text(label, )),
            Switch(
              value: controller.isReminderOn.value,
              onChanged: controller.toggleReminder,
              activeColor: AppColors.primaryColor,
              inactiveThumbColor: AppColors.greyColor,
              inactiveTrackColor: AppColors.whiteColor,
            ),
          ],
        ),
      );
    });
  }
}
