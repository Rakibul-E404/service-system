

class SubCategoryResponse {
  final bool success;
  final int code;
  final String message;
  final List<SubCategoryModel> data;

  SubCategoryResponse({
    required this.success,
    required this.code,
    required this.message,
    required this.data,
  });

  factory SubCategoryResponse.fromJson(Map<String, dynamic> json) {
    return SubCategoryResponse(
      success: json['success'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: List<SubCategoryModel>.from(
        (json['data'] ?? []).map(
              (x) => SubCategoryModel.fromJson(x ?? {}),
        ),
      ),
    );
  }
}
class SubCategoryModel {
  final String id;
  final String name;
  final String description;
  final String image;

  SubCategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
    );
  }
}
