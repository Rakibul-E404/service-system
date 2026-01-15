
class AddResponseModel {
  final bool success;
  final int code;
  final String message;
  final AdData? data;

  AddResponseModel({
    required this.success,
    required this.code,
    required this.message,
    this.data,
  });

  factory AddResponseModel.fromJson(Map<String, dynamic> json) {
    return AddResponseModel(
      success: json['success'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null ? AdData.fromJson(json['data']) : null,
    );
  }
}
class AdData {
  final String id;
  final String author;
  final String content;

  AdData({
    required this.id,
    required this.author,
    required this.content,
  });

  factory AdData.fromJson(Map<String, dynamic> json) {
    return AdData(
      id: json['_id'] ?? '',
      author: json['author'] ?? '',
      content: json['content'] ?? '',
    );
  }
}
