
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';
import 'package:url_launcher/url_launcher.dart';

class JobDetailsModal {
  static void show({
    required BuildContext context,
    required Map<String, dynamic> job,
    bool showCancelButton = true,
    bool showContactButtons = true,
    VoidCallback? onCancelPressed,
    String? customTitle,
  }) {
    // Extract service and provider data
    final Map<String, dynamic> service = job['service'] ?? <String, dynamic>{};
    final Map<String, dynamic> author = service['author'] ?? <String, dynamic>{};
    final Map<String, dynamic> subCategory = service['subCategory'] ?? <String, dynamic>{};

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

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
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
                children: <Widget>[
                  Text(
                    customTitle ?? 'Job Details',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
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
                  children: <Widget>[
                    // Provider Image and Info
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: imageUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  placeholder: (BuildContext context, String url) => Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey.shade200,
                                    child: const Center(
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  ),
                                  errorWidget: (BuildContext context, String url, Object error) =>
                                      Container(
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                author['name']?.toString() ?? 'Unknown Provider',
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

                    // Additional Information
                    if (job['details'] != null && job['details'].toString().isNotEmpty) ...<Widget>[
                      const SizedBox(height: 24),
                      const Text(
                        'Job Details',
                        style: const TextStyle(
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
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Action Buttons (Conditional)
                    if (showCancelButton) ...<Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Get.back();
                                onCancelPressed?.call();
                              },
                              label: const Text('Cancel Job'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Additional Contact Options
                    if (showContactButtons &&
                        (providerPhone != null || providerEmail != null)) ...<Widget>[
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
                          if (providerPhone != null && providerEmail != null)
                            const SizedBox(width: 16),
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
                          if (providerPhone != null && providerEmail != null)
                            const SizedBox(width: 16),
                          // Message button can stay if you have chat, but we'll omit logic for now
                          // You can keep it as a placeholder or remove
                          _buildContactOption(
                            icon: CupertinoIcons.chat_bubble_text_fill,
                            label: 'Message',
                            color: Colors.purple,
                            onTap: () {
                              Get.back();
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
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
    );
  }

  static Future<void> _launchPhoneNumber(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
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
    final Uri emailUri = Uri(scheme: 'mailto', path: email);

    try {
      final bool launched = await launchUrl(emailUri, mode: LaunchMode.externalApplication);
      if (!launched) {
        Get.snackbar(
          'No Email App',
          'No email app found. Please install one to contact the provider.',
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

  // ========== Rest of the helper methods (unchanged) ==========

  static Widget _buildDetailItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500),
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
    const List<String> days = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  static String _getMonthName(int month) {
    const List<String> months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  static String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}









