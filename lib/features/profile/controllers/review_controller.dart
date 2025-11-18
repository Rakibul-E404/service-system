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
