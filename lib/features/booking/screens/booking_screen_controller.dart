/**
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:manx_mate/core/utils/api/app_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

/// Controller for Active Slot Bookings (Active Slot)
class ActiveSlotBookingsController extends GetxController {
  var isLoading = false.obs;
  var activeSlotBookings = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;
  var isCancelling = false.obs;

  final String baseUrl = AppUrl.baseUrl;

  Future<String?> _getAuthToken() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      print('🔐 Token retrieved: ${token != null ? 'EXISTS (${token.length} chars)' : 'NULL'}');
      return token;
    } catch (e) {
      print('❌ Error getting auth token: $e');
      return null;
    }
  }

  Future<void> fetchActiveSlotBookings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = await _getAuthToken();
      if (token == null || token.isEmpty) {
        errorMessage.value = 'Authentication required. Please login again.';
        isLoading.value = false;
        return;
      }

      final url = Uri.parse('$baseUrl/booking/user?status=pending');
      print('🌐 Fetching active slot bookings from: $url');
      print('🔑 Using token: ${token.substring(0, 20)}...');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('✅ Parsed JSON: $jsonData');

        if (jsonData['success'] == true) {
          final List<dynamic> bookingsData = jsonData['data']['data'] ?? [];
          activeSlotBookings.value = bookingsData.cast<Map<String, dynamic>>();
          print('✅ Loaded ${activeSlotBookings.length} active bookings');
        } else {
          errorMessage.value = jsonData['message'] ?? 'Failed to load bookings';
          print('❌ API returned success=false: ${errorMessage.value}');
        }
      } else if (response.statusCode == 401) {
        errorMessage.value = 'Unauthorized. Please login again.';
        print('❌ Unauthorized access - token may be expired');
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
        print('❌ Server error: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      errorMessage.value = 'An error occurred: $e';
      print('❌ Error fetching bookings: $e');
      print('❌ Stack trace: $stackTrace');
    } finally {
      isLoading.value = false;
      print('🏁 Fetch completed. isLoading: ${isLoading.value}');
    }
  }

  /// Cancel booking by changing status to "cancelled"
  Future<bool> cancelBooking(String bookingId) async {
    if (bookingId.isEmpty) {
      print('❌ Cannot cancel: bookingId is empty');
      Get.snackbar(
        'Error',
        'Invalid booking ID',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    try {
      isCancelling.value = true;
      print('🗑️ Starting cancellation for booking: $bookingId');

      final token = await _getAuthToken();
      if (token == null || token.isEmpty) {
        print('❌ Cannot cancel: No auth token');
        Get.snackbar(
          'Error',
          'Authentication required. Please login again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      final url = Uri.parse('$baseUrl/booking/respond/$bookingId');
      print('🌐 PATCH request to: $url');
      print('🔑 Using token: ${token.substring(0, 20)}...');
      print('📤 Request body: {"status": "cancelled"}');

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'status': 'cancelled',
        }),
      );

      print('📡 Cancel Response status: ${response.statusCode}');
      print('📦 Cancel Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final jsonData = json.decode(response.body);
          print('✅ Parsed cancel response: $jsonData');

          if (jsonData['success'] == true) {
            // Remove the cancelled booking from the list
            final removedCount = activeSlotBookings.length;
            activeSlotBookings.removeWhere((booking) => booking['_id'] == bookingId);
            print('✅ Booking removed from list. Before: $removedCount, After: ${activeSlotBookings.length}');

            Get.snackbar(
              'Success',
              'Booking cancelled successfully',
              backgroundColor: Colors.green,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 2),
            );

            return true;
          } else {
            final errorMsg = jsonData['message'] ?? 'Failed to cancel booking';
            print('❌ API returned success=false: $errorMsg');
            Get.snackbar(
              'Error',
              errorMsg,
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
            );
            return false;
          }
        } catch (parseError) {
          print('❌ Error parsing response: $parseError');
          Get.snackbar(
            'Error',
            'Invalid response from server',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
          return false;
        }
      } else if (response.statusCode == 401) {
        print('❌ Unauthorized - token may be invalid');
        Get.snackbar(
          'Error',
          'Session expired. Please login again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      } else if (response.statusCode == 404) {
        print('❌ Booking not found');
        Get.snackbar(
          'Error',
          'Booking not found',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      } else {
        print('❌ Server error: ${response.statusCode}');
        Get.snackbar(
          'Error',
          'Server error: ${response.statusCode}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } on http.ClientException catch (e) {
      print('❌ Network error: $e');
      Get.snackbar(
        'Error',
        'Network error. Please check your connection.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (e, stackTrace) {
      print('❌ Unexpected error cancelling booking: $e');
      print('❌ Stack trace: $stackTrace');
      Get.snackbar(
        'Error',
        'Failed to cancel booking: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isCancelling.value = false;
      print('🏁 Cancellation completed. isCancelling: ${isCancelling.value}');
    }
  }
}

/// Controller for Pending Bookings (Ongoing Slot)
class PendingBookingsController extends GetxController {
  var isLoading = false.obs;
  var pendingBookings = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;
  var isCompleting = false.obs; // ✅ Added for completion tracking

  final String baseUrl = AppUrl.baseUrl;

  Future<String?> _getAuthToken() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      return token;
    } catch (e) {
      print('❌ Error getting auth token: $e');
      return null;
    }
  }

  Future<void> fetchPendingBookings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = await _getAuthToken();
      if (token == null) {
        errorMessage.value = 'Authentication required. Please login again.';
        isLoading.value = false;
        return;
      }

      final url = Uri.parse('$baseUrl/booking/user?status=accepted');
      print('🌐 Fetching pending bookings from: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          final List<dynamic> bookingsData = jsonData['data']['data'] ?? [];
          pendingBookings.value = bookingsData.cast<Map<String, dynamic>>();
          print('✅ Loaded ${pendingBookings.length} pending bookings');
        } else {
          errorMessage.value = jsonData['message'] ?? 'Failed to load bookings';
        }
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: $e';
      print('❌ Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ NEW METHOD: Mark booking as completed
  Future<bool> completeBooking(String bookingId) async {
    if (bookingId.isEmpty) {
      print('❌ Cannot complete: bookingId is empty');
      Get.snackbar(
        'Error',
        'Invalid booking ID',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    try {
      isCompleting.value = true;
      print('✅ Starting completion for booking: $bookingId');

      final token = await _getAuthToken();
      if (token == null || token.isEmpty) {
        print('❌ Cannot complete: No auth token');
        Get.snackbar(
          'Error',
          'Authentication required. Please login again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      final url = Uri.parse('$baseUrl/booking/respond/$bookingId');
      print('🌐 PATCH request to: $url');
      print('🔑 Using token: ${token.substring(0, 20)}...');
      print('📤 Request body: {"status": "completed"}');

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'status': 'completed',
        }),
      );

      print('📡 Complete Response status: ${response.statusCode}');
      print('📦 Complete Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final jsonData = json.decode(response.body);
          print('✅ Parsed complete response: $jsonData');

          if (jsonData['success'] == true) {
            // Remove the completed booking from the pending list
            final removedCount = pendingBookings.length;
            pendingBookings.removeWhere((booking) => booking['_id'] == bookingId);
            print('✅ Booking removed from ongoing list. Before: $removedCount, After: ${pendingBookings.length}');

            Get.snackbar(
              'Success',
              'Booking marked as completed successfully',
              backgroundColor: Colors.green,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 2),
              icon: const Icon(Icons.check_circle, color: Colors.white),
            );

            return true;
          } else {
            final errorMsg = jsonData['message'] ?? 'Failed to complete booking';
            print('❌ API returned success=false: $errorMsg');
            Get.snackbar(
              'Error',
              errorMsg,
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
            );
            return false;
          }
        } catch (parseError) {
          print('❌ Error parsing response: $parseError');
          Get.snackbar(
            'Error',
            'Invalid response from server',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
          return false;
        }
      } else if (response.statusCode == 401) {
        print('❌ Unauthorized - token may be invalid');
        Get.snackbar(
          'Error',
          'Session expired. Please login again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      } else if (response.statusCode == 404) {
        print('❌ Booking not found');
        Get.snackbar(
          'Error',
          'Booking not found',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      } else {
        print('❌ Server error: ${response.statusCode}');
        Get.snackbar(
          'Error',
          'Server error: ${response.statusCode}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } on http.ClientException catch (e) {
      print('❌ Network error: $e');
      Get.snackbar(
        'Error',
        'Network error. Please check your connection.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (e, stackTrace) {
      print('❌ Unexpected error completing booking: $e');
      print('❌ Stack trace: $stackTrace');
      Get.snackbar(
        'Error',
        'Failed to complete booking: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isCompleting.value = false;
      print('🏁 Completion process finished. isCompleting: ${isCompleting.value}');
    }
  }
}

/// Controller for Completed Bookings (Past Slot)
class CompletedBookingsController extends GetxController {
  var isLoading = false.obs;
  var completedBookings = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;

  final String baseUrl = AppUrl.baseUrl;

  Future<String?> _getAuthToken() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      return token;
    } catch (e) {
      print('❌ Error getting auth token: $e');
      return null;
    }
  }

  Future<void> fetchCompletedBookings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = await _getAuthToken();
      if (token == null) {
        errorMessage.value = 'Authentication required. Please login again.';
        isLoading.value = false;
        return;
      }

      final url = Uri.parse('$baseUrl/booking/user?status=completed');
      print('🌐 Fetching completed bookings from: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          final List<dynamic> bookingsData = jsonData['data']['data'] ?? [];
          completedBookings.value = bookingsData.cast<Map<String, dynamic>>();
          print('✅ Loaded ${completedBookings.length} completed bookings');
        } else {
          errorMessage.value = jsonData['message'] ?? 'Failed to load bookings';
        }
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: $e';
      print('❌ Error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}*/







