
import 'package:intl/intl.dart';

/// =======================
/// Review Response Model
/// =======================
class ReviewResponse {
  final bool success;
  final int code;
  final String message;
  final ReviewData data;

  ReviewResponse({
    required this.success,
    required this.code,
    required this.message,
    required this.data,
  });

  factory ReviewResponse.fromJson(Map<String, dynamic> json) {
    return ReviewResponse(
      success: json['success'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: ReviewData.fromJson(json['data'] ?? {}),
    );
  }
}

/// =======================
/// Review Data
/// =======================
class ReviewData {
  final List<ReviewModel> reviews;
  final Pagination pagination;

  ReviewData({
    required this.reviews,
    required this.pagination,
  });

  factory ReviewData.fromJson(Map<String, dynamic> json) {
    return ReviewData(
      reviews: (json['data'] as List<dynamic>? ?? [])
          .map((e) => ReviewModel.fromJson(e))
          .toList(),
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

/// =======================
/// Single Review Model
/// =======================
class ReviewModel {
  final String id;
  final ReviewAuthor author;
  final String description;
  final double rating;
  final DateTime? createdAt;

  ReviewModel({
    required this.id,
    required this.author,
    required this.description,
    required this.rating,
    this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['_id'] ?? '',
      author: ReviewAuthor.fromJson(json['author'] ?? {}),
      description: json['description'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  /// Optional: Formatted date
  String get formattedDate {
    if (createdAt == null) return 'Unknown date';
    return DateFormat('MMM dd, yyyy').format(createdAt!);
  }
}

/// =======================
/// Author Info
/// =======================
class ReviewAuthor {
  final String id;
  final String name;
  final String image;

  ReviewAuthor({
    required this.id,
    required this.name,
    required this.image,
  });

  factory ReviewAuthor.fromJson(Map<String, dynamic> json) {
    return ReviewAuthor(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
    );
  }
}

/// =======================
/// Pagination Model
/// =======================
class Pagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  Pagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'] ?? 0,
      limit: json['limit'] ?? 0,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}
