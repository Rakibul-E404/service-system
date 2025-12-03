/**
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/common/components/custom_network_image.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import 'package:manx_mate/core/routes/app_routes.dart';
import 'package:manx_mate/features/auth/screens/profile_service.dart';
import '../../../core/config/app_colors.dart';
import '../widgets/logout_modal.dart';
import '../widgets/profile_common_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileService profileService = Get.find<ProfileService>();

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (profileService.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!profileService.isLoggedIn.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Not Logged In',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please login to view your profile',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Get.offAllNamed(AppRoutes.roleSelectionRoute);
                    },
                    child: const Text('Go to Login'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenHorizontal),
            child: Column(
              children: <Widget>[
                const SizedBox(height: AppSizes.lg),

                // Profile Image - Using ProfileService directly
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!, width: 3),
                  ),
                  child: ClipOval(
                    child: profileService.profileImage.value.isNotEmpty
                        ? CustomCachedImage(
                      imageUrl: profileService.getImageUrl(),
                      fit: BoxFit.cover,
                    )
                        : const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.sm),

                // User Name - Using ProfileService directly
                Text(
                  profileService.name.value.isNotEmpty
                      ? profileService.name.value
                      : 'Guest User',
                  style: context.txtTheme.titleLarge,
                ),


                const SizedBox(height: AppSizes.md),

                // MENU ITEMS AS PER IMAGE DESIGN
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // 1. Personal Information
                      _buildMenuItem(
                        icon: Icons.person_outline,
                        title: 'Personal Information',
                        onTap: () {
                          Get.toNamed(AppRoutes.personalProfileInformationPage);
                        },
                      ),

                      const Divider(height: 1, indent: 16, endIndent: 16),


                      const Divider(height: 1, indent: 16, endIndent: 16),

                      // 3. Settings
                      _buildMenuItem(
                        icon: Icons.settings_outlined,
                        title: 'Settings',
                        onTap: () {
                          Get.toNamed(AppRoutes.settingsPage);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.md),

                // Logout Button (separate container as per image)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _buildMenuItem(
                    icon: Icons.logout_outlined,
                    title: 'Logout',
                    iconColor: Colors.red,
                    textColor: Colors.red,
                    onTap: () {
                      LogoutModal.show(
                        context: context,
                        onConfirm: () async {
                          Get.back();
                          await profileService.logout();
                        },
                      );
                    },
                  ),
                ),

                // Add some bottom padding to prevent overflow
                const SizedBox(height: AppSizes.xl),
              ],
            ),
          );
        }),
      ),
    );
  }

  // Helper method to build menu items as shown in image
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = Colors.grey,
    Color textColor = Colors.black,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[100],
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.grey,
        size: 22,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}

*/








///
///
///
///
/// todo:::: fixing to get the provider dashboard with profile
///
///
///
///
///





import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/common/components/custom_network_image.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import 'package:manx_mate/core/routes/app_routes.dart';
import 'package:manx_mate/features/auth/screens/profile_service.dart';
import '../../../core/config/app_colors.dart';
import '../controllers/profile_controller.dart';
import '../widgets/logout_modal.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {


    final ProfileService profileService = Get.find<ProfileService>();

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (profileService.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!profileService.isLoggedIn.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Not Logged In',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please login to view your profile',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Get.offAllNamed(AppRoutes.roleSelectionRoute);
                    },
                    child: const Text('Go to Login'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenHorizontal),
            child: Column(
              children: <Widget>[
                const SizedBox(height: AppSizes.lg),

                // Profile Image - Using ProfileService directly
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!, width: 3),
                  ),
                  child: ClipOval(
                    child: profileService.profileImage.value.isNotEmpty
                        ? CustomCachedImage(
                      imageUrl: profileService.getImageUrl(),
                      fit: BoxFit.cover,
                    )
                        : const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.sm),

                // User Name - Using ProfileService directly
                Text(
                  profileService.name.value.isNotEmpty
                      ? profileService.name.value
                      : 'Guest User',
                  style: context.txtTheme.titleLarge,
                ),


                const SizedBox(height: AppSizes.md),

                // MENU ITEMS AS PER IMAGE DESIGN
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // 1. Personal Information
                      _buildMenuItem(
                        icon: Icons.person_outline,
                        title: 'Personal Information',
                        onTap: () {
                          Get.toNamed(AppRoutes.personalProfileInformationPage);
                        },
                      ),

                      const Divider(height: 1, indent: 16, endIndent: 16),

                      // 2. Settings
                      _buildMenuItem(
                        icon: Icons.settings_outlined,
                        title: 'Settings',
                        onTap: () {
                          Get.toNamed(AppRoutes.settingsPage);
                        },
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),

                      // 3. Subscriptions
                      if (profileService.role.value == 'provider')
                      _buildMenuItem(
                        icon: CupertinoIcons.bookmark,
                        title: 'Subscriptions',
                        onTap: () {
                          Get.toNamed(AppRoutes.subscriptionPageRoute);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.md),

                // Logout Button (separate container as per image)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _buildMenuItem(
                    icon: Icons.logout_outlined,
                    title: 'Logout',
                    iconColor: Colors.red,
                    textColor: Colors.red,
                    onTap: () {
                      LogoutModal.show(
                        context: context,
                        onConfirm: () async {
                          Get.back();
                          await profileService.logout();
                        },
                      );
                    },
                  ),
                ),

                // Add some bottom padding to prevent overflow
                const SizedBox(height: AppSizes.xl),
              ],
            ),
          );
        }),
      ),
    );
  }

  // Helper method to build menu items as shown in image
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = Colors.grey,
    Color textColor = Colors.black,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[100],
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.grey,
        size: 22,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}









