import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/network/network_caller.dart';
import 'package:manx_mate/core/network/network_response.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';
import 'package:manx_mate/core/utils/token_service/token_storage_service.dart';

class ActiveJobController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();

  final RxList<Map<String, dynamic>> activeJobs = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxBool hasMore = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchActiveJobs();
  }

  /// Fetch active jobs with pagination
  Future<void> fetchActiveJobs({bool isRefresh = false}) async {
    if (isLoading.value) return;

    try {
      if (isRefresh) {
        currentPage.value = 1;
        hasMore.value = true;
        activeJobs.clear();
      }

      if (!hasMore.value) return;

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
        return;
      }

      final NetworkResponse response = await _networkCaller.getRequest(
        '${AppUrl.bookingUrlV1}?status=accepted&page=${currentPage.value}&limit=10',
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
        return;
      }

      final json = response.jsonResponse!;
      final data = json['data'];

      if (data == null || data['bookings'] is! List) return;

      final List<dynamic> list = data['bookings'];
      activeJobs.addAll(list.whereType<Map<String, dynamic>>().toList());

      /// Pagination handling
      if (data['pagination'] != null) {
        totalPages.value = data['pagination']['totalPages'] ?? 1;
        hasMore.value = currentPage.value < totalPages.value;
      }

      /// Remove duplicates by ID
      activeJobs.assignAll({
        for (var job in activeJobs) job['_id']: job,
      }.values.toList());

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
}