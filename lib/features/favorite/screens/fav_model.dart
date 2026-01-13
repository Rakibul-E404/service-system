class FavoriteModel {
  final String id;
  final String? userId;
  final String? providerServiceId;
  final ProviderService? providerService;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  bool isDeleted;  // <-- Add this field

  FavoriteModel({
    required this.id,
    this.userId,
    this.providerServiceId,
    this.providerService,
    this.createdAt,
    this.updatedAt,
    this.isDeleted = false,  // Initialize as false by default
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['_id'] ?? '',
      userId: json['user_id'],
      providerServiceId: json['provider_service_id'],
      providerService: json['providerService'] != null
          ? ProviderService.fromJson(json['providerService'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      isDeleted: json['isDeleted'] ?? false,  // Deserialize isDeleted if available
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user_id': userId,
      'provider_service_id': providerServiceId,
      'providerService': providerService?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isDeleted': isDeleted,  // Serialize isDeleted to JSON
    };
  }
}

class ProviderService {
  final String id;
  final String title;
  final String description;
  final String? image;
  final String location;
  final double? rating;
  final String categoryName;
  final String subcategoryName;
  final Provider? provider;
  final int? totalRating;

  ProviderService({
    required this.id,
    required this.title,
    required this.description,
    this.image,
    required this.location,
    this.rating,
    required this.categoryName,
    required this.subcategoryName,
    this.provider,
    this.totalRating,
  });

  factory ProviderService.fromJson(Map<String, dynamic> json) {
    return ProviderService(
      id: json['_id'] ?? '',
      title: json['name'] ?? json['title'] ?? 'No Title',
      description: json['description'] ?? '',
      image: json['image'],
      location: json['location'] ?? 'Unknown Location',
      rating: json['averageRating'] != null
          ? (json['averageRating'] as num).toDouble()
          : (json['rating'] != null ? (json['rating'] as num).toDouble() : null),
      totalRating: json['totalRating'],
      categoryName: json['category_name'] ?? '',
      subcategoryName: json['subcategory_name'] ?? '',
      provider: json['provider'] != null
          ? Provider.fromJson(json['provider'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': title,
      'description': description,
      'image': image,
      'location': location,
      'averageRating': rating,
      'totalRating': totalRating,
      'category_name': categoryName,
      'subcategory_name': subcategoryName,
      'provider': provider?.toJson(),
    };
  }

  String get imageUrl {
    if (image == null || image!.isEmpty) {
      return 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=300&fit=crop';
    }
    return 'https://d7001.sobhoy.com/$image';
  }
}

class Provider {
  final String id;
  final String name;
  final String? email;

  Provider({
    required this.id,
    required this.name,
    this.email,
  });

  factory Provider.fromJson(Map<String, dynamic> json) {
    return Provider(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown Provider',
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
    };
  }
}





