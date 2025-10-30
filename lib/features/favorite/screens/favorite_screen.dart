/**
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import 'package:manx_mate/features/home/widget/home_top_bar.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../booking/widgets/booking_card.dart';
import '../controllers/favorite_controller.dart';

class FavoriteScreen extends GetView<FavoriteController> {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                color: AppColors.whiteColor,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: AppSizes.lg,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=300&fit=crop',
                        ),
                      ),
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
              const SizedBox(height: AppSizes.md),
              Text('  My Favorite', style: context.txtTheme.titleLarge),
              const SizedBox(height: AppSizes.md),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.screenHorizontal,
                    vertical: AppSizes.lg,
                  ),
                  itemCount: 3,
                  itemBuilder: (BuildContext context, int index) {
                    return HorizontalServiceCard(
                      imageUrl:
                          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=300&fit=crop',
                      title: 'Ongoing Service $index',
                      subtitle: 'Math & Science',
                      location: 'Dublin, Ireland',
                      rating: "4.7",
                      onTap: () {
                        // print('Ongoing card $index tapped');
                      },

                      onDelete: () {
                        // print('View ongoing card $index');
                      },
                      showStatus: false,
                      status: "Requested",
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const Column(
                      children: <Widget>[
                        Divider(),
                        SizedBox(height: AppSizes.md),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/






///
///
///
/// todo::: showing the user iamge also
///
///
///



import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../booking/widgets/booking_card.dart';
import '../../home/controllers/home_top_bar_controller.dart';
import '../controllers/favorite_controller.dart';

class FavoriteScreen extends GetView<FavoriteController> {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller for profile image
    final HomeTopBarController profileController = Get.put(HomeTopBarController());

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              color: AppColors.whiteColor,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.lg,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    // Profile Image (Dynamically loaded)
                    Obx(() {
                      final imageUrl = profileController.getImageUrl(); // Get image URL from controller
                      return CircleAvatar(
                        radius: 30,
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
            const SizedBox(height: AppSizes.md),
            Text('  My Favorite', style: context.txtTheme.titleLarge),
            const SizedBox(height: AppSizes.md),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.screenHorizontal,
                  vertical: AppSizes.lg,
                ),
                itemCount: 3,
                itemBuilder: (BuildContext context, int index) {
                  return HorizontalServiceCard(
                    imageUrl:
                    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=300&fit=crop',
                    title: 'Ongoing Service $index',
                    subtitle: 'Math & Science',
                    // location: 'Dublin, Ireland',
                    description: 'Dublin, Ireland',
                    rating: "4.7",
                    onTap: () {
                      // print('Ongoing card $index tapped');
                    },
                    onDelete: () {
                      // print('View ongoing card $index');
                    },
                    showStatus: false,
                    status: "Requested",
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const Column(
                    children: <Widget>[
                      Divider(),
                      SizedBox(height: AppSizes.md),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
