import 'package:flutter/material.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import '../../../core/common/components/custom_network_image.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_sizes.dart';

class ProviderServiceSecondaryCard extends StatelessWidget {
  final String serviceImageUrl;

  final String serviceTitle;

  final String serviceDetails;

  final String time;

  final String? providerName;
  final bool showBottomPart;

  const ProviderServiceSecondaryCard({
    super.key,
    required this.serviceImageUrl,
    required this.serviceTitle,
    required this.serviceDetails,
    required this.time,
    required this.providerName,
    this.showBottomPart = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
        border: Border.all(color: AppColors.primaryColor),
        color: AppColors.primaryColorLight.withValues(alpha: 0.4),
      ),
      child: Column(
        children: <Widget>[
          Row(
            spacing: AppSizes.sm,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),

                    border: const Border(
                      right: BorderSide(color: AppColors.primaryColor, width: 5),
                      bottom: BorderSide(color: AppColors.primaryColor, width: 1),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),

                    child: CustomCachedImage(imageUrl: serviceImageUrl, height: 90),
                  ),
                ),
              ),

              ///====== The texts ====>
              Expanded(
                flex: 4,
                child: Column(
                  spacing: 2,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(serviceTitle, style: context.txtTheme.titleLarge),
                    Text(
                      serviceDetails,
                      style: context.txtTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),

          /// =================> The Bottom of Other Card ================>
          if (showBottomPart == true)
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppSizes.borderRadiusLg),
                  bottomRight: Radius.circular(AppSizes.borderRadiusLg),
                ),
                color: AppColors.primaryColorLight,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      time,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IntrinsicWidth(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: const Text("Cancel", style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IntrinsicWidth(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: const Text("Accept", style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
