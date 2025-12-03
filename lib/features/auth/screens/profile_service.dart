/**

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/network/network_caller.dart';
import 'package:manx_mate/core/config/app_constants.dart';
import 'package:manx_mate/core/data/secured_storage.dart';
import 'package:manx_mate/core/network/network_response.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';
import 'package:manx_mate/core/routes/app_routes.dart';
import 'package:manx_mate/core/utils/token_service/token_storage_service.dart';

/// Shared Profile Service - Single Source of Truth for User Profile
class ProfileService extends GetxService {
  final NetworkCaller _networkCaller = NetworkCaller();
  final SecureStorageService _secureStorage = SecureStorageService();
  final SharedPrefService _sharedPrefService = SharedPrefService();

  // Observables - Shared across all screens
  RxString userId = ''.obs;
  RxString name = ''.obs;
  RxString email = ''.obs;
  RxString profileImage = ''.obs;
  RxString location = ''.obs;
  RxString role = ''.obs;
  RxString phone = ''.obs;
  RxBool isLoading = false.obs;
  RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('🔄 ProfileService initialized');
    _initializeService();
  }

  /// Initialize the service - check login status and load profile
  Future<void> _initializeService() async {
    await checkLoginStatus();
  }

  /// Check if user is logged in and load profile
  Future<void> checkLoginStatus() async {
    try {
      isLoading.value = true;

      // Check if tokens exist in SecureStorage
      final String? token = await _secureStorage.read(AppConstants.authToken);
      final String? storedRole = await _secureStorage.read(AppConstants.roleType);

      debugPrint('🔐 Checking login status...');
      debugPrint('📝 Token exists: ${token != null && token.isNotEmpty}');
      debugPrint('🎭 Stored role: $storedRole');

      if (token != null && token.isNotEmpty) {
        isLoggedIn.value = true;

        // Set role from storage immediately (will be updated from API)
        if (storedRole != null && storedRole.isNotEmpty) {
          role.value = storedRole;
          debugPrint('✅ Set initial role from storage: $storedRole');
        }

        // Load profile data
        await fetchUserProfile();
      } else {
        isLoggedIn.value = false;
        debugPrint('❌ No auth token found - user not logged in');
      }
    } catch (e) {
      debugPrint('❌ Error checking login status: $e');
      isLoggedIn.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch user profile from API
  Future<void> fetchUserProfile() async {
    try {
      if (!isLoggedIn.value) {
        debugPrint('⚠️ Not logged in, skipping profile fetch');
        return;
      }

      isLoading.value = true;

      debugPrint('═══════════════════════════════════════');
      debugPrint('👤 FETCHING USER PROFILE');
      debugPrint('═══════════════════════════════════════');

      final String? token = await _secureStorage.read(AppConstants.authToken);

      if (token == null || token.isEmpty) {
        debugPrint('❌ No auth token found');
        isLoading.value = false;
        return;
      }

      debugPrint('📤 API REQUEST');
      debugPrint('URL: ${AppUrl.selfProfileUrl}');
      debugPrint('🔑 Token: ${token.substring(0, 30)}...');

      final NetworkResponse response = await _networkCaller.getRequest(
        AppUrl.selfProfileUrl,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('───────────────────────────────────────');
      debugPrint('📥 API RESPONSE');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Is Success: ${response.isSuccess}');
      debugPrint('───────────────────────────────────────');

      if (response.isSuccess && response.jsonResponse != null) {
        final bool success = response.jsonResponse!['success'] ?? false;
        final Map<String, dynamic>? data = response.jsonResponse!['data'];

        debugPrint('✅ Profile Fetch Success: $success');

        if (success && data != null) {
          // Extract and update all profile data
          userId.value = data['_id']?.toString() ?? '';
          name.value = data['name']?.toString() ?? 'Guest User';
          email.value = data['email']?.toString() ?? '';
          profileImage.value = data['image']?.toString() ?? '';
          location.value = data['location']?.toString() ?? '';
          phone.value = data['phone']?.toString() ?? '';

          // CRITICAL: Get role from API response
          final String apiRole = data['role']?.toString()?.toLowerCase() ?? '';
          if (apiRole.isNotEmpty) {
            role.value = apiRole;
            // Update stored role for consistency
            await _secureStorage.write(AppConstants.roleType, apiRole);
            debugPrint('✅ Role updated from API: $apiRole');
          }

          debugPrint('👤 User ID: ${userId.value}');
          debugPrint('📛 Name: ${name.value}');
          debugPrint('📧 Email: ${email.value}');
          debugPrint('📞 Phone: ${phone.value}');
          debugPrint('📍 Location: ${location.value}');
          debugPrint('🖼️ Image: ${profileImage.value}');
          debugPrint('🎭 Role: ${role.value}');

          // Save to SharedPreferences for persistence
          await _sharedPrefService.saveTokens(
            accessToken: token,
            refreshToken: await _secureStorage.read(AppConstants.refressToken) ?? '',
            userRole: role.value,
          );

          isLoggedIn.value = true;
          debugPrint('✅ Profile loaded successfully');
        } else {
          _showError('Failed to load profile data');
          debugPrint('❌ No user data in response');
        }
      } else {
        final String errorMessage = response.jsonResponse?['message'] ??
            response.errorMessage ??
            'Failed to load profile';

        debugPrint('❌ Profile Fetch Failed: $errorMessage');

        // If unauthorized, clear login state
        if (response.statusCode == 401) {
          debugPrint('🔐 Unauthorized - clearing login data');
          await logout();
        } else {
          _showError(errorMessage);
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ EXCEPTION OCCURRED');
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');
      _showError('An unexpected error occurred');
    } finally {
      isLoading.value = false;
      debugPrint('═══════════════════════════════════════');
    }
  }

  /// Force refresh profile data
  Future<void> refreshProfile() async {
    debugPrint('🔄 Refreshing profile data...');
    await fetchUserProfile();
  }

  /// Update profile data locally (for UI updates)
  void updateProfileData({
    String? newName,
    String? newEmail,
    String? newPhone,
    String? newLocation,
    String? newImage,
  }) {
    if (newName != null && newName.isNotEmpty) name.value = newName;
    if (newEmail != null && newEmail.isNotEmpty) email.value = newEmail;
    if (newPhone != null && newPhone.isNotEmpty) phone.value = newPhone;
    if (newLocation != null) location.value = newLocation;
    if (newImage != null && newImage.isNotEmpty) profileImage.value = newImage;

    debugPrint('🔄 Profile data updated locally');
  }

  /// Get full image URL for profile picture
  String getImageUrl() {
    if (profileImage.value.isEmpty) return '';
    final String url = AppUrl.getUserProfileImageUrl(profileImage.value);
    debugPrint('🖼️ Profile image URL: $url');
    return url;
  }

  /// Format location for display
  String getDisplayLocation() {
    if (location.value.isEmpty) return 'Location not set';
    return location.value;
  }

  /// Show error message
  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  /// Save login data after successful login
  Future<void> saveLoginData({
    required String accessToken,
    required String refreshToken,
    required String userRole,
    required String userId,
    String? userName,
    String? userEmail,
  }) async {
    try {
      debugPrint('💾 Saving login data...');

      // Save to SecureStorage (for API calls)
      await _secureStorage.write(AppConstants.authToken, accessToken);
      await _secureStorage.write(AppConstants.refressToken, refreshToken);
      await _secureStorage.write(AppConstants.roleType, userRole.toLowerCase());
      await _secureStorage.write(AppConstants.userId, userId);

      if (userName != null) {
        await _secureStorage.write(AppConstants.userName, userName);
      }

      if (userEmail != null) {
        await _secureStorage.write(AppConstants.userEmail, userEmail);
      }

      // Save to SharedPreferences (for persistence)
      await _sharedPrefService.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        userRole: userRole.toLowerCase(),
      );

      // Update ProfileService state
      role.value = userRole.toLowerCase();
      this.userId.value = userId;
      if (userName != null) name.value = userName;
      if (userEmail != null) email.value = userEmail;

      isLoggedIn.value = true;

      debugPrint('✅ Login data saved successfully');
      debugPrint('🎭 Role: ${role.value}');
      debugPrint('👤 User ID: ${this.userId.value}');
      debugPrint('📛 Name: ${name.value}');
      debugPrint('📧 Email: ${email.value}');

      // Fetch complete profile data from API
      await fetchUserProfile();

    } catch (e) {
      debugPrint('❌ Error saving login data: $e');
      _showError('Failed to save login data');
    }
  }

  /// Clear all profile data (for logout)
  Future<void> clearProfile() async {
    userId.value = '';
    name.value = '';
    email.value = '';
    profileImage.value = '';
    location.value = '';
    phone.value = '';
    role.value = '';
    isLoggedIn.value = false;

    debugPrint('🧹 Profile data cleared');
  }

  /// Logout the user
  Future<void> logout() async {
    try {
      debugPrint('═══════════════════════════════════════');
      debugPrint('🚪 LOGGING OUT USER');
      debugPrint('═══════════════════════════════════════');

      isLoading.value = true;

      // Clear SharedPreferences
      debugPrint('🧹 Clearing SharedPreferences...');
      await _sharedPrefService.clearAll();
      debugPrint('✅ SharedPreferences cleared');

      // Clear SecureStorage
      debugPrint('🧹 Clearing SecureStorage...');
      await _secureStorage.delete(AppConstants.authToken);
      await _secureStorage.delete(AppConstants.refressToken);
      await _secureStorage.delete(AppConstants.roleType);
      await _secureStorage.delete(AppConstants.userId);
      await _secureStorage.delete(AppConstants.userName);
      await _secureStorage.delete(AppConstants.userEmail);
      debugPrint('✅ All SecureStorage data cleared');

      // Clear profile data
      await clearProfile();
      isLoading.value = false;

      debugPrint('═══════════════════════════════════════');
      debugPrint('✅ LOGOUT COMPLETED SUCCESSFULLY');
      debugPrint('🔄 Navigating to Role Selection...');
      debugPrint('═══════════════════════════════════════');

      // Navigate to role selection
      Get.offAllNamed(AppRoutes.roleSelectionRoute);

      // Show success message
      await Future.delayed(const Duration(milliseconds: 300));
      Get.snackbar(
        'Success',
        'You have been logged out successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );

    } catch (e, stackTrace) {
      isLoading.value = false;
      debugPrint('═══════════════════════════════════════');
      debugPrint('❌ LOGOUT FAILED');
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');
      debugPrint('═══════════════════════════════════════');

      Get.snackbar(
        'Error',
        'An error occurred during logout. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }

  /// Check if user is a provider
  bool get isProvider => role.value == 'provider';

  /// Check if user is a regular user
  bool get isUser => role.value == 'user';
}

*/





