import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================================
// CONTROLLER FOR PENDING BOOKINGS
// ============================================================================
class PendingBookingsController extends GetxController {
  // Observable variables
  var isLoading = false.obs;
  var pendingBookings = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;

  final String baseUrl = 'https://d7001.sobhoy.com/api/v1';

  // Get authorization token
  Future<String?> _getAuthToken() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      print('🔐 Token retrieved: ${token != null ? '${token.substring(0, 20)}...' : 'null'}');
      return token;
    } catch (e) {
      print('❌ Error getting auth token: $e');
      return null;
    }
  }

  // Fetch pending bookings from API
  Future<void> fetchPendingBookings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      pendingBookings.clear(); // Clear previous data

      // Get authorization token
      final token = await _getAuthToken();
      if (token == null) {
        errorMessage.value = 'Authentication required. Please login again.';
        isLoading.value = false;
        return;
      }

      // API endpoint for pending bookings
      final url = Uri.parse('$baseUrl/booking/user?status=pending');
      print('🌐 Fetching pending bookings from: $url');

      // Make GET request with authorization
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      // Handle response
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('✅ Pending Bookings API Response: $jsonData');

        if (jsonData['success'] == true) {
          // Extract bookings from the correct path in response
          final List<dynamic> bookingsData = jsonData['data']['data'] ?? [];
          print('📋 Found ${bookingsData.length} pending bookings');

          pendingBookings.value = bookingsData.cast<Map<String, dynamic>>();
          print('🎯 Loaded ${pendingBookings.length} bookings into controller');
        } else {
          errorMessage.value = jsonData['message'] ?? 'Failed to load pending bookings';
          print('❌ API Error: ${errorMessage.value}');
        }
      } else if (response.statusCode == 401) {
        errorMessage.value = 'Unauthorized. Please login again.';
        print('❌ Unauthorized access');
      } else if (response.statusCode == 404) {
        errorMessage.value = 'API endpoint not found';
        print('❌ Endpoint not found');
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
        print('❌ Server error: ${response.statusCode} - ${response.body}');
      }
    } on http.ClientException catch (e) {
      errorMessage.value = 'Network error. Please check your connection.';
      print('❌ Network error: $e');
    } on FormatException catch (e) {
      errorMessage.value = 'Invalid response from server';
      print('❌ Format error: $e');
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred: $e';
      print('❌ Unexpected error: $e');
      print('❌ Stack trace: ${e.toString()}');
    } finally {
      isLoading.value = false;
      print('🏁 Loading completed. isLoading: ${isLoading.value}');
    }
  }
}

/// ============================================================================
///
/// CONTROLLER FOR COMPLETED BOOKINGS
/// ============================================================================
class CompletedBookingsController extends GetxController {
  // Observable variables
  var isLoading = false.obs;
  var completedBookings = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;

  final String baseUrl = 'https://d7001.sobhoy.com/api/v1';

  // Get authorization token
  Future<String?> _getAuthToken() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      print('🔐 Token retrieved: ${token != null ? '${token.substring(0, 20)}...' : 'null'}');
      return token;
    } catch (e) {
      print('❌ Error getting auth token: $e');
      return null;
    }
  }

  // Fetch completed bookings from API
  Future<void> fetchCompletedBookings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      completedBookings.clear(); // Clear previous data

      // Get authorization token
      final token = await _getAuthToken();
      if (token == null) {
        errorMessage.value = 'Authentication required. Please login again.';
        isLoading.value = false;
        return;
      }

      // API endpoint for completed bookings
      final url = Uri.parse('$baseUrl/booking/user?status=completed');
      print('🌐 Fetching completed bookings from: $url');

      // Make GET request with authorization
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      // Handle response
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('✅ Completed Bookings API Response: $jsonData');

        if (jsonData['success'] == true) {
          // Extract bookings from the correct path in response
          final List<dynamic> bookingsData = jsonData['data']['data'] ?? [];
          print('📋 Found ${bookingsData.length} completed bookings');

          completedBookings.value = bookingsData.cast<Map<String, dynamic>>();
          print('🎯 Loaded ${completedBookings.length} bookings into controller');
        } else {
          errorMessage.value = jsonData['message'] ?? 'Failed to load bookings';
          print('❌ API Error: ${errorMessage.value}');
        }
      } else if (response.statusCode == 401) {
        errorMessage.value = 'Unauthorized. Please login again.';
        print('❌ Unauthorized access');
      } else if (response.statusCode == 404) {
        errorMessage.value = 'API endpoint not found';
        print('❌ Endpoint not found');
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
        print('❌ Server error: ${response.statusCode} - ${response.body}');
      }
    } on http.ClientException catch (e) {
      errorMessage.value = 'Network error. Please check your connection.';
      print('❌ Network error: $e');
    } on FormatException catch (e) {
      errorMessage.value = 'Invalid response from server';
      print('❌ Format error: $e');
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred: $e';
      print('❌ Unexpected error: $e');
      print('❌ Stack trace: ${e.toString()}');
    } finally {
      isLoading.value = false;
      print('🏁 Loading completed. isLoading: ${isLoading.value}');
    }
  }
}