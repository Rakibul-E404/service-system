

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:manx_mate/core/utils/api/app_url.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingActionController extends GetxController {
  // Track which specific booking and action is loading
  var loadingBookingId = ''.obs;
  var processingStatus = ''.obs;

  Future<bool> updateBookingStatus(String bookingId, String status) async {
    try {
      // Set which specific action is running
      loadingBookingId.value = bookingId;
      processingStatus.value = status;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) {
        Get.snackbar('Error', 'Authentication token not found');
        return false;
      }

      final url = Uri.parse('${AppUrl.baseUrl}/booking/respond/$bookingId');
      
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"status": status}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        Get.snackbar(
          'Success', 
          data['message'] ?? 'Booking $status successfully',
          backgroundColor: Colors.green.withOpacity(0.7),
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar('Update Failed', data['message'] ?? 'Error');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Connection problem');
      return false;
    } finally {
      // Reset variables so loading stops
      loadingBookingId.value = '';
      processingStatus.value = '';
    }
  }
}