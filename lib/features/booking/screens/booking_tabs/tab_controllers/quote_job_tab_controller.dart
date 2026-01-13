import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/network/network_caller.dart';
import '../../../../../core/network/network_response.dart';
import '../../../../../core/utils/api/app_url.dart';
import '../../../../../core/utils/token_service/token_storage_service.dart';
import '../../../../../model/booking_service_model.dart';

class QuoteController extends GetxController {
  var isLoading = false.obs;
  var quotes = <BookingServiceModel>[].obs;

  final NetworkCaller _networkCaller = NetworkCaller();
  final SharedPrefService _sharedPrefService = Get.find<SharedPrefService>();

  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var hasMore = true.obs;

  // Polling
  Timer? _pollingTimer;
  final RxBool isPollingEnabled = true.obs;
  static const int pollingIntervalSeconds = 1000;

  @override
  void onInit() {
    super.onInit();
    fetchQuotes();
    _startPolling();
  }

  @override
  void onClose() {
    _pollingTimer?.cancel();
    super.onClose();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: pollingIntervalSeconds),
          (_) {
        if (isPollingEnabled.value && !isLoading.value) {
          _silentRefresh();
        }
      },
    );
  }

  /// ---------------- DELETE QUOTE ----------------
  Future<void> deleteQuote(String quoteId) async {
    try {
      isLoading.value = true;

      final String? accessToken = await _sharedPrefService.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        Get.snackbar(
          'Unauthorized',
          'Please login again',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

      final NetworkResponse response = await _networkCaller.deleteRequest(
        AppUrl.userQuoteDelete(quoteId),
        headers: headers,
      );

      if (response.isSuccess) {
        quotes.removeWhere((q) => q.id == quoteId);

        Get.snackbar(
          'Cancelled',
          'Quote has been cancelled successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Error',
          response.errorMessage ?? 'Failed to cancel quote',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('❌ Delete Quote Error: $e');
      Get.snackbar(
        'Error',
        'Something went wrong',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// ---------------- FETCH QUOTES ----------------
  Future<void> fetchQuotes({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        currentPage.value = 1;
        hasMore.value = true;
        quotes.clear();
      }

      if (!hasMore.value) return;

      isLoading.value = true;

      final String? accessToken = await _sharedPrefService.getAccessToken();
      if (accessToken == null) return;

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

      final response = await _networkCaller.getRequest(
        '${AppUrl.getMyQuote}?page=${currentPage.value}&limit=10',
        headers: headers,
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final data = response.jsonResponse!['data'];

        final List parsed = data['data'] ?? [];
        final List<BookingServiceModel> parsedQuotes =
        parsed.map((e) => BookingServiceModel.fromJson(e)).toList();

        quotes.addAll(parsedQuotes);

        final pagination = data['pagination'];
        currentPage.value = pagination['page'];
        totalPages.value = pagination['totalPages'];
        hasMore.value = currentPage.value < totalPages.value;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshQuotes() async {
    await fetchQuotes(isRefresh: true);
  }

  Future<void> loadMoreQuotes() async {
    if (hasMore.value && !isLoading.value) {
      currentPage.value++;
      await fetchQuotes();
    }
  }

  Future<void> _silentRefresh() async {}
}