///
///
///
/// todo::: fixing for hte provider
///
///
///
///






// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:manx_mate/core/network/network_caller.dart';
// import 'package:manx_mate/core/config/app_constants.dart';
// import 'package:manx_mate/core/data/secured_storage.dart';
// import 'package:manx_mate/core/network/network_response.dart';
// import 'package:manx_mate/core/utils/api/app_url.dart';
// import 'package:manx_mate/core/routes/app_routes.dart';
// import 'package:manx_mate/core/utils/token_service/token_storage_service.dart';
//
// /// Shared Profile Service - Single Source of Truth for User Profile
// class ProfileService extends GetxService {
//   final NetworkCaller _networkCaller = NetworkCaller();
//   final SecureStorageService _secureStorage = SecureStorageService();
//   final SharedPrefService _sharedPrefService = SharedPrefService();
//
//
//   // Observables - Shared across all screens
//   RxString userId = ''.obs;
//   RxString name = ''.obs;
//   RxString email = ''.obs;
//   RxString profileImage = ''.obs;
//   RxString location = ''.obs;
//   RxString role = ''.obs;
//   RxString phone = ''.obs;
//   RxBool isLoading = false.obs;
//   RxBool isLoggedIn = false.obs;
//   RxBool isProviderProfile = false.obs;
//
//   static ProfileService get instance => Get.find<ProfileService>();
//
//   @override
//   void onInit() {
//     super.onInit();
//     debugPrint('🔄 ProfileService initialized');
//     _initializeService();
//   }
//
//   /// Initialize the service - check login status and load profile
//   Future<void> _initializeService() async {
//     await checkLoginStatus();
//   }
//
//   /// Check if user is logged in and load profile
//   Future<void> checkLoginStatus() async {
//     try {
//       isLoading.value = true;
//
//       // Check if tokens exist in SecureStorage
//       final String? token = await _secureStorage.read(AppConstants.authToken);
//       final String? storedRole = await _secureStorage.read(AppConstants.roleType);
//
//       debugPrint('🔐 Checking login status...');
//       debugPrint('📝 Token exists: ${token != null && token.isNotEmpty}');
//       debugPrint('🎭 Stored role: $storedRole');
//
//       if (token != null && token.isNotEmpty) {
//         isLoggedIn.value = true;
//
//         // Set role from storage immediately (will be updated from API)
//         if (storedRole != null && storedRole.isNotEmpty) {
//           role.value = storedRole;
//           debugPrint('✅ Set initial role from storage: $storedRole');
//         }
//
//         // Load profile data
//         await fetchUserProfile();
//       } else {
//         isLoggedIn.value = false;
//         debugPrint('❌ No auth token found - user not logged in');
//       }
//     } catch (e) {
//       debugPrint('❌ Error checking login status: $e');
//       isLoggedIn.value = false;
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   /// Fetch user profile from API
//   Future<void> fetchUserProfile() async {
//     try {
//       if (!isLoggedIn.value) {
//         debugPrint('⚠️ Not logged in, skipping profile fetch');
//         return;
//       }
//
//       isLoading.value = true;
//
//       debugPrint('═══════════════════════════════════════');
//       debugPrint('👤 FETCHING USER PROFILE');
//       debugPrint('═══════════════════════════════════════');
//
//       final String? token = await _secureStorage.read(AppConstants.authToken);
//
//       if (token == null || token.isEmpty) {
//         debugPrint('❌ No auth token found');
//         isLoading.value = false;
//         return;
//       }
//
//       debugPrint('📤 API REQUEST');
//       debugPrint('URL: ${AppUrl.selfProfileUrl}');
//       debugPrint('🔑 Token: ${token.substring(0, 30)}...');
//
//       final NetworkResponse response = await _networkCaller.getRequest(
//         AppUrl.selfProfileUrl,
//         headers: {
//           'Authorization': 'Bearer $token',
//         },
//       );
//
//       debugPrint('───────────────────────────────────────');
//       debugPrint('📥 API RESPONSE');
//       debugPrint('Status Code: ${response.statusCode}');
//       debugPrint('Is Success: ${response.isSuccess}');
//       debugPrint('───────────────────────────────────────');
//
//       if (response.isSuccess && response.jsonResponse != null) {
//         final bool success = response.jsonResponse!['success'] ?? false;
//         final Map<String, dynamic>? data = response.jsonResponse!['data'];
//
//         debugPrint('✅ Profile Fetch Success: $success');
//
//         if (success && data != null) {
//           // Extract and update all profile data
//           userId.value = data['_id']?.toString() ?? '';
//           name.value = data['name']?.toString() ?? 'Guest User';
//           email.value = data['email']?.toString() ?? '';
//           profileImage.value = data['image']?.toString() ?? '';
//           location.value = data['location']?.toString() ?? '';
//           phone.value = data['phone']?.toString() ?? '';
//
//           // CRITICAL: Get role from API response
//           final String apiRole = data['role']?.toString()?.toLowerCase() ?? '';
//           if (apiRole.isNotEmpty) {
//             role.value = apiRole;
//             // Update stored role for consistency
//             await _secureStorage.write(AppConstants.roleType, apiRole);
//             debugPrint('✅ Role updated from API: $apiRole');
//           }
//
//           debugPrint('👤 User ID: ${userId.value}');
//           debugPrint('📛 Name: ${name.value}');
//           debugPrint('📧 Email: ${email.value}');
//           debugPrint('📞 Phone: ${phone.value}');
//           debugPrint('📍 Location: ${location.value}');
//           debugPrint('🖼️ Image: ${profileImage.value}');
//           debugPrint('🎭 Role: ${role.value}');
//
//           // Save to SharedPreferences for persistence
//           await _sharedPrefService.saveTokens(
//             accessToken: token,
//             refreshToken: await _secureStorage.read(AppConstants.refressToken) ?? '',
//             userRole: role.value,
//           );
//
//           isLoggedIn.value = true;
//           debugPrint('✅ Profile loaded successfully');
//         } else {
//           _showError('Failed to load profile data');
//           debugPrint('❌ No user data in response');
//         }
//       } else {
//         final String errorMessage = response.jsonResponse?['message'] ??
//             response.errorMessage ??
//             'Failed to load profile';
//
//         debugPrint('❌ Profile Fetch Failed: $errorMessage');
//
//         // If unauthorized, clear login state
//         if (response.statusCode == 401) {
//           debugPrint('🔐 Unauthorized - clearing login data');
//           await logout();
//         } else {
//           _showError(errorMessage);
//         }
//       }
//     } catch (e, stackTrace) {
//       debugPrint('❌ EXCEPTION OCCURRED');
//       debugPrint('Error: $e');
//       debugPrint('StackTrace: $stackTrace');
//       _showError('An unexpected error occurred');
//     } finally {
//       isLoading.value = false;
//       debugPrint('═══════════════════════════════════════');
//     }
//   }
//
//   /// Force refresh profile data
//   Future<void> refreshProfile() async {
//     debugPrint('🔄 Refreshing profile data...');
//     await fetchUserProfile();
//   }
//
//   /// Update profile data locally (for UI updates)
//   void updateProfileData({
//     String? newName,
//     String? newEmail,
//     String? newPhone,
//     String? newLocation,
//     String? newImage,
//   }) {
//     if (newName != null && newName.isNotEmpty) name.value = newName;
//     if (newEmail != null && newEmail.isNotEmpty) email.value = newEmail;
//     if (newPhone != null && newPhone.isNotEmpty) phone.value = newPhone;
//     if (newLocation != null) location.value = newLocation;
//     if (newImage != null && newImage.isNotEmpty) profileImage.value = newImage;
//
//     debugPrint('🔄 Profile data updated locally');
//   }
//
//   /// Get full image URL for profile picture
//   String getImageUrl() {
//     if (profileImage.value.isEmpty) return '';
//     final String url = AppUrl.getUserProfileImageUrl(profileImage.value);
//     debugPrint('🖼️ Profile image URL: $url');
//     return url;
//   }
//
//   /// Get display name
//   String getDisplayName() {
//     if (name.value.isEmpty) return 'Guest User';
//     return name.value;
//   }
//
//   /// Format location for display
//   String getDisplayLocation() {
//     if (location.value.isEmpty) return 'Location not set';
//     return location.value;
//   }
//
//   /// Get display phone
//   String getDisplayPhone() {
//     if (phone.value.isEmpty) return 'Phone not set';
//     return phone.value;
//   }
//
//   /// Show error message
//   void _showError(String message) {
//     Get.snackbar(
//       'Error',
//       message,
//       backgroundColor: Colors.red,
//       colorText: Colors.white,
//       snackPosition: SnackPosition.TOP,
//     );
//   }
//
//   /// Save login data after successful login
//   Future<void> saveLoginData({
//     required String accessToken,
//     required String refreshToken,
//     required String userRole,
//     required String userId,
//     String? userName,
//     String? userEmail,
//   }) async {
//     try {
//       debugPrint('💾 Saving login data...');
//
//       // Save to SecureStorage (for API calls)
//       await _secureStorage.write(AppConstants.authToken, accessToken);
//       await _secureStorage.write(AppConstants.refressToken, refreshToken);
//       await _secureStorage.write(AppConstants.roleType, userRole.toLowerCase());
//       await _secureStorage.write(AppConstants.userId, userId);
//
//       if (userName != null) {
//         await _secureStorage.write(AppConstants.userName, userName);
//       }
//
//       if (userEmail != null) {
//         await _secureStorage.write(AppConstants.userEmail, userEmail);
//       }
//
//       // Save to SharedPreferences (for persistence)
//       await _sharedPrefService.saveTokens(
//         accessToken: accessToken,
//         refreshToken: refreshToken,
//         userRole: userRole.toLowerCase(),
//       );
//
//       // Update ProfileService state
//       role.value = userRole.toLowerCase();
//       this.userId.value = userId;
//       if (userName != null) name.value = userName;
//       if (userEmail != null) email.value = userEmail;
//
//       isLoggedIn.value = true;
//
//       debugPrint('✅ Login data saved successfully');
//       debugPrint('🎭 Role: ${role.value}');
//       debugPrint('👤 User ID: ${this.userId.value}');
//       debugPrint('📛 Name: ${name.value}');
//       debugPrint('📧 Email: ${email.value}');
//
//       // Fetch complete profile data from API
//       await fetchUserProfile();
//
//     } catch (e) {
//       debugPrint('❌ Error saving login data: $e');
//       _showError('Failed to save login data');
//     }
//   }
//
//   /// Clear all profile data (for logout)
//   Future<void> clearProfile() async {
//     userId.value = '';
//     name.value = '';
//     email.value = '';
//     profileImage.value = '';
//     location.value = '';
//     phone.value = '';
//     role.value = '';
//     isLoggedIn.value = false;
//     isProviderProfile.value = false;
//
//     debugPrint('🧹 Profile data cleared');
//   }
//
//   /// Logout the user
//   Future<void> logout() async {
//     try {
//       debugPrint('═══════════════════════════════════════');
//       debugPrint('🚪 LOGGING OUT USER');
//       debugPrint('═══════════════════════════════════════');
//
//       isLoading.value = true;
//
//       // Clear SharedPreferences
//       debugPrint('🧹 Clearing SharedPreferences...');
//       await _sharedPrefService.clearAll();
//       debugPrint('✅ SharedPreferences cleared');
//
//       // Clear SecureStorage
//       debugPrint('🧹 Clearing SecureStorage...');
//       await _secureStorage.delete(AppConstants.authToken);
//       await _secureStorage.delete(AppConstants.refressToken);
//       await _secureStorage.delete(AppConstants.roleType);
//       await _secureStorage.delete(AppConstants.userId);
//       await _secureStorage.delete(AppConstants.userName);
//       await _secureStorage.delete(AppConstants.userEmail);
//       debugPrint('✅ All SecureStorage data cleared');
//
//       // Clear profile data
//       await clearProfile();
//       isLoading.value = false;
//
//       debugPrint('═══════════════════════════════════════');
//       debugPrint('✅ LOGOUT COMPLETED SUCCESSFULLY');
//       debugPrint('🔄 Navigating to Role Selection...');
//       debugPrint('═══════════════════════════════════════');
//
//       // Navigate to role selection
//       Get.offAllNamed(AppRoutes.roleSelectionRoute);
//
//       // Show success message
//       await Future.delayed(const Duration(milliseconds: 300));
//       Get.snackbar(
//         'Success',
//         'You have been logged out successfully',
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//         snackPosition: SnackPosition.TOP,
//         duration: const Duration(seconds: 2),
//         icon: const Icon(Icons.check_circle, color: Colors.white),
//       );
//
//     } catch (e, stackTrace) {
//       isLoading.value = false;
//       debugPrint('═══════════════════════════════════════');
//       debugPrint('❌ LOGOUT FAILED');
//       debugPrint('Error: $e');
//       debugPrint('StackTrace: $stackTrace');
//       debugPrint('═══════════════════════════════════════');
//
//       Get.snackbar(
//         'Error',
//         'An error occurred during logout. Please try again.',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         snackPosition: SnackPosition.TOP,
//         duration: const Duration(seconds: 3),
//         icon: const Icon(Icons.error, color: Colors.white),
//       );
//     }
//   }
//
//   /// Check if user is a provider
//   bool get isProvider => role.value == 'provider';
//
//   /// Check if user is a regular user
//   bool get isUser => role.value == 'user';
//
//   /// Set profile mode (provider or user)
//   void setProviderProfileMode(bool isProviderMode) {
//     isProviderProfile.value = isProviderMode;
//   }
// }


