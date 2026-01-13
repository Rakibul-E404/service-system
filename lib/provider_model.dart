/**
import 'package:flutter/foundation.dart';
import '../../../core/utils/api/app_url.dart';

class ProviderModel {
  final String id;
  final String name;
  final String phone;
  final String description;
  final String location;
  final String image;
  final bool isAvailable;
  final bool isProfileComplete;
  final String createdAt;
  final double rating;
  final int ratingCount;
  final String? author;
  final String? updatedAt;

  ProviderModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.description,
    required this.location,
    required this.image,
    required this.isAvailable,
    required this.isProfileComplete,
    required this.createdAt,
    required this.rating,
    required this.ratingCount,
    this.author,
    this.updatedAt,
  });

  String get fullImageUrl {
    if (image.isEmpty) return '';
    if (image.startsWith('http://') || image.startsWith('https://')) {
      return image;
    }
    // Remove 'public/' prefix if present since baseUrl likely includes it
    final cleanImage = image.startsWith('public/') ? image.substring(7) : image;
    return '${AppUrl.imageBaseUrl}/$cleanImage';
  }

  // Helper getter for bio/description
  String get bio => description;

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    debugPrint('🔍 ========== PARSING PROVIDER MODEL ==========');
    debugPrint('   📄 Full JSON: $json');
    debugPrint('   🆔 _id: ${json['_id']} (${json['_id']?.runtimeType})');
    debugPrint('   👤 name: ${json['name']} (${json['name']?.runtimeType})');
    debugPrint('   📞 phone: ${json['phone']} (${json['phone']?.runtimeType})');
    debugPrint('   📝 description: ${json['description']} (${json['description']?.runtimeType})');
    debugPrint('   📍 location: ${json['location']} (${json['location']?.runtimeType})');
    debugPrint('   🖼️ image: ${json['image']} (${json['image']?.runtimeType})');
    debugPrint('   ✅ isAvailable: ${json['isAvailable']} (${json['isAvailable']?.runtimeType})');
    debugPrint('   ✅ isProfileComplete: ${json['isProfileComplete']} (${json['isProfileComplete']?.runtimeType})');
    debugPrint('   ⭐ rating: ${json['rating']} (${json['rating']?.runtimeType})');
    debugPrint('   🔢 ratingCount: ${json['ratingCount']} (${json['ratingCount']?.runtimeType})');
    debugPrint('   👤 author: ${json['author']} (${json['author']?.runtimeType})');

    try {
      // Extract name with trim to remove extra spaces
      final String rawName = json['name']?.toString() ?? 'Unknown Provider';
      final String cleanName = rawName.trim();

      debugPrint('   🧹 Cleaned name: "$cleanName"');

      final model = ProviderModel(
        id: json['_id']?.toString() ?? '',
        name: cleanName.isEmpty ? 'Unknown Provider' : cleanName,
        phone: json['phone']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        location: json['location']?.toString() ?? 'Location not specified',
        image: json['image']?.toString() ?? '',
        isAvailable: json['isAvailable'] == true,
        isProfileComplete: json['isProfileComplete'] == true,
        createdAt: json['createdAt']?.toString() ?? '',
        rating: _parseDouble(json['rating']), // Will be 0.0 if null
        ratingCount: _parseInt(json['ratingCount']), // Will be 0 if null
        author: json['author']?.toString(),
        updatedAt: json['updatedAt']?.toString(),
      );

      debugPrint('✅ ========== PROVIDER MODEL CREATED ==========');
      debugPrint('   👤 Name: "${model.name}"');
      debugPrint('   📍 Location: "${model.location}"');
      debugPrint('   📞 Phone: "${model.phone}"');
      debugPrint('   📝 Description: "${model.description}"');
      debugPrint('   ⭐ Rating: ${model.rating} (${model.ratingCount} reviews)');
      debugPrint('   ✅ Available: ${model.isAvailable}');
      debugPrint('   ✅ Profile Complete: ${model.isProfileComplete}');
      debugPrint('   🖼️ Image: "${model.image}"');
      debugPrint('   🌐 Full Image URL: "${model.fullImageUrl}"');
      debugPrint('=============================================\n');

      return model;
    } catch (e, stackTrace) {
      debugPrint('❌ ========== ERROR PARSING PROVIDER ==========');
      debugPrint('   💥 Error: $e');
      debugPrint('   📚 StackTrace: $stackTrace');
      debugPrint('   📄 Problematic JSON: $json');
      debugPrint('=============================================\n');
      rethrow;
    }
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0; // Default to 0.0 if null
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0; // Default to 0 if null
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'phone': phone,
      'description': description,
      'location': location,
      'image': image,
      'isAvailable': isAvailable,
      'isProfileComplete': isProfileComplete,
      'createdAt': createdAt,
      'rating': rating,
      'ratingCount': ratingCount,
      'author': author,
      'updatedAt': updatedAt,
    };
  }

  @override
  String toString() {
    return 'ProviderModel{id: $id, name: $name, phone: $phone, location: $location, rating: $rating, available: $isAvailable}';
  }
}*/













import 'package:flutter/foundation.dart';
import '../../../core/utils/api/app_url.dart';

