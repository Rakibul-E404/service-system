
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../core/utils/api/app_url.dart';
import '../../../core/utils/token_service/token_storage_service.dart';
import '../model/add_response_model.dart';
import 'dart:developer';

class AdsListController extends GetxController {
  var isLoading = false.obs;
  var adsList = <AdData>[].obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSelfAds();
  }

  Future<void> fetchSelfAds() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = await _getAuthToken();
      print('--- ADS API DEBUG ---');
      print('Token: $token');
      print('URL: ${AppUrl.getAddsDetails}');

      final response = await http.get(
        Uri.parse(AppUrl.getAddsDetails),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('Status Code: ${response.statusCode}');
      // log() is better than print() for long JSON strings
      log('Raw Response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final addResponse = AddResponseModel.fromJson(jsonResponse);

        if (addResponse.success && addResponse.data != null) {
          adsList.assignAll([addResponse.data!]);

          // Debugging the Image URL formation
          final content = addResponse.data!.content;
          final fullUrl = content.startsWith('http')
              ? content
              : '${AppUrl.imageBaseUrl}$content';

          print('Ad Found! Content Path: $content');
          print('Final Calculated Image URL: $fullUrl');
        } else {
          print('Success was false or data was null in JSON');
          adsList.clear();
        }
      } else {
        print('Server Error: ${response.body}');
        errorMessage.value = 'Server Error: ${response.statusCode}';
      }
    } catch (e) {
      print('CATCH ERROR: $e');
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
      print('--- DEBUG END ---');
    }
  }

  Future<String?> _getAuthToken() async {
    return await SharedPrefService().getAccessToken();
  }
}