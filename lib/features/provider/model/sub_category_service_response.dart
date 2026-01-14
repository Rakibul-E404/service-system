
class ServiceResponse {
  final bool success;
  final int code;
  final String message;
  final List<ServiceModel> data;

  ServiceResponse({
    required this.success,
    required this.code,
    required this.message,
    required this.data,
  });

  factory ServiceResponse.fromJson(Map<String, dynamic> json) {
    return ServiceResponse(
      success: json['success'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: List<ServiceModel>.from(
        (json['data'] ?? []).map(
              (x) => ServiceModel.fromJson(x ?? {}),
        ),
      ),
    );
  }
}
class ServiceModel {
  final String id;
  final ServiceSubCategory subCategory;

  ServiceModel({
    required this.id,
    required this.subCategory,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['_id'] ?? '',
      subCategory: ServiceSubCategory.fromJson(
        json['subCategory'] ?? {},
      ),
    );
  }
}
class ServiceSubCategory {
  final String id;
  final String name;

  ServiceSubCategory({
    required this.id,
    required this.name,
  });

  factory ServiceSubCategory.fromJson(Map<String, dynamic> json) {
    return ServiceSubCategory(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}
