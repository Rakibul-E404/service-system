import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/common/widgets/reusable_button.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';
import 'package:manx_mate/features/provider/screens/booking_tabs/provider_quote_controller.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../shared/subscriptions_controller.dart';
import '../../../message/controllers/message_controller.dart';

class ProviderQuoteTab extends StatelessWidget {
  const ProviderQuoteTab({super.key});

  // Controllers
  ProviderQuoteController get controller => Get.find<ProviderQuoteController>();
  SubscriptionsController get subController => Get.find<SubscriptionsController>();
  MessageController get messageController => Get.find<MessageController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
      }

      if (controller.errorMessage.isNotEmpty) {
        return RefreshIndicator(
          onRefresh: () async => controller.fetchBookings(refresh: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: _buildErrorState(controller.errorMessage.value, () => controller.fetchBookings(refresh: true)),
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
              child: _buildEmptyState('No pending quotes', () => controller.fetchBookings(refresh: true)),
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
          itemBuilder: (context, i) => _buildQuoteCard(context, controller.bookings[i]),
          separatorBuilder: (_, __) => const SizedBox(height: 8),
        ),
      );
    });
  }

  // --- UI Components ---

  Widget _buildQuoteCard(BuildContext context, Map<String, dynamic> booking) {
    final Map<String, dynamic> author = booking['author'] ?? {};
    final Map<String, dynamic> subCategory = booking['subCategory'] ?? {};
    final String bookingId = booking['_id']?.toString() ?? '';
    final String categoryName = subCategory['name']?.toString() ?? 'Service Request';
    final String location = booking['location']?.toString() ?? 'Unknown';
    final String additionalInfo = booking['additionalInfo']?.toString() ?? 'No additional details provided';
    final String status = booking['status']?.toString() ?? 'active';
    final String bookingDate = booking['date']?.toString() ?? '';

    String formattedDate = '';
    try {
      final date = DateTime.parse(bookingDate);
      formattedDate = '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      formattedDate = 'N/A';
    }

    final authorName = author['name']?.toString() ?? 'Unknown';
    final authorImagePath = author['image']?.toString();
    final isProcessing = controller.isProcessing(bookingId);

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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        Text(authorName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                        const SizedBox(height: 2),
                        Text("Client", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: status == 'active' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(status.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: status == 'active' ? Colors.green : Colors.orange)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(categoryName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
              const SizedBox(height: 4),
              Text(
                additionalInfo.length > 60 ? '${additionalInfo.substring(0, 60)}...' : additionalInfo,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_month, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(formattedDate, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const SizedBox(width: 16),
                  Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(child: Text(location, style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis)),
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
                      onPressed: isProcessing ? null : () => _showConfirmationDialog(context, 'Cancel Booking', 'Are you sure?', () => controller.cancelBookingLocally(bookingId)),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      child: isProcessing ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isProcessing ? null : () => _showConfirmationDialog(context, 'Accept Booking', 'Are you sure?', () => controller.respondToBooking(bookingId: bookingId)),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      child: isProcessing ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Accept', style: TextStyle(fontWeight: FontWeight.w600)),
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

  // --- Modal & Contact Flow ---

  void _showBookingDetails(BuildContext context, Map<String, dynamic> booking) {
    final Map<String, dynamic> author = booking['author'] ?? {};
    final Map<String, dynamic> subCategory = booking['subCategory'] ?? {};
    final String? authorPhone = author['phone']?.toString();
    final String? authorEmail = author['email']?.toString();
    final String authorId = author['_id']?.toString() ?? '';
    final String authorImg = _getImageUrl(author['image']?.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          children: [
            Center(child: Container(margin: const EdgeInsets.symmetric(vertical: 12), width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Quote Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(radius: 30, backgroundImage: NetworkImage(authorImg)),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(author['name']?.toString() ?? 'Unknown', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('Client Inquiry', style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildDetailRow(icon: Icons.work_outline, label: 'Service Category', value: subCategory['name']?.toString() ?? 'Service'),
                    const SizedBox(height: 16),
                    _buildDetailRow(icon: Icons.description, label: 'Additional Info', value: booking['additionalInfo']?.toString() ?? 'No details'),
                    const SizedBox(height: 16),
                    _buildDetailRow(icon: Icons.location_on, label: 'Location', value: booking['location']?.toString() ?? 'Unknown'),

                    const SizedBox(height: 40),
                    const Center(child: Text('Quick Contact', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey))),
                    const SizedBox(height: 20),

                    // --- CONTACT BUTTONS ROW ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Call
                        _buildContactOption(
                          icon: Icons.call, label: 'Call', color: Colors.green,
                          onTap: () {
                            if (subController.canCall && authorPhone != null) {
                              Navigator.pop(context);
                              _launchPhone(authorPhone);
                            } else {
                              subController.showPremiumContactAlert("Phone Call");
                            }
                          },
                        ),
                        // Email
                        if (authorEmail != null && authorEmail.isNotEmpty)
                          _buildContactOption(
                            icon: Icons.email, label: 'Email', color: Colors.blue,
                            onTap: () {
                              if (subController.canEmail) {
                                Navigator.pop(context);
                                _launchEmail(authorEmail);
                              } else {
                                subController.showPremiumContactAlert("Email");
                              }
                            },
                          ),
                        // Message (Chat)
                        _buildContactOption(
                          icon: Icons.chat, label: 'Message', color: Colors.purple,
                          onTap: () {
                            if (subController.canMessage && authorId.isNotEmpty) {
                              Navigator.pop(context);
                              messageController.createConversationAndNavigate(
                                receiverId: authorId,
                                receiverName: author['name']?.toString() ?? 'Client',
                                receiverAvatar: authorImg,
                              );
                            } else {
                              subController.showPremiumContactAlert("Messaging");
                            }
                          },
                        ),
                      ],
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

  // --- Helper Methods ---

  String _getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return 'https://via.placeholder.com/150';
    if (imagePath.startsWith('http')) return imagePath;
    return '${AppUrl.imageBaseUrl}/$imagePath';
  }

  void _launchPhone(String phone) async {
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  void _launchEmail(String email) async {
    final url = Uri(scheme: 'mailto', path: email);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      Get.snackbar('Error', 'No email app found', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Widget _buildContactOption({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[700])),
      ],
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

  void _showConfirmationDialog(BuildContext context, String title, String message, VoidCallback onConfirm) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text(title), content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('No')),
        TextButton(onPressed: () { Navigator.pop(context); onConfirm(); }, child: const Text('Yes')),
      ],
    ));
  }

  Widget _buildEmptyState(String message, VoidCallback onRefresh) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
      const SizedBox(height: 16),
      Text(message, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
      const SizedBox(height: 24),
      SizedBox(width: 150, child: ReusableButton(onTap: onRefresh, label: "Refresh")),
    ]));
  }

  Widget _buildErrorState(String error, VoidCallback onRetry) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
      const SizedBox(height: 16),
      Text(error, style: TextStyle(color: Colors.red[600], fontSize: 16)),
      const SizedBox(height: 24),
      SizedBox(width: 150, child: ReusableButton(onTap: onRetry, label: "Try Again")),
    ]));
  }
}