import '../../../core/utils/api/app_url.dart';

class SubCategoryModel {
  final String id;
  final String name;
  final String image;
  final String description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SubCategoryModel({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    this.createdAt,
    this.updatedAt,
  });

  // Convert JSON to SubCategoryModel
  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  // Convert SubCategoryModel to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'image': image,
      'description': description,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
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

// Pagination model
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
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'totalPages': totalPages,
    };
  }
}

// Response wrapper for API
class SubCategoryResponse {
  final bool success;
  final int code;
  final String message;
  final List<SubCategoryModel> subCategories;
  final Pagination? pagination;

  SubCategoryResponse({
    required this.success,
    required this.code,
    required this.message,
    required this.subCategories,
    this.pagination,
  });

  factory SubCategoryResponse.fromJson(Map<String, dynamic> json) {
    List<SubCategoryModel> subcategoryList = [];
    Pagination? paginationData;

    // Handle nested data structure: data -> data -> array
    if (json['data'] != null) {
      var outerData = json['data'];

      if (outerData is Map<String, dynamic>) {
        // Extract the inner data array
        if (outerData['data'] != null && outerData['data'] is List) {
          subcategoryList = (outerData['data'] as List)
              .map((item) => SubCategoryModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }

        // Extract pagination if exists
        if (outerData['pagination'] != null && outerData['pagination'] is Map<String, dynamic>) {
          paginationData = Pagination.fromJson(outerData['pagination'] as Map<String, dynamic>);
        }
      } else if (outerData is List) {
        // Fallback: if data is directly a list
        subcategoryList = outerData
            .map((item) => SubCategoryModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }

    return SubCategoryResponse(
      success: json['success'] ?? false,
      code: json['code'] ?? 200,
      message: json['message'] ?? '',
      subCategories: subcategoryList,
      pagination: paginationData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'code': code,
      'message': message,
      'data': {
        'data': subCategories.map((item) => item.toJson()).toList(),
        if (pagination != null) 'pagination': pagination!.toJson(),
      },
    };
  }
}
