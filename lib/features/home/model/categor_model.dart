
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
}