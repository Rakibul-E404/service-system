
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
  final String createdAt;
  final int rating;
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

  // Factory method to create a BusinessProfile from JSON
  factory BusinessProfile.fromJson(Map<String, dynamic> json) {
    return BusinessProfile(
      id: json['_id'],
      name: json['name'],
      phone: json['phone'],
      description: json['description'],
      location: json['location'],
      image: json['image'],
      isAvailable: json['isAvailable'],
      isProfileComplete: json['isProfileComplete'],
      createdAt: json['createdAt'],
      rating: json['rating'],
      ratingCount: json['ratingCount'],
    );
  }
}
