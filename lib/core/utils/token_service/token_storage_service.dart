/**

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class SharedPrefService {
  static const String _keyAccessToken = 'accessToken';
  static const String _keyRefreshToken = 'refreshToken';
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyUserRole = 'userRole';

  /// Save tokens and set logged in status to true
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String userRole,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyAccessToken, accessToken);
      await prefs.setString(_keyRefreshToken, refreshToken);
      await prefs.setString(_keyUserRole, userRole);
      await prefs.setBool(_keyIsLoggedIn, true);

      debugPrint('✅ Tokens saved successfully');
      debugPrint('📦 Access Token: ${accessToken.substring(0, 20)}...');
      debugPrint('🔄 Refresh Token: ${refreshToken.substring(0, 20)}...');
      debugPrint('🎭 User Role: $userRole');
      debugPrint('🔐 Login Status: true');
    } catch (e) {
      debugPrint('❌ Error saving tokens: $e');
    }
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAccessToken);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRefreshToken);
  }

  /// Get user role
  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserRole);
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    final String? accessToken = prefs.getString(_keyAccessToken);

    // User is logged in only if the flag is true AND token exists
    return isLoggedIn && accessToken != null && accessToken.isNotEmpty;
  }

  /// Clear all stored data (for logout)
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyAccessToken);
      await prefs.remove(_keyRefreshToken);
      await prefs.remove(_keyUserRole);
      await prefs.setBool(_keyIsLoggedIn, false);

      debugPrint('🧹 All tokens and login status cleared from SharedPreferences');
    } catch (e) {
      debugPrint('❌ Error clearing tokens: $e');
      rethrow;
    }
  }

  /// Completely clear all SharedPreferences data
  Future<void> deleteAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      debugPrint('🧹 All SharedPreferences data deleted');
    } catch (e) {
      debugPrint('❌ Error deleting all SharedPreferences: $e');
      rethrow;
    }
  }

  /// Update access token (useful for token refresh)
  Future<void> updateAccessToken(String newAccessToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyAccessToken, newAccessToken);
      debugPrint('🔄 Access token updated');
    } catch (e) {
      debugPrint('❌ Error updating access token: $e');
    }
  }
}





 */



///
///
///
///
/// todo:: with provider Id
///
///
///




import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class SharedPrefService {
  static const String _keyAccessToken = 'accessToken';
  static const String _keyRefreshToken = 'refreshToken';
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyUserRole = 'userRole';
  static const String _keyProviderId = 'providerId';

  /// Save tokens and set logged in status to true
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String userRole,
    String? providerId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyAccessToken, accessToken);
      await prefs.setString(_keyRefreshToken, refreshToken);
      await prefs.setString(_keyUserRole, userRole);
      await prefs.setBool(_keyIsLoggedIn, true);

      if (providerId != null) {
        await prefs.setString(_keyProviderId, providerId);
      }

      debugPrint('✅ Tokens saved successfully');
      debugPrint('📦 Access Token: ${accessToken.substring(0, 20)}...');
      debugPrint('🔄 Refresh Token: ${refreshToken.substring(0, 20)}...');
      debugPrint('🎭 User Role: $userRole');
      if (providerId != null) {
        debugPrint('🆔 Provider ID: $providerId');
      }
      debugPrint('🔐 Login Status: true');
    } catch (e) {
      debugPrint('❌ Error saving tokens: $e');
    }
  }

  /// Save provider ID
  Future<void> saveProviderId(String providerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyProviderId, providerId);
      debugPrint('✅ Provider ID saved: $providerId');
    } catch (e) {
      debugPrint('❌ Error saving provider ID: $e');
    }
  }

  /// Get provider ID
  Future<String?> getProviderId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyProviderId);
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAccessToken);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRefreshToken);
  }

  /// Get user role
  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserRole);
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    final String? accessToken = prefs.getString(_keyAccessToken);

    // User is logged in only if the flag is true AND token exists
    return isLoggedIn && accessToken != null && accessToken.isNotEmpty;
  }

  /// Clear all stored data (for logout)
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyAccessToken);
      await prefs.remove(_keyRefreshToken);
      await prefs.remove(_keyUserRole);
      await prefs.remove(_keyProviderId);
      await prefs.setBool(_keyIsLoggedIn, false);

      debugPrint('🧹 All tokens and login status cleared from SharedPreferences');
    } catch (e) {
      debugPrint('❌ Error clearing tokens: $e');
      rethrow;
    }
  }

  /// Completely clear all SharedPreferences data
  Future<void> deleteAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      debugPrint('🧹 All SharedPreferences data deleted');
    } catch (e) {
      debugPrint('❌ Error deleting all SharedPreferences: $e');
      rethrow;
    }
  }

  /// Update access token (useful for token refresh)
  Future<void> updateAccessToken(String newAccessToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyAccessToken, newAccessToken);
      debugPrint('🔄 Access token updated');
    } catch (e) {
      debugPrint('❌ Error updating access token: $e');
    }
  }
}

