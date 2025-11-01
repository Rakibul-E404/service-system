/**

import '../../../core/utils/api/app_url.dart';

class CategoryModel {
  final String id;
  final String name;
  final String description;
  final String image;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'image': image,
    };
  }

  String get fullImageUrl {
    if (image.isEmpty) return '';
    return '${AppUrl.imageBaseUrl}/$image';
  }
}

class CategoryResponse {
  final bool success;
  final int code;
  final String message;
  final List<CategoryModel> categories;
  final PaginationModel pagination;

  CategoryResponse({
    required this.success,
    required this.code,
    required this.message,
    required this.categories,
    required this.pagination,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final dataList = data['data'] as List? ?? [];

    return CategoryResponse(
      success: json['success'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      categories: dataList.map((e) => CategoryModel.fromJson(e)).toList(),
      pagination: PaginationModel.fromJson(data['pagination'] ?? {}),
    );
  }
}

class PaginationModel {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  PaginationModel({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}*/




///
///
///
///
/// todo::: adding the sub category api
///
///
///



import '../../../core/utils/api/app_url.dart';

class CategoryModel {
  final String id;
  final String name;
  final String description;
  final String image;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    this.createdAt,
    this.updatedAt,
  });

  // Convert JSON to CategoryModel
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  // Convert CategoryModel to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'image': image,
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
class CategoryResponse {
  final bool success;
  final int code;
  final String message;
  final List<CategoryModel> categories;
  final Pagination? pagination;

  CategoryResponse({
    required this.success,
    required this.code,
    required this.message,
    required this.categories,
    this.pagination,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    List<CategoryModel> categoryList = [];
    Pagination? paginationData;

    // Handle nested data structure: data -> data -> array
    if (json['data'] != null) {
      var outerData = json['data'];

      if (outerData is Map<String, dynamic>) {
        // Extract the inner data array
        if (outerData['data'] != null && outerData['data'] is List) {
          categoryList = (outerData['data'] as List)
              .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }

        // Extract pagination if exists
        if (outerData['pagination'] != null && outerData['pagination'] is Map<String, dynamic>) {
          paginationData = Pagination.fromJson(outerData['pagination'] as Map<String, dynamic>);
        }
      } else if (outerData is List) {
        // Fallback: if data is directly a list
        categoryList = outerData
            .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }

    return CategoryResponse(
      success: json['success'] ?? false,
      code: json['code'] ?? 200,
      message: json['message'] ?? '',
      categories: categoryList,
      pagination: paginationData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'code': code,
      'message': message,
      'data': {
        'data': categories.map((item) => item.toJson()).toList(),
        if (pagination != null) 'pagination': pagination!.toJson(),
      },
    };
  }
}