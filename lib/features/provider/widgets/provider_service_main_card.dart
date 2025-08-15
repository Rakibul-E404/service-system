import 'package:flutter/material.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import 'package:manx_mate/features/provider/widgets/status_badge.dart';

import '../../../core/common/components/custom_network_image.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_sizes.dart';

class ProviderServiceMainCard extends StatelessWidget {
  final String serviceImageUrl;

  final String? serviceStatus;

  final String serviceTitle;

  final String serviceDetails;

  final String serviceLocation;

  final String? providerImageUrl;

  final String? providerName;
  final bool showBottomPart;

  const ProviderServiceMainCard({
    super.key,
    required this.serviceImageUrl,
    required this.serviceStatus,
    required this.serviceTitle,
    required this.serviceDetails,
    required this.serviceLocation,
    required this.providerImageUrl,
    required this.providerName,
    this.showBottomPart = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
        border: Border.all(color: AppColors.primaryColor),
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

                    child: CustomCachedImage(imageUrl: serviceImageUrl, height: 120),
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
                    if (serviceStatus != null)
                      Align(
                        alignment: Alignment.bottomRight,
                        child: StatusBadge(status: serviceStatus ?? ''),
                      ),
                    Text(serviceTitle, style: context.txtTheme.titleLarge),
                    Text(
                      serviceDetails,
                      style: context.txtTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                    Row(
                      children: <Widget>[
                        const Icon(Icons.location_on_outlined),
                        Text(
                          serviceLocation,
                          style: context.txtTheme.bodyMedium?.copyWith(color: Colors.grey),
                        ),
                      ],
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
                    child: CustomCachedImage(
                      imageUrl: providerImageUrl ?? '',
                      width: 40,
                      height: 40,
                    ),
                  ),
                  Text(providerName ?? '', style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
