/**
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/routes/app_routes.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_sizes.dart';
import '../controllers/home_top_bar_controller.dart'; // Import the HomeTopBarController

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the HomeTopBarController instance
    final HomeTopBarController controller = Get.put(HomeTopBarController());

    return Stack(
      children: <Widget>[
        // Main Card
        Container(
          margin: const EdgeInsets.only(bottom: 40),
          // Space for half of the search field
          child: Card(
            color: AppColors.whiteColor,
            elevation: 3,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
                border: const Border(bottom: BorderSide(color: AppColors.primaryColor, width: 2)),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: AppSizes.md, // Add some vertical padding
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      // Profile Image
                      Obx(() {
                        final imageUrl = controller.getImageUrl();
                        return CircleAvatar(
                          radius: AppSizes.xl,
                          backgroundImage: imageUrl.isNotEmpty
                              ? NetworkImage(imageUrl) // Use network image if available
                              : null,
                          child: imageUrl.isEmpty
                              ? const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.grey,
                          )
                              : null,
                        );
                      }),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor,
                          border: Border.all(color: AppColors.primaryColor),
                          borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                        ),
                        child: IconButton(
                          onPressed: () {
                            Get.toNamed(AppRoutes.notificationPage);
                          },
                          icon: const Icon(CupertinoIcons.bell, color: AppColors.primaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Search Field - Positioned to overlap
        Positioned(
          bottom: 0,
          left: AppSizes.md,
          right: AppSizes.md,
          child: Material(
            color: AppColors.whiteColor,
            child: InkWell(
              splashColor: AppColors.greyColor,
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
              onTap: () {
                Get.toNamed(AppRoutes.homeSearchRoute);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.md,
                    horizontal: AppSizes.md,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primaryColor),
                    borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                  ),
                  child: Row(
                    spacing: AppSizes.md,
                    children: <Widget>[
                      const Icon(CupertinoIcons.search, color: AppColors.primaryColor),
                      Text("Search a service", style: Theme.of(context).textTheme.headlineMedium),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

*/









import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/routes/app_routes.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_sizes.dart';
import '../../profile/controllers/profile_controller.dart'; // Import ProfileController instead

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Use ProfileController instead of HomeTopBarController
    final ProfileController controller = Get.find<ProfileController>();


    return Stack(
      children: <Widget>[
        // Main Card
        Container(
          margin: const EdgeInsets.only(bottom: 40),
          child: Card(
            color: AppColors.whiteColor,
            elevation: 3,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
                border: const Border(bottom: BorderSide(color: AppColors.primaryColor, width: 2)),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: AppSizes.md,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      // Profile Image
                      Obx(() {
                        final imageUrl = controller.getImageUrl();
                        return CircleAvatar(
                          radius: AppSizes.xl,
                          backgroundImage: imageUrl.isNotEmpty
                              ? NetworkImage(imageUrl)
                              : null,
                          child: imageUrl.isEmpty
                              ? const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.grey,
                          )
                              : null,
                        );
                      }),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor,
                          border: Border.all(color: AppColors.primaryColor),
                          borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                        ),
                        child: IconButton(
                          onPressed: () {
                            Get.toNamed(AppRoutes.notificationPage);
                          },
                          icon: const Icon(CupertinoIcons.bell, color: AppColors.primaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Search Field - Positioned to overlap
        Positioned(
          bottom: 0,
          left: AppSizes.md,
          right: AppSizes.md,
          child: Material(
            color: AppColors.whiteColor,
            child: InkWell(
              splashColor: AppColors.greyColor,
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
              onTap: () {
                Get.toNamed(AppRoutes.homeSearchRoute);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.md,
                    horizontal: AppSizes.md,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primaryColor),
                    borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                  ),
                  child: Row(
                    spacing: AppSizes.md,
                    children: <Widget>[
                      const Icon(CupertinoIcons.search, color: AppColors.primaryColor),
                      Text("Search a service", style: Theme.of(context).textTheme.headlineMedium),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}