///
///---------->>> todo:: UPPER code is working but has some error trying to fix at bellow::
///
///




import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/network/network_caller.dart';
import 'package:manx_mate/core/config/app_constants.dart';
import 'package:manx_mate/core/data/secured_storage.dart';
import 'package:manx_mate/core/network/network_response.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';
import 'package:manx_mate/core/routes/app_routes.dart';
import 'package:manx_mate/core/utils/token_service/token_storage_service.dart';

/// Shared Profile Service - Single Source of Truth for User Profile
class ProfileService extends GetxService {
  final NetworkCaller _networkCaller = NetworkCaller();
  final SecureStorageService _secureStorage = SecureStorageService();
  final SharedPrefService _sharedPrefService = SharedPrefService();

  // FIXED: Use explicit Rx types and initialize with .obs
  final RxString userId = RxString('');
  final RxString name = RxString('');
  final RxString email = RxString('');
  final RxString profileImage = RxString('');
  final RxString location = RxString('');
  final RxString role = RxString('');
  final RxString phone = RxString('');
  final RxBool isLoading = RxBool(false);
  final RxBool isLoggedIn = RxBool(false);
  final RxBool isProviderProfile = RxBool(false);

  static ProfileService get instance => Get.find<ProfileService>();

  @override
  void onInit() {
    super.onInit();
    debugPrint('🔄 ProfileService initialized');
    // Don't call async methods directly in onInit
    // Use onReady instead
  }

