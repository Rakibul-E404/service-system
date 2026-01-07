/**
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/network/network_caller.dart';
import '../../../../../core/network/network_response.dart';
import '../../../../../core/utils/api/app_url.dart';
import '../../../../../core/utils/token_service/token_storage_service.dart';
import '../../../../../model/booking_service_model.dart';

class QuoteController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<BookingServiceModel> quotes = <BookingServiceModel>[].obs;
  final NetworkCaller _networkCaller = NetworkCaller();

  RxInt currentPage = 1.obs;
  RxInt totalPages = 1.obs;
  RxBool hasMore = true.obs;

  // Real-time polling
  Timer? _pollingTimer;
  final RxBool isPollingEnabled = true.obs;
  static const int pollingIntervalSeconds = 100; // Poll every 10 seconds

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
          (Timer timer) async {
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

      Map<String, String> headers = <String, String>{
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
              final List<BookingServiceModel> newQuotes = <BookingServiceModel>[];

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
                final Set<String> currentIds = quotes.map((BookingServiceModel q) => q.id).toSet();
                final bool hasNewData = newQuotes.any((BookingServiceModel q) => !currentIds.contains(q.id));

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
                final Map<String, BookingServiceModel> updatedQuotes = <String, BookingServiceModel>{};

                for (BookingServiceModel quote in newQuotes) {
                  updatedQuotes[quote.id] = quote;
                }

                for (BookingServiceModel quote in quotes) {
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

      Map<String, String> headers = <String, String>{
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
              final List<BookingServiceModel> parsedQuotes = <BookingServiceModel>[];

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
                quotes.value = <BookingServiceModel>[];
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
}*/


























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
