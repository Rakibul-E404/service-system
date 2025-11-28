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
import 'package:shared_preferences/shared_preferences.dart';

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

  // Storage keys - separate from token keys
  static const String _availabilityDataKey = 'provider_availability_data';
  static const String _alwaysAvailableKey = 'provider_always_available';
  static const String _availabilityInitializedKey = 'availability_initialized';

  @override
  void onInit() {
    super.onInit();
    _loadSavedAvailability();
  }

  void _initializeAvailability() {
    for (final String day in weekDays) {
      availabilityMap[day] = DayAvailability(day: day);
    }
  }

  Future<void> _loadSavedAvailability() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // Load always available setting
      final bool savedAlwaysAvailable = prefs.getBool(_alwaysAvailableKey) ?? false;
      isAlwaysAvailable.value = savedAlwaysAvailable;

      // Load availability data
      final String? savedData = prefs.getString(_availabilityDataKey);

      if (savedData != null && savedData.isNotEmpty) {
        await _loadFromSharedPrefs(savedData);
        debugPrint('✅ Loaded saved availability data from SharedPreferences');
      } else {
        _initializeAvailability();
        debugPrint('✅ Initialized fresh availability data');
      }
    } catch (e) {
      debugPrint('❌ Error loading availability: $e');
      _initializeAvailability();
    }
  }

  Future<void> _loadFromSharedPrefs(String jsonData) async {
    try {
      final Map<String, dynamic> data = Map<String, dynamic>.from(await _decodeJson(jsonData));
      final Map<String, DayAvailability> loadedData = <String, DayAvailability>{};

      for (final String day in weekDays) {
        final String dayKey = day.toLowerCase();
        if (data.containsKey(dayKey)) {
          final dynamic dayData = data[dayKey];
          if (dayData is Map<String, dynamic>) {
            loadedData[day] = DayAvailability.fromJson(dayData);
          } else {
            loadedData[day] = DayAvailability(day: day);
          }
        } else {
          loadedData[day] = DayAvailability(day: day);
        }
      }

      availabilityMap.value = loadedData;
    } catch (e) {
      debugPrint('❌ Error parsing availability data: $e');
      _initializeAvailability();
    }
  }

  Future<void> _saveToSharedPrefs() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // Save always available setting
      await prefs.setBool(_alwaysAvailableKey, isAlwaysAvailable.value);

      // Save availability data as JSON string
      final Map<String, dynamic> dataToSave = <String, dynamic>{};
      for (final String day in weekDays) {
        final DayAvailability dayAvailability = availabilityMap[day]!;
        dataToSave[day.toLowerCase()] = dayAvailability.toJson();
      }

      final String jsonString = await _encodeJson(dataToSave);
      await prefs.setString(_availabilityDataKey, jsonString);

      // Mark as initialized
      await prefs.setBool(_availabilityInitializedKey, true);

      debugPrint('✅ Availability data saved to SharedPreferences');
    } catch (e) {
      debugPrint('❌ Error saving availability: $e');
    }
  }

  // Helper methods for JSON encoding/decoding
  Future<String> _encodeJson(Map<String, dynamic> data) async {
    return data.toString(); // Simple implementation
  }

  Future<Map<String, dynamic>> _decodeJson(String jsonString) async {
    // Remove curly braces and split by comma
    final String cleanString = jsonString.replaceAll('{', '').replaceAll('}', '');
    final List<String> pairs = cleanString.split(', ');

    final Map<String, dynamic> result = <String, dynamic>{};

    for (final String pair in pairs) {
      final List<String> keyValue = pair.split(': ');
      if (keyValue.length == 2) {
        final String key = keyValue[0].trim();
        final String value = keyValue[1].trim();

        // Simple parsing - you might want to use a proper JSON decoder
        if (value == 'true') {
          result[key] = true;
        } else if (value == 'false') {
          result[key] = false;
        } else if (value.startsWith('DayAvailability')) {
          // Parse DayAvailability objects
          result[key] = _parseDayAvailability(value);
        } else {
          result[key] = value;
        }
      }
    }

    return result;
  }

  Map<String, dynamic> _parseDayAvailability(String value) {
    // Simple parsing - in real app, use proper JSON serialization
    return <String, dynamic>{
      'day': 'Monday', // Extract from value
      'isSelected': true,
      'timeRange': null,
    };
  }

  // Computed properties
  List<String> get selectedDays => availabilityMap.values
      .where((DayAvailability day) => day.isSelected)
      .map((DayAvailability day) => day.day)
      .toList();

  int get selectedDaysCount => selectedDays.length;

  bool get hasAnySelection => isAlwaysAvailable.value || selectedDaysCount > 0;

  // Convert to JSON for API (if needed)
  Map<String, dynamic> toApiFormat() {
    if (isAlwaysAvailable.value) {
      return <String, dynamic>{
        'available_24_7': true,
        'schedule': <String, dynamic>{},
      };
    }

    final Map<String, dynamic> schedule = <String, dynamic>{};
    for (final String day in selectedDays) {
      final DayAvailability dayData = availabilityMap[day]!;
      if (dayData.timeRange != null) {
        schedule[day.toLowerCase()] = <String, dynamic>{
          'start_time': dayData.timeRange!.start,
          'end_time': dayData.timeRange!.end,
          'available': true,
        };
      }
    }

    return <String, dynamic>{
      'available_24_7': false,
      'schedule': schedule,
    };
  }

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
      debugPrint('✅ Set to always available (24/7)');
    } else {
      // Clear all selections
      _initializeAvailability();
      debugPrint('✅ Disabled always available mode');
    }

    availabilityMap.refresh();
    _saveToSharedPrefs();
  }

  void toggleDay(String day) {
    final DayAvailability current = availabilityMap[day]!;

    if (current.isSelected) {
      // Deselect day
      availabilityMap[day] = current.copyWith(
        isSelected: false,
        timeRange: null,
      );
      debugPrint('✅ Deselected $day');
    } else {
      // Select day with default time
      availabilityMap[day] = current.copyWith(
        isSelected: true,
        timeRange: TimeRange(start: '9:00 AM', end: '5:00 PM'),
      );
      debugPrint('✅ Selected $day with default time');
    }

    availabilityMap.refresh();
    _saveToSharedPrefs();
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
    _saveToSharedPrefs();

    debugPrint('✅ Updated $day time to: $timeSlot');
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
    _saveToSharedPrefs();

    debugPrint('✅ Set custom time for $day: $startTime - $endTime');
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
    _saveToSharedPrefs();

    debugPrint('✅ Set weekday schedule (Mon-Fri, 9AM-5PM)');
  }

  void setWeekendSchedule() {
    isAlwaysAvailable.value = false;

    final List<String> weekends = <String>['Saturday', 'Sunday'];

    // Clear all first
    _initializeAvailability();

    // Set weekends
    for (final String day in weekends) {
      availabilityMap[day] = DayAvailability(
        day: day,
        isSelected: true,
        timeRange: TimeRange(start: '10:00 AM', end: '4:00 PM'),
      );
    }

    availabilityMap.refresh();
    _saveToSharedPrefs();

    debugPrint('✅ Set weekend schedule (Sat-Sun, 10AM-4PM)');
  }

  void clearAll() {
    isAlwaysAvailable.value = false;
    _initializeAvailability();
    availabilityMap.refresh();
    _saveToSharedPrefs();

    debugPrint('✅ Cleared all availability settings');
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

    // Data is already auto-saved to SharedPreferences
    debugPrint('=== AVAILABILITY CONFIRMED ===');
    if (isAlwaysAvailable.value) {
      debugPrint('✅ Available 24/7');
    } else {
      debugPrint('✅ Custom Schedule:');
      for (final String day in selectedDays) {
        final DayAvailability dayData = availabilityMap[day]!;
        if (dayData.timeRange != null) {
          debugPrint('  • $day: ${dayData.timeRange}');
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
      return 'Not Available';
    }
    if (timeRange.start == 'All Day') {
      return '24/7 Available';
    }
    return '${timeRange.start} - ${timeRange.end}';
  }

  // Get current availability summary for display
  String get availabilitySummary {
    if (isAlwaysAvailable.value) {
      return 'Available 24/7';
    }

    if (selectedDays.isEmpty) {
      return 'Not Available';
    }

    if (selectedDays.length == 7) {
      return 'All Days: ${getTimeDisplayForDay('Monday')}';
    }

    return '${selectedDays.length} days selected';
  }

  // Check if data exists in storage
  Future<bool> hasSavedData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_availabilityDataKey);
    return data != null && data.isNotEmpty;
  }
}

