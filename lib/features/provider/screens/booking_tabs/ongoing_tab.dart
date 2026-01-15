/**
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/common/widgets/reusable_button.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';
import 'package:manx_mate/features/booking/controllers/booking_action_controller.dart';
import 'package:manx_mate/features/provider/screens/booking_tabs/provider_ongoing_controller.dart';
import 'package:manx_mate/model/booking_service_model.dart';
import '../provider_services.dart';

class OngoingTab extends StatelessWidget {
  const OngoingTab({super.key});

ProviderOngoingController get controller => Get.find<ProviderOngoingController>();
  // Inject the Action Controller to handle button states
  BookingActionController get actionController => Get.find<BookingActionController>();
  
 String _getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return 'https://via.placeholder.com/150';
    }
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    return '${AppUrl.imageBaseUrl}/$imagePath';
  }

  // UPDATED: Now accepts BookingServiceModel instead of Map
 Widget _buildOngoingCard(BuildContext context, BookingServiceModel booking) {
    final String bookingId = booking.id;
    final String location = booking.location.isEmpty ? 'Unknown' : booking.location;
    final String description = booking.additionalInfo.isEmpty ? 'No description' : booking.additionalInfo;
    final String formattedDate = '${booking.date.day}/${booking.date.month}/${booking.date.year}';
    final String authorName = booking.author.name;
    final String? authorImagePath = booking.author.image;

    return Obx(() {
      // Logic to check which specific button is loading
      final bool isThisCardBusy = actionController.loadingBookingId.value == bookingId;
      final bool isCancelLoading = isThisCardBusy && actionController.processingStatus.value == 'cancelled';
      final bool isCompleteLoading = isThisCardBusy && actionController.processingStatus.value == 'completed';

      return Card(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        child: InkWell(
          onTap: isThisCardBusy ? null : () => _showBookingDetails(context, booking),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: NetworkImage(_getImageUrl(authorImagePath)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(authorName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(formattedDate, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  description.length > 50 ? '${description.substring(0, 50)}...' : description,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(location, style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(height: 1, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // CANCEL BUTTON
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isThisCardBusy ? null : () {
                          _showConfirmationDialog(context, 'Cancel Booking', 'Are you sure?', () async {
                            bool success = await actionController.updateBookingStatus(bookingId, 'cancelled');
                            if (success) controller.fetchBookings(refresh: true);
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: isCancelLoading 
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red))
                            : const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // COMPLETE BUTTON
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isThisCardBusy ? null : () {
                          _showConfirmationDialog(context, 'Complete Booking', 'Mark as finished?', () async {
                            bool success = await actionController.updateBookingStatus(bookingId, 'completed');
                            if (success) controller.fetchBookings(refresh: true);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: isCompleteLoading 
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Complete'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _showConfirmationDialog(BuildContext context, String title, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  // UPDATED: Now accepts BookingServiceModel instead of Map
void _showBookingDetails(BuildContext context, BookingServiceModel booking) {
  debugPrint('📑 Showing Details Sheet for: ${booking.id}');
  
  // No need for 'authorRaw' or 'try-catch' parsing anymore! 
  // The model has already done the heavy lifting.
  final String authorName = booking.author.name;
  final String authorImageUrl = _getImageUrl(booking.author.image);
  
  final String location = booking.location.isEmpty ? 'Unknown' : booking.location;
  final String description = booking.additionalInfo.isEmpty ? 'No description' : booking.additionalInfo;
  
  // Cleanly format the date from the model's DateTime object
  final String formattedDate = '${booking.date.day}/${booking.date.month}/${booking.date.year}';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Booking Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: NetworkImage(authorImageUrl),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(authorName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('Client', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildDetailRow(icon: Icons.description, label: 'Service Description', value: description),
                  const SizedBox(height: 16),
                  _buildDetailRow(icon: Icons.location_on, label: 'Location', value: location),
                  const SizedBox(height: 16),
                  _buildDetailRow(icon: Icons.calendar_today, label: 'Date', value: formattedDate),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: AppColors.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message, VoidCallback onRefresh) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: AppSizes.md),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.lg),
          SizedBox(
            width: 150,
            child: ReusableButton(onTap: onRefresh, label: "Refresh"),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
          const SizedBox(height: AppSizes.md),
          Text(
            error,
            style: TextStyle(color: Colors.red[600], fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.lg),
          SizedBox(
            width: 150,
            child: ReusableButton(onTap: onRetry, label: "Try Again"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        );
      }

      if (controller.errorMessage.isNotEmpty) {
        return RefreshIndicator(
          onRefresh: () async => controller.fetchBookings(refresh: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: _buildErrorState(
                controller.errorMessage.value,
                () => controller.fetchBookings(refresh: true),
              ),
            ),
          ),
        );
      }

      if (controller.bookings.isEmpty) {
        return RefreshIndicator(
          onRefresh: () async => controller.fetchBookings(refresh: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: _buildEmptyState(
                'No ongoing bookings',
                () => controller.fetchBookings(refresh: true),
              ),
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async => controller.fetchBookings(refresh: true),
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: controller.bookings.length,
          itemBuilder: (context, i) => _buildOngoingCard(context, controller.bookings[i]),
          separatorBuilder: (_, __) => const SizedBox(height: 8),
        ),
      );
    });
  }
}
*/



