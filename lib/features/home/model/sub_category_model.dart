// File location: lib/features/home/model/subcategory_model.dart

import '../../../core/utils/api/app_url.dart';

class SubCategoryModel {
  final String id;
  final String name;
  final String image;
  final String categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubCategoryModel({
    required this.id,
    required this.name,
    required this.image,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert JSON to SubCategoryModel
  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      categoryId: json['categoryId'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Convert SubCategoryModel to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'image': image,
      'categoryId': categoryId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Get full image URL
  String get fullImageUrl {
    if (image.isEmpty) return '';
    if (image.startsWith('http')) return image;

    String cleanPath = image;
    if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }
    return '${AppUrl.imageBaseUrl}/$cleanPath';
  }
}

// Response wrapper for API
class SubCategoryResponse {
  final bool success;
  final String message;
  final List<SubCategoryModel> subCategories;

  SubCategoryResponse({
    required this.success,
    required this.message,
    required this.subCategories,
  });

  factory SubCategoryResponse.fromJson(Map<String, dynamic> json) {
    return SubCategoryResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      subCategories: (json['data'] as List<dynamic>?)
          ?.map((item) => SubCategoryModel.fromJson(item as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': subCategories.map((item) => item.toJson()).toList(),
    };
  }
}