import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/network/network_caller.dart';
import '../../../../../core/network/network_response.dart';
import '../../../../../core/utils/api/app_url.dart';
import '../../../../../core/utils/token_service/token_storage_service.dart';
import '../../../../../model/booking_service_model.dart';

class QuoteController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();

  final isLoading = false.obs;
  final quotes = <BookingServiceModel>[].obs;

  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final hasMore = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchQuotes();
  }

  /// Fetch quotes (used for initial load, refresh & pagination)
  Future<void> fetchQuotes({bool isRefresh = false}) async {
    if (isLoading.value) return;

    try {
      if (isRefresh) {
        currentPage.value = 1;
        hasMore.value = true;
        quotes.clear();
      }

      if (!hasMore.value) return;

      isLoading.value = true;

      // Get access token
      final SharedPrefService sharedPrefService =
      Get.find<SharedPrefService>();
      final String? accessToken =
      await sharedPrefService.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        Get.snackbar(
          'Error',
          'Please login to view quotes',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final NetworkResponse response =
      await _networkCaller.getRequest(
        '${AppUrl.getMyQuote}?page=${currentPage.value}&limit=10',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (!response.isSuccess || response.jsonResponse == null) {
        Get.snackbar(
          'Error',
          response.errorMessage ?? 'Failed to fetch quotes',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final json = response.jsonResponse!;
      final data = json['data'];

      if (data == null || data['data'] is! List) return;

      final List<dynamic> list = data['data'];

      final parsedQuotes = list
          .whereType<Map<String, dynamic>>()
          .map(BookingServiceModel.fromJson)
          .toList();

      quotes.addAll(parsedQuotes);

      /// Pagination handling (BACKEND → frontend sync)
      if (data['pagination'] != null) {
        totalPages.value = data['pagination']['totalPages'] ?? 1;
        hasMore.value = currentPage.value < totalPages.value;
      }

      /// 🛡️ Safety: Remove accidental duplicates by ID
      quotes.assignAll({
        for (var q in quotes) q.id: q,
      }.values.toList());

    } catch (e) {
      debugPrint('🔥 QuoteController Error: $e');
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
  Future<void> refreshQuotes() async {
    await fetchQuotes(isRefresh: true);
  }

  /// Load next page
  Future<void> loadMoreQuotes() async {
    if (!hasMore.value || isLoading.value) return;
    currentPage.value++;
    await fetchQuotes();
  }
}
