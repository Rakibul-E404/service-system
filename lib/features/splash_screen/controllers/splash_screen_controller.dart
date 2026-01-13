/**
import 'package:get/get.dart';
import 'package:manx_mate/core/routes/app_routes.dart';
import 'package:manx_mate/core/utils/token_service/token_storage_service.dart';

class SplashScreenController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    navigateToNextScreen();
  }

  Future<void> navigateToNextScreen() async {
    // Delay for splash screen display
    await Future.delayed(const Duration(seconds: 2));

    // Check login status
    final SharedPrefService sharedPrefService = SharedPrefService();
    bool isLoggedIn = await sharedPrefService.isLoggedIn();

    if (isLoggedIn) {
      // Navigate to main screen if logged in
      print('✅ User is logged in - Navigating to MainBottomNav');
      Get.offNamed(AppRoutes.mainBottomNavPage);
    } else {
      // Navigate to role selection if not logged in
      print('❌ User is not logged in - Navigating to Role Selection');
      Get.offNamed(AppRoutes.roleSelectionRoute);
    }
  }
}
*/






///
///
///
/// todo::: fixing the role issue
///
///
///
///






/**

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/routes/app_routes.dart';
import 'package:manx_mate/core/utils/token_service/token_storage_service.dart';
import 'package:manx_mate/features/profile/controllers/profile_controller.dart';
// import 'package:manx_mate/features/main_bottom_nav/screens/main_bottom_nav_screen.dart';
// import 'package:manx_mate/features/main_bottom_nav/screens/provider_main_bottom_nav_screen.dart';

import '../../mainBottomNav/screens/mainbottomnav_screen.dart';
import '../../mainBottomNav/screens/provider_main_bottom_nav.dart';

class SplashScreenController extends GetxController {
  final SharedPrefService _sharedPrefService = SharedPrefService();
  final _isLoading = false.obs;
  final _errorMessage = ''.obs;
  Timer? _navigationTimer;
  bool _hasNavigated = false;

  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    print('🚀 SplashScreenController initialized');
  }

  @override
  void onReady() {
    super.onReady();
    print('🎯 SplashScreenController ready - starting navigation process');
    _startNavigationProcess();
  }

  @override
  void onClose() {
    _navigationTimer?.cancel();
    print('👋 SplashScreenController disposed');
    super.onClose();
  }

  void _startNavigationProcess() async {
    if (_hasNavigated) {
      print('⚠️ Navigation already completed, skipping');
      return;
    }

    print('═══════════════════════════════════════');
    print('🚀 SPLASH SCREEN - Starting Navigation');
    print('═══════════════════════════════════════');

    try {
      // Start with a minimum splash duration
      await Future.delayed(const Duration(seconds: 2));

      // Check authentication status
      await _checkAuthenticationAndNavigate();
    } catch (e, stackTrace) {
      print('❌ CRITICAL ERROR in splash navigation');
      print('Error: $e');
      print('Stack Trace: $stackTrace');
      _handleNavigationError('Failed to initialize app. Please try again.');
    }
  }

  Future<void> _checkAuthenticationAndNavigate() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      print('🔐 Checking authentication status...');

      // Check if user is logged in
      final bool isLoggedIn = await _sharedPrefService.isLoggedIn();
      print('📊 Login Status: $isLoggedIn');

      if (!isLoggedIn) {
        print('👤 User not logged in - Redirecting to role selection');
        await _navigateToRoleSelection();
        return;
      }

      // User is logged in, check role
      print('✅ User is logged in - Determining user role...');
      await _determineRoleAndNavigate();

    } catch (e) {
      print('❌ Error checking authentication: $e');
      _handleNavigationError('Authentication check failed');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _determineRoleAndNavigate() async {
    try {
      // Step 1: Try to get role from SharedPreferences (fastest)
      print('⚡ Attempting fast role check from cache...');
      final String? cachedRole = await _sharedPrefService.getUserRole();

      if (cachedRole != null && cachedRole.isNotEmpty) {
        print('🎭 Cached role found: $cachedRole');
        await _navigateBasedOnRole(cachedRole);
        return;
      }

      // Step 2: Fetch fresh profile data
      print('🔄 No cached role found, fetching fresh profile...');
      await _fetchProfileAndNavigate();

    } catch (e) {
      print('❌ Error determining role: $e');
      await _handleRoleDeterminationFailure();
    }
  }

  Future<void> _fetchProfileAndNavigate() async {
    try {
      // Show loading overlay
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Initialize ProfileController if not already
      ProfileController profileController;
      if (Get.isRegistered<ProfileController>()) {
        profileController = Get.find<ProfileController>();
      } else {
        profileController = Get.put(ProfileController());
      }

      // Fetch user profile
      await profileController.fetchUserProfile();

      // Close loading dialog
      Get.back();

      // Get role from ProfileController
      final String role = profileController.role.value.toLowerCase();
      print('🎭 Role from API: $role');

      if (role.isEmpty) {
        print('⚠️ Empty role returned from API');
        throw Exception('User role not available');
      }

      // Cache the role for future use
      // await _sharedPrefService.saveUserRole(role);
      print('💾 Role cached successfully: $role');

      // Navigate based on role
      await _navigateBasedOnRole(role);

    } catch (e) {
      Get.back(); // Close loading dialog if still open
      print('❌ Failed to fetch profile: $e');
      throw e;
    }
  }

  Future<void> _navigateBasedOnRole(String role) async {
    if (_hasNavigated) return;
    _hasNavigated = true;

    print('═══════════════════════════════════════');
    print('🎯 NAVIGATING BASED ON ROLE: $role');
    print('═══════════════════════════════════════');

    // Clear any existing timers
    _navigationTimer?.cancel();

    // Use a timer to ensure navigation happens in the next frame
    _navigationTimer = Timer(const Duration(milliseconds: 100), () {
      try {
        switch (role.toLowerCase()) {
          case 'provider':
            print('👨‍💼 PROVIDER DETECTED');
            print('📱 Navigating to ProviderMainBottomNavScreen');
            _navigateToProviderBottomNav();
            break;

          case 'user':
          case 'customer':
          case 'client':
            print('👤 CUSTOMER DETECTED');
            print('📱 Navigating to MainBottomNavScreen');
            _navigateToCustomerBottomNav();
            break;

          case 'admin':
            print('👑 ADMIN DETECTED');
            print('📱 Navigating to MainBottomNavScreen (admin)');
            _navigateToCustomerBottomNav();
            break;

          default:
            print('⚠️ UNKNOWN ROLE: $role');
            print('📱 Defaulting to customer navigation');
            _navigateToCustomerBottomNav();
            break;
        }
      } catch (e) {
        print('❌ Navigation error: $e');
        _navigateToRoleSelection();
      }
    });
  }

  Future<void> _handleRoleDeterminationFailure() async {
    print('🔄 Attempting fallback navigation...');

    try {
      // Check if we have a valid token
      final String? token = await _sharedPrefService.getAccessToken();

      if (token != null && token.isNotEmpty) {
        print('🔑 Valid token exists, defaulting to customer view');
        await _navigateBasedOnRole('user');
      } else {
        print('❌ No valid token found');
        await _navigateToRoleSelection();
      }
    } catch (e) {
      print('❌ Fallback also failed: $e');
      await _navigateToRoleSelection();
    }
  }

  void _navigateToProviderBottomNav() {
    print('🎬 Direct navigation to ProviderMainBottomNavScreen');
    Get.offAll(() => const ProviderMainBottomNavScreen(),
    //     duration: const Duration(milliseconds: 500),
        // curve: Curves.easeInOut
    );
  }

  void _navigateToCustomerBottomNav() {
    print('🎬 Direct navigation to MainBottomNavScreen');
    Get.offAll(() => const MainBottomNavScreen(),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut);
  }

  Future<void> _navigateToRoleSelection() async {
    if (_hasNavigated) return;
    _hasNavigated = true;

    print('🎬 Navigating to Role Selection');
    Get.offAllNamed(AppRoutes.roleSelectionRoute,
        // duration: const Duration(milliseconds: 500),
        // curve: Curves.easeInOut
        );
  }

  void _handleNavigationError(String message) {
    _errorMessage.value = message;
    print('❌ Navigation Error: $message');

    // Show error dialog
    Get.dialog(
      AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              _navigateToRoleSelection();
            },
            child: const Text('Go to Login'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _startNavigationProcess(); // Retry
            },
            child: const Text('Retry'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // Method to manually trigger navigation (for testing)
  Future<void> retryNavigation() async {
    print('🔄 Manual retry triggered');
    _hasNavigated = false;
    _errorMessage.value = '';
    // await _startNavigationProcess();
  }
}*/



