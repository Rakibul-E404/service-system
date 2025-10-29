/**
import 'package:get/get.dart';
import '../model/review.dart';

class MyReviewController extends GetxController {
  RxList<Review> reviews = <Review>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadReviews();
  }

  void loadReviews() {
    reviews.value = <Review>[
      Review(
          id: '1',
          userName: 'Lahan',
          userAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop',
          rating: 5,
          date: 'May 2023',
          comment: 'Best tutor I had so far. Super nice communicating attitude, listens to your query and has a lot is patience. She has experience with all age groups and provides best. Can check my daughter, notes too. .',
      ),
      Review(
        id: '2',
        userName: 'Afkana Afaq',
        userAvatar: 'https://images.unsplash.com/photo-1494790108755-2616b772390e?w=100&h=100&fit=crop',
        rating: 5,
        date: 'Apr 2023',
        comment: 'Excellent tutor with an amazing communicating attitude! She listens to your query and has a lot is patience. She has experience with all age groups and provides best results.',
      ),
      Review(
        id: '3',
        userName: 'Sarah Johnson',
        userAvatar: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop',
        rating: 4,
        date: 'Mar 2023',
        comment: 'Very professional and knowledgeable. My daughter has improved significantly in her studies. Highly recommend for anyone looking for quality tutoring.',
      ),
      Review(
        id: '4',
        userName: 'Michael Chen',
        userAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&h=100&fit=crop',
        rating: 5,
        date: 'Feb 2023',
        comment: 'Amazing experience! The tutor is very patient and explains concepts clearly. My son\'s grades have improved dramatically since starting sessions.',
      ),
      Review(
        id: '5',
        userName: 'Emma Wilson',
        userAvatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100&h=100&fit=crop',
        rating: 4,
        date: 'Jan 2023',
        comment: 'Great tutor with excellent communication skills. Very punctual and well-prepared for each session. Would definitely recommend to others.',
      ),
      Review(
        id: '6',
        userName: 'David Rodriguez',
        userAvatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop',
        rating: 5,
        date: 'Dec 2022',
        comment: 'Outstanding service! The tutor helped my daughter with math and science. She\'s now more confident in her studies and enjoys learning.',
      ),
      Review(
        id: '7',
        userName: 'Lisa Anderson',
        userAvatar: 'https://images.unsplash.com/photo-1534751516642-a1af1ef26a56?w=100&h=100&fit=crop',
        rating: 4,
        date: 'Nov 2022',
        comment: 'Very satisfied with the tutoring sessions. The tutor is knowledgeable and patient. My son has shown great improvement in his academic performance.',
      ),
      Review(
        id: '8',
        userName: 'James Thompson',
        userAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop',
        rating: 5,
        date: 'Oct 2022',
        comment: 'Exceptional tutor! Very professional and caring. My daughter looks forward to every session. Highly recommend for any subject.',
      ),
    ];
  }

  double getAverageRating() {
    if (reviews.isEmpty) return 0.0;
    double total = reviews.fold(0.0, (double sum, Review review) => sum + review.rating);
    return total / reviews.length;
  }
}
*/








///
///
///
/// todo:: adding the api
///
///
///



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

  final NetworkCaller _networkCaller = NetworkCaller();
  final SharedPrefService _sharedPrefService = SharedPrefService();

  // Fetch reviews from API
  Future<void> loadReviews(String providerServiceId) async {
    try {
      isLoading(true);
      errorMessage('');

      final url = AppUrl.getReviewsUrl(providerServiceId);

      // Get the access token
      final String? token = await _sharedPrefService.getAccessToken();

      Map<String, String>? headers;
      if (token != null && token.isNotEmpty) {
        headers = {'Authorization': 'Bearer $token'};
      }

      final NetworkResponse response = await _networkCaller.getRequest(
        url,
        headers: headers,
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final data = response.jsonResponse!['data'];

        if (data != null && data['data'] != null) {
          final List<dynamic> reviewData = data['data'];
          reviews.value = reviewData.map((json) => Review.fromJson(json)).toList();

          if (reviews.isEmpty) {
            errorMessage.value = 'No reviews available yet';
          }
        } else {
          errorMessage.value = 'No reviews found';
        }
      } else if (response.statusCode == 401) {
        errorMessage.value = 'Please login to view reviews';
      } else {
        errorMessage.value = response.errorMessage ?? 'Error fetching reviews';
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
    } finally {
      isLoading(false);
    }
  }

  double getAverageRating() {
    if (reviews.isEmpty) return 0.0;
    double total = reviews.fold(0.0, (double sum, Review review) => sum + review.rating);
    return total / reviews.length;
  }
}

class Review {
  final String id;
  final String userName;
  final String userAvatar;
  final double rating;
  final String date;
  final String comment;

  Review({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.date,
    required this.comment,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    // Format the date from ISO string to readable format
    String formattedDate = 'Unknown date';
    try {
      final DateTime dateTime = DateTime.parse(json['createdAt']);
      formattedDate = DateFormat('MMM dd, yyyy').format(dateTime);
    } catch (e) {
      formattedDate = json['createdAt'] ?? 'Unknown date';
    }

    return Review(
      id: json['_id'] ?? '',
      // Since author is an ID, we'll show "User" for now
      // You'll need to fetch user details separately or include them in the API response
      userName: json['authorName'] ?? 'User ${json['author']?.substring(0, 8) ?? 'Unknown'}',
      userAvatar: json['authorAvatar'] ?? '', // Will be empty, fallback to icon
      rating: (json['rating'] ?? 0).toDouble(),
      date: formattedDate,
      comment: json['description'] ?? 'No comment',
    );
  }
}