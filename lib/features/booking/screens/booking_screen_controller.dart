/**
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


/// ============================================================================
/// CONTROLLER FOR PENDING BOOKINGS
/// ============================================================================
class PendingBookingsController extends GetxController {
  // Observable variables
  var isLoading = false.obs;
  var pendingBookings = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;

  final String baseUrl = 'https://d7001.sobhoy.com/api/v1';

  // Get authorization token
  Future<String?> _getAuthToken() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      print('🔐 Token retrieved: ${token != null ? '${token.substring(0, 20)}...' : 'null'}');
      return token;
    } catch (e) {
      print('❌ Error getting auth token: $e');
      return null;
    }
  }

  // Fetch pending bookings from API
  Future<void> fetchPendingBookings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      pendingBookings.clear(); // Clear previous data

      // Get authorization token
      final token = await _getAuthToken();
      if (token == null) {
        errorMessage.value = 'Authentication required. Please login again.';
        isLoading.value = false;
        return;
      }

      // API endpoint for pending bookings
      final url = Uri.parse('$baseUrl/booking/user?status=pending');
      print('🌐 Fetching pending bookings from: $url');

      // Make GET request with authorization
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      // Handle response
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('✅ Pending Bookings API Response: $jsonData');

        if (jsonData['success'] == true) {
          // Extract bookings from the correct path in response
          final List<dynamic> bookingsData = jsonData['data']['data'] ?? [];
          print('📋 Found ${bookingsData.length} pending bookings');

          pendingBookings.value = bookingsData.cast<Map<String, dynamic>>();
          print('🎯 Loaded ${pendingBookings.length} bookings into controller');
        } else {
          errorMessage.value = jsonData['message'] ?? 'Failed to load pending bookings';
          print('❌ API Error: ${errorMessage.value}');
        }
      } else if (response.statusCode == 401) {
        errorMessage.value = 'Unauthorized. Please login again.';
        print('❌ Unauthorized access');
      } else if (response.statusCode == 404) {
        errorMessage.value = 'API endpoint not found';
        print('❌ Endpoint not found');
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
        print('❌ Server error: ${response.statusCode} - ${response.body}');
      }
    } on http.ClientException catch (e) {
      errorMessage.value = 'Network error. Please check your connection.';
      print('❌ Network error: $e');
    } on FormatException catch (e) {
      errorMessage.value = 'Invalid response from server';
      print('❌ Format error: $e');
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred: $e';
      print('❌ Unexpected error: $e');
      print('❌ Stack trace: ${e.toString()}');
    } finally {
      isLoading.value = false;
      print('🏁 Loading completed. isLoading: ${isLoading.value}');
    }
  }
}

/// ============================================================================
///
/// CONTROLLER FOR COMPLETED BOOKINGS
/// ============================================================================
class CompletedBookingsController extends GetxController {
  // Observable variables
  var isLoading = false.obs;
  var completedBookings = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;

  final String baseUrl = 'https://d7001.sobhoy.com/api/v1';

  // Get authorization token
  Future<String?> _getAuthToken() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      print('🔐 Token retrieved: ${token != null ? '${token.substring(0, 20)}...' : 'null'}');
      return token;
    } catch (e) {
      print('❌ Error getting auth token: $e');
      return null;
    }
  }

  // Fetch completed bookings from API
  Future<void> fetchCompletedBookings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      completedBookings.clear(); // Clear previous data

      // Get authorization token
      final token = await _getAuthToken();
      if (token == null) {
        errorMessage.value = 'Authentication required. Please login again.';
        isLoading.value = false;
        return;
      }

      // API endpoint for completed bookings
      final url = Uri.parse('$baseUrl/booking/user?status=completed');
      print('🌐 Fetching completed bookings from: $url');

      // Make GET request with authorization
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      // Handle response
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('✅ Completed Bookings API Response: $jsonData');

        if (jsonData['success'] == true) {
          // Extract bookings from the correct path in response
          final List<dynamic> bookingsData = jsonData['data']['data'] ?? [];
          print('📋 Found ${bookingsData.length} completed bookings');

          completedBookings.value = bookingsData.cast<Map<String, dynamic>>();
          print('🎯 Loaded ${completedBookings.length} bookings into controller');
        } else {
          errorMessage.value = jsonData['message'] ?? 'Failed to load bookings';
          print('❌ API Error: ${errorMessage.value}');
        }
      } else if (response.statusCode == 401) {
        errorMessage.value = 'Unauthorized. Please login again.';
        print('❌ Unauthorized access');
      } else if (response.statusCode == 404) {
        errorMessage.value = 'API endpoint not found';
        print('❌ Endpoint not found');
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
        print('❌ Server error: ${response.statusCode} - ${response.body}');
      }
    } on http.ClientException catch (e) {
      errorMessage.value = 'Network error. Please check your connection.';
      print('❌ Network error: $e');
    } on FormatException catch (e) {
      errorMessage.value = 'Invalid response from server';
      print('❌ Format error: $e');
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred: $e';
      print('❌ Unexpected error: $e');
      print('❌ Stack trace: ${e.toString()}');
    } finally {
      isLoading.value = false;
      print('🏁 Loading completed. isLoading: ${isLoading.value}');
    }
  }
}


/// ============================================================================
/// CONTROLLER FOR ACTIVE SLOT BOOKINGS
/// ============================================================================

class ActiveSlotBookingsController extends GetxController {
  // Observable variables
  var isLoading = false.obs;
  var activeSlotBookings = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;

  final String baseUrl = 'https://d7001.sobhoy.com/api/v1';

  // Get authorization token
  Future<String?> _getAuthToken() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      print('🔐 Token retrieved: ${token != null ? '${token.substring(0, 20)}...' : 'null'}');
      return token;
    } catch (e) {
      print('❌ Error getting auth token: $e');
      return null;
    }
  }

  // Fetch active slot bookings from API
  Future<void> fetchActiveSlotBookings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      activeSlotBookings.clear(); // Clear previous data

      // Get authorization token
      final token = await _getAuthToken();
      if (token == null) {
        errorMessage.value = 'Authentication required. Please login again.';
        isLoading.value = false;
        return;
      }

      // API endpoint for active slot bookings
      final url = Uri.parse('$baseUrl/booking/user?status=accepted');
      print('🌐 Fetching active slot bookings from: $url');

      // Make GET request with authorization
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      // Handle response
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('✅ Active Slot Bookings API Response: $jsonData');

        if (jsonData['success'] == true) {
          // Extract bookings from the correct path in response
          final List<dynamic> bookingsData = jsonData['data']['data'] ?? [];
          print('📋 Found ${bookingsData.length} active slot bookings');

          activeSlotBookings.value = bookingsData.cast<Map<String, dynamic>>();
          print('🎯 Loaded ${activeSlotBookings.length} bookings into controller');
        } else {
          errorMessage.value = jsonData['message'] ?? 'Failed to load bookings';
          print('❌ API Error: ${errorMessage.value}');
        }
      } else if (response.statusCode == 401) {
        errorMessage.value = 'Unauthorized. Please login again.';
        print('❌ Unauthorized access');
      } else if (response.statusCode == 404) {
        errorMessage.value = 'API endpoint not found';
        print('❌ Endpoint not found');
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
        print('❌ Server error: ${response.statusCode} - ${response.body}');
      }
    } on http.ClientException catch (e) {
      errorMessage.value = 'Network error. Please check your connection.';
      print('❌ Network error: $e');
    } on FormatException catch (e) {
      errorMessage.value = 'Invalid response from server';
      print('❌ Format error: $e');
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred: $e';
      print('❌ Unexpected error: $e');
      print('❌ Stack trace: ${e.toString()}');
    } finally {
      isLoading.value = false;
      print('🏁 Loading completed. isLoading: ${isLoading.value}');
    }
  }
}





*/















