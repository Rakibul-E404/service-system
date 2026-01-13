
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/network/network_caller.dart';
import 'package:manx_mate/core/network/network_response.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';
import 'package:manx_mate/core/utils/token_service/token_storage_service.dart';

class ReviewController extends GetxController {
  RxDouble rating = 3.0.obs;
  RxBool isSubmitting = false.obs;

  final TextEditingController descriptionController = TextEditingController();

  // Method to update the rating
  void updateRating(double newRating) {
    rating.value = newRating;
  }

  // Method to submit review
  Future<bool> submitReview(String bookingId) async {
    if (descriptionController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please write a review description',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    isSubmitting.value = true;

    try {
      final NetworkCaller networkCaller = NetworkCaller();
      final SharedPrefService sharedPrefService = SharedPrefService();

      final String? accessToken = await sharedPrefService.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        Get.snackbar(
          'Error',
          'Please login to submit review',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isSubmitting.value = false;
        return false;
      }

      final String url = '${AppUrl.baseUrl}/review/$bookingId';

      final Map<String, dynamic> requestBody = {
        'description': descriptionController.text.trim(),
        'rating': rating.value.toInt(),
      };

      debugPrint('📤 Submitting review to: $url');
      debugPrint('📦 Request body: $requestBody');

      final NetworkResponse response = await networkCaller.postRequest(
        url,
        body: requestBody,
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      debugPrint('📥 Response: ${response.jsonResponse}');

      if (response.isSuccess) {
        Get.snackbar(
          'Success',
          'Review submitted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Reset form
        descriptionController.clear();
        rating.value = 3.0;

        isSubmitting.value = false;
        return true;
      } else {
        final errorMessage = response.jsonResponse?['message'] ?? 'Failed to submit review';
        Get.snackbar(
          'Error',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isSubmitting.value = false;
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error submitting review: $e');
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      isSubmitting.value = false;
      return false;
    }
  }

  @override
  void onClose() {
    descriptionController.dispose();
    super.onClose();
  }
}