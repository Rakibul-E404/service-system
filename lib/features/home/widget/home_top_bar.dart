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

    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
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
              vertical: AppSizes.md, // Reduced vertical padding
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                // Profile Image - Use GetBuilder instead of Obx
                GetBuilder<ProfileController>(
                  builder: (ProfileController controller) {
                    final String imageUrl = controller.getImageUrl();
                    return GestureDetector(
                      onTap: () {
                        Get.toNamed(AppRoutes.personalProfileInformationPage);
                      },
                      child: CircleAvatar(
                        radius: 22, // Reduced from AppSizes.xl
                        backgroundImage: imageUrl.isNotEmpty
                            ? NetworkImage(imageUrl)
                            : null,
                        child: imageUrl.isEmpty
                            ? const Icon(
                          Icons.person,
                          size: 30, // Reduced size
                          color: Colors.grey,
                        )
                            : null,
                      ),
                    );
                  },
                ),

                Row(
                  children: [
                    Container(
                      width: 40, // Fixed width
                      height: 40, // Fixed height
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor,
                        border: Border.all(color: AppColors.greyColor.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          Get.toNamed(AppRoutes.homeSearchRoute);
                        },
                        icon: const Icon(
                          CupertinoIcons.search,
                          size: 20, // Reduced icon size
                          color: AppColors.blackColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8), // Reduced spacing

                    Container(
                      width: 40, // Fixed width
                      height: 40, // Fixed height
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor,
                        border: Border.all(color: AppColors.greyColor.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          Get.toNamed(AppRoutes.notificationPage);
                        },
                        icon: const Icon(
                          CupertinoIcons.bell,
                          size: 20, // Reduced icon size
                          color: AppColors.blackColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
