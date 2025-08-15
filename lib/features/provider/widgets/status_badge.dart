import 'package:flutter/material.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_sizes.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    // Set the color based on the status
    Color badgeColor;
    switch (status.toLowerCase()) {
      case 'requested':
        badgeColor = AppColors.primaryColor;
        break;
      case 'completed':
        badgeColor = Colors.green;
        break;
      case 'cancelled':
      default:
        badgeColor = Colors.red;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        border: Border.all(color: badgeColor),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
      ),
      child: Text(
        status.capitalize(),
        // You can use an extension method for capitalization
        style: context.txtTheme.bodySmall?.copyWith(color: Colors.white, fontSize: 11),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) {
      return this;
    }
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}
