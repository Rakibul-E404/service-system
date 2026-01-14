
import 'package:flutter/cupertino.dart';

import '../../../core/utils/api/app_url.dart';


class ServiceModel {
  final String id;
  final String authorId;
  final Map<String, dynamic>? author; // Optional author object
  final Map<String, dynamic> subCategory;
  final Map<String, dynamic> profileDetails;
  final double averageRating;
  final int totalReviews;
  final bool isSponsored;
  final bool isSubscribed;
  final List<String> accessibleBySubscription;

  ServiceModel({
    required this.id,
    required this.authorId,
    this.author,
    required this.subCategory,
    required this.profileDetails,
    required this.averageRating,
    required this.totalReviews,
    required this.isSponsored,
    required this.isSubscribed,
    required this.accessibleBySubscription,
  });

  // Getter for service name (from profileDetails.description or subCategory.name)
  String get name {
    if (profileDetails['description'] != null &&
        profileDetails['description'].toString().isNotEmpty) {
      return profileDetails['description'].toString();
    }
    return subCategory['name']?.toString() ?? 'Unnamed Service';
  }

  // Getter for service description
  String get description {
    return profileDetails['description']?.toString() ??
        subCategory['description']?.toString() ??
        'No description available';
  }

  // Getter for location
  String get location {
    return profileDetails['location']?.toString() ?? 'Location not specified';
  }

  // Getter for full image URL
  String get fullImageUrl {
    final imagePath = profileDetails['image']?.toString();
    if (imagePath != null && imagePath.isNotEmpty) {
      return '${AppUrl.imageBaseUrl}/$imagePath';
    }
    return 'https://via.placeholder.com/150';
  }

  // Getter for region
  String get region {
    return profileDetails['region']?.toString() ?? '';
  }

  // Getter for phone
  String get phone {
    return profileDetails['phone']?.toString() ?? '';
  }

  // Getter for rating
  double get rating {
    return averageRating;
  }

  // Getter for profile details ID
  String get profileId {
    return profileDetails['_id']?.toString() ?? '';
  }

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    try {
      return ServiceModel(
        id: json['_id']?.toString() ?? '',
        authorId: json['author']?.toString() ?? '',
        author: json['author'] is Map<String, dynamic> ? json['author'] : null,
        subCategory: json['subCategory'] is Map<String, dynamic>
            ? json['subCategory']
            : {},
        profileDetails: json['profileDetails'] is Map<String, dynamic>
            ? json['profileDetails']
            : {},
        averageRating: json['averageRating'] is double
            ? json['averageRating']
            : (json['averageRating'] is int
            ? (json['averageRating'] as int).toDouble()
            : 0.0),
        totalReviews: json['totalReviews'] is int
            ? json['totalReviews']
            : 0,
        isSponsored: json['isSponsored'] is bool
            ? json['isSponsored']
            : false,
        isSubscribed: json['isSubscribed'] is bool
            ? json['isSubscribed']
            : false,
        accessibleBySubscription: json['accessibleBySubscription'] is List
            ? (json['accessibleBySubscription'] as List)
            .map((item) => item.toString())
            .toList()
            : [],
      );
    } catch (e) {
      debugPrint('❌ Error parsing ServiceModel: $e');
      debugPrint('📦 JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'author': authorId,
      'subCategory': subCategory,
      'profileDetails': profileDetails,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'isSponsored': isSponsored,
      'isSubscribed': isSubscribed,
      'accessibleBySubscription': accessibleBySubscription,
    };
  }

  @override
  String toString() {
    return '''
ServiceModel {
  id: $id,
  name: $name,
  authorId: $authorId,
  location: $location,
  rating: $rating,
  image: ${fullImageUrl.length > 50 ? '${fullImageUrl.substring(0, 50)}...' : fullImageUrl}
}
''';
  }
}









