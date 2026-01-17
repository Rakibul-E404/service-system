
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/network/network_caller.dart';
import '../../../core/network/network_response.dart';
import '../../../core/utils/api/app_url.dart';

import 'dart:convert';

import '../../../core/utils/token_service/token_storage_service.dart';

class UserBookingServiceController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();
  final SharedPrefService _sharedPrefService = SharedPrefService(); // Add this
  var isBookingLoading = false.obs;

  /// Helper to get headers with Token
  Future<Map<String, String>> _getHeaders() async {
    final String? token = await _sharedPrefService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // This is what was missing
    };
  }

  Future<bool> confirmBooking({
    required String serviceId,
    required String details,
    required DateTime selectedDate,
    required String selectedTimeLabel,
    required String region,
    required String location,
  }) async {
    try {
      isBookingLoading.value = true;

      String formattedBookingDate = _combineDateAndTime(selectedDate, selectedTimeLabel);

      Map<String, dynamic> body = {
        "service": serviceId,
        "details": details,
        "bookingDate": formattedBookingDate,
        "region": region.toLowerCase(),
        "location": location,
      };

      // Get headers including the token
      final Map<String, String> headers = await _getHeaders();

      debugPrint("==== API REQUEST DETAILS ====");
      debugPrint("URL: ${AppUrl.userConfirmBookingService}");
      debugPrint("Headers: $headers"); // Log headers to verify token presence
      debugPrint("Body: ${jsonEncode(body)}");
      debugPrint("=============================");

      final NetworkResponse response = await _networkCaller.postRequest(
        AppUrl.userConfirmBookingService,
        body: body,
        headers: headers, // PASS THE HEADERS HERE
      );

      debugPrint("==== API RESPONSE DETAILS ====");
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.jsonResponse}");
      debugPrint("==============================");

      if (response.isSuccess) {
        Get.snackbar("Success", "Your booking has been confirmed!",
            backgroundColor: Colors.green, colorText: Colors.white);
        return true;
      } else {
        // Handle 401 specifically if token expired
        if (response.statusCode == 401) {
          Get.snackbar("Session Expired", "Please login again to book.",
              backgroundColor: Colors.red, colorText: Colors.white);
        } else {
          Get.snackbar("Booking Failed", response.errorMessage ?? "Something went wrong",
              backgroundColor: Colors.red, colorText: Colors.white);
        }
        return false;
      }
    } catch (e) {
      debugPrint("Critical Booking Error: $e");
      return false;
    } finally {
      isBookingLoading.value = false;
    }
  }

  String _combineDateAndTime(DateTime date, String timeLabel) {
    try {
      DateFormat inputFormat = DateFormat("h:mm a");
      DateTime parsedTime = inputFormat.parse(timeLabel);
      DateTime combined = DateTime(date.year, date.month, date.day, parsedTime.hour, parsedTime.minute);
      return combined.toUtc().toIso8601String();
    } catch (e) {
      return date.toUtc().toIso8601String();
    }
  }
}