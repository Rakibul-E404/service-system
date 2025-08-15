// Improved Availability Controller
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/day_availability.dart';
import '../model/time_range.dart';

class AvailabilityController extends GetxController {
  // Observable state
  RxBool isAlwaysAvailable = false.obs;
  RxMap<String, DayAvailability> availabilityMap = <String, DayAvailability>{}.obs;

  // Constants
  final List<String> weekDays = <String>[
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday'
  ];

  final List<String> quickTimeSlots = <String>[
    '9:00 AM - 5:00 PM',
    '10:00 AM - 6:00 PM',
    '12:00 PM - 8:00 PM',
    '6:00 PM - 10:00 PM',
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeAvailability();
  }

  void _initializeAvailability() {
    for (final String day in weekDays) {
      availabilityMap[day] = DayAvailability(day: day);
    }
  }

  // Computed properties
  List<String> get selectedDays => availabilityMap.values
      .where((DayAvailability day) => day.isSelected)
      .map((DayAvailability day) => day.day)
      .toList();

  int get selectedDaysCount => selectedDays.length;

  bool get hasAnySelection => isAlwaysAvailable.value || selectedDaysCount > 0;

  // Actions
  void toggleAlwaysAvailable() {
    isAlwaysAvailable.toggle();

    if (isAlwaysAvailable.value) {
      // Set all days as available 24/7
      for (final String day in weekDays) {
        availabilityMap[day] = DayAvailability(
          day: day,
          isSelected: true,
          timeRange: TimeRange(start: 'All Day', end: 'All Day'),
        );
      }
    } else {
      // Clear all selections
      _initializeAvailability();
    }
    availabilityMap.refresh();
  }

  void toggleDay(String day) {
    final DayAvailability current = availabilityMap[day]!;

    if (current.isSelected) {
      // Deselect day
      availabilityMap[day] = current.copyWith(
        isSelected: false,
        timeRange: null,
      );
    } else {
      // Select day with default time
      availabilityMap[day] = current.copyWith(
        isSelected: true,
        timeRange: TimeRange(start: '9:00 AM', end: '5:00 PM'),
      );
    }
    availabilityMap.refresh();
  }

  void setTimeForDay(String day, String timeSlot) {
    final DayAvailability current = availabilityMap[day]!;

    if (!current.isSelected) {
      return;
    }

    TimeRange timeRange;
    if (timeSlot.contains(' - ')) {
      final List<String> parts = timeSlot.split(' - ');
      timeRange = TimeRange(start: parts[0].trim(), end: parts[1].trim());
    } else {
      timeRange = TimeRange(start: timeSlot, end: timeSlot);
    }

    availabilityMap[day] = current.copyWith(timeRange: timeRange);
    availabilityMap.refresh();
  }

  void setCustomTime(String day, String startTime, String endTime) {
    final DayAvailability current = availabilityMap[day]!;

    if (!current.isSelected) {
      return;
    }

    availabilityMap[day] = current.copyWith(
      timeRange: TimeRange(start: startTime, end: endTime),
    );
    availabilityMap.refresh();
  }

  void setWeekdaySchedule() {
    isAlwaysAvailable.value = false;

    final List<String> weekdays = <String>['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];

    // Clear all first
    _initializeAvailability();

    // Set weekdays
    for (final String day in weekdays) {
      availabilityMap[day] = DayAvailability(
        day: day,
        isSelected: true,
        timeRange: TimeRange(start: '9:00 AM', end: '5:00 PM'),
      );
    }
    availabilityMap.refresh();
  }

  void clearAll() {
    isAlwaysAvailable.value = false;
    _initializeAvailability();
    availabilityMap.refresh();
  }

  void saveAvailability() {
    if (!hasAnySelection) {
      Get.snackbar(
        'No Selection',
        'Please set your availability first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    print('=== AVAILABILITY SAVED ===');
    if (isAlwaysAvailable.value) {
      print('Available 24/7');
    } else {
      for (final String day in selectedDays) {
        final DayAvailability dayData = availabilityMap[day]!;
        if (dayData.timeRange != null) {
          print('$day: ${dayData.timeRange}');
        }
      }
    }

    Get.snackbar(
      'Success',
      'Availability saved successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  // Helper methods
  bool isDaySelected(String day) {
    return availabilityMap[day]?.isSelected ?? false;
  }

  TimeRange? getTimeRange(String day) {
    return availabilityMap[day]?.timeRange;
  }

  String getTimeDisplayForDay(String day) {
    final TimeRange? timeRange = getTimeRange(day);
    if (timeRange == null) {
      return '';
    }
    if (timeRange.start == 'All Day') {
      return 'All Day';
    }
    return '${timeRange.start} - ${timeRange.end}';
  }
}