///
///
///
/// todo:: uppper is ok and now adding options to set the phone and email
///
///
///



import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/common/widgets/reusable_button.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';
import 'package:manx_mate/features/booking/controllers/booking_action_controller.dart';
import 'package:manx_mate/features/provider/screens/booking_tabs/provider_ongoing_controller.dart';
import 'package:manx_mate/model/booking_service_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../provider_services.dart';

class OngoingTab extends StatelessWidget {
  const OngoingTab({super.key});

  ProviderOngoingController get controller => Get.find<ProviderOngoingController>();
  BookingActionController get actionController => Get.find<BookingActionController>();

  String _getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return 'https://via.placeholder.com/150';
    }
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    return '${AppUrl.imageBaseUrl}/$imagePath';
  }

  Widget _buildOngoingCard(BuildContext context, BookingServiceModel booking) {
    final String bookingId = booking.id;
    final String location = booking.location.isEmpty ? 'Unknown' : booking.location;
    final String description = booking.additionalInfo.isEmpty ? 'No description' : booking.additionalInfo;
    final String formattedDate = '${booking.date.day}/${booking.date.month}/${booking.date.year}';
    final String authorName = booking.author.name;
    final String authorImagePath = booking.author.image;

    return Obx(() {
      final bool isThisCardBusy = actionController.loadingBookingId.value == bookingId;
      final bool isCancelLoading = isThisCardBusy && actionController.processingStatus.value == 'cancelled';
      final bool isCompleteLoading = isThisCardBusy && actionController.processingStatus.value == 'completed';

      return Card(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        child: InkWell(
          onTap: isThisCardBusy ? null : () => _showJobDetailsModal(booking),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: NetworkImage(_getImageUrl(authorImagePath)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(authorName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(formattedDate, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  description.length > 50 ? '${description.substring(0, 50)}...' : description,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(location, style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(height: 1, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // CANCEL BUTTON
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isThisCardBusy ? null : () {
                          _showConfirmationDialog(context, 'Cancel Booking', 'Are you sure?', () async {
                            bool success = await actionController.updateBookingStatus(bookingId, 'cancelled');
                            if (success) controller.fetchBookings(refresh: true);
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: isCancelLoading
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red))
                            : const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // COMPLETE BUTTON
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isThisCardBusy ? null : () {
                          _showConfirmationDialog(context, 'Complete Booking', 'Mark as finished?', () async {
                            bool success = await actionController.updateBookingStatus(bookingId, 'completed');
                            if (success) controller.fetchBookings(refresh: true);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: isCompleteLoading
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Complete'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _showConfirmationDialog(BuildContext context, String title, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _showJobDetailsModal(BookingServiceModel booking) {
    // Convert BookingServiceModel to the Map structure JobDetailsModal expects
    final Map<String, dynamic> jobData = {
      'service': {
        'author': {
          'name': booking.author.name,
          'phone': booking.author.phone,
          'email': booking.author.email,
          'image': booking.author.image,
        },
        'subCategory': {
          'name': booking.subCategory.name,
        }
      },
      'bookingDate': booking.date.toIso8601String(),
      'location': booking.location,
      'region': booking.region,
      'details': booking.additionalInfo,
      'createdAt': booking.createdAt.toIso8601String(),
      'status': booking.status,
    };

    // Show the JobDetailsModal with all contact buttons
    _showCustomJobDetailsModal(
      context: Get.context!,
      job: jobData,
      showCancelButton: false, // For provider side
      showContactButtons: true,
      customTitle: 'Booking Details',
    );
  }

  // Custom modal function that replicates JobDetailsModal but without Get.bottomSheet
  void _showCustomJobDetailsModal({
    required BuildContext context,
    required Map<String, dynamic> job,
    bool showCancelButton = true,
    bool showContactButtons = true,
    String? customTitle,
  }) {
    // Extract service and provider data
    final Map<String, dynamic> service = job['service'] ?? {};
    final Map<String, dynamic> author = service['author'] ?? {};
    final Map<String, dynamic> subCategory = service['subCategory'] ?? {};

    // Build image URL
    String imageUrl = '';
    if (author['image'] != null && author['image'].toString().isNotEmpty) {
      final String imagePath = author['image'].toString();
      if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
        imageUrl = imagePath;
      } else {
        imageUrl = '${AppUrl.imageBaseUrl}/$imagePath';
      }
    }

    // Extract contact info
    final String? providerPhone = author['phone']?.toString();
    final String? providerEmail = author['email']?.toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    customTitle ?? 'Booking Details',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Client Image and Info
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: imageUrl.isNotEmpty
                              ? Image.network(
                            imageUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey.shade200,
                              child: Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          )
                              : Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey.shade200,
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                author['name']?.toString() ?? 'Unknown Client',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                subCategory['name']?.toString() ?? 'Unknown Service',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (providerPhone != null && providerPhone.isNotEmpty)
                                Row(
                                  children: [
                                    Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
                                    const SizedBox(width: 6),
                                    Text(
                                      providerPhone,
                                      style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                                    ),
                                  ],
                                ),
                              if (providerEmail != null && providerEmail.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Row(
                                    children: [
                                      Icon(Icons.email, size: 16, color: Colors.grey.shade600),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          providerEmail,
                                          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Details Section
                    _buildDetailItem(
                      icon: Icons.calendar_today,
                      iconColor: Colors.blue,
                      title: 'Booking Date',
                      value: _formatDate(job['bookingDate']),
                    ),

                    const SizedBox(height: 16),

                    _buildDetailItem(
                      icon: Icons.location_on_outlined,
                      iconColor: Colors.red,
                      title: 'Location',
                      value: job['location']?.toString() ?? 'Not specified',
                    ),

                    const SizedBox(height: 16),

                    _buildDetailItem(
                      icon: Icons.map_outlined,
                      iconColor: Colors.green,
                      title: 'Region',
                      value: _capitalizeFirst(job['region']?.toString() ?? ''),
                    ),

                    const SizedBox(height: 16),

                    _buildDetailItem(
                      icon: Icons.access_time,
                      iconColor: Colors.purple,
                      title: 'Created',
                      value: _formatRelativeTime(job['createdAt']),
                    ),

                    const SizedBox(height: 16),

                    _buildDetailItem(
                      icon: Icons.info_outline,
                      iconColor: Colors.orange,
                      title: 'Status',
                      value: _capitalizeFirst(job['status']?.toString() ?? 'accepted'),
                    ),

                    // Additional Information
                    if (job['details'] != null && job['details'].toString().isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Job Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          job['details'].toString(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Additional Contact Options
                    if (showContactButtons && (providerPhone != null || providerEmail != null)) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Quick Contact',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (providerPhone != null && providerPhone.isNotEmpty)
                            _buildContactOption(
                              icon: Icons.call,
                              label: 'Call',
                              color: Colors.green,
                              onTap: () {
                                Navigator.pop(context);
                                _launchPhoneNumber(providerPhone);
                              },
                            ),
                          if (providerPhone != null && providerPhone.isNotEmpty && providerEmail != null && providerEmail.isNotEmpty)
                            const SizedBox(width: 16),
                          if (providerEmail != null && providerEmail.isNotEmpty)
                            _buildContactOption(
                              icon: Icons.email,
                              label: 'Email',
                              color: Colors.blue,
                              onTap: () {
                                Navigator.pop(context);
                                _launchEmail(providerEmail);
                              },
                            ),
                          if ((providerPhone != null && providerPhone.isNotEmpty ||
                              providerEmail != null && providerEmail.isNotEmpty))
                            const SizedBox(width: 16),
                          _buildContactOption(
                            icon: Icons.chat,
                            label: 'Message',
                            color: Colors.purple,
                            onTap: () {
                              Navigator.pop(context);
                              Get.snackbar(
                                'Coming Soon',
                                'In-app messaging will be available soon.',
                                backgroundColor: Colors.purple,
                                colorText: Colors.white,
                              );
                            },
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _launchPhoneNumber(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      Get.snackbar(
        'Error',
        'Could not launch dialer',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  static Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );

    try {
      final bool launched = await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        Get.snackbar(
          'No Email App',
          'No email app found. Please install one to contact the client.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unable to open email. Make sure an email app is installed.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Helper methods for formatting
  Widget _buildDetailItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(
              icon,
              size: 24,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(dynamic dateValue) {
    if (dateValue == null) return 'Date not set';

    try {
      DateTime date;
      if (dateValue is String) {
        date = DateTime.parse(dateValue).toLocal();
      } else if (dateValue is DateTime) {
        date = dateValue;
      } else {
        return 'Invalid date';
      }

      return '${_getDayName(date.weekday)}, ${date.day} ${_getMonthName(date.month)} ${date.year}';
    } catch (e) {
      return 'Date not available';
    }
  }

  static String _formatRelativeTime(dynamic dateValue) {
    if (dateValue == null) {
      return 'Recently';
    }

    try {
      DateTime date;
      if (dateValue is String) {
        date = DateTime.parse(dateValue).toLocal();
      } else if (dateValue is DateTime) {
        date = dateValue;
      } else {
        return 'Recently';
      }

      final DateTime now = DateTime.now();
      final Duration difference = now.difference(date);

      if (difference.inDays > 365) {
        final int years = (difference.inDays / 365).floor();
        return '$years ${years == 1 ? 'year' : 'years'} ago';
      } else if (difference.inDays > 30) {
        final int months = (difference.inDays / 30).floor();
        return '$months ${months == 1 ? 'month' : 'months'} ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
      } else {
        return 'just now';
      }
    } catch (e) {
      return 'Recently';
    }
  }

  static String _getDayName(int weekday) {
    const List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  static String _getMonthName(int month) {
    const List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  static String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  Widget _buildEmptyState(String message, VoidCallback onRefresh) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: AppSizes.md),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.lg),
          SizedBox(
            width: 150,
            child: ReusableButton(onTap: onRefresh, label: "Refresh"),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
          const SizedBox(height: AppSizes.md),
          Text(
            error,
            style: TextStyle(color: Colors.red[600], fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.lg),
          SizedBox(
            width: 150,
            child: ReusableButton(onTap: onRetry, label: "Try Again"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        );
      }

      if (controller.errorMessage.isNotEmpty) {
        return RefreshIndicator(
          onRefresh: () async => controller.fetchBookings(refresh: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: _buildErrorState(
                controller.errorMessage.value,
                    () => controller.fetchBookings(refresh: true),
              ),
            ),
          ),
        );
      }

      if (controller.bookings.isEmpty) {
        return RefreshIndicator(
          onRefresh: () async => controller.fetchBookings(refresh: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: _buildEmptyState(
                'No ongoing bookings',
                    () => controller.fetchBookings(refresh: true),
              ),
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async => controller.fetchBookings(refresh: true),
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: controller.bookings.length,
          itemBuilder: (context, i) => _buildOngoingCard(context, controller.bookings[i]),
          separatorBuilder: (_, __) => const SizedBox(height: 8),
        ),
      );
    });
  }
}