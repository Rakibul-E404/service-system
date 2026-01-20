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
    _notificationTimer = Timer.periodic(const Duration(seconds: 30), (Timer timer) {
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
        errorMessage.value = 'Please login to get notifications!';
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

