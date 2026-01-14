import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';

class ProviderQuoteController extends GetxController {
  var isLoading = false.obs;
  var bookings = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;
  var processingIds = <String>[].obs;

  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('accessToken');
    } catch (e) {
      print('❌ Error retrieving token: $e');
      return null;
    }
  }

  bool isProcessing(String bookingId) {
    return processingIds.contains(bookingId);
  }

// Change: Added {bool refresh = false} inside the parentheses
Future<void> fetchBookings({bool refresh = false}) async {
  try {
    // Always show loader when fetching data
    isLoading.value = true;

    errorMessage.value = '';

    // 2. If refresh is true, we clear the list so the UI resets
    if (refresh) {
      bookings.clear();
    }

    final token = await _getAuthToken();
    final url = Uri.parse(AppUrl.postInquiryQuote);

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['success'] == true) {
        final responseData = data['data'];
        List<Map<String, dynamic>> fetchedList = [];

        if (responseData is Map<String, dynamic>) {
          final List<dynamic> rawList = responseData['data'] ?? [];
          fetchedList = rawList.cast<Map<String, dynamic>>();
        } else if (responseData is List) {
          fetchedList = responseData.cast<Map<String, dynamic>>();
        }

        // Get locally cancelled booking IDs from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        String? cancelledIdsJson = prefs.getString('cancelled_booking_ids');
        List<String> cancelledIds = <String>[];

        if (cancelledIdsJson != null) {
          List<dynamic> decodedList = json.decode(cancelledIdsJson);
          cancelledIds = decodedList.cast<String>();
        }

        // Filter out locally cancelled bookings
        fetchedList = fetchedList.where((booking) => !cancelledIds.contains(booking['_id'])).toList();

        // 3. assignAll replaces whatever was there with EXACTLY what the API sent (the 4 items)
        bookings.assignAll(fetchedList);

        print('✅ Accurate Count: ${bookings.length}');
      } else {
        errorMessage.value = data['message'] ?? 'Failed to fetch data';
      }
    } else {
      errorMessage.value = 'Server Error: ${response.statusCode}';
    }
  } catch (e) {
    errorMessage.value = 'Error: $e';
    print('❌ Exception in fetchBookings: $e');
  } finally {
    isLoading.value = false;
  }
}

  Future<void> respondToBooking({
    required String bookingId,
  }) async {
    try {
      processingIds.add(bookingId);

      final token = await _getAuthToken();
      final url = Uri.parse('https://d7001.sobhoy.com/api/v1/service-inquiry/$bookingId/accept');
      print('🌐 Updating booking status: $url');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },

      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {

          bookings.removeWhere((booking) => booking['_id'] == bookingId);

          Get.snackbar(
            'Success',
            'Accepted successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          errorMessage.value = data['message'] ?? 'Failed to update booking';
          Get.snackbar(
            'Error',
            data['message'] ?? 'Failed to update booking',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        errorMessage.value = 'Server Error: ${response.statusCode}';
        Get.snackbar(
          'Error',
          'Server Error: ${response.statusCode}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
      Get.snackbar(
        'Error',
        'Error: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      processingIds.remove(bookingId);
    }
  }

  Future<void> cancelBookingLocally(String bookingId) async {
    try {
      // Store the cancelled booking ID in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      String? cancelledIdsJson = prefs.getString('cancelled_booking_ids');
      List<String> cancelledIds = <String>[];

      if (cancelledIdsJson != null) {
        List<dynamic> decodedList = json.decode(cancelledIdsJson);
        cancelledIds = decodedList.cast<String>();
      }

      cancelledIds.add(bookingId);
      await prefs.setString('cancelled_booking_ids', json.encode(cancelledIds));

      // Remove the booking from the local list
      bookings.removeWhere((booking) => booking['_id'] == bookingId);

      Get.snackbar(
        'Cancelled',
        'Booking cancelled Successfully',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to cancel booking',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }


  
}