///
///
///
/// todo::: fixing the loading state issue for the get.snackbar
///
///



import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:manx_mate/core/utils/api/app_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

/// Controller for Active Slot Bookings (Active Slot)
class ActiveSlotBookingsController extends GetxController {
  var isLoading = false.obs;
  var activeSlotBookings = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;
  var isCancelling = false.obs;

  final String baseUrl = AppUrl.baseUrl;

  Future<String?> _getAuthToken() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      print('🔐 Token retrieved: ${token != null ? 'EXISTS (${token.length} chars)' : 'NULL'}');
      return token;
    } catch (e) {
      print('❌ Error getting auth token: $e');
      return null;
    }
  }

  Future<void> fetchActiveSlotBookings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = await _getAuthToken();
      if (token == null || token.isEmpty) {
        errorMessage.value = 'Authentication required. Please login again.';
        isLoading.value = false;
        return;
      }

      final url = Uri.parse('$baseUrl/booking/user?status=pending');
      print('🌐 Fetching active slot bookings from: $url');
      print('🔑 Using token: ${token.substring(0, 20)}...');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('✅ Parsed JSON: $jsonData');

        if (jsonData['success'] == true) {
          final List<dynamic> bookingsData = jsonData['data']['data'] ?? [];
          activeSlotBookings.value = bookingsData.cast<Map<String, dynamic>>();
          print('✅ Loaded ${activeSlotBookings.length} active bookings');
        } else {
          errorMessage.value = jsonData['message'] ?? 'Failed to load bookings';
          print('❌ API returned success=false: ${errorMessage.value}');
        }
      } else if (response.statusCode == 401) {
        errorMessage.value = 'Unauthorized. Please login again.';
        print('❌ Unauthorized access - token may be expired');
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
        print('❌ Server error: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      errorMessage.value = 'An error occurred: $e';
      print('❌ Error fetching bookings: $e');
      print('❌ Stack trace: $stackTrace');
    } finally {
      isLoading.value = false;
      print('🏁 Fetch completed. isLoading: ${isLoading.value}');
    }
  }

  /// Cancel booking by changing status to "cancelled"
  Future<bool> cancelBooking(String bookingId) async {
    if (bookingId.isEmpty) {
      print('❌ Cannot cancel: bookingId is empty');
      // Use Get.context or defer snackbar to UI
      _showErrorSnackbar('Invalid booking ID');
      return false;
    }

    try {
      isCancelling.value = true;
      print('🗑️ Starting cancellation for booking: $bookingId');

      final token = await _getAuthToken();
      if (token == null || token.isEmpty) {
        print('❌ Cannot cancel: No auth token');
        _showErrorSnackbar('Authentication required. Please login again.');
        return false;
      }

      final url = Uri.parse('$baseUrl/booking/respond/$bookingId');
      print('🌐 PATCH request to: $url');
      print('🔑 Using token: ${token.substring(0, 20)}...');
      print('📤 Request body: {"status": "cancelled"}');

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'status': 'cancelled',
        }),
      );

      print('📡 Cancel Response status: ${response.statusCode}');
      print('📦 Cancel Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final jsonData = json.decode(response.body);
          print('✅ Parsed cancel response: $jsonData');

          if (jsonData['success'] == true) {
            // Remove the cancelled booking from the list
            final removedCount = activeSlotBookings.length;
            activeSlotBookings.removeWhere((booking) => booking['_id'] == bookingId);
            print('✅ Booking removed from list. Before: $removedCount, After: ${activeSlotBookings.length}');

            // Defer snackbar to next frame to ensure proper context
            _showSuccessSnackbar('Booking cancelled successfully');

            print('🏁 API call completed. Success: true');
            return true;
          } else {
            final errorMsg = jsonData['message'] ?? 'Failed to cancel booking';
            print('❌ API returned success=false: $errorMsg');
            _showErrorSnackbar(errorMsg);
            return false;
          }
        } catch (parseError) {
          print('❌ Error parsing response: $parseError');
          _showErrorSnackbar('Invalid response from server');
          return false;
        }
      } else if (response.statusCode == 401) {
        print('❌ Unauthorized - token may be invalid');
        _showErrorSnackbar('Session expired. Please login again.');
        return false;
      } else if (response.statusCode == 404) {
        print('❌ Booking not found');
        _showErrorSnackbar('Booking not found');
        return false;
      } else {
        print('❌ Server error: ${response.statusCode}');
        _showErrorSnackbar('Server error: ${response.statusCode}');
        return false;
      }
    } on http.ClientException catch (e) {
      print('❌ Network error: $e');
      _showErrorSnackbar('Network error. Please check your connection.');
      return false;
    } catch (e, stackTrace) {
      print('❌ Unexpected error cancelling booking: $e');
      print('❌ Stack trace: $stackTrace');
      _showErrorSnackbar('Failed to cancel booking');
      return false;
    } finally {
      isCancelling.value = false;
      print('🏁 Cancellation completed. isCancelling: ${isCancelling.value}');
    }
  }

  /// Helper method to show error snackbar with proper context handling
  void _showErrorSnackbar(String message) {
    // Use WidgetsBinding to ensure snackbar is shown in next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
      Get.snackbar(
        'Error',
        message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    });
  }

  /// Helper method to show success snackbar with proper context handling
  void _showSuccessSnackbar(String message) {
    // Use WidgetsBinding to ensure snackbar is shown in next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
      Get.snackbar(
        'Success',
        message,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    });
  }
}

