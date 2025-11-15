/**
import 'package:flutter/material.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import 'package:manx_mate/core/extensions/widget_extensions.dart';

import '../../config/app_colors.dart';
import '../../config/app_sizes.dart';
import '../../utils/device/device_utility.dart';

class ReusableButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final Color bgColor;

  const ReusableButton({
    super.key,
    required this.onTap,
    required this.label,
    this.bgColor = AppColors.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),

      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),

        splashColor: AppColors.primaryColorLight,
        onTap: () {
          DeviceUtility.hapticFeedback();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
          width: double.infinity,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd)),
          child: Text(label, style: context.txtTheme.labelMedium).centered,
        ),
      ),
    );
  }
}



*/






///
///
///
///
/// todo:::::::: updating the reusable button
///
///
///
///
///



import 'package:flutter/material.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import 'package:manx_mate/core/extensions/widget_extensions.dart';
import '../../config/app_colors.dart';
import '../../config/app_sizes.dart';
import '../../utils/device/device_utility.dart';

class ReusableButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final Color bgColor;
  final bool isLoading; // ← Add isLoading parameter

  const ReusableButton({
    super.key,
    required this.onTap,
    required this.label,
    this.bgColor = AppColors.primaryColor,
    this.isLoading = false, // ← Default to false
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor.withOpacity(isLoading ? 0.6 : 1.0), // ← Dim background when loading
      borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
        splashColor: AppColors.primaryColorLight,
        onTap: isLoading
            ? null
            : () {
          DeviceUtility.hapticFeedback();
          onTap();
        }, // ← Disable tap when loading
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
          ),
          child: isLoading
              ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ).centered
              : Text(
            label,
            style: context.txtTheme.labelMedium,
          ).centered,
        ),
      ),
    );
  }
}