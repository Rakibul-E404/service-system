
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

import '../../../core/utils/api/app_url.dart';
import '../../../core/utils/token_service/token_storage_service.dart';

class CreateAdController extends GetxController {
  final isLoading = false.obs;
  final Rx<File?> selectedImage = Rx<File?>(null);

  /// Pick Image (Camera or Gallery)
  Future<void> pickAdImage({required ImageSource source}) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source, imageQuality: 80);
    if (image != null) {
      selectedImage.value = File(image.path);
      debugPrint('📸 Image Selected: ${image.path}');
    }
  }

  /// Create / Update Advertisement
  Future<void> createAdvertisement() async {
    if (selectedImage.value == null) {
      debugPrint('⚠️ Validation Failed: No image selected');
      Get.snackbar(
        'Required',
        'Please select an image',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      final token = await _getAuthToken();
      debugPrint('🔑 Auth Token: ${token ?? "No Token Found"}');

      var request = http.MultipartRequest('POST', Uri.parse(AppUrl.createAddProvider));
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      String filePath = selectedImage.value!.path;
      String extension = filePath.split('.').last.toLowerCase();
      debugPrint('📤 Preparing Upload: $filePath with extension: $extension');

      request.files.add(await http.MultipartFile.fromPath(
        'content',
        filePath,
        contentType: MediaType('image', extension),
      ));

      debugPrint('🚀 Sending Request to: ${AppUrl.createAddProvider}');
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // Print raw response for debugging
      debugPrint('📡 Status Code: ${response.statusCode}');
      debugPrint('📄 Response Body: ${response.body}');

      var jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Ad Creation Success');
        Get.snackbar(
          'Success',
          'Ad published successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        _resetForm();
      } else {
        debugPrint('❌ Ad Creation Failed: ${jsonResponse['message']}');
        Get.snackbar('Error', jsonResponse['message'] ?? 'Failed to create Ad');
      }
    } catch (e) {
      debugPrint('🧨 Ad Creation Error: $e');
      Get.snackbar('Error', 'Server connection failed');
    } finally {
      isLoading.value = false;
    }
  }

  void _resetForm() {
    debugPrint('🧹 Resetting Form State');
    selectedImage.value = null;
  }

  Future<String?> _getAuthToken() async {
    return await Get.find<SharedPrefService>().getAccessToken();
  }
}