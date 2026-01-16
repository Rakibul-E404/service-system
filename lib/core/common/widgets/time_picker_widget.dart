import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_colors.dart';

class TimeController extends GetxController {
  // Reactive variable to hold the selected time
  var selectedTime = DateTime.now().obs;

  // Function to update the time
  void updateTime(DateTime newTime) {
    selectedTime.value = newTime;
  }

  // Add this method to update time from string (like "10am")
  void updateSelectedTime(String timeString) {
    final now = DateTime.now();
    int hour = now.hour;
    int minute = now.minute;

    // Parse time string like "10am", "2:30pm", etc.
    final cleanedTime = timeString.toLowerCase().replaceAll(RegExp(r'[^0-9:apm]'), '');

    if (cleanedTime.contains('pm')) {
      final timePart = cleanedTime.replaceAll('pm', '');
      if (timePart.contains(':')) {
        final parts = timePart.split(':');
        hour = int.parse(parts[0]);
        if (hour != 12) hour += 12;
        minute = int.parse(parts[1]);
      } else {
        hour = int.parse(timePart);
        if (hour != 12) hour += 12;
      }
    } else if (cleanedTime.contains('am')) {
      final timePart = cleanedTime.replaceAll('am', '');
      if (timePart.contains(':')) {
        final parts = timePart.split(':');
        hour = int.parse(parts[0]);
        if (hour == 12) hour = 0;
        minute = int.parse(parts[1]);
      } else {
        hour = int.parse(timePart);
        if (hour == 12) hour = 0;
      }
    }

    final newTime = DateTime(now.year, now.month, now.day, hour, minute);
    selectedTime.value = newTime;
  }
}

class TimePickerWidget extends StatelessWidget {
  final String label;
  final TimeController controller; // Use the controller for managing time
  final bool showTimeIcon;
  final bool showBorder;

  const TimePickerWidget({
    super.key,
    required this.label,
    required this.controller,
    this.showTimeIcon = false,
    this.showBorder = true,
  });

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(controller.selectedTime.value),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor, // Customize the primary color
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      final DateTime newTime = DateTime(
        controller.selectedTime.value.year,
        controller.selectedTime.value.month,
        controller.selectedTime.value.day,
        selectedTime.hour,
        selectedTime.minute,
      );
      controller.updateTime(newTime); // Update time in the controller
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: showBorder
          ? BoxDecoration(
        border: Border.all(color: AppColors.primaryColor, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      )
          : const BoxDecoration(),
      child: Row(
        children: <Widget>[
          if (showTimeIcon)
            const IconButton(
              disabledColor: AppColors.primaryColor,
              icon: Icon(Icons.watch_later),
              onPressed: null,
            )
          else
            const SizedBox.shrink(),
          Text(
            label,
            style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w400),
          ),
          const Spacer(),
          Obx(
            // Use Obx to update UI reactively when the time changes
                () => TextButton(
              onPressed: () => _selectTime(context),
              child: Text(
                '${controller.selectedTime.value.hour}:${controller.selectedTime.value.minute.toString().padLeft(2, '0')}',
              ),
            ),
          ),
        ],
      ),
    );
  }
}