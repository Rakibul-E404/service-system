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
