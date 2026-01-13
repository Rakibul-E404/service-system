import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/network/network_caller.dart';
import 'package:manx_mate/core/network/network_response.dart';
import 'package:manx_mate/core/service/socket_service.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';
import 'package:manx_mate/core/utils/token_service/token_storage_service.dart';

class PastJobController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();

  final RxList<Map<String, dynamic>> pastJobs = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxBool hasMore = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPastJobs();

    // Listen for real-time updates via Socket.io
    SocketServices().listen('OrderStatusUpdate', (data) {
      print("OrderStatusUpdate -----------> $data");
      // Refresh data when order status changes to completed
      fetchPastJobs(isRefresh: true);
    });
  }

  /// Fetch past jobs with pagination
  Future<void> fetchPastJobs({bool isRefresh = false}) async {
    if (isLoading.value) return;

    try {
      if (isRefresh) {
        currentPage.value = 1;
        hasMore.value = true;
        pastJobs.clear();
      }

      if (!hasMore.value && !isRefresh) return;

      isLoading.value = true;

      // Get access token
      final SharedPrefService sharedPrefService = Get.find<SharedPrefService>();
      final String? accessToken = await sharedPrefService.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        Get.snackbar(
          'Error',
          'Please login to view past jobs',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isLoading.value = false;
        return;
      }

      // Make API call using AppUrl helper
      final NetworkResponse response = await _networkCaller.getRequest(
        AppUrl.pastJob(currentPage.value),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (!response.isSuccess || response.jsonResponse == null) {
        Get.snackbar(
          'Error',
          response.errorMessage ?? 'Failed to fetch past jobs',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final Map<String, dynamic> json = response.jsonResponse!;
      final data = json['data'];

      if (data == null || data['bookings'] is! List) {
        return;
      }

      final List<dynamic> list = data['bookings'];

      if (isRefresh) {
        // Replace all items on refresh
        pastJobs.assignAll(list.whereType<Map<String, dynamic>>().toList());
      } else {
        // Add to existing items
        pastJobs.addAll(list.whereType<Map<String, dynamic>>().toList());
      }

      /// Pagination handling
      if (data['pagination'] != null) {
        totalPages.value = data['pagination']['totalPages'] ?? 1;
        hasMore.value = currentPage.value < totalPages.value;
      }

      /// Remove duplicates by ID
      pastJobs.assignAll({
        for (var job in pastJobs) job['_id']: job,
      }.values.toList());

      debugPrint('✅ Fetched ${list.length} past jobs (Page ${currentPage.value})');

    } catch (e) {
      debugPrint('🔥 PastJobController Error: $e');
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Pull-to-refresh
  Future<void> refreshPastJobs() async {
    await fetchPastJobs(isRefresh: true);
  }

  /// Load next page
  Future<void> loadMorePastJobs() async {
    if (!hasMore.value || isLoading.value) return;
    currentPage.value++;
    await fetchPastJobs();
  }
}