  @override
  void onReady() {
    super.onReady();
    _initializeService();
  }

  /// Initialize the service - check login status and load profile
  Future<void> _initializeService() async {
    await checkLoginStatus();
  }

  /// Check if user is logged in and load profile
  Future<void> checkLoginStatus() async {
    try {
      isLoading.value = true;

      // Check if tokens exist in SecureStorage
      final String? token = await _secureStorage.read(AppConstants.authToken);
      final String? storedRole = await _secureStorage.read(AppConstants.roleType);

      debugPrint('🔐 Checking login status...');
      debugPrint('📝 Token exists: ${token != null && token.isNotEmpty}');
      debugPrint('🎭 Stored role: $storedRole');

      if (token != null && token.isNotEmpty) {
        isLoggedIn.value = true;

        // Set role from storage immediately (will be updated from API)
        if (storedRole != null && storedRole.isNotEmpty) {
          role.value = storedRole;
          debugPrint('✅ Set initial role from storage: $storedRole');
        }

        // Load profile data
        await fetchUserProfile();
      } else {
        isLoggedIn.value = false;
        debugPrint('❌ No auth token found - user not logged in');
      }
    } catch (e) {
      debugPrint('❌ Error checking login status: $e');
      isLoggedIn.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch user profile from API
  Future<void> fetchUserProfile() async {
    try {
      if (!isLoggedIn.value) {
        debugPrint('⚠️ Not logged in, skipping profile fetch');
        return;
      }

      isLoading.value = true;

      debugPrint('═══════════════════════════════════════');
      debugPrint('👤 FETCHING USER PROFILE');
      debugPrint('═══════════════════════════════════════');

      final String? token = await _secureStorage.read(AppConstants.authToken);

      if (token == null || token.isEmpty) {
        debugPrint('❌ No auth token found');
        isLoading.value = false;
        isLoggedIn.value = false;
        return;
      }

      debugPrint('📤 API REQUEST');
      debugPrint('URL: ${AppUrl.selfProfileUrl}');

      final NetworkResponse response = await _networkCaller.getRequest(
        AppUrl.selfProfileUrl,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('───────────────────────────────────────');
      debugPrint('📥 API RESPONSE');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Is Success: ${response.isSuccess}');
      debugPrint('Response JSON: ${response.jsonResponse}');
      debugPrint('───────────────────────────────────────');

      if (response.isSuccess && response.jsonResponse != null) {
        final bool success = response.jsonResponse!['success'] ?? false;
        final Map<String, dynamic>? data = response.jsonResponse!['data'];

        debugPrint('✅ Profile Fetch Success: $success');

        if (success && data != null) {
          // FIXED: Always use .value for Rx variables
          userId.value = data['_id']?.toString() ?? '';
          name.value = data['name']?.toString() ?? 'Guest User';
          email.value = data['email']?.toString() ?? '';
          profileImage.value = data['image']?.toString() ?? '';
          location.value = data['location']?.toString() ?? '';
          phone.value = data['phone']?.toString() ?? '';

          // CRITICAL FIX: Handle role assignment safely
          final dynamic roleData = data['role'];
          if (roleData != null) {
            if (roleData is String) {
              role.value = roleData.toLowerCase();
            } else if (roleData is int) {
              role.value = roleData.toString().toLowerCase();
            } else {
              role.value = roleData.toString().toLowerCase();
            }
          } else {
            role.value = 'user'; // Default value
          }

          // Update stored role for consistency
          await _secureStorage.write(AppConstants.roleType, role.value);
          debugPrint('✅ Role updated from API: ${role.value}');

          debugPrint('👤 User ID: ${userId.value}');
          debugPrint('📛 Name: ${name.value}');
          debugPrint('📧 Email: ${email.value}');
          debugPrint('📞 Phone: ${phone.value}');
          debugPrint('📍 Location: ${location.value}');
          debugPrint('🖼️ Image: ${profileImage.value}');
          debugPrint('🎭 Role: ${role.value}');

          // Save to SharedPreferences for persistence
          await _sharedPrefService.saveTokens(
            accessToken: token,
            refreshToken: await _secureStorage.read(AppConstants.refressToken) ?? '',
            userRole: role.value,
          );

          isLoggedIn.value = true;
          debugPrint('✅ Profile loaded successfully');
        } else {
          debugPrint('❌ No user data in response');
          _showError('Failed to load profile data');
        }
      } else {
        final String errorMessage = response.jsonResponse?['message'] ??
            response.errorMessage ??
            'Failed to load profile';

        debugPrint('❌ Profile Fetch Failed: $errorMessage');

        // If unauthorized, clear login state
        if (response.statusCode == 401) {
          debugPrint('🔐 Unauthorized - clearing login data');
          await logout();
        } else {
          _showError(errorMessage);
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ EXCEPTION OCCURRED');
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');
      _showError('An unexpected error occurred');
    } finally {
      isLoading.value = false;
      debugPrint('═══════════════════════════════════════');
    }
  }

  /// Force refresh profile data
  Future<void> refreshProfile() async {
    debugPrint('🔄 Refreshing profile data...');
    await fetchUserProfile();
  }

  /// Update profile data locally (for UI updates)
  void updateProfileData({
    String? newName,
    String? newEmail,
    String? newPhone,
    String? newLocation,
    String? newImage,
  }) {
    if (newName != null && newName.isNotEmpty) name.value = newName;
    if (newEmail != null && newEmail.isNotEmpty) email.value = newEmail;
    if (newPhone != null && newPhone.isNotEmpty) phone.value = newPhone;
    if (newLocation != null) location.value = newLocation;
    if (newImage != null && newImage.isNotEmpty) profileImage.value = newImage;

    debugPrint('🔄 Profile data updated locally');
  }

  /// Get full image URL for profile picture
  String getImageUrl() {
    if (profileImage.value.isEmpty) return '';
    final String url = AppUrl.getUserProfileImageUrl(profileImage.value);
    debugPrint('🖼️ Profile image URL: $url');
    return url;
  }

  /// Get display name
  String getDisplayName() {
    if (name.value.isEmpty) return 'Guest User';
    return name.value;
  }

  /// Format location for display
  String getDisplayLocation() {
    if (location.value.isEmpty) return 'Location not set';
    return location.value;
  }

  /// Get display phone
  String getDisplayPhone() {
    if (phone.value.isEmpty) return 'Phone not set';
    return phone.value;
  }

  /// Show error message
  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  /// Save login data after successful login
  Future<void> saveLoginData({
    required String accessToken,
    required String refreshToken,
    required String userRole,
    required String userId,
    String? userName,
    String? userEmail,
  }) async {
    try {
      debugPrint('💾 Saving login data...');

      // Save to SecureStorage (for API calls)
      await _secureStorage.write(AppConstants.authToken, accessToken);
      await _secureStorage.write(AppConstants.refressToken, refreshToken);
      await _secureStorage.write(AppConstants.roleType, userRole.toLowerCase());
      await _secureStorage.write(AppConstants.userId, userId);

      if (userName != null) {
        await _secureStorage.write(AppConstants.userName, userName);
      }

      if (userEmail != null) {
        await _secureStorage.write(AppConstants.userEmail, userEmail);
      }

      // Save to SharedPreferences (for persistence)
      await _sharedPrefService.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        userRole: userRole.toLowerCase(),
      );

      // Update ProfileService state - USE .value
      role.value = userRole.toLowerCase();
      this.userId.value = userId;
      if (userName != null) name.value = userName;
      if (userEmail != null) email.value = userEmail;

      isLoggedIn.value = true;

      debugPrint('✅ Login data saved successfully');
      debugPrint('🎭 Role: ${role.value}');
      debugPrint('👤 User ID: ${this.userId.value}');
      debugPrint('📛 Name: ${name.value}');
      debugPrint('📧 Email: ${email.value}');

      // Fetch complete profile data from API
      await fetchUserProfile();

    } catch (e) {
      debugPrint('❌ Error saving login data: $e');
      _showError('Failed to save login data');
    }
  }

  /// Clear all profile data (for logout)
  Future<void> clearProfile() async {
    userId.value = '';
    name.value = '';
    email.value = '';
    profileImage.value = '';
    location.value = '';
    phone.value = '';
    role.value = 'user'; // Set default role
    isLoggedIn.value = false;
    isProviderProfile.value = false;

    debugPrint('🧹 Profile data cleared');
  }

  /// Logout the user
  Future<void> logout() async {
    try {
      debugPrint('═══════════════════════════════════════');
      debugPrint('🚪 LOGGING OUT USER');
      debugPrint('═══════════════════════════════════════');

      isLoading.value = true;

      // Clear SharedPreferences
      debugPrint('🧹 Clearing SharedPreferences...');
      await _sharedPrefService.clearAll();
      debugPrint('✅ SharedPreferences cleared');

      // Clear SecureStorage
      debugPrint('🧹 Clearing SecureStorage...');
      await _secureStorage.delete(AppConstants.authToken);
      await _secureStorage.delete(AppConstants.refressToken);
      await _secureStorage.delete(AppConstants.roleType);
      await _secureStorage.delete(AppConstants.userId);
      await _secureStorage.delete(AppConstants.userName);
      await _secureStorage.delete(AppConstants.userEmail);
      debugPrint('✅ All SecureStorage data cleared');

      // Clear profile data
      await clearProfile();
      isLoading.value = false;

      debugPrint('═══════════════════════════════════════');
      debugPrint('✅ LOGOUT COMPLETED SUCCESSFULLY');
      debugPrint('🔄 Navigating to Role Selection...');
      debugPrint('═══════════════════════════════════════');

      // Navigate to role selection
      Get.offAllNamed(AppRoutes.roleSelectionRoute);

      // Show success message
      await Future.delayed(const Duration(milliseconds: 300));
      Get.snackbar(
        'Success',
        'You have been logged out successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );

    } catch (e, stackTrace) {
      isLoading.value = false;
      debugPrint('═══════════════════════════════════════');
      debugPrint('❌ LOGOUT FAILED');
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');
      debugPrint('═══════════════════════════════════════');

      Get.snackbar(
        'Error',
        'An error occurred during logout. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }

  /// Check if user is a provider
  bool get isProvider => role.value == 'provider';

  /// Check if user is a regular user
  bool get isUser => role.value == 'user';

  /// Set profile mode (provider or user)
  void setProviderProfileMode(bool isProviderMode) {
    isProviderProfile.value = isProviderMode;
  }
}









