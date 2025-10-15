import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/common/components/custom_network_image.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import 'package:manx_mate/core/routes/app_routes.dart';
import '../controllers/profile_controller.dart';
import '../widgets/logout_modal.dart';
import '../widgets/profile_common_tile.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ProfileController());

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenHorizontal),
            child: Column(
              children: <Widget>[
                const SizedBox(height: AppSizes.lg),

                // Profile Image
                Obx(() {
                  final imageUrl = controller.getImageUrl();

                  return Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[300]!, width: 3),
                    ),
                    child: ClipOval(
                      child: imageUrl.isNotEmpty
                          ? CustomCachedImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                      )
                          : const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }),

                const SizedBox(height: AppSizes.sm),

                // User Name
                Obx(() => Text(
                  controller.name.value.isNotEmpty ? controller.name.value : 'Guest User',
                  style: context.txtTheme.titleLarge,
                )),

                // User Email (optional)
                Obx(() {
                  if (controller.email.value.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        controller.email.value,
                        style: context.txtTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),

                const SizedBox(height: AppSizes.md),

                ProfileCommonTile(
                  onTap: () {
                    Get.toNamed(AppRoutes.personalProfileInformationPage)?.then((_) {
                      // Refresh profile when returning from personal info screen
                      controller.refreshProfile();
                    });
                  },
                  leadingIcon: const Icon(CupertinoIcons.person_alt_circle_fill, color: Colors.grey),
                  title: 'Personal Information',
                ),

                const SizedBox(height: AppSizes.md),

                ProfileCommonTile(
                  onTap: () {
                    Get.toNamed(AppRoutes.myReviewPage);
                  },
                  leadingIcon: const Icon(CupertinoIcons.star_fill, color: Colors.grey),
                  title: 'My Review & Ratings',
                ),

                const SizedBox(height: AppSizes.md),

                ProfileCommonTile(
                  onTap: () {
                    Get.toNamed(AppRoutes.settingsPage);
                  },
                  leadingIcon: const Icon(CupertinoIcons.gear_solid, color: Colors.grey),
                  title: 'Settings',
                ),

                const SizedBox(height: AppSizes.md),

                ProfileCommonTile(
                  onTap: () {
                    LogoutModal.show(
                      context: context,
                      onConfirm: () {
                        Get.offAllNamed(AppRoutes.roleSelectionRoute);
                      },
                    );
                  },
                  leadingIcon: const Icon(Icons.logout_outlined, color: Colors.grey),
                  title: 'Logout',
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}