/**
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProviderRequestController extends GetxController {
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

  Future<void> fetchBookings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      bookings.clear();

      final token = await _getAuthToken();
      final url = Uri.parse('https://d7001.sobhoy.com/api/v1/booking/provider?status=pending');
      print('🌐 Fetching request bookings from: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📊 Full API Response: ${json.encode(data)}');

        if (data['success'] == true) {
          final responseData = data['data'];
          if (responseData is Map<String, dynamic>) {
            final List<dynamic> list = responseData['data'] ?? [];
            bookings.value = list.cast<Map<String, dynamic>>();
            print('✅ Loaded ${bookings.length} request bookings');
          } else if (responseData is List) {
            bookings.value = responseData.cast<Map<String, dynamic>>();
            print('✅ Loaded ${bookings.length} request bookings (direct list)');
          } else {
            errorMessage.value = 'Unexpected data format';
          }
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
    required String status,
  }) async {
    try {
      processingIds.add(bookingId);

      final token = await _getAuthToken();
      final url = Uri.parse('https://d7001.sobhoy.com/api/v1/booking/respond/$bookingId');
      print('🌐 Updating booking status: $url');

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
          print('✅ Booking $bookingId $status successfully');
          bookings.removeWhere((booking) => booking['_id'] == bookingId);

          Get.snackbar(
            'Success',
            'Booking ${status == 'accepted' ? 'approved' : 'rejected'} successfully',
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
}*/





import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';

class ProviderRequestController extends GetxController {
  var isLoading = false.obs;
  var bookings = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;
  var processingIds = <String>[].obs;

  // Pagination properties
  var currentPage = 1.obs;
  var hasMore = true.obs;
  var isRefreshing = false.obs;
  var isLoadMore = false.obs;

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

  Future<void> fetchBookings({bool refresh = false}) async {
    try {
      if (refresh) {
        isRefreshing.value = true;
        currentPage.value = 1;
        hasMore.value = true;
        bookings.clear();
      } else {
        isLoading.value = true;
      }
      errorMessage.value = '';

      final token = await _getAuthToken();
      if (token == null) {
        errorMessage.value = 'Authentication required';
        return;
      }

      final url = Uri.parse(AppUrl.providerJObRequested(currentPage.value));
      print('🌐 Fetching request bookings from: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📊 Full API Response: ${json.encode(data)}');

        if (data['success'] == true) {
          final responseData = data['data'];

          if (responseData is Map<String, dynamic>) {
            // Handle paginated response
            final List<dynamic> list = responseData['data'] ?? [];
            final meta = responseData['meta'] ?? {};

            // Check if there are more pages
            final totalPages = meta['totalPages'] ?? 1;
            hasMore.value = currentPage.value < totalPages;

            if (refresh) {
              bookings.value = list.cast<Map<String, dynamic>>();
            } else {
              bookings.addAll(list.cast<Map<String, dynamic>>());
            }

            print('✅ Loaded ${list.length} request bookings (Page ${currentPage.value}/$totalPages)');
          } else if (responseData is List) {
            // Handle direct list response (fallback)
            bookings.value = responseData.cast<Map<String, dynamic>>();
            print('✅ Loaded ${bookings.length} request bookings (direct list)');
            hasMore.value = false;
          } else {
            errorMessage.value = 'Unexpected data format';
          }
        } else {
          errorMessage.value = data['message'] ?? 'Failed to fetch data';
        }
      } else if (response.statusCode == 401) {
        errorMessage.value = 'Session expired. Please login again.';
      } else {
        errorMessage.value = 'Server Error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Connection Error: $e';
      print('❌ Exception in fetchBookings: $e');
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
      currentPage.value--; // Revert page increment on error
      print('❌ Error loading more bookings: $e');
    } finally {
      isLoadMore.value = false;
    }
  }

  Future<void> respondToBooking({
    required String bookingId,
    required String status,
  }) async {
    try {
      processingIds.add(bookingId);

      final token = await _getAuthToken();
      if (token == null) {
        Get.snackbar(
          'Error',
          'Authentication required',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final url = Uri.parse('${AppUrl.baseUrlV1}/booking/respond/$bookingId');
      print('🌐 Updating booking status: $url');

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
          print('✅ Booking $bookingId $status successfully');

          // Remove the booking from the list
          bookings.removeWhere((booking) => booking['_id'] == bookingId);

          Get.snackbar(
            'Success',
            'Booking ${status == 'accepted' ? 'approved' : 'rejected'} successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
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
      } else if (response.statusCode == 401) {
        Get.snackbar(
          'Error',
          'Session expired. Please login again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
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

  // Refresh function
  Future<void> refreshBookings() async {
    await fetchBookings(refresh: true);
  }
}