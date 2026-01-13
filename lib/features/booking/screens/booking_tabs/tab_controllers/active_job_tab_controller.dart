import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/network/network_caller.dart';
import 'package:manx_mate/core/network/network_response.dart';
import 'package:manx_mate/core/service/socket_service.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';
import 'package:manx_mate/core/utils/token_service/token_storage_service.dart';

class ActiveJobController extends GetxController {
  // Made public so it can be accessed from the UI layer for cancellation
  final NetworkCaller networkCaller = NetworkCaller();

  final RxList<Map<String, dynamic>> activeJobs = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxBool hasMore = true.obs;
  final RxBool isRefreshing = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchActiveJobs();

    // Listen for real-time updates via Socket.io
    SocketServices().listen('OrderStatusUpdate', (data) {
      debugPrint("OrderStatusUpdate -----------> $data");
      // Refresh data when order status changes
      refreshActiveJobs();
    });
  }

  /// Fetch active jobs with pagination
  Future<void> fetchActiveJobs({bool isRefresh = false}) async {
    if (isLoading.value && !isRefresh) return;

    try {
      if (isRefresh) {
        currentPage.value = 1;
        hasMore.value = true;
        isRefreshing.value = true;
      }

      if (!hasMore.value && !isRefresh) return;

      isLoading.value = true;

      // Get access token
      final SharedPrefService sharedPrefService = Get.find<SharedPrefService>();
      final String? accessToken = await sharedPrefService.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        Get.snackbar(
          'Error',
          'Please login to view active jobs',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isLoading.value = false;
        isRefreshing.value = false;
        return;
      }

      // Make API call using AppUrl helper
      final NetworkResponse response = await networkCaller.getRequest(
        AppUrl.activeJob(currentPage.value),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (!response.isSuccess || response.jsonResponse == null) {
        Get.snackbar(
          'Error',
          response.errorMessage ?? 'Failed to fetch active jobs',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isLoading.value = false;
        isRefreshing.value = false;
        return;
      }

      final Map<String, dynamic> json = response.jsonResponse!;
      final data = json['data'];

      if (data == null || data['bookings'] is! List) {
        isLoading.value = false;
        isRefreshing.value = false;
        return;
      }

      final List<dynamic> list = data['bookings'];

      if (isRefresh || currentPage.value == 1) {
        // Replace all items on refresh or first page
        activeJobs.assignAll(list.whereType<Map<String, dynamic>>().toList());
      } else {
        // Add to existing items
        activeJobs.addAll(list.whereType<Map<String, dynamic>>().toList());
      }

      /// Pagination handling
      if (data['pagination'] != null) {
        totalPages.value = data['pagination']['totalPages'] ?? 1;
        hasMore.value = currentPage.value < totalPages.value;
      }

      /// Remove duplicates by ID (optional safety)
      activeJobs.assignAll({
        for (var job in activeJobs) job['_id']: job,
      }.values.toList());

      // Notify UI to update
      update();

      debugPrint('✅ Fetched ${list.length} active jobs (Page ${currentPage.value})');

    } catch (e) {
      debugPrint('🔥 ActiveJobController Error: $e');
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  /// Pull-to-refresh
  Future<void> refreshActiveJobs() async {
    await fetchActiveJobs(isRefresh: true);
  }

  /// Load next page
  Future<void> loadMoreActiveJobs() async {
    if (!hasMore.value || isLoading.value) return;
    currentPage.value++;
    await fetchActiveJobs();
  }

  /// Cancel a booking by ID (used by UI)
  Future<NetworkResponse> cancelBooking(String bookingId) async {
    final SharedPrefService sharedPrefService = Get.find<SharedPrefService>();
    final String? accessToken = await sharedPrefService.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      return NetworkResponse(
        isSuccess: false,
        errorMessage: 'Unauthorized: Missing access token',
      );
    }

    return await networkCaller.patchRequest(
      AppUrl.userCanceledBooking(bookingId),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: {
        'status': 'cancelled',
      },
    );
  }
}
