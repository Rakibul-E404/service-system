// import '../../../core/utils/api/app_url.dart';
//
// class FeaturedProviderModel {
//   final String id;
//   final String name;
//   final String phone;
//   final String image;
//   final String description;
//   final String region;
//   final String author;
//   final double? averageRating;
//   final int totalRatings;
//
//   FeaturedProviderModel({
//     required this.id,
//     required this.name,
//     required this.phone,
//     required this.image,
//     required this.description,
//     required this.region,
//     required this.author,
//     this.averageRating,
//     this.totalRatings = 0,
//   });
//
//   // Convert JSON to FeaturedProviderModel
//   factory FeaturedProviderModel.fromJson(Map<String, dynamic> json) {
//     return FeaturedProviderModel(
//       id: json['_id']?.toString() ?? '',
//       name: json['name']?.toString() ?? '',
//       phone: json['phone']?.toString() ?? '',
//       image: json['image']?.toString() ?? '',
//       description: json['description']?.toString() ?? '',
//       region: json['region']?.toString() ?? '',
//       author: json['author']?.toString() ?? '',
//       averageRating: json['averageRating'] != null
//           ? (json['averageRating'] is int
//           ? (json['averageRating'] as int).toDouble()
//           : (json['averageRating'] as num).toDouble())
//           : null,
//       totalRatings: json['totalRatings'] != null
//           ? (json['totalRatings'] is int
//           ? json['totalRatings'] as int
//           : (json['totalRatings'] as num).toInt())
//           : 0,
//     );
//   }
//
//   // Convert FeaturedProviderModel to JSON
//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'name': name,
//       'phone': phone,
//       'image': image,
//       'description': description,
//       'region': region,
//       'author': author,
//       'averageRating': averageRating,
//       'totalRatings': totalRatings,
//     };
//   }
//
//   // Get full image URL
//   String get fullImageUrl {
//     if (image.isEmpty) return '';
//     if (image.startsWith('http')) return image;
//
//     String cleanPath = image;
//     if (cleanPath.startsWith('/')) {
//       cleanPath = cleanPath.substring(1);
//     }
//     return '${AppUrl.imageBaseUrl}/$cleanPath';
//   }
//
//   // Get display rating (with fallback)
//   double get displayRating => averageRating ?? 0.0;
//
//   // Get formatted rating text
//   String get ratingText {
//     if (averageRating == null || totalRatings == 0) {
//       return 'No ratings';
//     }
//     return '${averageRating!.toStringAsFixed(1)} ($totalRatings)';
//   }
// }
//
// // Response wrapper for API
// class FeaturedProviderResponse {
//   final bool success;
//   final int code;
//   final String message;
//   final List<FeaturedProviderModel> providers;
//
//   FeaturedProviderResponse({
//     required this.success,
//     required this.code,
//     required this.message,
//     required this.providers,
//   });
//
//   factory FeaturedProviderResponse.fromJson(Map<String, dynamic> json) {
//     List<FeaturedProviderModel> providerList = [];
//
//     if (json['data'] != null && json['data'] is List) {
//       providerList = (json['data'] as List)
//           .map((item) => FeaturedProviderModel.fromJson(item as Map<String, dynamic>))
//           .toList();
//     }
//
//     return FeaturedProviderResponse(
//       success: json['success'] ?? false,
//       code: json['code'] ?? 200,
//       message: json['message'] ?? '',
//       providers: providerList,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'success': success,
//       'code': code,
//       'message': message,
//       'data': providers.map((item) => item.toJson()).toList(),
//     };
//   }
// }










class FeaturedProviderModel {
  final String id;
  final String name;
  final String phone;
  final String image;
  final String description;
  final String region;
  final String author;
  final double? averageRating;
  final int totalRatings;

  FeaturedProviderModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.image,
    required this.description,
    required this.region,
    required this.author,
    this.averageRating,
    this.totalRatings = 0,
  });

  // Convert JSON to FeaturedProviderModel
  factory FeaturedProviderModel.fromJson(Map<String, dynamic> json) {
    return FeaturedProviderModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      region: json['region']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      averageRating: json['averageRating'] != null
          ? (json['averageRating'] is int
          ? (json['averageRating'] as int).toDouble()
          : (json['averageRating'] as num).toDouble())
          : null,
      totalRatings: json['totalRatings'] != null
          ? (json['totalRatings'] is int
          ? json['totalRatings'] as int
          : (json['totalRatings'] as num).toInt())
          : 0,
    );
  }
}

// Response wrapper for API
class FeaturedProviderResponse {
  final bool success;
  final int code;
  final String message;
  final List<FeaturedProviderModel> providers;

  FeaturedProviderResponse({
    required this.success,
    required this.code,
    required this.message,
    required this.providers,
  });

  factory FeaturedProviderResponse.fromJson(Map<String, dynamic> json) {
    List<FeaturedProviderModel> providerList = [];

    if (json['data'] != null && json['data'] is List) {
      providerList = (json['data'] as List)
          .map((item) => FeaturedProviderModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return FeaturedProviderResponse(
      success: json['success'] ?? false,
      code: json['code'] ?? 200,
      message: json['message'] ?? '',
      providers: providerList,
    );
  }
}