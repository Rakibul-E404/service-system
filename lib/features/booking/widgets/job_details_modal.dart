import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/app_colors.dart';
import '../../home/screens/add_review_page.dart';

class JobDetailsModal {
  static void show({
    required BuildContext context,
    required Map<String, dynamic> job,
    bool showCancelButton = true,
    bool showContactButtons = true,
    VoidCallback? onCancelPressed,
    String? customTitle,
  }) {
    final Map<String, dynamic> service = job['service'] ?? <String, dynamic>{};
    final Map<String, dynamic> author = service['author'] ?? <String, dynamic>{};
    final Map<String, dynamic> subCategory = service['subCategory'] ?? <String, dynamic>{};

    String imageUrl = '';
    if (author['image'] != null && author['image'].toString().isNotEmpty) {
      final String imagePath = author['image'].toString();
      imageUrl = imagePath.startsWith('http')
          ? imagePath
          : '${AppUrl.imageBaseUrl}/$imagePath';
    }

    final String? providerPhone = author['phone']?.toString();
    final String? providerEmail = author['email']?.toString();

    // final bool isPastJob = _isPastJob(job['bookingDate']);
    final bool isPastJob =true;

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    customTitle ?? 'Job Details',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: imageUrl.isNotEmpty
                              ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: Colors.grey.shade200,
                              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            ),
                            errorWidget: (_, __, ___) => _fallbackImage(),
                          )
                              : _fallbackImage(),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                author['name']?.toString() ?? 'Unknown Provider',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                subCategory['name']?.toString() ?? 'Unknown Service',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

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

                    if (job['details'] != null && job['details'].toString().isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Text('Job Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(job['details'].toString()),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // ✅ ADD REVIEW BUTTON (PAST JOB ONLY)
                    if (isPastJob) ...[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.rate_review),
                              label: const Text('Give Review',style: TextStyle(
                                color: AppColors.whiteColor
                              ),),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                // print(service);
                                // print("rolalala");
                                Get.to(
                                      () => AddReviewPage(
                                    providerName: author['name']?.toString() ?? 'Provider',
                                    serviceId: job['_id'].toString(),
                                  ),
                                );

                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],

                    if (showCancelButton && !isPastJob) ...[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Get.back();
                                onCancelPressed?.call();
                              },
                              icon: const Icon(Icons.cancel),
                              label: const Text('Cancel Job'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (showContactButtons && (providerPhone != null || providerEmail != null)) ...[
                      const SizedBox(height: 24),
                      const Text('Quick Contact', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          if (providerPhone != null)
                            _buildContactOption(
                              icon: Icons.call,
                              label: 'Call',
                              color: Colors.green,
                              onTap: () {
                                Get.back();
                                _launchPhoneNumber(providerPhone);
                              },
                            ),
                          if (providerEmail != null) const SizedBox(width: 16),
                          if (providerEmail != null)
                            _buildContactOption(
                              icon: Icons.email,
                              label: 'Email',
                              color: Colors.blue,
                              onTap: () {
                                Get.back();
                                _launchEmail(providerEmail);
                              },
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  static Widget _fallbackImage() => Container(
    width: 100,
    height: 100,
    color: Colors.grey.shade200,
    child: Icon(Icons.business, size: 40, color: Colors.grey.shade400),
  );

  static bool _isPastJob(dynamic bookingDate) {
    try {
      if (bookingDate == null) return false;
      final DateTime date = bookingDate is String
          ? DateTime.parse(bookingDate).toLocal()
          : bookingDate;
      return date.isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  static Future<void> _launchPhoneNumber(String phone) async {
    final Uri uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  static Future<void> _launchEmail(String email) async {
    final Uri uri = Uri(scheme: 'mailto', path: email);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Widget _buildDetailItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildContactOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(color: color)),
        ],
      ),
    );
  }

  static String _formatDate(dynamic date) {
    try {
      final DateTime d = date is String ? DateTime.parse(date) : date;
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) {
      return 'Date not set';
    }
  }

  static String _formatRelativeTime(dynamic date) {
    try {
      final DateTime d = date is String ? DateTime.parse(date) : date;
      final Duration diff = DateTime.now().difference(d);
      if (diff.inDays > 0) return '${diff.inDays} days ago';
      if (diff.inHours > 0) return '${diff.inHours} hours ago';
      if (diff.inMinutes > 0) return '${diff.inMinutes} minutes ago';
      return 'just now';
    } catch (_) {
      return 'Recently';
    }
  }

  static String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
