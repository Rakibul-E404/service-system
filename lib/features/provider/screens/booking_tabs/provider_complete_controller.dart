import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProviderCompleteController extends GetxController {
  var isLoading = false.obs;
  var bookings = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;

  final String baseUrl = 'https://d7001.sobhoy.com/api/v1';

  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('accessToken');
    } catch (e) {
      print('❌ Error retrieving token: $e');
      return null;
    }
  }

  Future<void> fetchBookings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      bookings.clear();

      final token = await _getAuthToken();
      final url = Uri.parse('$baseUrl/booking/provider?status=completed');
      print('🌐 Fetching completed bookings from: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📊 Full API Response: ${json.encode(data)}');

        if (data['success'] == true) {
          final responseData = data['data'];
          if (responseData is Map<String, dynamic>) {
            final List<dynamic> list = responseData['data'] ?? [];
            bookings.value = list.cast<Map<String, dynamic>>();
            print('✅ Loaded ${bookings.length} completed bookings');
          } else if (responseData is List) {
            bookings.value = responseData.cast<Map<String, dynamic>>();
            print('✅ Loaded ${bookings.length} completed bookings (direct list)');
          } else {
            errorMessage.value = 'Unexpected data format';
          }
        } else {
          errorMessage.value = data['message'] ?? 'Failed to fetch data';
        }
      } else {
        errorMessage.value = 'Server Error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
      print('❌ Exception in fetchBookings: $e');
    } finally {
      isLoading.value = false;
    }
  }
}