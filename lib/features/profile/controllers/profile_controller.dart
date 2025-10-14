/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/network/network_caller.dart';
import '../../../core/utils/api/app_url.dart';

class ProfileController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();

  // Observables
  final _name = ''.obs;
  final _email = ''.obs;
  final _profileImage = ''.obs;
  final _isLoading = false.obs;

  // Getters
  String get name => _name.value;
  String get email => _email.value;
  String get profileImage => _profileImage.value;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  /// Fetch user profile data
  Future<void> fetchUserProfile() async {
    try {
      _isLoading.value = true;

      final response = await _networkCaller.getRequest(
        AppUrl.selfProfileUrl,
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final data = response.jsonResponse!['data'];

        if (data != null) {
          _name.value = data['name'] ?? '';
          _email.value = data['email'] ?? '';
          _profileImage.value = data['profileImage'] ?? '';
        }
      } else {
        debugPrint('Failed to load profile: ${response.errorMessage}');
      }
    } catch (e) {
      debugPrint('Error fetching profile: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Refresh profile data
  Future<void> refreshProfile() async {
    await fetchUserProfile();
  }
}*/
















// profile_controller.dart
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/network/network_caller.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';

class ProfileController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();

  // Observables
  final _name = ''.obs;
  final _email = ''.obs;
  final _profileImage = ''.obs;
  final _isLoading = false.obs;

  // Getters
  String get name => _name.value;
  String get email => _email.value;
  String get profileImage => _profileImage.value;
  bool get isLoading => _isLoading.value;

  // Method to update name
  void updateName(String newName) {
    _name.value = newName;
  }

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      _isLoading.value = true;
      final response = await _networkCaller.getRequest(AppUrl.selfProfileUrl);
      if (response.isSuccess && response.jsonResponse != null) {
        final data = response.jsonResponse!['data'];
        if (data != null) {
          _name.value = data['name'] ?? '';
          _email.value = data['email'] ?? '';
          // Use 'image' key based on backend response for profile image
          _profileImage.value = data['image'] ?? '';
        }
      }
    } catch (e) {
      debugPrint('Error fetching profile: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> refreshProfile() async {
    await fetchUserProfile();
  }
}
