
/**
import 'package:get/get.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/network/network_response.dart';
import '../../../core/utils/api/app_url.dart';
import '../../../core/utils/token_service/token_storage_service.dart';

class NotificationController extends GetxController {
  final SharedPrefService _sharedPrefService = SharedPrefService();
  final NetworkCaller _networkCaller = NetworkCaller();

  RxList<dynamic> notifications = RxList<dynamic>([]);

  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      String? token = await _sharedPrefService.getAccessToken();

      if (token == null || token.isEmpty) {
        errorMessage.value = 'Access token not found. Please login again.';
        isLoading.value = false;
        return;
      }

      Map<String, String> headers = {
        'Authorization': 'Bearer $token',
      };

      NetworkResponse response = await _networkCaller.getRequest(
        AppUrl.notificationUrl,
        headers: headers,
      );

      if (response.isSuccess) {
        final data = response.jsonResponse?['data']['data'];
        if (data != null && data is List) {
          notifications.value = data;
        } else {
          errorMessage.value = 'No notifications found.';
          notifications.clear();
        }
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to fetch notifications.';
        notifications.clear();
      }
    } catch (e) {
      errorMessage.value = 'Error fetching notifications: $e';
      notifications.clear();
    } finally {
      isLoading.value = false;
    }
  }
}*/






///
///
///
///
///
/// todo:::: showing a don for the new notificaiton
///
///
///
///
///
///


/**


// controllers/notification_controller.dart
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/network/network_caller.dart';
import 'package:manx_mate/core/network/network_response.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';
import 'package:manx_mate/core/utils/token_service/token_storage_service.dart';

class NotificationController extends GetxController {
  final SharedPrefService _sharedPrefService = SharedPrefService();
  final NetworkCaller _networkCaller = NetworkCaller();

  RxList<dynamic> notifications = RxList<dynamic>([]);
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  // Observables for unread notifications
  RxInt unreadCount = 0.obs;
  RxBool hasUnreadNotifications = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      String? token = await _sharedPrefService.getAccessToken();

      if (token == null || token.isEmpty) {
        errorMessage.value = 'Access token not found. Please login again.';
        isLoading.value = false;
        return;
      }

      Map<String, String> headers = {
        'Authorization': 'Bearer $token',
      };

      NetworkResponse response = await _networkCaller.getRequest(
        AppUrl.notificationUrl,
        headers: headers,
      );

      if (response.isSuccess) {
        final data = response.jsonResponse?['data']['data'];
        if (data != null && data is List) {
          notifications.value = data;

          // Calculate unread notifications count
          _calculateUnreadCount();
        } else {
          errorMessage.value = 'No notifications found.';
          notifications.clear();
          unreadCount.value = 0;
          hasUnreadNotifications.value = false;
        }
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to fetch notifications.';
        notifications.clear();
        unreadCount.value = 0;
        hasUnreadNotifications.value = false;
      }
    } catch (e) {
      errorMessage.value = 'Error fetching notifications: $e';
      notifications.clear();
      unreadCount.value = 0;
      hasUnreadNotifications.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Calculate unread notifications count
  void _calculateUnreadCount() {
    try {
      int count = 0;
      for (var notification in notifications) {
        // Assuming your notification has a 'read' field
        // If not, you might need to adjust this logic based on your API response
        bool isRead = notification['read'] ?? false;
        if (!isRead) {
          count++;
        }
      }
      unreadCount.value = count;
      hasUnreadNotifications.value = count > 0;
    } catch (e) {
      unreadCount.value = 0;
      hasUnreadNotifications.value = false;
    }
  }


  Future<void> markAllNotificationsAsRead() async {
    try {
      // Simply update the local state to remove the dot
      unreadCount.value = 0;
      hasUnreadNotifications.value = false;

      debugPrint('✅ Notification dot removed');
    } catch (e) {
      debugPrint('❌ Error removing notification dot: $e');
    }
  }




  /// Mark a specific notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      String? token = await _sharedPrefService.getAccessToken();

      if (token == null || token.isEmpty) return;

      Map<String, String> headers = {
        'Authorization': 'Bearer $token',
      };

      // Call API to mark as read
      NetworkResponse response = await _networkCaller.putRequest(
          '${AppUrl.notificationUrl}/$notificationId/read', // Adjust this endpoint based on your API
          headers: headers,
          body: {}
      );

      if (response.isSuccess) {
        // Update local state
        if (unreadCount.value > 0) {
          unreadCount.value--;
        }
        hasUnreadNotifications.value = unreadCount.value > 0;

        // Update the specific notification
        for (int i = 0; i < notifications.length; i++) {
          if (notifications[i]['_id'] == notificationId) {
            var notification = Map<String, dynamic>.from(notifications[i]);
            notification['read'] = true;
            notifications[i] = notification;
            break;
          }
        }
        notifications.refresh(); // Force UI update
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  /// Refresh notifications
  Future<void> refreshNotifications() async {
    await fetchNotifications();
  }

  /// Add a new notification (call this when you receive a push notification)
  void addNewNotification(Map<String, dynamic> newNotification) {
    notifications.insert(0, newNotification);
    unreadCount.value++;
    hasUnreadNotifications.value = true;
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      String? token = await _sharedPrefService.getAccessToken();

      if (token == null || token.isEmpty) return;

      Map<String, String> headers = {
        'Authorization': 'Bearer $token',
      };

      NetworkResponse response = await _networkCaller.deleteRequest(
        AppUrl.notificationUrl,
        headers: headers,
      );

      if (response.isSuccess) {
        notifications.clear();
        unreadCount.value = 0;
        hasUnreadNotifications.value = false;
      }
    } catch (e) {
      debugPrint('Error clearing notifications: $e');
    }
  }
}*/