///
///
/// todo:  Upper is somethign wrong ,, trying to fix bellow::
///
///
///



import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/routes/app_routes.dart';
import 'package:manx_mate/core/utils/token_service/token_storage_service.dart';
import 'package:manx_mate/features/profile/controllers/profile_controller.dart';
import '../../mainBottomNav/screens/mainbottomnav_screen.dart';
import '../../mainBottomNav/screens/provider_main_bottom_nav.dart';

class SplashScreenController extends GetxController {
  final SharedPrefService _sharedPrefService = SharedPrefService();

  // Use .obs for proper Rx types
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  Timer? _navigationTimer;
  bool _hasNavigated = false;

  @override
  void onInit() {
    super.onInit();
    print('🚀 SplashScreenController initialized');
  }

  @override
  void onReady() {
    super.onReady();
    print('🎯 SplashScreenController ready - starting navigation process');
    _startNavigationProcess();
  }

  @override
  void onClose() {
    _navigationTimer?.cancel();
    print('👋 SplashScreenController disposed');
    super.onClose();
  }

  void _startNavigationProcess() async {
    if (_hasNavigated) {
      print('⚠️ Navigation already completed, skipping');
      return;
    }

    print('═══════════════════════════════════════');
    print('🚀 SPLASH SCREEN - Starting Navigation');
    print('═══════════════════════════════════════');

    try {
      // Start with a minimum splash duration
      await Future.delayed(const Duration(seconds: 2));

      // Check authentication status
      await _checkAuthenticationAndNavigate();
    } catch (e, stackTrace) {
      print('❌ CRITICAL ERROR in splash navigation');
      print('Error: $e');
      print('Stack Trace: $stackTrace');
      _handleNavigationError('Failed to initialize app. Please try again.');
    }
  }

