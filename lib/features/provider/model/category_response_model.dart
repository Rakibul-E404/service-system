
class CategoryResponse {
  final bool success;
  final int code;
  final String message;
  final List<CategoryModel> data;

  CategoryResponse({
    required this.success,
    required this.code,
    required this.message,
    required this.data,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      success: json['success'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: List<CategoryModel>.from(
        (json['data'] ?? []).map(
              (x) => CategoryModel.fromJson(x ?? {}),
        ),
      ),
    );
  }
}
class CategoryModel {
  final String id;
  final String name;
  final String image;
  final String bannerImage;

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    required this.bannerImage,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      bannerImage: json['bannerImage'] ?? '',
    );
  }
}
