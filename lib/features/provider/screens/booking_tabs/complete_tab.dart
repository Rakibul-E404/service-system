import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/common/widgets/reusable_button.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';
import 'package:manx_mate/features/provider/screens/booking_tabs/provider_complete_controller.dart';
import 'package:manx_mate/model/booking_service_model.dart';
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

  // UPDATED: Now accepts BookingServiceModel
 Widget _buildCompleteCard(BuildContext context, BookingServiceModel booking) {
  final location = booking.location;
  final description = booking.additionalInfo; // Model uses additionalInfo
  
  // Directly format since these are already DateTime objects
  final formattedDate = "${booking.date.day}/${booking.date.month}/${booking.date.year}";
  
  // Using createdAt as the completion reference since completedAt isn't in your model
  final formattedCompletedDate = 'Completed on ${booking.createdAt.day}/${booking.createdAt.month}/${booking.createdAt.year}';

  final authorName = booking.author.name;
  final authorImagePath = booking.author.image;

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
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formattedDate,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description.length > 50 ? '${description.substring(0, 50)}...' : description,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    location,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.check_circle, size: 14, color: Colors.green[600]),
                const SizedBox(width: 4),
                Text(
                  formattedCompletedDate,
                  style: TextStyle(fontSize: 12, color: Colors.green[600], fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(height: 1, color: Colors.grey[300]),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _showBookingDetails(context, booking),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryColor,
                  side: BorderSide(color: AppColors.primaryColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('View Details', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  // UPDATED: Now accepts BookingServiceModel
void _showBookingDetails(BuildContext context, BookingServiceModel booking) {
  final authorImageUrl = _getImageUrl(booking.author.image);
  
  // Updated Helper: Directly accepts DateTime
  String format(DateTime date, {bool includeTime = false}) {
    final minute = date.minute.toString().padLeft(2, '0');
    return includeTime 
        ? "${date.day}/${date.month}/${date.year} at ${date.hour}:$minute"
        : "${date.day}/${date.month}/${date.year}";
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 10, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Booking Summary', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(authorImageUrl),
                        backgroundColor: Colors.grey[100],
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(booking.author.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('Client', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  _buildDetailRow(icon: Icons.work_outline, label: 'Service', value: booking.subCategory.name),
                  const SizedBox(height: 20),
                  _buildDetailRow(icon: Icons.description_outlined, label: 'Details', value: booking.additionalInfo),
                  const SizedBox(height: 20),
                  _buildDetailRow(icon: Icons.location_on_outlined, label: 'Location', value: booking.location),
                  const SizedBox(height: 20),
                  _buildDetailRow(icon: Icons.calendar_today_outlined, label: 'Scheduled Date', value: format(booking.date)),
                  const SizedBox(height: 20),
                  _buildDetailRow(icon: Icons.info_outline, label: 'Status', value: booking.status.toUpperCase()),
                  const SizedBox(height: 20),
                  _buildDetailRow(
                    icon: Icons.check_circle_outline, 
                    label: 'Completed At', 
                    value: format(booking.createdAt, includeTime: true)
                  ),
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
      if (controller.isLoading.value && controller.bookings.isEmpty) {
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
              height: MediaQuery.of(context).size.height * 0.7,
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
              height: MediaQuery.of(context).size.height * 0.7,
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
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: controller.bookings.length,
          itemBuilder: (context, i) =>
              _buildCompleteCard(context, controller.bookings[i]),
          separatorBuilder: (_, __) => const SizedBox(height: 8),
        ),
      );
    });
  }
}