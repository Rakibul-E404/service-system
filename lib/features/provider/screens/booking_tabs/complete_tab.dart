import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/common/widgets/reusable_button.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';
import 'package:manx_mate/features/provider/screens/booking_tabs/provider_complete_controller.dart';
import '../provider_services.dart';

class CompleteTab extends StatelessWidget {
  const CompleteTab({super.key});

  ProviderCompleteController get controller => Get.find<ProviderCompleteController>();

  String _getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return 'https://via.placeholder.com/150';
    }

    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }

    if (imagePath.contains('cloudinary.com')) {
      if (imagePath.startsWith('https://')) {
        return imagePath;
      } else {
        return 'https://$imagePath';
      }
    }

    return '${AppUrl.imageBaseUrl}/$imagePath';
  }

  Widget _buildCompleteCard(BuildContext context, Map<String, dynamic> booking) {
    final dynamic authorRaw = booking['author'];
    final Map<String, dynamic> author = (authorRaw is Map<String, dynamic>) ? authorRaw : {};

    final location = booking['location']?.toString() ?? 'Unknown';
    final description = booking['description']?.toString() ?? booking['additionalInfo']?.toString() ?? 'No description';
    final bookingDate = booking['bookingDate']?.toString() ?? booking['date']?.toString() ?? '';
    final completedDate = booking['completedAt']?.toString() ?? booking['updatedAt']?.toString() ?? '';

    String formattedDate = '';
    try {
      final date = DateTime.parse(bookingDate);
      formattedDate = '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      formattedDate = 'Invalid date';
    }

    String formattedCompletedDate = '';
    try {
      final date = DateTime.parse(completedDate);
      formattedCompletedDate = 'Completed on ${date.day}/${date.month}/${date.year}';
    } catch (_) {
      formattedCompletedDate = '';
    }

    final authorName = author['name']?.toString() ?? 'Unknown';
    final authorImagePath = author['image']?.toString();

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      child: InkWell(
        onTap: () => _showBookingDetails(context, booking),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Info Row with Avatar
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: NetworkImage(_getImageUrl(authorImagePath)),
                    onBackgroundImageError: (_, __) {},
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authorName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Service Title
              Text(
                description.length > 50
                    ? '${description.substring(0, 50)}...'
                    : description,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 8),

              // Location Row
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      location,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              if (formattedCompletedDate.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 14,
                      color: Colors.green[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formattedCompletedDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 16),
              Divider(height: 1, color: Colors.grey[300]),
              const SizedBox(height: 12),

              // View Details Button (Read-only for completed bookings)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _showBookingDetails(context, booking),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryColor,
                    side: BorderSide(color: AppColors.primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'View Details',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBookingDetails(BuildContext context, Map<String, dynamic> booking) {
    final dynamic authorRaw = booking['author'];
    final Map<String, dynamic> author = (authorRaw is Map<String, dynamic>) ? authorRaw : {};
    final location = booking['location']?.toString() ?? 'Unknown';
    final description = booking['description']?.toString() ?? booking['additionalInfo']?.toString() ?? 'No description';
    final bookingDate = booking['bookingDate']?.toString() ?? booking['date']?.toString() ?? '';
    final status = booking['status']?.toString() ?? 'N/A';
    final completedDate = booking['completedAt']?.toString() ?? booking['updatedAt']?.toString() ?? '';

    String formattedDate = '';
    try {
      final date = DateTime.parse(bookingDate);
      formattedDate = '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      formattedDate = 'Invalid date';
    }

    String formattedCompletedDate = '';
    try {
      final date = DateTime.parse(completedDate);
      formattedCompletedDate = 'Completed on ${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute}';
    } catch (_) {
      formattedCompletedDate = '';
    }

    final authorName = author['name']?.toString() ?? 'Unknown';
    final authorImagePath = author['image']?.toString();
    final authorImageUrl = _getImageUrl(authorImagePath);

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
                  const Text(
                    'Booking Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
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
                    // User Info
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: NetworkImage(authorImageUrl),
                          onBackgroundImageError: (_, __) {},
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authorName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Client',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Booking Details
                    _buildDetailRow(
                      icon: Icons.description,
                      label: 'Service Description',
                      value: description,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      icon: Icons.location_on,
                      label: 'Location',
                      value: location,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      icon: Icons.calendar_today,
                      label: 'Date',
                      value: formattedDate,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      icon: Icons.info,
                      label: 'Status',
                      value: status.toUpperCase(),
                    ),
                    if (formattedCompletedDate.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        icon: Icons.check_circle,
                        label: 'Completion Date',
                        value: formattedCompletedDate,
                      ),
                    ],
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
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.lg),
          SizedBox(
            width: 150,
            child: ReusableButton(
              onTap: onRefresh,
              label: "Refresh",
            ),
          ),
          const SizedBox(height: AppSizes.md),
          TextButton(
            onPressed: onRefresh,
            child: const Text(
              "Pull down to refresh",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
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
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[400],
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            error,
            style: TextStyle(
              color: Colors.red[600],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.lg),
          SizedBox(
            width: 150,
            child: ReusableButton(
              onTap: onRetry,
              label: "Try Again",
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading.value) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      );
    }

    if (controller.errorMessage.isNotEmpty) {
      return RefreshIndicator(
        onRefresh: () async => controller.fetchBookings(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: _buildErrorState(
              controller.errorMessage.value,
              controller.fetchBookings,
            ),
          ),
        ),
      );
    }

    if (controller.bookings.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => controller.fetchBookings(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: _buildEmptyState(
              'No completed bookings',
              controller.fetchBookings,
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => controller.fetchBookings(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: controller.bookings.length,
        itemBuilder: (context, i) => _buildCompleteCard(context, controller.bookings[i]),
        separatorBuilder: (_, __) => const SizedBox(height: 8),
      ),
    );
  }
}