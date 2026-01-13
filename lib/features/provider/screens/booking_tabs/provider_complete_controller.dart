import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProviderCompleteController extends GetxController {
  var isLoading = false.obs;
  var bookings = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;

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

  // UPDATED: Added named parameter to match your Screen's fetch call
  Future<void> fetchBookings({bool refresh = false}) async {
    try {
      // Only show main loading if not refreshing
      if (!refresh) {
        isLoading.value = true;
      }
      
      errorMessage.value = '';

      // Clear data if refreshing to prevent "Ghost" items
      if (refresh) {
        bookings.clear();
      }

      final token = await _getAuthToken();
      final url = Uri.parse('$baseUrl/booking/provider?status=completed');
      print('🌐 Fetching completed bookings from: $url');

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

          // Parse logic
          if (responseData is Map<String, dynamic>) {
            final List<dynamic> list = responseData['data'] ?? [];
            fetchedList = list.cast<Map<String, dynamic>>();
          } else if (responseData is List) {
            fetchedList = responseData.cast<Map<String, dynamic>>();
          }

          // UPDATED: assignAll replaces the list entirely, fixing the 15-vs-4 count issue
          bookings.assignAll(fetchedList);
          
          print('✅ Loaded ${bookings.length} completed bookings');
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
}