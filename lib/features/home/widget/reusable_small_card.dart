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
        elevation: 0,
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Image Container
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
                    ),
                    child: imagePath.isNotEmpty
                        ? CustomCachedImage(
                      imageUrl: imagePath,
                      fit: BoxFit.cover,
                    )
                        : const Center(
                      child: Icon(
                        Icons.category,
                        size: 40,
                        color: AppColors.greyColor,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              /// Title
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.xs,
                ),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blackColor,
                    height: 1.2,
                  ),
                  maxLines: 1,
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