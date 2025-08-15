import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/routes/app_routes.dart';

class ProviderTopBar extends StatelessWidget {
  const ProviderTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xl, horizontal: AppSizes.sm),
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.sm,  ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.primaryColor, width: 2)),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppSizes.borderRadiusXl),
          bottomRight: Radius.circular(AppSizes.borderRadiusXl),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Text("Hey Isahn.H"),
          Row(
            children: <Widget>[
              const CircleAvatar(radius: 24),
              IconButton(
                onPressed: () {
                  Get.toNamed(AppRoutes.notificationPage);
                },
                icon: const Icon(CupertinoIcons.bell),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
