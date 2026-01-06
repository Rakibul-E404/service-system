/**
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
*/
















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

  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var hasMore = true.obs;

  // Real-time polling
  Timer? _pollingTimer;
  final RxBool isPollingEnabled = true.obs;
  static const int pollingIntervalSeconds = 1000; // Poll every 10 seconds

  @override
  void onInit() {
    super.onInit();
    fetchQuotes();
    _startPolling();
  }

  @override
  void onClose() {
    _stopPolling();
    super.onClose();
  }

  /// Start periodic polling for real-time updates
  void _startPolling() {
    _pollingTimer?.cancel();

    _pollingTimer = Timer.periodic(
      const Duration(seconds: pollingIntervalSeconds),
          (timer) async {
        if (isPollingEnabled.value && !isLoading.value) {
          await _silentRefresh();
        }
      },
    );

    debugPrint('🔄 Quote polling started (every $pollingIntervalSeconds seconds)');
  }

  /// Stop polling
  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    debugPrint('⏸️ Quote polling stopped');
  }

  /// Toggle polling on/off
  void togglePolling(bool enabled) {
    isPollingEnabled.value = enabled;
    if (enabled) {
      _startPolling();
    } else {
      _stopPolling();
    }
  }

  /// Silent refresh without showing loading indicator
  Future<void> _silentRefresh() async {
    try {
      final SharedPrefService sharedPrefService = Get.find<SharedPrefService>();
      final String? accessToken = await sharedPrefService.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        return;
      }

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

      final NetworkResponse response = await _networkCaller.getRequest(
        '${AppUrl.getMyQuote}?page=1&limit=10',
        headers: headers,
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final Map<String, dynamic> jsonData = response.jsonResponse!;

        if (jsonData['success'] == true && jsonData.containsKey('data')) {
          final Map<String, dynamic> data = jsonData['data'];

          if (data.containsKey('data') && data['data'] is List) {
            final List<dynamic> quotesData = data['data'];

            if (quotesData.isNotEmpty) {
              final List<BookingServiceModel> newQuotes = [];

              for (var item in quotesData) {
                try {
                  if (item is Map<String, dynamic>) {
                    newQuotes.add(BookingServiceModel.fromJson(item));
                  }
                } catch (e) {
                  debugPrint('❌ Error parsing quote: $e');
                }
              }

              // Check if there are new quotes
              if (newQuotes.isNotEmpty) {
                final currentIds = quotes.map((q) => q.id).toSet();
                final hasNewData = newQuotes.any((q) => !currentIds.contains(q.id));

                if (hasNewData) {
                  // Show notification
                  Get.snackbar(
                    '🔔 New Quotes Available',
                    'Tap to refresh and see new quotes',
                    backgroundColor: Colors.blue.shade600,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 3),
                    snackPosition: SnackPosition.TOP,
                    margin: const EdgeInsets.all(16),
                    borderRadius: 8,
                    onTap: (_) => refreshQuotes(),
                  );
                }

                // Update silently
                final updatedQuotes = <String, BookingServiceModel>{};

                for (var quote in newQuotes) {
                  updatedQuotes[quote.id] = quote;
                }

                for (var quote in quotes) {
                  if (!updatedQuotes.containsKey(quote.id)) {
                    updatedQuotes[quote.id] = quote;
                  }
                }

                quotes.assignAll(updatedQuotes.values.toList());
              }

              debugPrint('✅ Silent quote refresh - ${newQuotes.length} quotes');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('🔥 Silent quote refresh error: $e');
    }
  }

  Future<void> fetchQuotes({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        currentPage.value = 1;
        hasMore.value = true;
        quotes.clear();
      }

      if (!hasMore.value && !isRefresh) return;

      isLoading.value = true;

      final SharedPrefService sharedPrefService = Get.find<SharedPrefService>();
      final String? accessToken = await sharedPrefService.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        Get.snackbar(
          'Error',
          'Please login to view quotes',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        isLoading.value = false;
        return;
      }

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

      debugPrint('🔑 Fetching quotes with token: ${accessToken.substring(0, 20)}...');

      final NetworkResponse response = await _networkCaller.getRequest(
        '${AppUrl.getMyQuote}?page=${currentPage.value}&limit=10',
        headers: headers,
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final Map<String, dynamic> jsonData = response.jsonResponse!;

        if (jsonData['success'] == true && jsonData.containsKey('data')) {
          final Map<String, dynamic> data = jsonData['data'];

          if (data.containsKey('data') && data['data'] is List) {
            final List<dynamic> quotesData = data['data'];

            if (quotesData.isNotEmpty) {
              final List<BookingServiceModel> parsedQuotes = [];

              for (var item in quotesData) {
                try {
                  if (item is Map<String, dynamic>) {
                    debugPrint('✅ Parsing quote: ${item['_id']}');
                    parsedQuotes.add(BookingServiceModel.fromJson(item));
                  }
                } catch (e) {
                  debugPrint('❌ Error parsing quote item: $e');
                }
              }

              if (isRefresh) {
                quotes.value = parsedQuotes;
              } else {
                quotes.addAll(parsedQuotes);
              }

              debugPrint('🎉 Successfully loaded ${parsedQuotes.length} quotes');

              if (data.containsKey('pagination') && data['pagination'] is Map<String, dynamic>) {
                final Map<String, dynamic> pagination = data['pagination'];
                currentPage.value = (pagination['page'] as int?) ?? 1;
                totalPages.value = (pagination['totalPages'] as int?) ?? 1;
                hasMore.value = currentPage.value < totalPages.value;
              }
            } else {
              debugPrint('📭 No quotes found');
              if (isRefresh) {
                quotes.value = [];
              }
            }
          }
        }
      } else {
        Get.snackbar(
          'Error',
          response.errorMessage ?? 'Failed to fetch quotes',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      debugPrint('🔥 Exception in fetchQuotes: $e');
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
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
}