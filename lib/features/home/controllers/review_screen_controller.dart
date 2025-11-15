/**
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/network/network_caller.dart';

class ReviewController extends GetxController {
  // Rating variables
  var qualityRating = 0.0.obs;
  var timelinessRating = 0.0.obs;
  var professionalismRating = 0.0.obs;
  var valueForMoneyRating = 0.0.obs;
  var flexibilityRating = 0.0.obs;

  // Loading state
  var isLoading = false.obs;

  // Network Caller
  final NetworkCaller _networkCaller = NetworkCaller();

  // Rating update methods
  void updateQualityRating(double rating) {
    qualityRating.value = rating;
  }

  void updateResponseTimeRating(double rating) {
    timelinessRating.value = rating;
  }

  void updateProfessionalismRating(double rating) {
    professionalismRating.value = rating;
  }

  void updateValurForMoney(double rating) {
    valueForMoneyRating.value = rating;
  }

  void updateFlexibilityRating(double rating) {
    flexibilityRating.value = rating;
  }

  // Submit review method using NetworkCaller
  Future<bool> submitReview({
    required String serviceId,
    required String description,
    required double rating,
  }) async {
    try {
      isLoading(true);

      print('🚀 Submitting review for service: $serviceId');

      // Prepare the request body
      final Map<String, dynamic> requestBody = {
        "description": description,
        "rating": rating.toInt(),
      };

      print('📦 Request Body: $requestBody');

      // Get your auth token (replace with your actual token retrieval method)
      final String? authToken = await _getAuthToken();

      // Prepare headers with authentication if available
      Map<String, String> headers = {};
      if (authToken != null && authToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $authToken';
      }

      // Make API call using NetworkCaller
      final response = await _networkCaller.postRequest(
        'https://d7001.sobhoy.com/api/v1/review/$serviceId',
        body: requestBody,
        headers: headers,
      );

      isLoading(false);

      if (response.isSuccess) {
        print('✅ Review submitted successfully');
        Get.snackbar(
          'Success',
          'Review submitted successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else {
        print('❌ API Error: ${response.statusCode} - ${response.errorMessage}');
        Get.snackbar(
          'Error',
          response.errorMessage ?? 'Failed to submit review. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      isLoading(false);
      print('❌ Exception during review submission: $e');
      Get.snackbar(
        'Error',
        'Failed to submit review. Please check your connection.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  // Helper method to get auth token (replace with your actual implementation)
  Future<String?> _getAuthToken() async {
    // Example: Get token from storage
    // return await StorageService().getToken();
    return null; // Return null if no token available
  }
}*/










///
///
///
///
///
///
///
///
///
///
///
///
///






// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:manx_mate/core/network/network_caller.dart';
// import '../../../core/utils/token_service/token_storage_service.dart';
//
// class ReviewController extends GetxController {
//   // Rating variables
//   var qualityRating = 0.0.obs;
//   var timelinessRating = 0.0.obs;
//   var professionalismRating = 0.0.obs;
//   var valueForMoneyRating = 0.0.obs;
//   var flexibilityRating = 0.0.obs;
//
//   // Loading state
//   var isLoading = false.obs;
//
//   // Network Caller
//   final NetworkCaller _networkCaller = NetworkCaller();
//
//   // SharedPreferences Service
//   final SharedPrefService _sharedPrefService = SharedPrefService();
//
//   // Rating update methods
//   void updateQualityRating(double rating) {
//     qualityRating.value = rating;
//   }
//
//   void updateResponseTimeRating(double rating) {
//     timelinessRating.value = rating;
//   }
//
//   void updateProfessionalismRating(double rating) {
//     professionalismRating.value = rating;
//   }
//
//   void updateValurForMoney(double rating) {
//     valueForMoneyRating.value = rating;
//   }
//
//   void updateFlexibilityRating(double rating) {
//     flexibilityRating.value = rating;
//   }
//
//   // Submit review method using NetworkCaller
//   // NOTE: The parameter is called serviceId but it should actually be the BOOKING ID
//   Future<bool> submitReview({
//     required String bookingId, // Changed from serviceId to bookingId for clarity
//     required String description,
//     required double rating,
//   }) async {
//     try {
//       isLoading(true);
//
//       print('🚀 Submitting review for booking: $bookingId');
//
//       // Prepare the request body
//       final Map<String, dynamic> requestBody = {
//         "description": description,
//         "rating": rating.toInt(),
//       };
//
//       print('📦 Request Body: $requestBody');
//
//       // Get your auth token
//       final String? authToken = await _getAuthToken();
//
//       // Prepare headers with authentication if available
//       Map<String, String> headers = {};
//       if (authToken != null && authToken.isNotEmpty) {
//         headers['Authorization'] = 'Bearer $authToken';
//         print('🔐 Authorization header added');
//       } else {
//         print('⚠️ No auth token available');
//       }
//
//       // Make API call using NetworkCaller
//       // IMPORTANT: Use BOOKING ID in the URL, not service ID
//       final response = await _networkCaller.postRequest(
//         'https://d7001.sobhoy.com/api/v1/review/$serviceId',
//         body: requestBody,
//         headers: headers,
//       );
//
//       isLoading(false);
//
//       if (response.isSuccess) {
//         print('✅ Review submitted successfully');
//         print('📄 Response: ${response.jsonResponse}');
//
//         Get.snackbar(
//           'Success',
//           'Thank you for your review!',
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//           snackPosition: SnackPosition.BOTTOM,
//           margin: const EdgeInsets.all(16),
//           duration: const Duration(seconds: 2),
//         );
//
//         // Navigate back after successful submission
//         Future.delayed(const Duration(milliseconds: 500), () {
//           Get.back();
//         });
//
//         return true;
//       } else {
//         print('❌ API Error: ${response.statusCode} - ${response.errorMessage}');
//
//         // Show user-friendly error message
//         String errorMessage = response.errorMessage ?? 'Failed to submit review. Please try again.';
//
//         // Handle specific error cases
//         if (response.statusCode == 400) {
//           if (errorMessage.contains('you can not review before service is accepted')) {
//             errorMessage = 'This booking is not ready for review yet. Please wait until the service is completed.';
//           } else if (errorMessage.contains('already reviewed')) {
//             errorMessage = 'You have already submitted a review for this booking.';
//           }
//         } else if (response.statusCode == 401) {
//           errorMessage = 'Please login to submit a review.';
//         } else if (response.statusCode == 404) {
//           errorMessage = 'Booking not found. Please try again.';
//         }
//
//         Get.snackbar(
//           'Error',
//           errorMessage,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//           snackPosition: SnackPosition.BOTTOM,
//           margin: const EdgeInsets.all(16),
//           duration: const Duration(seconds: 3),
//         );
//         return false;
//       }
//     } catch (e) {
//       isLoading(false);
//       print('❌ Exception during review submission: $e');
//       Get.snackbar(
//         'Error',
//         'Failed to submit review. Please check your connection.',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         snackPosition: SnackPosition.BOTTOM,
//         margin: const EdgeInsets.all(16),
//       );
//       return false;
//     }
//   }
//
//   // Helper method to get auth token from SharedPreferences
//   Future<String?> _getAuthToken() async {
//     try {
//       final String? token = await _sharedPrefService.getAccessToken();
//       if (token != null && token.isNotEmpty) {
//         print('✅ Auth token retrieved: ${token.substring(0, 20)}...');
//         return token;
//       } else {
//         print('⚠️ No auth token found in SharedPreferences');
//         return null;
//       }
//     } catch (e) {
//       print('❌ Error getting auth token: $e');
//       return null;
//     }
//   }
//
//   // Reset all ratings
//   void resetRatings() {
//     qualityRating.value = 0.0;
//     timelinessRating.value = 0.0;
//     professionalismRating.value = 0.0;
//     valueForMoneyRating.value = 0.0;
//     flexibilityRating.value = 0.0;
//   }
//
//   @override
//   void onClose() {
//     resetRatings();
//     super.onClose();
//   }
// }



import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/network/network_caller.dart';
import '../../../core/utils/token_service/token_storage_service.dart';

