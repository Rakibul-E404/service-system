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
  final String? authorId;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.subCategory,
    required this.location,
    required this.rating,
    required this.ratingCount,
    this.authorId,
  });

  String get fullImageUrl {
    if (image.isEmpty) return '';

    if (image.startsWith('http://') || image.startsWith('https://')) {
      return image;
    }

    return '${AppUrl.imageBaseUrl}/$image';
  }

  Map<String, dynamic>? get author {
    if (authorId == null || authorId!.isEmpty) return null;
    return {'_id': authorId};
  }

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    debugPrint('🔍 Parsing ServiceModel from JSON: ${json['_id']}');

    String? extractedAuthorId;
    final dynamic authorField = json['author'];

    if (authorField is String) {
      extractedAuthorId = authorField;
    } else if (authorField is Map<String, dynamic>) {
      extractedAuthorId = authorField['_id']?.toString();
    }

    return ServiceModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unnamed Service',
      description: json['description']?.toString() ?? 'No description',
      image: json['image']?.toString() ?? '',
      subCategory: json['subCategory']?.toString() ?? '',
      location: json['location']?.toString() ?? 'Unknown location',
      rating: _parseDouble(json['rating']),
      ratingCount: _parseInt(json['ratingCount']),
      authorId: extractedAuthorId,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

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
      'author': authorId,
    };
  }

  @override
  String toString() {
    return 'ServiceModel{id: $id, name: $name, authorId: $authorId}';
  }
}