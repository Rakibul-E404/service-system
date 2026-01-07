import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/features/booking/screens/booking_tabs/tab_controllers/active_job_tab_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/network/network_response.dart';
import '../../../../core/utils/api/app_url.dart';
import '../../../../core/utils/token_service/token_storage_service.dart';
import '../../widgets/job_details_modal.dart';

class ActiveJobTab extends StatelessWidget {
  final ActiveJobController controller;
  const ActiveJobTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return RefreshIndicator(
        onRefresh: () async {
          await controller.refreshActiveJobs();
          // Force UI update after refresh
          controller.activeJobs.refresh();
        },
        child: _buildContent(context),
      );
    });
  }

  Widget _buildContent(BuildContext context) {
    if (controller.isLoading.value && controller.activeJobs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading your active jobs...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (controller.activeJobs.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.work_outline,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No Active Jobs',
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
                        'When your booking requests are accepted by providers, they will appear here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () async {
                        await controller.refreshActiveJobs();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
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
              ),
            ),
          );
        },
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: controller.activeJobs.length + (controller.hasMore.value ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == controller.activeJobs.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: controller.isLoading.value
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: () {
                  controller.loadMoreActiveJobs();
                },
                child: const Text('Load More'),
              ),
            ),
          );
        }

        final Map<String, dynamic> job = controller.activeJobs[index];
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showJobDetailsModal(Map<String, dynamic> job) {
    JobDetailsModal.show(
      context: Get.context!,
      job: job,
      showCancelButton: true,
      showContactButtons: true,
      onCancelPressed: () => _handleCancelJob(job),
      customTitle: 'Active Job Details',
    );
  }

  void _handleCancelJob(Map<String, dynamic> job) {
    final String bookingId = job['_id']?.toString() ?? '';
    if (bookingId.isEmpty) {
      Get.snackbar(
        'Error',
        'Invalid booking ID',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    Get.defaultDialog(
      title: 'Cancel Job',
      middleText: 'Are you sure you want to cancel this job?',
      textConfirm: 'Yes, Cancel',
      textCancel: 'No',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      cancelTextColor: Colors.grey.shade700,
      onConfirm: () async {
        Get.back(); // Close confirmation dialog

        // Show loading indicator via snackbar
        Get.snackbar(
          'Cancelling...',
          'Please wait',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          isDismissible: false,
          shouldIconPulse: false,
        );

        // Get access token
        final SharedPrefService sharedPrefService = Get.find<SharedPrefService>();
        final String? accessToken = await sharedPrefService.getAccessToken();

        if (accessToken == null || accessToken.isEmpty) {
          Get.closeAllSnackbars();
          Get.snackbar(
            'Session Expired',
            'Please log in again.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }

        // Send PATCH request to cancel booking
        final NetworkResponse response = await controller.networkCaller.patchRequest(
          AppUrl.userCanceledBooking(bookingId),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: {
            'status': 'cancelled',
          },
        );

        Get.closeAllSnackbars();

        if (response.isSuccess) {
          Get.snackbar(
            snackPosition: SnackPosition.BOTTOM,
            'Success',
            'Job has been cancelled successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );

          // Refresh the active jobs list immediately
          await controller.refreshActiveJobs();

          // Force UI update
          controller.activeJobs.refresh();
        } else {
          Get.snackbar(
            'Failed',
            response.errorMessage ?? 'Unable to cancel job. Please try again.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        }
      },
    );
  }
}


