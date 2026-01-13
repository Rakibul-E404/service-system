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
  final Author author; // Changed from String to Author object
  final SubCategory subCategory;
  final DateTime date;
  final String region;
  final String location;
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
    // Helper to safely parse dates and avoid crashes
    DateTime parseSafeDate(dynamic value) {
      if (value == null) return DateTime.now();
      return DateTime.tryParse(value.toString()) ?? DateTime.now();
    }

    return BookingServiceModel(
      id: json['_id'] ?? '',
      // Handles author as an Object
      author: Author.fromJson(json['author'] is Map<String, dynamic> ? json['author'] : {}),
      // Handles 'subcategory' or 'subCategory'
      subCategory: SubCategory.fromJson(
        json['subcategory'] ?? json['subCategory'] ?? {},
      ),
      // Handles 'bookingDate' or 'date'
      date: parseSafeDate(json['bookingDate'] ?? json['date']),
      region: json['region'] ?? '',
      location: json['location'] ?? '',
      status: json['status'] ?? '',
      // Handles 'details' or 'additionalInfo'
      additionalInfo: json['details'] ?? json['additionalInfo'] ?? '',
      createdAt: parseSafeDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'author': author.toJson(),
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

class Author {
  final String id;
  final String name;
  final String image;
  final String email;

  Author({
    required this.id,
    required this.name,
    required this.image,
    required this.email,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown User',
      image: json['image'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'image': image,
      'email': email,
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