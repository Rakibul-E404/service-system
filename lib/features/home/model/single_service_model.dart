
class ServiceResponseModel {
  final bool success;
  final int code;
  final String message;
  final SingleServiceModel data;

  ServiceResponseModel({
    required this.success,
    required this.code,
    required this.message,
    required this.data,
  });

  factory ServiceResponseModel.fromJson(Map<String, dynamic> json) {
    return ServiceResponseModel(
      success: json['success'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: SingleServiceModel.fromJson(json['data'] ?? {}),
    );
  }
}
class SingleServiceModel {
  final String id;
  final ServiceAuthor author;
  final SubCategoryModel subCategory;
  final ProfileDetailsModel profileDetails;
  final bool isSponsored;
  final bool isSubscribed;
  final List<String> accessibleBySubscription;

  SingleServiceModel({
    required this.id,
    required this.author,
    required this.subCategory,
    required this.profileDetails,
    required this.isSponsored,
    required this.isSubscribed,
    required this.accessibleBySubscription,
  });

  factory SingleServiceModel.fromJson(Map<String, dynamic> json) {
    return SingleServiceModel(
      id: json['_id'] ?? '',
      author: ServiceAuthor.fromJson(json['author'] ?? {}),
      subCategory: SubCategoryModel.fromJson(json['subCategory'] ?? {}),
      profileDetails: ProfileDetailsModel.fromJson(json['profileDetails'] ?? {}),
      isSponsored: json['isSponsored'] ?? false,
      isSubscribed: json['isSubscribed'] ?? false,
      accessibleBySubscription:
      List<String>.from(json['accessibleBySubscription'] ?? []),
    );
  }
}
class ServiceAuthor {
  final String id;
  final String name;

  ServiceAuthor({
    required this.id,
    required this.name,
  });

  factory ServiceAuthor.fromJson(Map<String, dynamic> json) {
    return ServiceAuthor(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
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
class ProfileDetailsModel {
  final String id;
  final String name;
  final String region;
  final String location;
  final String image;
  final String description;
  final String phone;
  final String email;
  final AvailabilityModel availability;
  final double averageRating;
  final int totalReviews;

  ProfileDetailsModel({
    required this.id,
    required this.name,
    required this.region,
    required this.location,
    required this.image,
    required this.description,
    required this.phone,
    required this.email,
    required this.availability,
    required this.averageRating,
    required this.totalReviews,
  });

  factory ProfileDetailsModel.fromJson(Map<String, dynamic> json) {
    return ProfileDetailsModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      region: json['region'] ?? '',
      location: json['location'] ?? '',
      image: json['image'] ?? '',
      description: json['description'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      availability: AvailabilityModel.fromJson(json['availability'] ?? {}),
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] ?? 0,
    );
  }
}
class AvailabilityModel {
  final Map<String, DayAvailability> days;

  AvailabilityModel({required this.days});

  factory AvailabilityModel.fromJson(Map<String, dynamic> json) {
    final Map<String, DayAvailability> parsedDays = {};
    json.forEach((key, value) {
      parsedDays[key] = DayAvailability.fromJson(value);
    });
    return AvailabilityModel(days: parsedDays);
  }
}
class DayAvailability {
  final bool isAvailable;
  final int openingTime;
  final int closingTime;

  DayAvailability({
    required this.isAvailable,
    required this.openingTime,
    required this.closingTime,
  });

  factory DayAvailability.fromJson(Map<String, dynamic> json) {
    return DayAvailability(
      isAvailable: json['isAvailable'] ?? false,
      openingTime: json['openingTime'] ?? 0,
      closingTime: json['closingTime'] ?? 0,
    );
  }
}