  Future<void> _checkAuthenticationAndNavigate() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('🔐 Checking authentication status...');

      // Check if user is logged in
      final bool isLoggedIn = await _sharedPrefService.isLoggedIn();
      print('📊 Login Status: $isLoggedIn');

      if (!isLoggedIn) {
        print('👤 User not logged in - Redirecting to role selection');
        _navigateToRoleSelection();
        return;
      }

      // User is logged in, check role
      print('✅ User is logged in - Determining user role...');
      await _determineRoleAndNavigate();

    } catch (e) {
      print('❌ Error checking authentication: $e');
      _handleNavigationError('Authentication check failed');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _determineRoleAndNavigate() async {
    try {
      // Step 1: Try to get role from SharedPreferences (fastest)
      print('⚡ Attempting fast role check from cache...');
      final String? cachedRole = await _sharedPrefService.getUserRole();

      if (cachedRole != null && cachedRole.isNotEmpty) {
        print('🎭 Cached role found: $cachedRole');
        _navigateBasedOnRole(cachedRole);
        return;
      }

      // Step 2: Fetch fresh profile data
      print('🔄 No cached role found, fetching fresh profile...');
      await _fetchProfileAndNavigate();

    } catch (e) {
      print('❌ Error determining role: $e');
      _handleRoleDeterminationFailure();
    }
  }

  Future<void> _fetchProfileAndNavigate() async {
    try {
      // Show loading overlay
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Initialize ProfileController if not already
      ProfileController profileController;
      if (Get.isRegistered<ProfileController>()) {
        profileController = Get.find<ProfileController>();
      } else {
        profileController = Get.put(ProfileController());
      }

      // Fetch user profile
      await profileController.fetchUserProfile();

      // Close loading dialog
      Get.back();

      // Get role from ProfileController
      final String role = profileController.role.value.toLowerCase();
      print('🎭 Role from API: $role');

      if (role.isEmpty) {
        print('⚠️ Empty role returned from API');
        throw Exception('User role not available');
      }

      // Cache the role for future use
      await _sharedPrefService.saveUserRole(role);
      print('💾 Role cached successfully: $role');

      // Navigate based on role
      _navigateBasedOnRole(role);

    } catch (e) {
      // Ensure dialog is closed if still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      print('❌ Failed to fetch profile: $e');
      _handleRoleDeterminationFailure();
    }
  }

  void _navigateBasedOnRole(String role) {
    if (_hasNavigated) return;
    _hasNavigated = true;

    print('═══════════════════════════════════════');
    print('🎯 NAVIGATING BASED ON ROLE: $role');
    print('═══════════════════════════════════════');

    // Clear any existing timers
    _navigationTimer?.cancel();

    // Use a timer to ensure navigation happens in the next frame
    _navigationTimer = Timer(const Duration(milliseconds: 100), () {
      try {
        switch (role.toLowerCase()) {
          case 'provider':
            print('👨‍💼 PROVIDER DETECTED');
            print('📱 Navigating to ProviderMainBottomNavScreen');
            _navigateToProviderBottomNav();
            break;

          case 'user':
          case 'customer':
          case 'client':
            print('👤 CUSTOMER DETECTED');
            print('📱 Navigating to MainBottomNavScreen');
            _navigateToCustomerBottomNav();
            break;

          case 'admin':
            print('👑 ADMIN DETECTED');
            print('📱 Navigating to MainBottomNavScreen (admin)');
            _navigateToCustomerBottomNav();
            break;

          default:
            print('⚠️ UNKNOWN ROLE: $role');
            print('📱 Defaulting to customer navigation');
            _navigateToCustomerBottomNav();
            break;
        }
      } catch (e) {
        print('❌ Navigation error: $e');
        _navigateToRoleSelection();
      }
    });
  }

  Future<void> _handleRoleDeterminationFailure() async {
    print('🔄 Attempting fallback navigation...');

    try {
      // Check if we have a valid token
      final String? token = await _sharedPrefService.getAccessToken();

      if (token != null && token.isNotEmpty) {
        print('🔑 Valid token exists, defaulting to customer view');
        _navigateBasedOnRole('user');
      } else {
        print('❌ No valid token found');
        _navigateToRoleSelection();
      }
    } catch (e) {
      print('❌ Fallback also failed: $e');
      _navigateToRoleSelection();
    }
  }

  void _navigateToProviderBottomNav() {
    print('🎬 Direct navigation to ProviderMainBottomNavScreen');
    Get.offAll(() => const ProviderMainBottomNavScreen());
  }

  void _navigateToCustomerBottomNav() {
    print('🎬 Direct navigation to MainBottomNavScreen');
    Get.offAll(() => const MainBottomNavScreen());
  }

  void _navigateToRoleSelection() {
    if (_hasNavigated) return;
    _hasNavigated = true;

    print('🎬 Navigating to Role Selection');
    Get.offAllNamed(AppRoutes.roleSelectionRoute);
  }

  void _handleNavigationError(String message) {
    errorMessage.value = message;
    print('❌ Navigation Error: $message');

    // Show error dialog
    Get.dialog(
      AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              _navigateToRoleSelection();
            },
            child: const Text('Go to Login'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _retryNavigation();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // ADD THIS METHOD - It was missing!
  void _retryNavigation() {
    print('🔄 Manual retry triggered');
    _hasNavigated = false;
    errorMessage.value = '';
    _startNavigationProcess();
  }

  // Public method for UI to call
  void retryNavigation() {
    _retryNavigation();
  }
}


