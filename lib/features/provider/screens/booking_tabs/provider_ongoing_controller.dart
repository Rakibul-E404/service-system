import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProviderOngoingController extends GetxController {
  var isLoading = false.obs;
  var bookings = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;
  var processingIds = <String>[].obs;

  final String baseUrl = 'https://d7001.sobhoy.com/api/v1';

  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('accessToken');
    } catch (e) {
      print('❌ Error retrieving token: $e');
      return null;
    }
  }

  // UPDATED: Added {bool refresh = false} named parameter
  Future<void> fetchBookings({bool refresh = false}) async {
    try {
      // If not a refresh, show the main loading indicator
      if (!refresh) {
        isLoading.value = true;
      }
      
      errorMessage.value = '';
      
      // Clear the list if it's a refresh to ensure we start fresh
      if (refresh) {
        bookings.clear();
      }

      final token = await _getAuthToken();
      final url = Uri.parse('$baseUrl/booking/provider?status=accepted');
      print('🌐 Fetching provider pending bookings from: $url');

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
          final List<dynamic> list = data['data']['data'] ?? [];
          
          // UPDATED: Use assignAll to replace old data with exactly what comes from the API
          bookings.assignAll(list.cast<Map<String, dynamic>>());
          
          print('✅ Loaded ${bookings.length} pending bookings');
        } else {
          errorMessage.value = data['message'] ?? 'Failed to fetch data';
        }
      } else {
        errorMessage.value = 'Server Error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
      print('❌ Exception: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> respondToBooking(String bookingId, String status) async {
    try {
      processingIds.add(bookingId);

      final token = await _getAuthToken();
      final url = Uri.parse('$baseUrl/booking/respond/$bookingId');

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Remove from list immediately upon success
          bookings.removeWhere((booking) => 
            booking['_id'] == bookingId || booking['id'] == bookingId
          );
          
          Get.snackbar('Success', 'Action performed successfully',
            backgroundColor: Colors.green, colorText: Colors.white);
        }
      }
    } catch (e) {
      print('❌ Error responding: $e');
    } finally {
      processingIds.remove(bookingId);
    }
  }

  bool isProcessing(String bookingId) => processingIds.contains(bookingId);
}