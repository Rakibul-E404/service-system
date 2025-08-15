import 'package:flutter/material.dart';
import 'package:manx_mate/core/config/app_colors.dart' show AppColors;
import 'package:manx_mate/core/config/app_sizes.dart';


class AppTextUnderline extends StatelessWidget {
  const AppTextUnderline({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 56,
      child: Divider(thickness: 8, color: AppColors.primaryColor, height: AppSizes.md),
    );
  }
}
