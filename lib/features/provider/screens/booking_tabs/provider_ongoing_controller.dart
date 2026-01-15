/**import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:manx_mate/core/utils/api/app_url.dart';
import 'package:manx_mate/model/booking_service_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProviderOngoingController extends GetxController {
  var isLoading = false.obs;
  
  // FIXED: Now uses the typed Model instead of a Map
  var bookings = <BookingServiceModel>[].obs;

  var errorMessage = ''.obs;
  var processingIds = <String>[].obs;

  // Added Pagination variables to match Request Controller flow
  var currentPage = 1.obs;
  var hasMore = true.obs;
  var isRefreshing = false.obs;
  var isLoadMore = false.obs;

  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('accessToken');
    } catch (e) {
      return null;
    }
  }

  bool isProcessing(String bookingId) => processingIds.contains(bookingId);

  Future<void> fetchBookings({bool refresh = false}) async {
    try {
      // Always show loader when fetching data
      if (currentPage.value == 1) {
        isLoading.value = true;
      }

      if (refresh) {
        currentPage.value = 1;
        hasMore.value = true;
        isRefreshing.value = true;
      }

      errorMessage.value = '';
      final token = await _getAuthToken();
      if (token == null) {
        errorMessage.value = 'Authentication required';
        return;
      }

      // Ensure your AppUrl has a route for ongoing/accepted bookings
      // Using status=accepted as per your initial code
      final url = Uri.parse('${AppUrl.baseUrl}/booking/provider?status=accepted&page=${currentPage.value}');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json', 
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final responseData = data['data'];
          final List<dynamic> rawList = responseData['data'] ?? [];

          // Map raw json to typed Models
          final List<BookingServiceModel> parsedList = rawList
              .map((e) => BookingServiceModel.fromJson(e))
              .toList();

          // Handle Pagination logic
          final pagination = responseData['meta'] ?? responseData['pagination'] ?? {};
          final totalPages = pagination['totalPages'] ?? 1;
          hasMore.value = currentPage.value < totalPages;

          if (refresh || currentPage.value == 1) {
            bookings.assignAll(parsedList);
          } else {
            bookings.addAll(parsedList);
          }
        } else {
          errorMessage.value = data['message'] ?? 'Failed to fetch data';
        }
      } else {
        errorMessage.value = 'Server Error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Connection Error';
      debugPrint('🔥 Ongoing Fetch Error: $e');
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  // Same logic as Request controller to keep it consistent
  Future<void> loadMoreBookings() async {
    if (isLoadMore.value || !hasMore.value) return;
    try {
      isLoadMore.value = true;
      currentPage.value++;
      await fetchBookings();
    } catch (e) {
      currentPage.value--;
    } finally {
      isLoadMore.value = false;
    }
  }

  Future<void> respondToBooking({required String bookingId, required String status}) async {
    try {
      processingIds.add(bookingId);
      final token = await _getAuthToken();
      final url = Uri.parse('${AppUrl.baseUrlV1}/booking/respond/$bookingId');

      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Model-based removal (using .id property)
          bookings.removeWhere((booking) => booking.id == bookingId);
          Get.snackbar(
            'Success', 'Booking updated to $status',
            backgroundColor: Colors.green, colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      debugPrint('🔥 Error in Ongoing respondToBooking: $e');
    } finally {
      processingIds.remove(bookingId);
    }
  }
}*/



///
///
/// todo:: uppper is ok and now adding options to set the phone and email
///
///
///



import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:manx_mate/core/utils/api/app_url.dart';
import 'package:manx_mate/model/booking_service_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProviderOngoingController extends GetxController {
  var isLoading = false.obs;

  var bookings = <BookingServiceModel>[].obs;
  var errorMessage = ''.obs;
  var processingIds = <String>[].obs;

  // Pagination variables
  var currentPage = 1.obs;
  var hasMore = true.obs;
  var isRefreshing = false.obs;
  var isLoadMore = false.obs;

  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('accessToken');
    } catch (e) {
      return null;
    }
  }

  bool isProcessing(String bookingId) => processingIds.contains(bookingId);

  Future<void> fetchBookings({bool refresh = false}) async {
    try {
      // Always show loader when fetching data
      if (currentPage.value == 1) {
        isLoading.value = true;
      }

      if (refresh) {
        currentPage.value = 1;
        hasMore.value = true;
        isRefreshing.value = true;
      }

      errorMessage.value = '';
      final token = await _getAuthToken();
      if (token == null) {
        errorMessage.value = 'Authentication required';
        return;
      }

      final url = Uri.parse('${AppUrl.baseUrl}/booking/provider?status=accepted&page=${currentPage.value}');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('📦 API Response: ${response.body}'); // Debug log

        if (data['success'] == true) {
          final responseData = data['data'];
          final List<dynamic> rawList = responseData['data'] ?? [];

          // Map raw json to typed Models
          final List<BookingServiceModel> parsedList = rawList
              .map((e) => BookingServiceModel.fromJson(e))
              .toList();

          // Handle Pagination logic
          final pagination = responseData['pagination'] ?? {};
          final totalPages = pagination['totalPages'] ?? 1;
          final currentPageNum = pagination['page'] ?? 1;

          hasMore.value = currentPageNum < totalPages;
          currentPage.value = currentPageNum;

          if (refresh || currentPage.value == 1) {
            bookings.assignAll(parsedList);
          } else {
            bookings.addAll(parsedList);
          }
        } else {
          errorMessage.value = data['message'] ?? 'Failed to fetch data';
        }
      } else {
        errorMessage.value = 'Server Error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Connection Error: ${e.toString()}';
      debugPrint('🔥 Ongoing Fetch Error: $e');
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  Future<void> loadMoreBookings() async {
    if (isLoadMore.value || !hasMore.value) return;
    try {
      isLoadMore.value = true;
      currentPage.value++;
      await fetchBookings();
    } catch (e) {
      currentPage.value--;
    } finally {
      isLoadMore.value = false;
    }
  }

  Future<void> respondToBooking({required String bookingId, required String status}) async {
    try {
      processingIds.add(bookingId);
      final token = await _getAuthToken();
      final url = Uri.parse('${AppUrl.baseUrlV1}/booking/respond/$bookingId');

      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          bookings.removeWhere((booking) => booking.id == bookingId);
          Get.snackbar(
            'Success',
            'Booking updated to $status',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        } else {
          Get.snackbar(
            'Error',
            data['message'] ?? 'Failed to update booking',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Server error: ${response.statusCode}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('🔥 Error in Ongoing respondToBooking: $e');
      Get.snackbar(
        'Error',
        'Connection failed',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      processingIds.remove(bookingId);
    }
  }
}