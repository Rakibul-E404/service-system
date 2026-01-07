/**
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../model/booking_service_model.dart';
import '../../../../core/utils/api/app_url.dart';

void showQuoteDetailsModal(BookingServiceModel quote) {
  // Build image URL
  String imageUrl = '';
  if (quote.subCategory.image.isNotEmpty) {
    if (quote.subCategory.image.startsWith('http://') ||
        quote.subCategory.image.startsWith('https://')) {
      imageUrl = quote.subCategory.image;
    } else {
      imageUrl = '${AppUrl.imageBaseUrl}/${quote.subCategory.image}';
    }
  }

  Get.bottomSheet(
    Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
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
                const Text(
                  'Quote Details',
                  style: TextStyle(
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
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Provider Image and Info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                              child: CircularProgressIndicator(
                                  strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
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
                            const Text(
                              'FreshOps Business',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              quote.subCategory.name,
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
                    title: 'Scheduled Date',
                    value: _formatDate(quote.date),
                  ),

                  const SizedBox(height: 16),

                  _buildDetailItem(
                    icon: Icons.location_on_outlined,
                    iconColor: Colors.red,
                    title: 'Location',
                    value:
                    quote.location.isNotEmpty ? quote.location : 'Not specified',
                  ),

                  const SizedBox(height: 16),

                  _buildDetailItem(
                    icon: Icons.map_outlined,
                    iconColor: Colors.green,
                    title: 'Region',
                    value: _capitalizeFirst(quote.region),
                  ),

                  const SizedBox(height: 16),

                  _buildDetailItem(
                    icon: Icons.access_time,
                    iconColor: Colors.purple,
                    title: 'Created',
                    value: _formatRelativeTime(quote.createdAt),
                  ),

                  // Additional Information
                  if (quote.additionalInfo.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Additional Information',
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
                        quote.additionalInfo,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Get.back();
                            _handleCancelQuote(quote);
                          },
                          icon: const Icon(Icons.remove_circle, size: 20),
                          label: const Text('Remove'),
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
  );
}

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

String _formatDate(DateTime date) {
  return '${_getDayName(date.weekday)}, ${date.day} ${_getMonthName(date.month)} ${date.year}';
}

String _getDayName(int weekday) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return days[weekday - 1];
}

String _getMonthName(int month) {
  const months = [
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
    'Dec'
  ];
  return months[month - 1];
}

String _formatRelativeTime(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays > 365) {
    final years = (difference.inDays / 365).floor();
    return '$years ${years == 1 ? 'year' : 'years'} ago';
  } else if (difference.inDays > 30) {
    final months = (difference.inDays / 30).floor();
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
}

String _capitalizeFirst(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1).toLowerCase();
}

void _handleCancelQuote(BookingServiceModel quote) {
  Get.defaultDialog(
    title: 'Cancel Quote',
    middleText: 'Are you sure you want to cancel this quote request?',
    textConfirm: 'Yes, Cancel',
    textCancel: 'No',
    confirmTextColor: Colors.white,
    buttonColor: Colors.red,
    cancelTextColor: Colors.grey.shade700,
    onConfirm: () {
      Get.back();
      Get.snackbar(
        'Cancelled',
        'Quote has been cancelled successfully',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    },
  );
}*/











import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../model/booking_service_model.dart';
import '../../../../core/utils/api/app_url.dart';
import '../screens/booking_tabs/tab_controllers/quote_job_tab_controller.dart';

void showQuoteDetailsModal(
    BookingServiceModel quote,
    QuoteController controller,
    ) {
  // Build image URL
  String imageUrl = '';
  if (quote.subCategory.image.isNotEmpty) {
    if (quote.subCategory.image.startsWith('http://') ||
        quote.subCategory.image.startsWith('https://')) {
      imageUrl = quote.subCategory.image;
    } else {
      imageUrl = '${AppUrl.imageBaseUrl}/${quote.subCategory.image}';
    }
  }

  Get.bottomSheet(
    Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
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
                const Text(
                  'Quote Details',
                  style: TextStyle(
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
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Provider Image and Info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _imagePlaceholder(),
                          errorWidget: (_, __, ___) =>
                              _imageErrorPlaceholder(),
                        )
                            : _imageErrorPlaceholder(),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'FreshOps Business',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              quote.subCategory.name,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
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
                    title: 'Scheduled Date',
                    value: _formatDate(quote.date),
                  ),
                  const SizedBox(height: 16),

                  _buildDetailItem(
                    icon: Icons.location_on_outlined,
                    iconColor: Colors.red,
                    title: 'Location',
                    value: quote.location.isNotEmpty
                        ? quote.location
                        : 'Not specified',
                  ),
                  const SizedBox(height: 16),

                  _buildDetailItem(
                    icon: Icons.map_outlined,
                    iconColor: Colors.green,
                    title: 'Region',
                    value: _capitalizeFirst(quote.region),
                  ),
                  const SizedBox(height: 16),

                  _buildDetailItem(
                    icon: Icons.access_time,
                    iconColor: Colors.purple,
                    title: 'Created',
                    value: _formatRelativeTime(quote.createdAt),
                  ),

                  if (quote.additionalInfo.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Additional Information',
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
                        quote.additionalInfo,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Get.back();
                            _confirmCancelQuote(controller, quote.id);
                          },
                          icon: const Icon(Icons.remove_circle, size: 20),
                          label: const Text('Remove'),
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
  );
}

/// ================= CONFIRM DELETE =================
void _confirmCancelQuote(QuoteController controller, String quoteId) {
  Get.defaultDialog(
    title: 'Cancel Quote',
    middleText: 'Are you sure you want to cancel this quote request?',
    textConfirm: 'Yes, Cancel',
    textCancel: 'No',
    confirmTextColor: Colors.white,
    buttonColor: Colors.red,
    cancelTextColor: Colors.grey.shade700,
    onConfirm: () {
      Get.back();
      controller.deleteQuote(quoteId);
    },
  );
}

/// ================= HELPERS =================
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
        child: Icon(icon, size: 20, color: iconColor),
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
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _imagePlaceholder() => Container(
  width: 100,
  height: 100,
  color: Colors.grey.shade200,
  child: const Center(
    child: CircularProgressIndicator(strokeWidth: 2),
  ),
);

Widget _imageErrorPlaceholder() => Container(
  width: 100,
  height: 100,
  color: Colors.grey.shade200,
  child: Icon(Icons.person, size: 40, color: Colors.grey.shade400),
);

String _formatDate(DateTime date) =>
    '${_getDayName(date.weekday)}, ${date.day} ${_getMonthName(date.month)} ${date.year}';

String _getDayName(int weekday) =>
    const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][weekday - 1];

String _getMonthName(int month) =>
    const ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][month - 1];

String _formatRelativeTime(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inDays > 365) return '${(diff.inDays / 365).floor()} years ago';
  if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} months ago';
  if (diff.inDays > 0) return '${diff.inDays} days ago';
  if (diff.inHours > 0) return '${diff.inHours} hours ago';
  if (diff.inMinutes > 0) return '${diff.inMinutes} minutes ago';
  return 'just now';
}

String _capitalizeFirst(String text) =>
    text.isEmpty ? text : text[0].toUpperCase() + text.substring(1).toLowerCase();