class ProviderModel {
  final String id;
  final String name;
  final String phone;
  final String description;
  final String location;
  final String image;
  final bool isAvailable;
  final bool isProfileComplete;
  final String createdAt;
  final double rating;
  final int ratingCount;
  final String? author;
  final String? updatedAt;
  final String? email; // Add email field

  ProviderModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.description,
    required this.location,
    required this.image,
    required this.isAvailable,
    required this.isProfileComplete,
    required this.createdAt,
    required this.rating,
    required this.ratingCount,
    this.author,
    this.updatedAt,
    this.email, // Add email to constructor
  });

  String get fullImageUrl {
    if (image.isEmpty) return '';
    if (image.startsWith('http://') || image.startsWith('https://')) {
      return image;
    }
    // Remove 'public/' prefix if present since baseUrl likely includes it
    final cleanImage = image.startsWith('public/') ? image.substring(7) : image;
    return '${AppUrl.imageBaseUrl}/$cleanImage';
  }

  // Helper getter for bio/description
  String get bio => description;

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    debugPrint('🔍 ========== PARSING PROVIDER MODEL ==========');
    debugPrint('   📄 Full JSON: $json');
    debugPrint('   🆔 _id: ${json['_id']} (${json['_id']?.runtimeType})');
    debugPrint('   👤 name: ${json['name']} (${json['name']?.runtimeType})');
    debugPrint('   📞 phone: ${json['phone']} (${json['phone']?.runtimeType})');
    debugPrint('   📧 email: ${json['email']} (${json['email']?.runtimeType})'); // Add email debug
    debugPrint('   📝 description: ${json['description']} (${json['description']?.runtimeType})');
    debugPrint('   📍 location: ${json['location']} (${json['location']?.runtimeType})');
    debugPrint('   🖼️ image: ${json['image']} (${json['image']?.runtimeType})');
    debugPrint('   ✅ isAvailable: ${json['isAvailable']} (${json['isAvailable']?.runtimeType})');
    debugPrint('   ✅ isProfileComplete: ${json['isProfileComplete']} (${json['isProfileComplete']?.runtimeType})');
    debugPrint('   ⭐ rating: ${json['rating']} (${json['rating']?.runtimeType})');
    debugPrint('   🔢 ratingCount: ${json['ratingCount']} (${json['ratingCount']?.runtimeType})');
    debugPrint('   👤 author: ${json['author']} (${json['author']?.runtimeType})');

    try {
      // Extract name with trim to remove extra spaces
      final String rawName = json['name']?.toString() ?? 'Unknown Provider';
      final String cleanName = rawName.trim();

      debugPrint('   🧹 Cleaned name: "$cleanName"');

      final model = ProviderModel(
        id: json['_id']?.toString() ?? '',
        name: cleanName.isEmpty ? 'Unknown Provider' : cleanName,
        phone: json['phone']?.toString() ?? '',
        email: json['email']?.toString(), // Parse email
        description: json['description']?.toString() ?? '',
        location: json['location']?.toString() ?? 'Location not specified',
        image: json['image']?.toString() ?? '',
        isAvailable: json['isAvailable'] == true,
        isProfileComplete: json['isProfileComplete'] == true,
        createdAt: json['createdAt']?.toString() ?? '',
        rating: _parseDouble(json['rating']), // Will be 0.0 if null
        ratingCount: _parseInt(json['ratingCount']), // Will be 0 if null
        author: json['author']?.toString(),
        updatedAt: json['updatedAt']?.toString(),
      );

      debugPrint('✅ ========== PROVIDER MODEL CREATED ==========');
      debugPrint('   👤 Name: "${model.name}"');
      debugPrint('   📍 Location: "${model.location}"');
      debugPrint('   📞 Phone: "${model.phone}"');
      debugPrint('   📧 Email: "${model.email}"');
      debugPrint('   📝 Description: "${model.description}"');
      debugPrint('   ⭐ Rating: ${model.rating} (${model.ratingCount} reviews)');
      debugPrint('   ✅ Available: ${model.isAvailable}');
      debugPrint('   ✅ Profile Complete: ${model.isProfileComplete}');
      debugPrint('   🖼️ Image: "${model.image}"');
      debugPrint('   🌐 Full Image URL: "${model.fullImageUrl}"');
      debugPrint('=============================================\n');

      return model;
    } catch (e, stackTrace) {
      debugPrint('❌ ========== ERROR PARSING PROVIDER ==========');
      debugPrint('   💥 Error: $e');
      debugPrint('   📚 StackTrace: $stackTrace');
      debugPrint('   📄 Problematic JSON: $json');
      debugPrint('=============================================\n');
      rethrow;
    }
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0; // Default to 0.0 if null
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0; // Default to 0 if null
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'phone': phone,
      'email': email, // Add email to JSON
      'description': description,
      'location': location,
      'image': image,
      'isAvailable': isAvailable,
      'isProfileComplete': isProfileComplete,
      'createdAt': createdAt,
      'rating': rating,
      'ratingCount': ratingCount,
      'author': author,
      'updatedAt': updatedAt,
    };
  }

  @override
  String toString() {
    return 'ProviderModel{id: $id, name: $name, phone: $phone, email: $email, location: $location, rating: $rating, available: $isAvailable}';
  }
}