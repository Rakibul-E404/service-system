/**
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
*/








///
///
///
/// todo::: fixing the design as new update-->>
///
///
///




import 'package:flutter/material.dart';
import '../../../core/common/components/custom_network_image.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_sizes.dart';

class ReusableSmallCard extends StatelessWidget {
  final String imagePath;
  final VoidCallback onTap;
  final String title;
  final double? elevation;
  final Color? backgroundColor;

  const ReusableSmallCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.onTap,
    this.elevation = 0,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
        ),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(AppSizes.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
            color: backgroundColor ?? AppColors.whiteColor2,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // Image Container
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.primaryColor.withValues(alpha: 0.3),
                        width: 0,
                      ),
                      borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
                    ),
                    child: CustomCachedImage(
                      imageUrl: imagePath,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Title
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.xs,
                  vertical: 6,
                ),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blackColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}