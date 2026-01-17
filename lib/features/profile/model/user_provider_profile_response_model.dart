
import '../../../core/utils/api/app_url.dart';

/// =======================
/// API Response Wrapper
/// =======================
class UserProviderProfileResponseModel {
  final bool success;
  final int code;
  final String message;
  final ProviderInfoData? data;

  UserProviderProfileResponseModel({
    required this.success,
    required this.code,
    required this.message,
    this.data,
  });

  factory UserProviderProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return UserProviderProfileResponseModel(
      success: json['success'] ?? false,
      code: json['code'] ?? 200,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? ProviderInfoData.fromJson(json['data'])
          : null,
    );
  }
}
class ProviderInfoData {
  final ProviderProfile profile;
  final List<String> accessibleBySubscription;
  final List<UserProviderService> services;
  final Pagination pagination;

  ProviderInfoData({
    required this.profile,
    required this.accessibleBySubscription,
    required this.services,
    required this.pagination,
  });

  factory ProviderInfoData.fromJson(Map<String, dynamic> json) {
    return ProviderInfoData(
      profile: ProviderProfile.fromJson(json['profile']),
      accessibleBySubscription:
      List<String>.from(json['accessibleBySubscription'] ?? []),
      services: (json['services'] as List? ?? [])
          .map((e) => UserProviderService.fromJson(e))
          .toList(),
      pagination: Pagination.fromJson(json['pagination']),
    );
  }
}
class ProviderProfile {
  final String id;
  final ProviderAuthor author;
  final String name;
  final String phone;
  final bool isProfileComplete;
  final String image;
  final String region;
  final String location;
  final Map<String, AvailabilityDay> availability;

  ProviderProfile({
    required this.id,
    required this.author,
    required this.name,
    required this.phone,
    required this.isProfileComplete,
    required this.image,
    required this.region,
    required this.location,
    required this.availability,
  });

  factory ProviderProfile.fromJson(Map<String, dynamic> json) {
    return ProviderProfile(
      id: json['_id'] ?? '',
      author: ProviderAuthor.fromJson(json['author']),
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      isProfileComplete: json['isProfileComplete'] ?? false,
      image: json['image'] ?? '',
      region: json['region'] ?? '',
      location: json['location'] ?? '',
      availability: (json['availability'] as Map<String, dynamic>? ?? {})
          .map((key, value) =>
          MapEntry(key, AvailabilityDay.fromJson(value))),
    );
  }

  /// Full business profile image
  String get fullImageUrl {
    if (image.isEmpty) return '';
    if (image.startsWith('http')) return image;
    final clean = image.startsWith('/') ? image.substring(1) : image;
    return '${AppUrl.imageBaseUrl}/$clean';
  }
}
class ProviderAuthor {
  final String id;
  final String name;
  final String email;
  final String image;

  ProviderAuthor({
    required this.id,
    required this.name,
    required this.email,
    required this.image,
  });

  factory ProviderAuthor.fromJson(Map<String, dynamic> json) {
    return ProviderAuthor(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      image: json['image'] ?? '',
    );
  }

  String get fullImageUrl {
    if (image.isEmpty) return '';
    if (image.startsWith('http')) return image;
    final clean = image.startsWith('/') ? image.substring(1) : image;
    return '${AppUrl.imageBaseUrl}/$clean';
  }
}
class AvailabilityDay {
  final bool isAvailable;
  final int? openingTime;
  final int? closingTime;

  AvailabilityDay({
    required this.isAvailable,
    this.openingTime,
    this.closingTime,
  });

  factory AvailabilityDay.fromJson(Map<String, dynamic> json) {
    return AvailabilityDay(
      isAvailable: json['isAvailable'] ?? false,
      openingTime: json['openingTime'],
      closingTime: json['closingTime'],
    );
  }
}
class UserProviderService {
  final String id;
  final String name;
  final String description;
  final String image;

  UserProviderService({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
  });

  factory UserProviderService.fromJson(Map<String, dynamic> json) {
    return UserProviderService(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
    );
  }

  String get fullImageUrl {
    if (image.isEmpty) return '';
    if (image.startsWith('http')) return image;
    final clean = image.startsWith('/') ? image.substring(1) : image;
    return '${AppUrl.imageBaseUrl}/$clean';
  }
}
class Pagination {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  Pagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}