///
///
///
///
///
///
///
/// todo::::: making the notificaiotn realtime
///
///
///
///
///
///
///
///








import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/network/network_caller.dart';
import 'package:manx_mate/core/network/network_response.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';
import 'package:manx_mate/core/utils/token_service/token_storage_service.dart';

class NotificationController extends GetxController {
  final SharedPrefService _sharedPrefService = SharedPrefService();
  final NetworkCaller _networkCaller = NetworkCaller();

  RxList<dynamic> notifications = RxList<dynamic>([]);
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  // Observables for unread notifications
  RxInt unreadCount = 0.obs;
  RxBool hasUnreadNotifications = false.obs;

  Timer? _notificationTimer;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    // Start periodic checking for new notifications
    startNotificationPolling();
  }

  @override
  void onClose() {
    // Clean up the timer when controller is closed
    _notificationTimer?.cancel();
    super.onClose();
  }

  // Start polling for notifications every 30 seconds
  void startNotificationPolling() {
    _notificationTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      fetchNotifications();
    });
  }

  // Stop polling (call this when app goes to background if needed)
  void stopNotificationPolling() {
    _notificationTimer?.cancel();
  }

  Future<void> fetchNotifications() async {
    try {
      String? token = await _sharedPrefService.getAccessToken();

      if (token == null || token.isEmpty) {
        errorMessage.value = 'Access token not found. Please login again.';
        return;
      }

      Map<String, String> headers = {
        'Authorization': 'Bearer $token',
      };

      NetworkResponse response = await _networkCaller.getRequest(
        AppUrl.notificationUrl,
        headers: headers,
      );

      if (response.isSuccess) {
        final data = response.jsonResponse?['data']['data'];
        if (data != null && data is List) {
          notifications.value = data;

          // Calculate unread notifications count in real-time
          _calculateUnreadCount();
        } else {
          notifications.clear();
          unreadCount.value = 0;
          hasUnreadNotifications.value = false;
        }
      } else {
        notifications.clear();
        unreadCount.value = 0;
        hasUnreadNotifications.value = false;
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    }
  }

  /// Calculate unread notifications count in real-time
  void _calculateUnreadCount() {
    try {
      int count = 0;
      for (var notification in notifications) {
        // Check if notification has a 'read' field or any other indicator
        bool isRead = notification['read'] ?? false;
        // Or if your API uses 'isRead', 'status', etc.
        // bool isRead = notification['isRead'] ?? false;
        // bool isRead = notification['status'] == 'read';

        if (!isRead) {
          count++;
        }
      }
      unreadCount.value = count;
      hasUnreadNotifications.value = count > 0;

      debugPrint('📊 Real-time unread count: $count');
    } catch (e) {
      unreadCount.value = 0;
      hasUnreadNotifications.value = false;
      debugPrint('Error calculating unread count: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    try {
      // Update local state immediately
      unreadCount.value = 0;
      hasUnreadNotifications.value = false;

      // Optionally call API to mark as read on server
      // await _markAllAsReadOnServer();

      debugPrint('✅ All notifications marked as read - dot removed');
    } catch (e) {
      debugPrint('❌ Error marking notifications as read: $e');
    }
  }

  /// Optional: Mark as read on server
  Future<void> _markAllAsReadOnServer() async {
    try {
      String? token = await _sharedPrefService.getAccessToken();

      if (token == null || token.isEmpty) return;

      Map<String, String> headers = {
        'Authorization': 'Bearer $token',
      };

      // Adjust this endpoint based on your API
      await _networkCaller.putRequest(
          '${AppUrl.notificationUrl}/mark-all-read',
          headers: headers,
          body: {}
      );
    } catch (e) {
      debugPrint('Error marking as read on server: $e');
    }
  }

  /// Manually trigger notification check
  Future<void> checkForNewNotifications() async {
    await fetchNotifications();
  }

  /// Add a new notification (for testing or push notifications)
  void simulateNewNotification() {
    unreadCount.value++;
    hasUnreadNotifications.value = true;
    debugPrint('🆕 Simulated new notification - unread count: ${unreadCount.value}');
  }
}

