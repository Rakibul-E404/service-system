/**
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
}*/







///
///
///
///
///
///
///
/// todo::::: stopping the dispose for the avality
///
///
///
///
///
///
///
///







// Availability Controller with SharedPreferences Persistence
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/features/provider/controllers/provider_profile_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/network/network_caller.dart';
import '../../../core/utils/api/app_url.dart';
import '../../../core/utils/token_service/token_storage_service.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';


class AvailabilityController extends GetxController {
  final isLoading = false.obs;
  final NetworkCaller _networkCaller = NetworkCaller();

  // Helper to get token (following your ProviderProfileController pattern)
  Future<String?> _getAuthToken() async {
    final tokenService = SharedPrefService();
    return await tokenService.getAccessToken();
  }

  // Converts "10:00am" -> 10 or "2:00pm" -> 14
  int _parseTimeToHour(String timeStr) {
    String cleanStr = timeStr.toLowerCase().replaceAll(' ', '');
    int hour = int.parse(cleanStr.split(':')[0]);

    if (cleanStr.contains('pm') && hour != 12) {
      hour += 12;
    } else if (cleanStr.contains('am') && hour == 12) {
      hour = 0;
    }
    return hour;
  }

  Future<void> updateBusinessAvailability({
    required Map<String, bool> availability,
    required Map<String, String> startTimes,
    required Map<String, String> endTimes,
  }) async {
    try {
      isLoading.value = true;

      // 1. Get the token
      final token = await _getAuthToken();

      if (token == null || token.isEmpty) {
        debugPrint('❌ No token found in AvailabilityController');
        Get.snackbar('Auth Error', 'Please log in again');
        return;
      }

      // 2. Construct the body
      Map<String, dynamic> body = {};
      availability.forEach((day, isAvailable) {
        body[day] = {
          "isAvailable": isAvailable,
          "openingTime": _parseTimeToHour(startTimes[day]!),
          "closingTime": _parseTimeToHour(endTimes[day]!),
        };
      });

      debugPrint('📡 Sending Availability Update to: ${AppUrl.putAvailabilityPart}');

      // 3. API Call with Headers
      final response = await _networkCaller.putRequest(
        AppUrl.putAvailabilityPart,
        body: body,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Fixed: Added the dynamic token
        },
      );

      if (response.isSuccess) {
        Get.snackbar("Success", "Business hours updated!",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);

        // 4. Refresh the Profile screen data
        if (Get.isRegistered<ProviderProfileController>()) {
          Get.find<ProviderProfileController>().fetchBusinessProfile();
        }
      } else if (response.statusCode == 401) {
        Get.snackbar("Session Expired", "Please log in again",
            backgroundColor: Colors.red, colorText: Colors.white);
      } else {
        Get.snackbar("Error", "Update failed: ${response.statusCode}",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      debugPrint('🧨 Availability Update Error: $e');
      Get.snackbar('Error', 'An unexpected error occurred');
    } finally {
      isLoading.value = false;
    }
  }
}