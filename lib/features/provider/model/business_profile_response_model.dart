
class BusinessProfileResponse {
  final bool success;
  final int code;
  final String message;
  final BusinessProfile data;

  BusinessProfileResponse({
    required this.success,
    required this.code,
    required this.message,
    required this.data,
  });

  factory BusinessProfileResponse.fromJson(Map<String, dynamic> json) {
    return BusinessProfileResponse(
      success: json['success'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: BusinessProfile.fromJson(json['data'] ?? {}),
    );
  }
}

class BusinessProfile {
  final String id;
  final String author;
  final String name;
  final String phone;
  final String description;
  final String serviceCategory;
  final bool isProfileComplete;
  final String createdAt;
  final String updatedAt;
  final int version;
  final String image;
  final String region;
  final String location;
  final Map<String, AvailabilityDay> availability;
  final bool isSubscribed;
  final List<String> subscriptionAccess;

  BusinessProfile({
    required this.id,
    required this.author,
    required this.name,
    required this.phone,
    required this.description,
    required this.serviceCategory,
    required this.isProfileComplete,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    required this.image,
    required this.region,
    required this.location,
    required this.availability,
    required this.isSubscribed,
    required this.subscriptionAccess,
  });

  factory BusinessProfile.fromJson(Map<String, dynamic> json) {
    final availabilityJson = json['availability'] ?? {};

    return BusinessProfile(
      id: json['_id'] ?? '',
      author: json['author'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      description: json['description'] ?? '',
      serviceCategory: json['serviceCategory'] ?? '',
      isProfileComplete: json['isProfileComplete'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      version: json['__v'] ?? 0,
      image: json['image'] ?? '',
      region: json['region'] ?? '',
      location: json['location'] ?? '',
      availability: Map<String, AvailabilityDay>.from(
        availabilityJson.map(
              (key, value) => MapEntry(
            key,
            AvailabilityDay.fromJson(value ?? {}),
          ),
        ),
      ),
      isSubscribed: json['isSubscribed'] ?? false,
      subscriptionAccess: List<String>.from(
        json['subscriptionAccess'] ?? [],
      ),
    );
  }
}


class AvailabilityDay {
  final bool isAvailable;
  final int openingTime;
  final int closingTime;

  AvailabilityDay({
    required this.isAvailable,
    required this.openingTime,
    required this.closingTime,
  });

  factory AvailabilityDay.fromJson(Map<String, dynamic> json) {
    return AvailabilityDay(
      isAvailable: json['isAvailable'] ?? false,
      openingTime: json['openingTime'] ?? 0,
      closingTime: json['closingTime'] ?? 0,
    );
  }
}


