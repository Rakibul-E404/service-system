/**
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/common/components/custom_network_image.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import '../../auth/widgets/app_custom_modal.dart';
import '../screens/booking_screen_controller.dart';

class HorizontalServiceCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String description;
  final String status;
  final String bookingId;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final double? width;
  final double? height;
  final bool showStatus;
  final int tabIndex;
  final ActiveSlotBookingsController? controller;

  const HorizontalServiceCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.bookingId,
    this.onTap,
    this.onDelete,
    this.width,
    this.height,
    required this.status,
    this.showStatus = true,
    this.tabIndex = 0,
    this.controller,
  });

  // Method to handle booking cancellation
  void _handleCancelBooking(BuildContext context) {
    // Only allow cancellation for Active bookings (tabIndex 0)
    if (tabIndex != 0) {
      Get.snackbar(
        'Info',
        'Only active bookings can be cancelled',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return AppDeleteModal(
          onTap: () {
            Get.back(); // Close the modal
            _performCancellation();
          },
        );
      },
    );
  }

  // Method to perform the actual API cancellation
  void _performCancellation() async {
    if (bookingId.isEmpty) {
      Get.snackbar(
        'Error',
        'Invalid booking ID',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      // Get the controller
      ActiveSlotBookingsController bookingController;

      if (controller != null) {
        bookingController = controller!;
      } else {
        // Try to find the controller
        if (Get.isRegistered<ActiveSlotBookingsController>()) {
          bookingController = Get.find<ActiveSlotBookingsController>();
        } else {
          Get.snackbar(
            'Error',
            'Controller not found',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
      }

      // Show loading dialog
      Get.dialog(
        WillPopScope(
          onWillPop: () async => false,
          child: const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Cancelling booking...'),
                  ],
                ),
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      print('🔄 Starting cancellation for booking: $bookingId');

      // Call the API to cancel the booking
      final bool success = await bookingController.cancelBooking(bookingId);

      // Close loading dialog
      Get.back();

      if (success) {
        print('✅ Booking cancelled successfully');

        // Call the onDelete callback if provided
        if (onDelete != null) {
          onDelete!();
        }
      } else {
        print('❌ Booking cancellation failed');
      }
    } catch (e) {
      // Close loading dialog if open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      print('❌ Exception during cancellation: $e');

      Get.snackbar(
        'Error',
        'Failed to cancel booking. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = width ?? screenWidth * 0.9;
    final double cardHeight = height ?? 150;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: cardWidth,
        height: cardHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CustomCachedImage(
                  imageUrl: imageUrl,
                  height: cardHeight * 0.8,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: context.txtTheme.labelLarge?.copyWith(
                      fontSize: screenWidth * 0.05,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Text(
                      description,
                      overflow: TextOverflow.ellipsis,
                      style: context.txtTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                        fontSize: screenWidth * 0.03,
                      ),
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Show delete icon only if the tabIndex is 0 (Active Slot)
                  if (tabIndex == 0)
                    IconButton(
                      onPressed: () => _handleCancelBooking(context),
                      icon: Icon(
                        CupertinoIcons.delete,
                        color: Colors.red,
                        size: screenWidth * 0.07,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    )
                  else
                    const SizedBox(height: 40), // Placeholder when no delete button

                  if (showStatus)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: _getStatusColor(status),
                      ),
                      child: Text(
                        _getStatusText(status),
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          fontWeight: FontWeight.w700,
                          color: _getStatusTextColor(status),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get status color based on status string
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'accepted':
        return Colors.orange.withOpacity(0.1);
      case 'pending':
      case 'requested':
        return AppColors.primaryColor.withOpacity(0.1);
      case 'processing':
        return Colors.orange.withOpacity(0.1);
      case 'completed':
        return AppColors.successColor;
      case 'cancelled':
        return Colors.red.withOpacity(0.1);
      default:
        return AppColors.greyColor.withOpacity(0.1);
    }
  }

  // Helper method to get status text color
  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'accepted':
        return Colors.deepOrange;
      case 'pending':
      case 'requested':
        return AppColors.primaryColor;
      case 'processing':
        return Colors.orange;
      case 'completed':
        return AppColors.whiteColor;
      case 'cancelled':
        return Colors.red;
      default:
        return AppColors.whiteColor;
    }
  }

  // Helper method to format status text
  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'pending':
        return 'Accepted';
      case 'processing':
        return 'Processing';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}*/







///
///
///
///
/// todo:::::::: updating to pass the serviceId to the rating page
///
///
///
///
///



import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/common/components/custom_network_image.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import '../../auth/widgets/app_custom_modal.dart';
import '../screens/booking_screen_controller.dart';

class HorizontalServiceCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String description;
  final String status;
  final String bookingId;
  final String? serviceId; // Added serviceId parameter
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final double? width;
  final double? height;
  final bool showStatus;
  final int tabIndex;
  final ActiveSlotBookingsController? controller;

  const HorizontalServiceCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.bookingId,
    this.serviceId, // Added as required parameter
    this.onTap,
    this.onDelete,
    this.width,
    this.height,
    required this.status,
    this.showStatus = true,
    this.tabIndex = 0,
    this.controller,
  });

  // Method to handle booking cancellation
  void _handleCancelBooking(BuildContext context) {
    // Only allow cancellation for Active bookings (tabIndex 0)
    if (tabIndex != 0) {
      Get.snackbar(
        'Info',
        'Only active bookings can be cancelled',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return AppDeleteModal(
          onTap: () {
            Get.back(); // Close the modal
            _performCancellation();
          },
        );
      },
    );
  }

  // Method to perform the actual API cancellation
  void _performCancellation() async {
    if (bookingId.isEmpty) {
      Get.snackbar(
        'Error',
        'Invalid booking ID',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      // Get the controller
      ActiveSlotBookingsController bookingController;

      if (controller != null) {
        bookingController = controller!;
      } else {
        // Try to find the controller
        if (Get.isRegistered<ActiveSlotBookingsController>()) {
          bookingController = Get.find<ActiveSlotBookingsController>();
        } else {
          Get.snackbar(
            'Error',
            'Controller not found',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
      }

      // Show loading dialog
      Get.dialog(
        WillPopScope(
          onWillPop: () async => false,
          child: const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Cancelling booking...'),
                  ],
                ),
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      print('🔄 Starting cancellation for booking: $bookingId');

      // Call the API to cancel the booking
      final bool success = await bookingController.cancelBooking(bookingId);

      // Close loading dialog
      Get.back();

      if (success) {
        print('✅ Booking cancelled successfully');

        // Call the onDelete callback if provided
        if (onDelete != null) {
          onDelete!();
        }
      } else {
        print('❌ Booking cancellation failed');
      }
    } catch (e) {
      // Close loading dialog if open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      print('❌ Exception during cancellation: $e');

      Get.snackbar(
        'Error',
        'Failed to cancel booking. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = width ?? screenWidth * 0.9;
    final double cardHeight = height ?? 150;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: cardWidth,
        height: cardHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CustomCachedImage(
                  imageUrl: imageUrl,
                  height: cardHeight * 0.8,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: context.txtTheme.labelLarge?.copyWith(
                      fontSize: screenWidth * 0.05,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Text(
                      description,
                      overflow: TextOverflow.ellipsis,
                      style: context.txtTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                        fontSize: screenWidth * 0.03,
                      ),
                      maxLines: 2,
                    ),
                  ),
                  // Optional: Display service ID for debugging
                  // if (serviceId.isNotEmpty)
                  //   Text(
                  //     'Service ID: ${serviceId.substring(0, 8)}...',
                  //     style: context.txtTheme.bodySmall?.copyWith(
                  //       color: Colors.grey,
                  //       fontSize: screenWidth * 0.025,
                  //     ),
                  //   ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Show delete icon only if the tabIndex is 0 (Active Slot)
                  if (tabIndex == 0)
                    IconButton(
                      onPressed: () => _handleCancelBooking(context),
                      icon: Icon(
                        CupertinoIcons.delete,
                        color: Colors.red,
                        size: screenWidth * 0.07,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    )
                  else
                    const SizedBox(height: 40), // Placeholder when no delete button

                  if (showStatus)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: _getStatusColor(status),
                      ),
                      child: Text(
                        _getStatusText(status),
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          fontWeight: FontWeight.w700,
                          color: _getStatusTextColor(status),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get status color based on status string
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'accepted':
        return Colors.orange.withOpacity(0.1);
      case 'pending':
      case 'requested':
        return AppColors.primaryColor.withOpacity(0.1);
      case 'processing':
        return Colors.orange.withOpacity(0.1);
      case 'completed':
        return AppColors.successColor;
      case 'cancelled':
        return Colors.red.withOpacity(0.1);
      default:
        return AppColors.greyColor.withOpacity(0.1);
    }
  }

  // Helper method to get status text color
  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'accepted':
        return Colors.deepOrange;
      case 'pending':
      case 'requested':
        return AppColors.primaryColor;
      case 'processing':
        return Colors.orange;
      case 'completed':
        return AppColors.whiteColor;
      case 'cancelled':
        return Colors.red;
      default:
        return AppColors.whiteColor;
    }
  }

  // Helper method to format status text
  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'pending':
        return 'Accepted';
      case 'processing':
        return 'Processing';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}