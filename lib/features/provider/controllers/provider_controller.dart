/**

import 'package:get/get.dart';

class ProviderController extends GetxController {

  final RxInt count = 0.obs;

  void increment() => count.value++;


  
  /// [onInit] Lifecycle method called when the controller is initialized.
  ///
  /// Resets loading states, clears existing data, and triggers and more..
  /// initial fetch
  /// 
  @override
  void onInit() {
    super.onInit();
    count.value = 0;
  }

  /// [dispose] Lifecycle method called when the controller is destroyed.
  ///
  /// Cleans up by resetting loading states and clearing lists and more...
  @override
  void dispose() {
    super.dispose();
    count.value = 0;
  }
}





 */




///
///
///
/// todo::: addign teh api
///
///
///



import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/utils/token_service/token_storage_service.dart';

class ProviderController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller(); // Create an instance of NetworkCaller
  final SharedPrefService _sharedPrefService = SharedPrefService();

  // Observable variables
  RxBool isLoading = false.obs;
  RxBool isAvailable = false.obs;
  Rx<BusinessProfile?> businessProfile = Rx<BusinessProfile?>(null); // Use the correct BusinessProfile type

  @override
  void onInit() {
    super.onInit();
    fetchBusinessProfile();
  }

  // Fetch business profile data
  Future<void> fetchBusinessProfile() async {
    try {
      isLoading.value = true;

      // Assuming you have the access token and URL logic
      final providerAccessToken = await _sharedPrefService.getAccessToken();
      final response = await _networkCaller.getRequest(
        'https://d7001.sobhoy.com/api/v1/business_profile',
        headers: {'Authorization': 'Bearer $providerAccessToken'},
      );

      if (response.isSuccess && response.jsonResponse != null) {
        businessProfile.value = BusinessProfile.fromJson(response.jsonResponse!['data']);
      } else {
        throw Exception(response.errorMessage ?? 'Failed to fetch business profile');
      }
    } catch (e) {
      // Handle error
      debugPrint('❌ Error fetching business profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Update availability status
  Future<void> updateAvailability(bool value) async {
    try {
      isLoading.value = true;

      // Prepare the body for the PUT request
      final Map<String, dynamic> body = {
        'isAvailable': value,
      };

      // Make the PUT request to update availability
      final response = await _networkCaller.putRequest(
        'https://d7001.sobhoy.com/api/v1/business_profile/availability',
        body: body,
        headers: {
          'Authorization': 'Bearer ${await _sharedPrefService.getAccessToken()}',
        },
      );

      if (response.isSuccess) {
        // If successful, update the local state
        isAvailable.value = value;
        Get.snackbar('Success', 'Availability updated successfully');
      } else {
        throw Exception(response.errorMessage ?? 'Failed to update availability');
      }
    } catch (e) {
      debugPrint('❌ Error updating availability: $e');
      Get.snackbar('Error', 'Failed to update availability');
    } finally {
      isLoading.value = false;
    }
  }
}





class BusinessProfile {
  final String id;
  final String name;
  final String phone;
  final String description;
  final String location;
  final String image;
  final bool isAvailable;
  final bool isProfileComplete;
  final DateTime createdAt;
  final double rating;
  final int ratingCount;

  BusinessProfile({
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
  });

  // Factory constructor to create a BusinessProfile from JSON
  factory BusinessProfile.fromJson(Map<String, dynamic> json) {
    return BusinessProfile(
      id: json['_id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      image: json['image'] as String,
      isAvailable: json['isAvailable'] as bool,
      isProfileComplete: json['isProfileComplete'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      rating: (json['rating'] as num).toDouble(),
      ratingCount: json['ratingCount'] as int,
    );
  }

  // Method to convert a BusinessProfile to JSON
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
      'createdAt': createdAt.toIso8601String(),
      'rating': rating,
      'ratingCount': ratingCount,
    };
  }
}