// import 'package:get/get.dart';
// import 'package:manx_mate/core/utils/api/app_url.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/material.dart';
// import '../../../core/network/network_caller.dart';
// import '../../../core/network/network_response.dart';
//
// /// Controller for Pending Bookings (Ongoing Slot)
// class PendingBookingsController extends GetxController {
//   var isLoading = false.obs;
//   var pendingBookings = <Map<String, dynamic>>[].obs;
//   var errorMessage = ''.obs;
//
//   final String baseUrl = 'https://d7001.sobhoy.com/api/v1';
//   final NetworkCaller _networkCaller = NetworkCaller();
//
//   Future<String?> _getAuthToken() async {
//     try {
//       final SharedPreferences prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('accessToken');
//       print('🔐 Token retrieved: ${token != null ? '${token.substring(0, 20)}...' : 'null'}');
//       return token;
//     } catch (e) {
//       print('❌ Error getting auth token: $e');
//       return null;
//     }
//   }
//
//   Future<void> fetchPendingBookings() async {
//     try {
//       isLoading.value = true;
//       errorMessage.value = '';
//       pendingBookings.clear();
//
//       final token = await _getAuthToken();
//       if (token == null) {
//         errorMessage.value = 'Authentication required. Please login again.';
//         isLoading.value = false;
//         return;
//       }
//
//       final url = '$baseUrl/booking/user?status=pending';
//       print('🌐 Fetching pending bookings from: $url');
//
//       final NetworkResponse response = await _networkCaller.getRequest(
//         url,
//         headers: {'Authorization': 'Bearer $token'},
//       );
//
//       if (response.isSuccess) {
//         final jsonData = response.jsonResponse;
//         if (jsonData != null && jsonData['success'] == true) {
//           final List<dynamic> bookingsData = jsonData['data']['data'] ?? [];
//           pendingBookings.value = bookingsData.cast<Map<String, dynamic>>();
//           print('✅ Loaded ${pendingBookings.length} pending bookings');
//         } else {
//           errorMessage.value = jsonData?['message'] ?? 'Failed to load bookings';
//         }
//       } else {
//         errorMessage.value = response.errorMessage ?? 'Failed to fetch bookings';
//       }
//     } catch (e) {
//       errorMessage.value = 'An error occurred: $e';
//       print('❌ Error: $e');
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }
//
// /// Controller for Completed Bookings (Past Slot)
// class CompletedBookingsController extends GetxController {
//   var isLoading = false.obs;
//   var completedBookings = <Map<String, dynamic>>[].obs;
//   var errorMessage = ''.obs;
//
//   final String baseUrl = 'https://d7001.sobhoy.com/api/v1';
//   final NetworkCaller _networkCaller = NetworkCaller();
//
//   Future<String?> _getAuthToken() async {
//     try {
//       final SharedPreferences prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('accessToken');
//       return token;
//     } catch (e) {
//       print('❌ Error getting auth token: $e');
//       return null;
//     }
//   }
//
//   Future<void> fetchCompletedBookings() async {
//     try {
//       isLoading.value = true;
//       errorMessage.value = '';
//       completedBookings.clear();
//
//       final token = await _getAuthToken();
//       if (token == null) {
//         errorMessage.value = 'Authentication required. Please login again.';
//         isLoading.value = false;
//         return;
//       }
//
//       final url = '$baseUrl/booking/user?status=completed';
//       print('🌐 Fetching completed bookings from: $url');
//
//       final NetworkResponse response = await _networkCaller.getRequest(
//         url,
//         headers: {'Authorization': 'Bearer $token'},
//       );
//
//       if (response.isSuccess) {
//         final jsonData = response.jsonResponse;
//         if (jsonData != null && jsonData['success'] == true) {
//           final List<dynamic> bookingsData = jsonData['data']['data'] ?? [];
//           completedBookings.value = bookingsData.cast<Map<String, dynamic>>();
//           print('✅ Loaded ${completedBookings.length} completed bookings');
//         } else {
//           errorMessage.value = jsonData?['message'] ?? 'Failed to load bookings';
//         }
//       } else {
//         errorMessage.value = response.errorMessage ?? 'Failed to fetch bookings';
//       }
//     } catch (e) {
//       errorMessage.value = 'An error occurred: $e';
//       print('❌ Error: $e');
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }
//
// /// Controller for Active Slot Bookings (Active Slot)
// class ActiveSlotBookingsController extends GetxController {
//   var isLoading = false.obs;
//   var activeSlotBookings = <Map<String, dynamic>>[].obs;
//   var errorMessage = ''.obs;
//   var isCancelling = false.obs;
//
//   final String baseUrl = AppUrl.baseUrl;
//   final NetworkCaller _networkCaller = NetworkCaller();
//
//   Future<String?> _getAuthToken() async {
//     try {
//       final SharedPreferences prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('accessToken');
//       print('🔐 Token retrieved: ${token != null ? '${token.substring(0, 20)}...' : 'null'}');
//       return token;
//     } catch (e) {
//       print('❌ Error getting auth token: $e');
//       return null;
//     }
//   }
//
//   Future<void> fetchActiveSlotBookings() async {
//     try {
//       isLoading.value = true;
//       errorMessage.value = '';
//       activeSlotBookings.clear();
//
//       final token = await _getAuthToken();
//       if (token == null) {
//         errorMessage.value = 'Authentication required. Please login again.';
//         isLoading.value = false;
//         return;
//       }
//
//       final url = '$baseUrl/booking/user?status=accepted';
//       print('🌐 Fetching active slot bookings from: $url');
//
//       final NetworkResponse response = await _networkCaller.getRequest(
//         url,
//         headers: {'Authorization': 'Bearer $token'},
//       );
//
//       if (response.isSuccess) {
//         final jsonData = response.jsonResponse;
//         if (jsonData != null && jsonData['success'] == true) {
//           final List<dynamic> bookingsData = jsonData['data']['data'] ?? [];
//           activeSlotBookings.value = bookingsData.cast<Map<String, dynamic>>();
//           print('✅ Loaded ${activeSlotBookings.length} active bookings');
//         } else {
//           errorMessage.value = jsonData?['message'] ?? 'Failed to load bookings';
//         }
//       } else {
//         if (response.statusCode == 401) {
//           errorMessage.value = 'Unauthorized. Please login again.';
//         } else {
//           errorMessage.value = response.errorMessage ?? 'Failed to fetch bookings';
//         }
//       }
//     } catch (e) {
//       errorMessage.value = 'An error occurred: $e';
//       print('❌ Error: $e');
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   /// Cancel booking by changing status to "cancelled"
//   /// Cancel booking by changing status to "cancelled"
//   Future<bool> cancelBooking(String bookingId) async {
//     try {
//       isCancelling.value = true;
//       print('🗑️ Starting cancellation for booking: $bookingId');
//
//       final token = await _getAuthToken();
//       if (token == null) {
//         Get.snackbar(
//           'Error',
//           'Authentication required. Please login again.',
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//           snackPosition: SnackPosition.BOTTOM,
//         );
//         return false;
//       }
//
//       // Try different approaches - one of these should work:
//
//       // Option 1: PATCH with status in body (your current approach)
//       final url = '$baseUrl/booking/respond/$bookingId';
//       print('🌐 PATCH request to: $url');
//
//       final NetworkResponse response = await _networkCaller.patchRequest(
//         url,
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json', // Add content type
//         },
//         body: {'status': 'cancelled'},
//       );
//
//       print('📡 Cancel Response status: ${response.statusCode}');
//       print('📦 Cancel Response: ${response.jsonResponse}');
//
//       // If PATCH doesn't work, try DELETE method
//       if (!response.isSuccess) {
//         print('🔄 PATCH failed, trying DELETE method...');
//
//         final deleteUrl = '$baseUrl/booking/$bookingId';
//         final NetworkResponse deleteResponse = await _networkCaller.deleteRequest(
//           deleteUrl,
//           headers: {
//             'Authorization': 'Bearer $token',
//           },
//         );
//
//         if (deleteResponse.isSuccess) {
//           return _handleSuccessfulCancellation(bookingId);
//         } else {
//           _handleCancellationError(deleteResponse);
//           return false;
//         }
//       }
//
//       if (response.isSuccess) {
//         return _handleSuccessfulCancellation(bookingId);
//       } else {
//         _handleCancellationError(response);
//         return false;
//       }
//     } catch (e) {
//       print('❌ Error cancelling booking: $e');
//       Get.snackbar(
//         'Error',
//         'Failed to cancel booking: $e',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       return false;
//     } finally {
//       isCancelling.value = false;
//     }
//   }
//
// // Helper method for successful cancellation
//   bool _handleSuccessfulCancellation(String bookingId) {
//     // Remove the cancelled booking from the list
//     activeSlotBookings.removeWhere((booking) => booking['_id'] == bookingId);
//
//     print('✅ Booking cancelled successfully');
//
//     Get.snackbar(
//       'Success',
//       'Booking cancelled successfully',
//       backgroundColor: Colors.green,
//       colorText: Colors.white,
//       snackPosition: SnackPosition.BOTTOM,
//       duration: const Duration(seconds: 2),
//     );
//
//     // Refresh the list to get updated data
//     fetchActiveSlotBookings();
//
//     return true;
//   }
//
// // Helper method for error handling
//   void _handleCancellationError(NetworkResponse response) {
//     String errorMessage = response.errorMessage ?? 'Failed to cancel booking';
//
//     // Check if there's a more specific message in the response
//     final jsonData = response.jsonResponse;
//     if (jsonData != null && jsonData['message'] != null) {
//       errorMessage = jsonData['message'];
//     }
//
//     Get.snackbar(
//       'Error',
//       errorMessage,
//       backgroundColor: Colors.red,
//       colorText: Colors.white,
//       snackPosition: SnackPosition.BOTTOM,
//     );
//   }
// }


