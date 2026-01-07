import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/features/booking/screens/booking_tabs/tab_controllers/ongoing_job_tab_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/utils/api/app_url.dart';
import '../../widgets/job_details_modal.dart';

class OngoingJobTab extends StatelessWidget {
  final OngoingJobController controller;
  const OngoingJobTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return RefreshIndicator(
        onRefresh: () async {
          await controller.fetchOngoingJobs();
        },
        child: _buildContent(),
      );
    });
  }

  Widget _buildContent() {
    if (controller.isLoading.value && controller.ongoingJobs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading your ongoing jobs...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (controller.ongoingJobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hourglass_empty_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            const Text(
              'No Ongoing Jobs',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'When your booking requests are accepted by providers and in progress, they will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                controller.fetchOngoingJobs();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, size: 20),
                  SizedBox(width: 8),
                  Text('Refresh'),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.ongoingJobs.length + (controller.hasMore.value ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == controller.ongoingJobs.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: controller.isLoading.value
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: () {
                  controller.loadMoreOngoingJobs();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Load More'),
              ),
            ),
          );
        }

        final Map<String, dynamic> job = controller.ongoingJobs[index];
        return _buildJobCard(job);
      },
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    // Extract service and provider data
    final Map<String, dynamic> service = job['service'] ?? {};
    final Map<String, dynamic> author = service['author'] ?? {};
    final Map<String, dynamic> subCategory = service['subCategory'] ?? {};

    // Build image URL
    String imageUrl = '';
    if (author['image'] != null && author['image'].toString().isNotEmpty) {
      String imagePath = author['image'].toString();
      if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
        imageUrl = imagePath;
      } else {
        imageUrl = '${AppUrl.imageBaseUrl}/$imagePath';
      }
    }

    // Get status
    String status = job['status']?.toString() ?? 'pending';

    return GestureDetector(
      onTap: () => _showJobDetailsModal(job),
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.greyColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Provider Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey.shade200,
                    child: Icon(
                      Icons.business,
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
                    Icons.business,
                    size: 40,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Content Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Business Name
                    Text(
                      author['name']?.toString() ?? 'Unknown Provider',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Service Name
                    Text(
                      subCategory['name']?.toString() ?? 'Unknown Service',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Location Row
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            job['location']?.toString() ?? 'Location not specified',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    // Booking Date (if available)
                    if (job['bookingDate'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _formatBookingDate(job['bookingDate'].toString()),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 1,
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
        ),
      ),
    );
  }

  String _formatBookingDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }


  void _showJobDetailsModal(Map<String, dynamic> job) {
    JobDetailsModal.show(
      context: Get.context!,
      job: job,
      showCancelButton: false, // Ongoing jobs typically can't be cancelled
      showContactButtons: true,
      onContactPressed: () => _handleContactProvider(job),
      customTitle: 'Ongoing Job Details',
    );
  }

  void _handleContactProvider(Map<String, dynamic> job) {
    final Map<String, dynamic> service = job['service'] ?? {};
    final Map<String, dynamic> author = service['author'] ?? {};
    final String providerName = author['name']?.toString() ?? 'Provider';

    Get.snackbar(
      'Contact Provider',
      'Opening chat with $providerName...',
      backgroundColor: AppColors.primaryColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
}