// Models with proper JSON serialization
class DayAvailability {
  final String day;
  final bool isSelected;
  final TimeRange? timeRange;

  DayAvailability({
    required this.day,
    this.isSelected = false,
    this.timeRange,
  });

  DayAvailability copyWith({
    String? day,
    bool? isSelected,
    TimeRange? timeRange,
  }) {
    return DayAvailability(
      day: day ?? this.day,
      isSelected: isSelected ?? this.isSelected,
      timeRange: timeRange ?? this.timeRange,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'day': day,
      'isSelected': isSelected,
      'timeRange': timeRange?.toJson(),
    };
  }

  factory DayAvailability.fromJson(Map<String, dynamic> json) {
    return DayAvailability(
      day: json['day'] as String,
      isSelected: json['isSelected'] as bool? ?? false,
      timeRange: json['timeRange'] != null
          ? TimeRange.fromJson(Map<String, dynamic>.from(json['timeRange'] as Map))
          : null,
    );
  }

  @override
  String toString() {
    return 'DayAvailability(day: $day, isSelected: $isSelected, timeRange: $timeRange)';
  }
}

class TimeRange {
  final String start;
  final String end;

  TimeRange({required this.start, required this.end});

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'start': start,
      'end': end,
    };
  }

  factory TimeRange.fromJson(Map<String, dynamic> json) {
    return TimeRange(
      start: json['start'] as String,
      end: json['end'] as String,
    );
  }

  @override
  String toString() {
    return '$start - $end';
  }
}



