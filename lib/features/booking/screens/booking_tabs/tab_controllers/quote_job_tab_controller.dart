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

  @override
  void onInit() {
    super.onInit();
    fetchQuotes();
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

      // Get access token
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

      // Prepare headers
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
                    debugPrint('📝 SubCategory: ${item['subCategory']}');
                    debugPrint('📍 Location: ${item['location']}');

                    parsedQuotes.add(BookingServiceModel.fromJson(item));
                  }
                } catch (e) {
                  debugPrint('❌ Error parsing quote item: $e');
                  debugPrint('❌ Item data: $item');
                }
              }

              if (isRefresh) {
                quotes.value = parsedQuotes;
              } else {
                quotes.addAll(parsedQuotes);
              }

              debugPrint('🎉 Successfully loaded ${parsedQuotes.length} quotes');

              // Handle pagination
              if (data.containsKey('pagination') && data['pagination'] is Map<String, dynamic>) {
                final Map<String, dynamic> pagination = data['pagination'];
                currentPage.value = (pagination['page'] as int?) ?? 1;
                totalPages.value = (pagination['totalPages'] as int?) ?? 1;
                hasMore.value = currentPage.value < totalPages.value;
              }
            } else {
              debugPrint('📭 No quotes found in data array');
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