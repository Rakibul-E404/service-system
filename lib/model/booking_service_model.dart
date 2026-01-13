// // booking_service_model.dart
// class BookingServiceModel {
//   final String id;
//   final String author;
//   final String subCategory;
//   final DateTime date;
//   final String region;
//   final String status;
//   final String additionalInfo;
//   final DateTime createdAt;
//
//   BookingServiceModel({
//     required this.id,
//     required this.author,
//     required this.subCategory,
//     required this.date,
//     required this.region,
//     required this.status,
//     required this.additionalInfo,
//     required this.createdAt,
//   });
//
//   factory BookingServiceModel.fromJson(Map<String, dynamic> json) {
//     return BookingServiceModel(
//       id: json['_id'] ?? '',
//       author: json['author'] ?? '',
//       subCategory: json['subCategory'] ?? '',
//       date: DateTime.parse(json['date']),
//       region: json['region'] ?? '',
//       status: json['status'] ?? '',
//       additionalInfo: json['additionalInfo'] ?? '',
//       createdAt: DateTime.parse(json['createdAt']),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'author': author,
//       'subCategory': subCategory,
//       'date': date.toIso8601String(),
//       'region': region,
//       'status': status,
//       'additionalInfo': additionalInfo,
//       'createdAt': createdAt.toIso8601String(),
//     };
//   }
// }

// booking_service_model.dart
class BookingServiceModel {
  final String id;
  final String author;
  final SubCategory subCategory; // Changed from String to SubCategory object
  final DateTime date;
  final String region;
  final String location; // New field
  final String status;
  final String additionalInfo;
  final DateTime createdAt;

  BookingServiceModel({
    required this.id,
    required this.author,
    required this.subCategory,
    required this.date,
    required this.region,
    required this.location,
    required this.status,
    required this.additionalInfo,
    required this.createdAt,
  });

  factory BookingServiceModel.fromJson(Map<String, dynamic> json) {
    return BookingServiceModel(
      id: json['_id'] ?? '',
      author: json['author'] ?? '',
      subCategory: SubCategory.fromJson(
        json['subCategory'] is String
            ? {'_id': json['subCategory']} // Handle old format
            : (json['subCategory'] as Map<String, dynamic>?) ?? {},
      ),
      date: DateTime.parse(json['date']),
      region: json['region'] ?? '',
      location: json['location'] ?? '',
      status: json['status'] ?? '',
      additionalInfo: json['additionalInfo'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'author': author,
      'subCategory': subCategory.toJson(),
      'date': date.toIso8601String(),
      'region': region,
      'location': location,
      'status': status,
      'additionalInfo': additionalInfo,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class SubCategory {
  final String id;
  final String name;
  final String image;

  SubCategory({
    required this.id,
    required this.name,
    required this.image,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'image': image,
    };
  }
}