/// Controller for Pending Bookings (Ongoing Slot)
class PendingBookingsController extends GetxController {
  var isLoading = false.obs;
  var pendingBookings = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;
  var isCompleting = false.obs; // ✅ Added for completion tracking

  final String baseUrl = AppUrl.baseUrl;

  Future<String?> _getAuthToken() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      return token;
    } catch (e) {
      print('❌ Error getting auth token: $e');
      return null;
    }
  }

  Future<void> fetchPendingBookings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = await _getAuthToken();
      if (token == null) {
        errorMessage.value = 'Authentication required. Please login again.';
        isLoading.value = false;
        return;
      }

      final url = Uri.parse('$baseUrl/booking/user?status=accepted');
      print('🌐 Fetching pending bookings from: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          final List<dynamic> bookingsData = jsonData['data']['data'] ?? [];
          pendingBookings.value = bookingsData.cast<Map<String, dynamic>>();
          print('✅ Loaded ${pendingBookings.length} pending bookings');
        } else {
          errorMessage.value = jsonData['message'] ?? 'Failed to load bookings';
        }
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: $e';
      print('❌ Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ NEW METHOD: Mark booking as completed
  Future<bool> completeBooking(String bookingId) async {
    if (bookingId.isEmpty) {
      print('❌ Cannot complete: bookingId is empty');
      _showErrorSnackbar('Invalid booking ID');
      return false;
    }

    try {
      isCompleting.value = true;
      print('✅ Starting completion for booking: $bookingId');

      final token = await _getAuthToken();
      if (token == null || token.isEmpty) {
        print('❌ Cannot complete: No auth token');
        _showErrorSnackbar('Authentication required. Please login again.');
        return false;
      }

      final url = Uri.parse('$baseUrl/booking/respond/$bookingId');
      print('🌐 PATCH request to: $url');
      print('🔑 Using token: ${token.substring(0, 20)}...');
      print('📤 Request body: {"status": "completed"}');

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'status': 'completed',
        }),
      );

      print('📡 Complete Response status: ${response.statusCode}');
      print('📦 Complete Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final jsonData = json.decode(response.body);
          print('✅ Parsed complete response: $jsonData');

          if (jsonData['success'] == true) {
            // Remove the completed booking from the pending list
            final removedCount = pendingBookings.length;
            pendingBookings.removeWhere((booking) => booking['_id'] == bookingId);
            print('✅ Booking removed from ongoing list. Before: $removedCount, After: ${pendingBookings.length}');

            _showSuccessSnackbar('Booking marked as completed successfully');
            return true;
          } else {
            final errorMsg = jsonData['message'] ?? 'Failed to complete booking';
            print('❌ API returned success=false: $errorMsg');
            _showErrorSnackbar(errorMsg);
            return false;
          }
        } catch (parseError) {
          print('❌ Error parsing response: $parseError');
          _showErrorSnackbar('Invalid response from server');
          return false;
        }
      } else if (response.statusCode == 401) {
        print('❌ Unauthorized - token may be invalid');
        _showErrorSnackbar('Session expired. Please login again.');
        return false;
      } else if (response.statusCode == 404) {
        print('❌ Booking not found');
        _showErrorSnackbar('Booking not found');
        return false;
      } else {
        print('❌ Server error: ${response.statusCode}');
        _showErrorSnackbar('Server error: ${response.statusCode}');
        return false;
      }
    } on http.ClientException catch (e) {
      print('❌ Network error: $e');
      _showErrorSnackbar('Network error. Please check your connection.');
      return false;
    } catch (e, stackTrace) {
      print('❌ Unexpected error completing booking: $e');
      print('❌ Stack trace: $stackTrace');
      _showErrorSnackbar('Failed to complete booking');
      return false;
    } finally {
      isCompleting.value = false;
      print('🏁 Completion process finished. isCompleting: ${isCompleting.value}');
    }
  }

  /// Helper method to show error snackbar with proper context handling
  void _showErrorSnackbar(String message) {
    // Use WidgetsBinding to ensure snackbar is shown in next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
      Get.snackbar(
        'Error',
        message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    });
  }

  /// Helper method to show success snackbar with proper context handling
  void _showSuccessSnackbar(String message) {
    // Use WidgetsBinding to ensure snackbar is shown in next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
      Get.snackbar(
        'Success',
        message,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    });
  }
}

/// Controller for Completed Bookings (Past Slot)
class CompletedBookingsController extends GetxController {
  var isLoading = false.obs;
  var completedBookings = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;

  final String baseUrl = AppUrl.baseUrl;

  Future<String?> _getAuthToken() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      return token;
    } catch (e) {
      print('❌ Error getting auth token: $e');
      return null;
    }
  }

  Future<void> fetchCompletedBookings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = await _getAuthToken();
      if (token == null) {
        errorMessage.value = 'Authentication required. Please login again.';
        isLoading.value = false;
        return;
      }

      final url = Uri.parse('$baseUrl/booking/user?status=completed');
      print('🌐 Fetching completed bookings from: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          final List<dynamic> bookingsData = jsonData['data']['data'] ?? [];
          completedBookings.value = bookingsData.cast<Map<String, dynamic>>();
          print('✅ Loaded ${completedBookings.length} completed bookings');
        } else {
          errorMessage.value = jsonData['message'] ?? 'Failed to load bookings';
        }
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: $e';
      print('❌ Error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}



