import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:manx_mate/core/utils/api/app_url.dart';
import 'package:manx_mate/model/booking_service_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProviderCompleteController extends GetxController {
  var isLoading = false.obs;

  // FIXED: Changed from Map to BookingServiceModel
  var bookings = <BookingServiceModel>[].obs;

  var errorMessage = ''.obs;

  // Added Pagination variables for consistent data flow
  var currentPage = 1.obs;
  var hasMore = true.obs;
  var isRefreshing = false.obs;
  var isLoadMore = false.obs;

  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('accessToken');
    } catch (e) {
      debugPrint('❌ Error retrieving token: $e');
      return null;
    }
  }

  Future<void> fetchBookings({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 1;
        hasMore.value = true;
        isRefreshing.value = true;
      } else if (currentPage.value == 1) {
        isLoading.value = true;
      }

      errorMessage.value = '';
      final token = await _getAuthToken();
      
      if (token == null) {
        errorMessage.value = 'Authentication required';
        return;
      }

      // Constructing URL with status=completed and pagination
      final url = Uri.parse('${AppUrl.baseUrl}/booking/provider?status=completed&page=${currentPage.value}');
      debugPrint('🌐 Fetching completed bookings from: $url');

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
          final List<dynamic> rawList = responseData['data'] ?? [];

          // Map raw json to typed Models
          final List<BookingServiceModel> parsedList = rawList
              .map((e) => BookingServiceModel.fromJson(e))
              .toList();

          // Handle Pagination logic (supports 'meta' or 'pagination' keys)
          final pagination = responseData['meta'] ?? responseData['pagination'] ?? {};
          final totalPages = pagination['totalPages'] ?? 1;
          hasMore.value = currentPage.value < totalPages;

          if (refresh || currentPage.value == 1) {
            // Replaces the list entirely, fixing the data count issues
            bookings.assignAll(parsedList);
          } else {
            // Adds more data for infinite scroll
            bookings.addAll(parsedList);
          }
          
          debugPrint('✅ Loaded ${bookings.length} completed bookings');
        } else {
          errorMessage.value = data['message'] ?? 'Failed to fetch data';
        }
      } else {
        errorMessage.value = 'Server Error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Connection Error';
      debugPrint('🔥 Exception in Complete Fetch: $e');
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  // Load more function for Infinite Scroll
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
}