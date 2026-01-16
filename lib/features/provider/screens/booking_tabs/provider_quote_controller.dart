import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';

import '../../../../core/service/socket_service.dart';

class ProviderQuoteController extends GetxController {
  var isLoading = false.obs;
  var bookings = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;
  var processingIds = <String>[].obs;

  final SocketServices _socketService = SocketServices();

  @override
  void onInit() {
    super.onInit();
    // 🔹 Order matters: Start listening first, then fetch
    _initSocketListener();
    fetchBookings();
  }

  Future<void> _initSocketListener() async {
    await _socketService.listen("NewServiceInquiry", (data) async {
      if (data == null) return;

      final String status = data['status']?.toString() ?? '';
      final String inquiryId = data['_id']?.toString() ?? '';

      if (status == 'respond') {
        bookings.removeWhere((item) => item['_id'] == inquiryId);
        debugPrint('🚫 Socket: Removed $inquiryId');
      }
      else if (status == 'active') {
        // 🔹 STRICT DUPLICATE CHECK
        bool alreadyExists = bookings.any((item) => item['_id'] == inquiryId);

        if (!alreadyExists) {
          final isCancelled = await _isLocallyCancelled(inquiryId);
          if (!isCancelled) {
            bookings.insert(0, data);
            debugPrint('✅ Socket: Inserted $inquiryId');
          }
        } else {
          debugPrint('ℹ️ Socket: Muted duplicate $inquiryId');
        }
      }
    });
  }

  Future<bool> _isLocallyCancelled(String id) async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonStr = prefs.getString('cancelled_booking_ids');
    if (jsonStr == null) return false;
    List<dynamic> list = json.decode(jsonStr);
    return list.contains(id);
  }

  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('accessToken');
    } catch (e) {
      debugPrint('❌ Error retrieving token: $e');
      return null;
    }
  }

  bool isProcessing(String bookingId) {
    return processingIds.contains(bookingId);
  }

  Future<void> fetchBookings({bool refresh = false}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = await _getAuthToken();
      final response = await http.get(
        Uri.parse(AppUrl.postInquiryQuote),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          List<Map<String, dynamic>> fetchedList = [];
          var responseData = data['data'];

          if (responseData is Map) {
            fetchedList = (responseData['data'] as List).cast<Map<String, dynamic>>();
          } else if (responseData is List) {
            fetchedList = responseData.cast<Map<String, dynamic>>();
          }

          // 1. Filter locally cancelled items
          final prefs = await SharedPreferences.getInstance();
          final cancelledIds = json.decode(prefs.getString('cancelled_booking_ids') ?? '[]');

          final filteredList = fetchedList.where((b) => !cancelledIds.contains(b['_id'])).toList();

          // 2. 🔹 MERGE LOGIC (Avoid overwriting socket data)
          if (refresh) {
            bookings.assignAll(filteredList);
          } else {
            for (var newItem in filteredList) {
              bool exists = bookings.any((oldItem) => oldItem['_id'] == newItem['_id']);
              if (!exists) {
                bookings.add(newItem);
              }
            }
          }
          debugPrint('✨ Sync complete. Total: ${bookings.length}');
        }
      }
    } catch (e) {
      debugPrint('🔥 Fetch Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> respondToBooking({required String bookingId}) async {
    try {
      debugPrint('🔘 Action: Accepting quote $bookingId...');
      processingIds.add(bookingId);

      final token = await _getAuthToken();
      final url = Uri.parse('https://d7001.sobhoy.com/api/v1/service-inquiry/$bookingId/accept');

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
          debugPrint('✅ Accept Success: Inquiry $bookingId removed from UI');
          Get.snackbar('Success', 'Accepted successfully', backgroundColor: Colors.green, colorText: Colors.white);
        } else {
          debugPrint('⚠️ Accept Failed: ${data['message']}');
          Get.snackbar('Error', data['message'] ?? 'Failed to update', backgroundColor: Colors.red, colorText: Colors.white);
        }
      }
    } catch (e) {
      debugPrint('🔥 Accept Exception: $e');
    } finally {
      processingIds.remove(bookingId);
    }
  }

  Future<void> cancelBookingLocally(String bookingId) async {
    try {
      debugPrint('🔘 Action: Cancelling booking $bookingId locally...');
      final prefs = await SharedPreferences.getInstance();
      String? cancelledIdsJson = prefs.getString('cancelled_booking_ids');
      List<String> cancelledIds = [];

      if (cancelledIdsJson != null) {
        cancelledIds = List<String>.from(json.decode(cancelledIdsJson));
      }

      if (!cancelledIds.contains(bookingId)) {
        cancelledIds.add(bookingId);
        await prefs.setString('cancelled_booking_ids', json.encode(cancelledIds));
        debugPrint('💾 Local Storage: ID $bookingId added to ignore list');
      }

      bookings.removeWhere((booking) => booking['_id'] == bookingId);
      debugPrint('🗑️ UI: Inquiry $bookingId removed');

      Get.snackbar('Cancelled', 'Quote cancelled Successfully', backgroundColor: Colors.orange, colorText: Colors.white);
    } catch (e) {
      debugPrint('🔥 Cancel Exception: $e');
    }
  }
}