import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:manx_mate/core/utils/api/app_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

/// Controller for Active Slot Bookings (Active Slot)
class ActiveSlotBookingsController extends GetxController {
  var isLoading = false.obs;
  var activeSlotBookings = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;
  var isCancelling = false.obs;

  final String baseUrl = AppUrl.baseUrl;

  Future<String?> _getAuthToken() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      print('🔐 Token retrieved: ${token != null ? 'EXISTS (${token.length} chars)' : 'NULL'}');
      return token;
    } catch (e) {
      print('❌ Error getting auth token: $e');
      return null;
    }
  }

  Future<void> fetchActiveSlotBookings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = await _getAuthToken();
      if (token == null || token.isEmpty) {
        errorMessage.value = 'Authentication required. Please login again.';
        isLoading.value = false;
        return;
      }

      final url = Uri.parse('$baseUrl/booking/user?status=pending');
      print('🌐 Fetching active slot bookings from: $url');
      print('🔑 Using token: ${token.substring(0, 20)}...');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('✅ Parsed JSON: $jsonData');

        if (jsonData['success'] == true) {
          final List<dynamic> bookingsData = jsonData['data']['data'] ?? [];
          activeSlotBookings.value = bookingsData.cast<Map<String, dynamic>>();
          print('✅ Loaded ${activeSlotBookings.length} active bookings');
        } else {
          errorMessage.value = jsonData['message'] ?? 'Failed to load bookings';
          print('❌ API returned success=false: ${errorMessage.value}');
        }
      } else if (response.statusCode == 401) {
        errorMessage.value = 'Unauthorized. Please login again.';
        print('❌ Unauthorized access - token may be expired');
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
        print('❌ Server error: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      errorMessage.value = 'An error occurred: $e';
      print('❌ Error fetching bookings: $e');
      print('❌ Stack trace: $stackTrace');
    } finally {
      isLoading.value = false;
      print('🏁 Fetch completed. isLoading: ${isLoading.value}');
    }
  }

  /// Cancel booking by changing status to "cancelled"
  Future<bool> cancelBooking(String bookingId) async {
    if (bookingId.isEmpty) {
      print('❌ Cannot cancel: bookingId is empty');
      Get.snackbar(
        'Error',
        'Invalid booking ID',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    try {
      isCancelling.value = true;
      print('🗑️ Starting cancellation for booking: $bookingId');

      final token = await _getAuthToken();
      if (token == null || token.isEmpty) {
        print('❌ Cannot cancel: No auth token');
        Get.snackbar(
          'Error',
          'Authentication required. Please login again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      final url = Uri.parse('$baseUrl/booking/respond/$bookingId');
      print('🌐 PATCH request to: $url');
      print('🔑 Using token: ${token.substring(0, 20)}...');
      print('📤 Request body: {"status": "cancelled"}');

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'status': 'cancelled',
        }),
      );

      print('📡 Cancel Response status: ${response.statusCode}');
      print('📦 Cancel Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final jsonData = json.decode(response.body);
          print('✅ Parsed cancel response: $jsonData');

          if (jsonData['success'] == true) {
            // Remove the cancelled booking from the list
            final removedCount = activeSlotBookings.length;
            activeSlotBookings.removeWhere((booking) => booking['_id'] == bookingId);
            print('✅ Booking removed from list. Before: $removedCount, After: ${activeSlotBookings.length}');

            Get.snackbar(
              'Success',
              'Booking cancelled successfully',
              backgroundColor: Colors.green,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 2),
            );

            return true;
          } else {
            final errorMsg = jsonData['message'] ?? 'Failed to cancel booking';
            print('❌ API returned success=false: $errorMsg');
            Get.snackbar(
              'Error',
              errorMsg,
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
            );
            return false;
          }
        } catch (parseError) {
          print('❌ Error parsing response: $parseError');
          Get.snackbar(
            'Error',
            'Invalid response from server',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
          return false;
        }
      } else if (response.statusCode == 401) {
        print('❌ Unauthorized - token may be invalid');
        Get.snackbar(
          'Error',
          'Session expired. Please login again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      } else if (response.statusCode == 404) {
        print('❌ Booking not found');
        Get.snackbar(
          'Error',
          'Booking not found',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      } else {
        print('❌ Server error: ${response.statusCode}');
        Get.snackbar(
          'Error',
          'Server error: ${response.statusCode}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } on http.ClientException catch (e) {
      print('❌ Network error: $e');
      Get.snackbar(
        'Error',
        'Network error. Please check your connection.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (e, stackTrace) {
      print('❌ Unexpected error cancelling booking: $e');
      print('❌ Stack trace: $stackTrace');
      Get.snackbar(
        'Error',
        'Failed to cancel booking: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isCancelling.value = false;
      print('🏁 Cancellation completed. isCancelling: ${isCancelling.value}');
    }
  }
}

/// Controller for Pending Bookings (Ongoing Slot)
class PendingBookingsController extends GetxController {
  var isLoading = false.obs;
  var pendingBookings = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;

  final String baseUrl = 'https://d7001.sobhoy.com/api/v1';

  Future<String?> _getAuthToken() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      return token;
    } catch (e) {
      print('❌ Error getting auth token: $e');
      return null;
    }
  }

  Future<void> fetchPendingBookings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = await _getAuthToken();
      if (token == null) {
        errorMessage.value = 'Authentication required. Please login again.';
        isLoading.value = false;
        return;
      }

      final url = Uri.parse('$baseUrl/booking/user?status=accepted');
      print('🌐 Fetching pending bookings from: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          final List<dynamic> bookingsData = jsonData['data']['data'] ?? [];
          pendingBookings.value = bookingsData.cast<Map<String, dynamic>>();
          print('✅ Loaded ${pendingBookings.length} pending bookings');
        } else {
          errorMessage.value = jsonData['message'] ?? 'Failed to load bookings';
        }
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: $e';
      print('❌ Error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

/// Controller for Completed Bookings (Past Slot)
class CompletedBookingsController extends GetxController {
  var isLoading = false.obs;
  var completedBookings = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;

  final String baseUrl = 'https://d7001.sobhoy.com/api/v1';

  Future<String?> _getAuthToken() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      return token;
    } catch (e) {
      print('❌ Error getting auth token: $e');
      return null;
    }
  }

  Future<void> fetchCompletedBookings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = await _getAuthToken();
      if (token == null) {
        errorMessage.value = 'Authentication required. Please login again.';
        isLoading.value = false;
        return;
      }

      final url = Uri.parse('$baseUrl/booking/user?status=completed');
      print('🌐 Fetching completed bookings from: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          final List<dynamic> bookingsData = jsonData['data']['data'] ?? [];
          completedBookings.value = bookingsData.cast<Map<String, dynamic>>();
          print('✅ Loaded ${completedBookings.length} completed bookings');
        } else {
          errorMessage.value = jsonData['message'] ?? 'Failed to load bookings';
        }
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: $e';
      print('❌ Error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}