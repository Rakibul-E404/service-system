import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/routes/app_routes.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_sizes.dart';
import '../../profile/controllers/profile_controller.dart';

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Use ProfileController instead of HomeTopBarController
    final ProfileController controller = Get.find<ProfileController>();

    return Obx(() {
      // Optional: show a placeholder/loading bar if profile is loading
      final bool isLoading = controller.isLoading.value;
      final bool isLoggedIn = controller.isLoggedIn.value;

      return Container(
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Status bar space
            SizedBox(height: MediaQuery.of(context).padding.top),

            // Main content
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md,
                vertical: AppSizes.md,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  // Profile Image - Conditionally tappable
                  _buildProfileAvatar(controller, isLoggedIn),

                  Row(
                    children: [

                      // Notification & search Button - Only show if logged in
                      if (isLoggedIn) ...[
                        // Search Button
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            border: Border.all(
                              color: AppColors.greyColor.withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              Get.toNamed(AppRoutes.homeServiceSearchScreen);
                            },
                            icon: const Icon(
                              CupertinoIcons.search,
                              size: 20,
                              color: AppColors.blackColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            border: Border.all(
                              color: AppColors.greyColor.withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              Get.toNamed(AppRoutes.notificationPage);
                            },
                            icon: const Icon(
                              CupertinoIcons.bell,
                              size: 20,
                              color: AppColors.blackColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Optional: Loading indicator below the top bar
            if (isLoading)
              const LinearProgressIndicator(
                minHeight: 2,
                backgroundColor: Colors.transparent,
              ),
          ],
        ),
      );
    });
  }

  // Helper method to build profile avatar with conditional tap behavior
  Widget _buildProfileAvatar(ProfileController controller, bool isLoggedIn) {
    final avatar = CircleAvatar(
      radius: 22,
      backgroundImage: controller.profileImage.value.isNotEmpty
          ? NetworkImage(controller.getImageUrl())
          : null,
      child: controller.profileImage.value.isEmpty
          ? const Icon(
        Icons.person,
        size: 30,
        color: Colors.grey,
      )
          : null,
    );

    // If user is logged in, make it tappable
    if (isLoggedIn) {
      return GestureDetector(
        onTap: () {
          Get.toNamed(AppRoutes.personalProfileInformationPage);
        },
        child: avatar,
      );
    }
    // If user is not logged in, show with disabled styling
    else {
      return Opacity(
        opacity: 0.6, // Make it look disabled
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.greyColor.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: avatar,
        ),
      );
    }
  }
}