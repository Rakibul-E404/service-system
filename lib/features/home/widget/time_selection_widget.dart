import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_colors.dart';

// GetX Controller for Time Selection
class TimeSelectionController extends GetxController {
  var selectedTime = ''.obs;
  var timeSlots = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    generateTimeSlots();
  }

  void generateTimeSlots() {
    List<String> slots = [];

    // Morning slots (9am - 12pm)
    for (int i = 9; i <= 12; i++) {
      if (i == 12) {
        slots.add('${i}pm');
      } else {
        slots.add('${i}am');
      }
    }

    // Afternoon slots (1pm - 6pm)
    for (int i = 1; i <= 6; i++) {
      slots.add('${i}pm');
    }

    timeSlots.value = slots;
  }

  void selectTime(String time) {
    selectedTime.value = time;
  }

  bool isSelected(String time) {
    return selectedTime.value == time;
  }
}

// Time Selector Widget
class TimeSelector extends StatelessWidget {
  final Function(String)? onTimeSelected;
  final String? initialTime;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;

  const TimeSelector({
    super.key,
    this.onTimeSelected,
    this.initialTime,
    this.selectedColor,
    this.unselectedColor,
    this.selectedTextColor,
    this.unselectedTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TimeSelectionController());

    // Set initial time if provided
    if (initialTime != null && initialTime!.isNotEmpty) {
      controller.selectedTime.value = initialTime!;
    }

    return Obx(() => Wrap(
      spacing: 8,
      runSpacing: 8,
      children: controller.timeSlots.map((time) {
        final isSelected = controller.isSelected(time);

        return GestureDetector(
          onTap: () {
            controller.selectTime(time);
            if (onTimeSelected != null) {
              onTimeSelected!(time);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? (selectedColor ?? Colors.blue)
                  : (unselectedColor ?? AppColors.primaryColor.withValues(alpha: 0.1)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? (selectedColor ?? Colors.blue)
                    : Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Text(
              time,
              style: TextStyle(
                color: isSelected
                    ? (selectedTextColor ?? Colors.white)
                    : (unselectedTextColor ?? Colors.black87),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ),
        );
      }).toList(),
    ));
  }
}
