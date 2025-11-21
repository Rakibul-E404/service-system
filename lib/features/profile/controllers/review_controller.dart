/**
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/network/network_response.dart';
import '../../../core/utils/api/app_url.dart';
import '../../../core/utils/token_service/token_storage_service.dart';

class MyReviewController extends GetxController {
  RxList<Review> reviews = <Review>[].obs;
  RxBool isLoading = true.obs;
  RxString errorMessage = ''.obs;
  RxList<Service> services = <Service>[].obs;

  final NetworkCaller _networkCaller = NetworkCaller();
  final SharedPrefService _sharedPrefService = SharedPrefService();

  @override
  void onInit() {
    super.onInit();
    loadAllServicesAndReviews();
  }

  // Fetch all services and then fetch reviews for each service
  Future<void> loadAllServicesAndReviews() async {
    try {
      isLoading(true);
      errorMessage('');

      // Step 1: Fetch all services
      final servicesUrl = AppUrl.baseUrl + "/service/all";

      final String? token = await _sharedPrefService.getAccessToken();
      Map<String, String>? headers;
      if (token != null && token.isNotEmpty) {
        headers = {'Authorization': 'Bearer $token'};
      }

      final NetworkResponse servicesResponse = await _networkCaller.getRequest(
        servicesUrl,
        headers: headers,
      );

      if (servicesResponse.isSuccess && servicesResponse.jsonResponse != null) {
        final data = servicesResponse.jsonResponse!['data'];

        if (data != null && data['data'] != null) {
          final List<dynamic> servicesData = data['data'];
          services.value = servicesData.map((json) => Service.fromJson(json)).toList();

          // Step 2: Fetch reviews for each service
          List<Review> allReviews = [];
          for (var service in services) {
            final reviewsList = await fetchReviewsForService(service.id, headers);
            allReviews.addAll(reviewsList);
          }

          reviews.value = allReviews;

          if (reviews.isEmpty) {
            errorMessage.value = 'No reviews available';
          }
        } else {
          errorMessage.value = 'No services found';
        }
      } else if (servicesResponse.statusCode == 401) {
        errorMessage.value = 'Please login to view reviews';
      } else {
        errorMessage.value = servicesResponse.errorMessage ?? 'Failed to load services';
      }
    } catch (e) {
      errorMessage.value = 'Something went wrong. Please try again.';
      print('Error loading services and reviews: $e');
    } finally {
      isLoading(false);
    }
  }

  // Fetch reviews for a specific service
  Future<List<Review>> fetchReviewsForService(
      String providerServiceId,
      Map<String, String>? headers,
      ) async {
    try {
      final url = AppUrl.getReviewsUrl(providerServiceId);

      final NetworkResponse response = await _networkCaller.getRequest(
        url,
        headers: headers,
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final data = response.jsonResponse!['data'];

        if (data != null && data['data'] != null) {
          final List<dynamic> reviewData = data['data'];
          return reviewData.map((json) => Review.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching reviews for service $providerServiceId: $e');
      return [];
    }
  }

  // Get average rating
  double getAverageRating() {
    if (reviews.isEmpty) return 0.0;
    double total = reviews.fold(0.0, (double sum, Review review) => sum + review.rating);
    return total / reviews.length;
  }

  // Get reviews grouped by service
  Map<String, List<Review>> getReviewsByService() {
    Map<String, List<Review>> grouped = {};
    for (var review in reviews) {
      if (!grouped.containsKey(review.providerServiceId)) {
        grouped[review.providerServiceId] = [];
      }
      grouped[review.providerServiceId]!.add(review);
    }
    return grouped;
  }

  // Get service name by ID
  String getServiceName(String serviceId) {
    try {
      return services.firstWhere((s) => s.id == serviceId).name;
    } catch (e) {
      return 'Unknown Service';
    }
  }
}

// Service Model
class Service {
  final String id;
  final String name;
  final String description;
  final String image;
  final String subCategory;
  final String location;
  final double rating;
  final int ratingCount;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.subCategory,
    required this.location,
    required this.rating,
    required this.ratingCount,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      subCategory: json['subCategory'] ?? '',
      location: json['location'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
    );
  }
}

// Review Model
class Review {
  final String id;
  final String userName;
  final String userAvatar;
  final double rating;
  final String date;
  final String comment;
  final String providerServiceId;
  final String authorId;

  Review({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.date,
    required this.comment,
    required this.providerServiceId,
    required this.authorId,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    String formattedDate = 'Unknown date';
    try {
      final DateTime dateTime = DateTime.parse(json['createdAt']);
      formattedDate = DateFormat('MMM dd, yyyy').format(dateTime);
    } catch (e) {
      formattedDate = json['createdAt'] ?? 'Unknown date';
    }

    return Review(
      id: json['_id'] ?? '',
      userName: json['authorName'] ?? 'User ${json['author']?.substring(0, 8) ?? 'Unknown'}',
      userAvatar: json['authorAvatar'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      date: formattedDate,
      comment: json['description'] ?? 'No comment',
      providerServiceId: json['providerService'] ?? '',
      authorId: json['author'] ?? '',
    );
  }
}
*/





