/**
import 'package:flutter/foundation.dart';
import '../../../core/utils/api/app_url.dart';

class ServiceModel {
  final String id;
  final String name;
  final String description;
  final String image;
  final String subCategory;
  final String location;
  final double rating;
  final int ratingCount;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.subCategory,
    required this.location,
    required this.rating,
    required this.ratingCount,
  });

  // Make fullImageUrl a getter that returns non-nullable String
  String get fullImageUrl {
    if (image.isEmpty) return '';

    // If image already contains http/https, return as is
    if (image.startsWith('http://') || image.startsWith('https://')) {
      return image;
    }

    // Use AppUrl.baseUrl for the base URL
    return '${AppUrl.imageBaseUrl}/$image';
  }

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    debugPrint('🔍 Parsing ServiceModel from JSON:');
    debugPrint('   - Full JSON: $json');
    debugPrint('   - _id: ${json['_id']}');
    debugPrint('   - name: ${json['name']}');
    debugPrint('   - description: ${json['description']}');
    debugPrint('   - image: ${json['image']}');
    debugPrint('   - subCategory: ${json['subCategory']}');
    debugPrint('   - location: ${json['location']}');
    debugPrint('   - rating: ${json['rating']} (type: ${json['rating']?.runtimeType})');
    debugPrint('   - ratingCount: ${json['ratingCount']} (type: ${json['ratingCount']?.runtimeType})');

    try {
      final model = ServiceModel(
        id: json['_id']?.toString() ?? '',
        name: json['name']?.toString() ?? 'Unnamed Service',
        description: json['description']?.toString() ?? 'No description',
        image: json['image']?.toString() ?? '',
        subCategory: json['subCategory']?.toString() ?? '',
        location: json['location']?.toString() ?? 'Unknown location',
        rating: _parseDouble(json['rating']),
        ratingCount: _parseInt(json['ratingCount']),
      );

      debugPrint('✅ Successfully created ServiceModel: ${model.name}');
      return model;
    } catch (e, stackTrace) {
      debugPrint('❌ Error parsing ServiceModel: $e');
      debugPrint('📚 StackTrace: $stackTrace');
      rethrow;
    }
  }

  // Helper method to safely parse double
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  // Helper method to safely parse int
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'image': image,
      'subCategory': subCategory,
      'location': location,
      'rating': rating,
      'ratingCount': ratingCount,
    };
  }

  @override
  String toString() {
    return 'ServiceModel{id: $id, name: $name, location: $location, rating: $rating, ratingCount: $ratingCount}';
  }
}
*/








///
///
///
///
/// todo:: taking the author id
///
///
///





import 'package:flutter/foundation.dart';
import '../../../core/utils/api/app_url.dart';

class ServiceModel {
  final String id;
  final String name;
  final String description;
  final String image;
  final String subCategory;
  final String location;
  final double rating;
  final int ratingCount;
  final String author; // Added 'author' field

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.subCategory,
    required this.location,
    required this.rating,
    required this.ratingCount,
    required this.author, // Updated constructor to accept 'author'
  });

  // Make fullImageUrl a getter that returns non-nullable String
  String get fullImageUrl {
    if (image.isEmpty) return '';

    // If image already contains http/https, return as is
    if (image.startsWith('http://') || image.startsWith('https://')) {
      return image;
    }

    // Use AppUrl.baseUrl for the base URL
    return '${AppUrl.imageBaseUrl}/$image';
  }

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    debugPrint('🔍 Parsing ServiceModel from JSON:');
    debugPrint('   - Full JSON: $json');
    debugPrint('   - _id: ${json['_id']}');
    debugPrint('   - name: ${json['name']}');
    debugPrint('   - description: ${json['description']}');
    debugPrint('   - image: ${json['image']}');
    debugPrint('   - subCategory: ${json['subCategory']}');
    debugPrint('   - location: ${json['location']}');
    debugPrint('   - rating: ${json['rating']} (type: ${json['rating']?.runtimeType})');
    debugPrint('   - ratingCount: ${json['ratingCount']} (type: ${json['ratingCount']?.runtimeType})');
    debugPrint('   - author: ${json['author']}');

    try {
      final model = ServiceModel(
        id: json['_id']?.toString() ?? '',
        name: json['name']?.toString() ?? 'Unnamed Service',
        description: json['description']?.toString() ?? 'No description',
        image: json['image']?.toString() ?? '',
        subCategory: json['subCategory']?.toString() ?? '',
        location: json['location']?.toString() ?? 'Unknown location',
        rating: _parseDouble(json['rating']),
        ratingCount: _parseInt(json['ratingCount']),
        author: json['author']?.toString() ?? 'Unknown author', // Parse 'author' field
      );

      debugPrint('✅ Successfully created ServiceModel: ${model.name}');
      return model;
    } catch (e, stackTrace) {
      debugPrint('❌ Error parsing ServiceModel: $e');
      debugPrint('📚 StackTrace: $stackTrace');
      rethrow;
    }
  }

  // Helper method to safely parse double
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  // Helper method to safely parse int
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'image': image,
      'subCategory': subCategory,
      'location': location,
      'rating': rating,
      'ratingCount': ratingCount,
      'author': author, // Include 'author' in toJson
    };
  }

  @override
  String toString() {
    return 'ServiceModel{id: $id, name: $name, location: $location, rating: $rating, ratingCount: $ratingCount, author: $author}';
  }
}
