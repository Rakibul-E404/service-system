import 'package:flutter/material.dart';

import '../../../core/common/components/custom_network_image.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_sizes.dart';

class ReusableSmallCard extends StatelessWidget {
  final String imagePath;
final VoidCallback onTap ;
  final String title;

  const ReusableSmallCard({super.key, required this.imagePath, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withValues(alpha: 0.1),
          border: Border.all(color: AppColors.primaryColor, width: 2),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppSizes.lg),
            topRight: Radius.circular(AppSizes.sm),
            bottomRight: Radius.circular(AppSizes.lg),
            bottomLeft: Radius.circular(AppSizes.sm),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
              child: CustomCachedImage(imageUrl: imagePath, height: 100),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.sm),
              child: Divider(thickness: 2, color: AppColors.primaryColor),
            ),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