///
///
///
/// todo::: updating the review functionality
///
///
///





import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/network/network_response.dart';
import '../../../core/utils/token_service/token_storage_service.dart';

// ============================================================================
// REVIEW CONTROLLER (For submitting and updating reviews)
// ============================================================================

class ReviewController extends GetxController {
  // Rating observables
  final qualityRating = 0.0.obs;
  final isLoading = false.obs;
  final isFetchingExistingReview = false.obs;

  // Store existing review data
  final existingReviewId = ''.obs;
  final existingReviewDescription = ''.obs;
  final existingReviewRating = 0.0.obs;
  final hasExistingReview = false.obs;

  final NetworkCaller _networkCaller = NetworkCaller();

  void updateQualityRating(double rating) {
    qualityRating.value = rating;
  }

  Future<String?> _getAuthToken() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      return token;
    } catch (e) {
      debugPrint('❌ Error getting auth token: $e');
      return null;
    }
  }

  /// Fetch existing review for a service
  Future<void> fetchExistingReview(String serviceId) async {
    if (serviceId.isEmpty) {
      debugPrint('❌ Cannot fetch review: serviceId is empty');
      return;
    }

    try {
      isFetchingExistingReview.value = true;
      hasExistingReview.value = false;
      existingReviewId.value = '';
      existingReviewDescription.value = '';
      existingReviewRating.value = 0.0;

      debugPrint('🔍 Fetching existing review for service: $serviceId');

      final token = await _getAuthToken();
      if (token == null || token.isEmpty) {
        debugPrint('⚠️ No auth token, skipping review fetch');
        return;
      }

      final url = '${AppUrl.baseUrl}/review/all/$serviceId';
      debugPrint('🌐 GET request to: $url');

      final Map<String, String> headers = {
        'Authorization': 'Bearer $token',
      };

      final NetworkResponse response = await _networkCaller.getRequest(
        url,
        headers: headers,
      );

      debugPrint('📡 Response status: ${response.statusCode}');
      debugPrint('📦 Response: ${response.jsonResponse}');

      if (response.isSuccess && response.jsonResponse != null) {
        final jsonData = response.jsonResponse!;

        if (jsonData['success'] == true) {
          final List<dynamic> reviews = jsonData['data']?['data'] ?? [];

          if (reviews.isNotEmpty) {
            // Get the user's own review (first one in the list)
            final review = reviews[0];

            existingReviewId.value = review['_id']?.toString() ?? '';
            existingReviewDescription.value = review['description']?.toString() ?? '';
            existingReviewRating.value = (review['rating'] as num?)?.toDouble() ?? 0.0;
            hasExistingReview.value = true;

            // Update the current rating
            qualityRating.value = existingReviewRating.value;

            debugPrint('✅ Found existing review:');
            debugPrint('   - Review ID: ${existingReviewId.value}');
            debugPrint('   - Rating: ${existingReviewRating.value}');
            debugPrint('   - Description: ${existingReviewDescription.value}');
          } else {
            debugPrint('📭 No existing review found');
            hasExistingReview.value = false;
          }
        }
      } else if (response.statusCode == 404) {
        debugPrint('📭 No reviews found (404)');
        hasExistingReview.value = false;
      } else {
        debugPrint('❌ Failed to fetch reviews: ${response.statusCode}');
        debugPrint('❌ Error: ${response.errorMessage}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching existing review: $e');
    } finally {
      isFetchingExistingReview.value = false;
    }
  }

  /// Submit a new review (POST)
  Future<void> submitReview({
    required String bookingId,
    required String description,
    required double rating,
  }) async {
    if (bookingId.isEmpty) {
      Get.snackbar(
        'Error',
        'Booking ID is required',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;
      debugPrint('📤 Submitting NEW review...');
      debugPrint('   - Booking ID: $bookingId');
      debugPrint('   - Rating: $rating');
      debugPrint('   - Description: $description');

      final token = await _getAuthToken();
      if (token == null || token.isEmpty) {
        Get.snackbar(
          'Error',
          'Authentication required. Please login again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final url = '${AppUrl.baseUrl}/review/$bookingId';
      debugPrint('🌐 POST request to: $url');

      final Map<String, dynamic> requestBody = {
        'description': description,
        'rating': rating,
      };
      debugPrint('📤 Request body: $requestBody');

      final Map<String, String> headers = {
        'Authorization': 'Bearer $token',
      };

      final NetworkResponse response = await _networkCaller.postRequest(
        url,
        body: requestBody,
        headers: headers,
      );

      debugPrint('📡 Response status: ${response.statusCode}');
      debugPrint('📦 Response: ${response.jsonResponse}');

      if (response.isSuccess && response.jsonResponse != null) {
        final jsonData = response.jsonResponse!;

        if (jsonData['success'] == true) {
          Get.back(); // Close the review screen
          Get.snackbar(
            'Success',
            'Review submitted successfully!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
            icon: const Icon(Icons.check_circle, color: Colors.white),
          );
        } else {
          Get.snackbar(
            'Error',
            jsonData['message'] ?? 'Failed to submit review',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          response.errorMessage ?? 'Failed to submit review',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint('❌ Error submitting review: $e');
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Update existing review (PUT)
  Future<void> updateReview({
    required String reviewId,
    required String description,
    required double rating,
  }) async {
    if (reviewId.isEmpty) {
      Get.snackbar(
        'Error',
        'Review ID is required',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;
      debugPrint('📤 Updating EXISTING review...');
      debugPrint('   - Review ID: $reviewId');
      debugPrint('   - Rating: $rating');
      debugPrint('   - Description: $description');

      final token = await _getAuthToken();
      if (token == null || token.isEmpty) {
        Get.snackbar(
          'Error',
          'Authentication required. Please login again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final url = '${AppUrl.baseUrl}/review/$reviewId';
      debugPrint('🌐 PUT request to: $url');

      final Map<String, dynamic> requestBody = {
        'description': description,
        'rating': rating,
      };
      debugPrint('📤 Request body: $requestBody');

      final Map<String, String> headers = {
        'Authorization': 'Bearer $token',
      };

      final NetworkResponse response = await _networkCaller.putRequest(
        url,
        body: requestBody,
        headers: headers,
      );

      debugPrint('📡 Response status: ${response.statusCode}');
      debugPrint('📦 Response: ${response.jsonResponse}');

      if (response.isSuccess && response.jsonResponse != null) {
        final jsonData = response.jsonResponse!;

        if (jsonData['success'] == true) {
          Get.back(); // Close the review screen
          Get.snackbar(
            'Success',
            'Review updated successfully!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
            icon: const Icon(Icons.check_circle, color: Colors.white),
          );
        } else {
          Get.snackbar(
            'Error',
            jsonData['message'] ?? 'Failed to update review',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          response.errorMessage ?? 'Failed to update review',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint('❌ Error updating review: $e');
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    qualityRating.value = 0.0;
    hasExistingReview.value = false;
    existingReviewId.value = '';
    existingReviewDescription.value = '';
    existingReviewRating.value = 0.0;
    super.onClose();
  }
}

// ============================================================================
// MY REVIEW CONTROLLER (For viewing all reviews)
// ============================================================================

class MyReviewController extends GetxController {
  final RxList<Review> reviews = <Review>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxList<Service> services = <Service>[].obs;

  final NetworkCaller _networkCaller = NetworkCaller();
  final SharedPrefService _sharedPrefService = SharedPrefService();

  @override
  void onInit() {
    super.onInit();
    loadAllServicesAndReviews();
  }

  // Fetch all services and then fetch reviews for each service
  Future<void> loadAllServicesAndReviews() async {
    try {
      isLoading(true);
      errorMessage('');

      // Step 1: Fetch all services
      final servicesUrl = "${AppUrl.baseUrl}/service/all";

      final String? token = await _sharedPrefService.getAccessToken();
      Map<String, String>? headers;
      if (token != null && token.isNotEmpty) {
        headers = {'Authorization': 'Bearer $token'};
      }

      final NetworkResponse servicesResponse = await _networkCaller.getRequest(
        servicesUrl,
        headers: headers,
      );

      if (servicesResponse.isSuccess && servicesResponse.jsonResponse != null) {
        final data = servicesResponse.jsonResponse!['data'];

        if (data != null && data['data'] != null) {
          final List<dynamic> servicesData = data['data'];
          services.value = servicesData.map((json) => Service.fromJson(json)).toList();

          // Step 2: Fetch reviews for each service
          List<Review> allReviews = [];
          for (var service in services) {
            final reviewsList = await fetchReviewsForService(service.id, headers);
            allReviews.addAll(reviewsList);
          }

          reviews.value = allReviews;

          if (reviews.isEmpty) {
            errorMessage.value = 'No reviews available';
          }
        } else {
          errorMessage.value = 'No services found';
        }
      } else if (servicesResponse.statusCode == 401) {
        errorMessage.value = 'Please login to view reviews';
      } else {
        errorMessage.value = servicesResponse.errorMessage ?? 'Failed to load services';
      }
    } catch (e) {
      errorMessage.value = 'Something went wrong. Please try again.';
      debugPrint('Error loading services and reviews: $e');
    } finally {
      isLoading(false);
    }
  }

  // Fetch reviews for a specific service
  Future<List<Review>> fetchReviewsForService(
      String providerServiceId,
      Map<String, String>? headers,
      ) async {
    try {
      final url = AppUrl.getReviewsUrl(providerServiceId);

      final NetworkResponse response = await _networkCaller.getRequest(
        url,
        headers: headers,
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final data = response.jsonResponse!['data'];

        if (data != null && data['data'] != null) {
          final List<dynamic> reviewData = data['data'];
          return reviewData.map((json) => Review.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching reviews for service $providerServiceId: $e');
      return [];
    }
  }

  // Get average rating
  double getAverageRating() {
    if (reviews.isEmpty) return 0.0;
    double total = reviews.fold(0.0, (double sum, Review review) => sum + review.rating);
    return total / reviews.length;
  }

  // Get reviews grouped by service
  Map<String, List<Review>> getReviewsByService() {
    Map<String, List<Review>> grouped = {};
    for (var review in reviews) {
      if (!grouped.containsKey(review.providerServiceId)) {
        grouped[review.providerServiceId] = [];
      }
      grouped[review.providerServiceId]!.add(review);
    }
    return grouped;
  }

  // Get service name by ID
  String getServiceName(String serviceId) {
    try {
      return services.firstWhere((s) => s.id == serviceId).name;
    } catch (e) {
      return 'Unknown Service';
    }
  }
}

// ============================================================================
// MODEL CLASSES
// ============================================================================

// Service Model
class Service {
  final String id;
  final String name;
  final String description;
  final String image;
  final String subCategory;
  final String location;
  final double rating;
  final int ratingCount;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.subCategory,
    required this.location,
    required this.rating,
    required this.ratingCount,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      subCategory: json['subCategory'] ?? '',
      location: json['location'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
    );
  }
}

// Review Model
class Review {
  final String id;
  final String userName;
  final String userAvatar;
  final double rating;
  final String date;
  final String comment;
  final String providerServiceId;
  final String authorId;

  Review({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.date,
    required this.comment,
    required this.providerServiceId,
    required this.authorId,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    String formattedDate = 'Unknown date';
    try {
      final DateTime dateTime = DateTime.parse(json['createdAt']);
      formattedDate = DateFormat('MMM dd, yyyy').format(dateTime);
    } catch (e) {
      formattedDate = json['createdAt'] ?? 'Unknown date';
    }

    return Review(
      id: json['_id'] ?? '',
      userName: json['authorName'] ?? 'User ${json['author']?.substring(0, 8) ?? 'Unknown'}',
      userAvatar: json['authorAvatar'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      date: formattedDate,
      comment: json['description'] ?? 'No comment',
      providerServiceId: json['providerService'] ?? '',
      authorId: json['author'] ?? '',
    );
  }
}