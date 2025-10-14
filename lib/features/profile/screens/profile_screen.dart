/**
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenHorizontal),
          child: Column(
            children: <Widget>[
              const CircleAvatar(radius: 50),
              const SizedBox(height: AppSizes.sm),
              Text("Ishan.I ", style: context.txtTheme.titleLarge),
              const SizedBox(height: AppSizes.md),
              ProfileCommonTile(
                onTap: () {
                  Get.toNamed(AppRoutes.personalProfileInformationPage);
                },
                leadingIcon: const Icon(CupertinoIcons.person_alt_circle_fill, color: Colors.grey),
                title: 'Personal Information',
              ),
              const SizedBox(height: AppSizes.md),
              ProfileCommonTile(
                onTap: () {
                  Get.toNamed(AppRoutes.myReviewPage);
                },
                leadingIcon: const Icon(CupertinoIcons.person_alt_circle_fill, color: Colors.grey),
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
        ),
      ),
    );
  }
}
*/
















///
///
///
///
/// todo:: fetching user name
///
///
///
///
///





import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Use cached_network_image package
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import 'package:manx_mate/core/routes/app_routes.dart';
import '../controllers/profile_controller.dart';
import '../widgets/logout_modal.dart';
import '../widgets/profile_common_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.put(ProfileController());

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.refreshProfile,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.screenHorizontal,
              ),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: AppSizes.lg),

                  // Profile Image with correct placeholders and error handling
                  Obx(() {
                    final imageUrl = controller.profileImage;
                    return Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey[300]!, width: 3),
                      ),
                      child: ClipOval(
                        child: imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.grey,
                          ),
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

                  // Live Username
                  Obx(() {
                    return Text(
                      controller.name.isNotEmpty ? controller.name : 'User',
                      style: context.txtTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }),

                  const SizedBox(height: AppSizes.md),

                  ProfileCommonTile(
                    onTap: () async {
                      await Get.toNamed(AppRoutes.personalProfileInformationPage);
                      controller.refreshProfile();
                    },
                    leadingIcon: const Icon(
                      CupertinoIcons.person_alt_circle_fill,
                      color: Colors.grey,
                    ),
                    title: 'Personal Information',
                  ),

                  const SizedBox(height: AppSizes.md),

                  ProfileCommonTile(
                    onTap: () {
                      Get.toNamed(AppRoutes.myReviewPage);
                    },
                    leadingIcon: const Icon(
                      CupertinoIcons.star_fill,
                      color: Colors.grey,
                    ),
                    title: 'My Review & Ratings',
                  ),

                  const SizedBox(height: AppSizes.md),

                  ProfileCommonTile(
                    onTap: () {
                      Get.toNamed(AppRoutes.settingsPage);
                    },
                    leadingIcon: const Icon(
                      CupertinoIcons.gear_solid,
                      color: Colors.grey,
                    ),
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
                    leadingIcon: const Icon(
                      Icons.logout_outlined,
                      color: Colors.grey,
                    ),
                    title: 'Logout',
                  ),

                  const SizedBox(height: AppSizes.md),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}