class ReviewController extends GetxController {
  // Rating variables
  var qualityRating = 0.0.obs;
  var timelinessRating = 0.0.obs;
  var professionalismRating = 0.0.obs;
  var valueForMoneyRating = 0.0.obs;
  var flexibilityRating = 0.0.obs;

  // Loading state
  var isLoading = false.obs;

  // Network Caller
  final NetworkCaller _networkCaller = NetworkCaller();

  // SharedPreferences Service
  final SharedPrefService _sharedPrefService = SharedPrefService();

  // Rating update methods
  void updateQualityRating(double rating) {
    qualityRating.value = rating;
  }

  void updateResponseTimeRating(double rating) {
    timelinessRating.value = rating;
  }

  void updateProfessionalismRating(double rating) {
    professionalismRating.value = rating;
  }

  void updateValurForMoney(double rating) {
    valueForMoneyRating.value = rating;
  }

  void updateFlexibilityRating(double rating) {
    flexibilityRating.value = rating;
  }

  // Submit review method using NetworkCaller
  // NOTE: The parameter is called serviceId but it should actually be the BOOKING ID
  Future<bool> submitReview({
    required String bookingId, // Changed from serviceId to bookingId for clarity
    required String description,
    required double rating,
  }) async {
    try {
      isLoading(true);

      print('🚀 Submitting review for booking: $bookingId');

      // Prepare the request body
      final Map<String, dynamic> requestBody = {
        "description": description,
        "rating": rating.toInt(),
      };

      print('📦 Request Body: $requestBody');

      // Get your auth token
      final String? authToken = await _getAuthToken();

      // Prepare headers with authentication if available
      Map<String, String> headers = {};
      if (authToken != null && authToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $authToken';
        print('🔐 Authorization header added');
      } else {
        print('⚠️ No auth token available');
      }

      // Make API call using NetworkCaller
      // IMPORTANT: Use BOOKING ID in the URL, not service ID
      final response = await _networkCaller.postRequest(
        'https://d7001.sobhoy.com/api/v1/review/$bookingId',
        body: requestBody,
        headers: headers,
      );

      isLoading(false);

      if (response.isSuccess) {
        print('✅ Review submitted successfully');
        print('📄 Response: ${response.jsonResponse}');

        Get.snackbar(
          'Success',
          'Thank you for your review!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        );

        // Navigate back after successful submission
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.back();
        });

        return true;
      } else {
        print('❌ API Error: ${response.statusCode} - ${response.errorMessage}');

        // Show user-friendly error message
        String errorMessage = response.errorMessage ?? 'Failed to submit review. Please try again.';

        // Handle specific error cases
        if (response.statusCode == 400) {
          if (errorMessage.contains('you can not review before service is accepted')) {
            errorMessage = 'This booking is not ready for review yet. Please wait until the service is completed.';
          } else if (errorMessage.contains('already reviewed')) {
            errorMessage = 'You have already submitted a review for this booking.';
          }
        } else if (response.statusCode == 401) {
          errorMessage = 'Please login to submit a review.';
        } else if (response.statusCode == 404) {
          errorMessage = 'Booking not found. Please try again.';
        }

        Get.snackbar(
          'Error',
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
        return false;
      }
    } catch (e) {
      isLoading(false);
      print('❌ Exception during review submission: $e');
      Get.snackbar(
        'Error',
        'Failed to submit review. Please check your connection.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
  }

  // Helper method to get auth token from SharedPreferences
  Future<String?> _getAuthToken() async {
    try {
      final String? token = await _sharedPrefService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        print('✅ Auth token retrieved: ${token.substring(0, 20)}...');
        return token;
      } else {
        print('⚠️ No auth token found in SharedPreferences');
        return null;
      }
    } catch (e) {
      print('❌ Error getting auth token: $e');
      return null;
    }
  }

  // Reset all ratings
  void resetRatings() {
    qualityRating.value = 0.0;
    timelinessRating.value = 0.0;
    professionalismRating.value = 0.0;
    valueForMoneyRating.value = 0.0;
    flexibilityRating.value = 0.0;
  }

  @override
  void onClose() {
    resetRatings();
    super.onClose();
  }
}