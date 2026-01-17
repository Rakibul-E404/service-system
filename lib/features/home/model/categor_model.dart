import '../../../core/utils/api/app_url.dart';

/// =======================
/// Category Model
/// =======================
class CategoryModel {
  final String id;
  final String name;
  final String description;
  final String image;
  final String? bannerImage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    this.bannerImage,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      bannerImage: json['bannerImage'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'image': image,
      if (bannerImage != null) 'bannerImage': bannerImage,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  /// Full category image URL
  String get fullImageUrl {
    if (image.isEmpty) return '';
    if (image.startsWith('http')) return image;

    final cleanPath = image.startsWith('/') ? image.substring(1) : image;
    return '${AppUrl.imageBaseUrl}/$cleanPath';
  }

  /// Full banner image URL
  String get fullBannerImageUrl {
    if (bannerImage == null || bannerImage!.isEmpty) return '';
    if (bannerImage!.startsWith('http')) return bannerImage!;

    final cleanPath =
    bannerImage!.startsWith('/') ? bannerImage!.substring(1) : bannerImage!;
    return '${AppUrl.imageBaseUrl}/$cleanPath';
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

/// =======================
/// Category API Response
/// =======================
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

    final outerData = json['data'];

    /// Case 1: data is paginated object
    if (outerData is Map<String, dynamic>) {
      if (outerData['data'] is List) {
        categoryList = (outerData['data'] as List)
            .map((e) => CategoryModel.fromJson(e))
            .toList();
      }

      if (outerData['pagination'] is Map<String, dynamic>) {
        paginationData = Pagination.fromJson(outerData['pagination']);
      }
    }

    /// Case 2: data is direct list
    else if (outerData is List) {
      categoryList =
          outerData.map((e) => CategoryModel.fromJson(e)).toList();
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
        'data': categories.map((e) => e.toJson()).toList(),
        if (pagination != null) 'pagination': pagination!.toJson(),
      },
    };
  }
}
