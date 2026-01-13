import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/common/widgets/reusable_button.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';
import 'package:manx_mate/features/provider/screens/booking_tabs/provider_request_controller.dart';
import 'package:manx_mate/model/booking_service_model.dart';


class RequestTab extends StatelessWidget {
  const RequestTab({super.key});

  ProviderRequestController get controller => Get.find<ProviderRequestController>();

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

  Widget _buildRequestCard(BuildContext context, BookingServiceModel booking) {
  // Accessing properties directly from the Model
  final String bookingId = booking.id;
  final String location = booking.location.isEmpty ? 'Unknown' : booking.location;
  
  // The model already handles the 'details' vs 'additionalInfo' logic
  final String description = booking.additionalInfo.isEmpty ? 'No description' : booking.additionalInfo;
  
  // Format date safely using the DateTime object from the model
  final String formattedDate = '${booking.date.day}/${booking.date.month}/${booking.date.year}';

  // Access nested Author object
  final String authorName = booking.author.name;
  final String? authorImagePath = booking.author.image;
  
  final bool isProcessing = controller.isProcessing(bookingId);

  return Card(
    color: Colors.white,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: Colors.grey[300]!, width: 1),
    ),
    child: InkWell(
      onTap: () {
        debugPrint('🖱️ Card Tapped: BookingID $bookingId');
        _showBookingDetails(context, booking);
      },
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
                  onBackgroundImageError: (exception, stackTrace) {
                    debugPrint('🖼️ Image Load Error: $authorImagePath');
                  },
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
            Text(
              description.length > 50 ? '${description.substring(0, 50)}...' : description,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
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
            const SizedBox(height: 16),
            Divider(height: 1, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isProcessing
                        ? null
                        : () {
                            _showConfirmationDialog(
                              context,
                              'Reject Request',
                              'Are you sure you want to reject this booking request?',
                              () => controller.respondToBooking(
                                bookingId: bookingId,
                                status: 'rejected',
                              ),
                            );
                          },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: isProcessing
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red))
                        : const Text('Reject', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isProcessing
                        ? null
                        : () {
                            _showConfirmationDialog(
                              context,
                              'Accept Request',
                              'Are you sure you want to accept this booking request?',
                              () => controller.respondToBooking(
                                bookingId: bookingId,
                                status: 'accepted',
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: isProcessing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Accept', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

  void _showConfirmationDialog(BuildContext context, String title, String message, VoidCallback onConfirm) {
    debugPrint('❓ Showing Confirmation Dialog: $title');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                debugPrint('❌ Dialog: User selected NO');
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                debugPrint('✅ Dialog: User selected YES');
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

  Widget _buildDetailRow({required IconData icon, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: AppColors.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      debugPrint('🎨 RequestTab Re-building: Loading=${controller.isLoading.value}, Count=${controller.bookings.length}');

if (controller.isLoading.value) {
    return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
  }

  // 2. ONLY show Empty State if we are NOT loading AND the list is truly empty
  if (controller.bookings.isEmpty) {
    return RefreshIndicator(
      onRefresh: () async => controller.fetchBookings(refresh: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: _buildEmptyState('No new booking requests', () => controller.fetchBookings(refresh: true)),
        ),
      ),
    );
  }

      return RefreshIndicator(
        onRefresh: () async {
          debugPrint('🔝 Pull-to-refresh triggered');
          await controller.fetchBookings(refresh: true);
        },
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: controller.bookings.length,
          itemBuilder: (context, i) => _buildRequestCard(context, controller.bookings[i]),
          separatorBuilder: (_, __) => const SizedBox(height: 8),
        ),
      );
    }
    );
  }

  // Build helpers for states
  Widget _buildEmptyState(String message, VoidCallback onRefresh) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey[600], fontSize: 16), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          SizedBox(width: 150, child: ReusableButton(onTap: onRefresh, label: "Refresh")),
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
          const SizedBox(height: 16),
          Text(error, style: TextStyle(color: Colors.red[600], fontSize: 16), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          SizedBox(width: 150, child: ReusableButton(onTap: onRetry, label: "Try Again")),
        ],
      ),
    );
  }
}