import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/routes/app_routes.dart';
import 'package:manx_mate/features/profile/widgets/profile_common_tile.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenHorizontal),
          child: Column(
            children: <Widget>[
              const SizedBox(height: AppSizes.md),
              ProfileCommonTile(
                onTap: () {
                  Get.toNamed(AppRoutes.changePasswordPage);
                },
                leadingIcon: const Icon(CupertinoIcons.lock_fill, color: Colors.grey),
                title: 'Change Password',
              ),
              const SizedBox(height: AppSizes.sm),
              ProfileCommonTile(
                onTap: () {
                  Get.toNamed(
                    AppRoutes.privacyPolicyTemplatePage,
                    arguments: <String, String>{
                      'title': 'Privacy Policy',
                      'bodyText': '2025-08-13',
                    },
                  );
                },
                leadingIcon: const Icon(CupertinoIcons.bookmark_fill, color: Colors.grey),
                title: 'Privacy Policy',
              ),
              const SizedBox(height: AppSizes.sm),
              ProfileCommonTile(
                onTap: () {
                  Get.toNamed(
                    AppRoutes.privacyPolicyTemplatePage,
                    arguments: <String, String>{
                      'title': 'Terms and Conditions',
                      'bodyText': '2025-08-13',
                    },
                  );
                },
                leadingIcon: const Icon(Icons.warning, color: Colors.grey),
                title: 'Terms and Conditions',
              ),
              const SizedBox(height: AppSizes.sm),
              ProfileCommonTile(
                onTap: () {
                  Get.toNamed(
                    AppRoutes.privacyPolicyTemplatePage,
                    arguments: <String, String>{'title': 'About Us', 'bodyText': '2025-08-13'},
                  );
                },
                leadingIcon: const Icon(Icons.info, color: Colors.grey),
                title: 'About Us ',
              ),
              const SizedBox(height: AppSizes.sm),
              ProfileCommonTile(
                onTap: () {
                  Get.toNamed(
                    AppRoutes.privacyPolicyTemplatePage,
                    arguments: <String, String>{'title': 'Host Policy', 'bodyText': '2025-08-13'},
                  );
                },
                leadingIcon: const Icon(Icons.help, color: Colors.grey),
                title: 'Host Policy',
              ),
              const SizedBox(height: AppSizes.sm),
              ProfileCommonTile(
                onTap: () {
                  Get.toNamed(AppRoutes.reportPage);
                },
                leadingIcon: const Icon(Icons.description, color: Colors.grey),
                title: 'Report',
              ),
              const SizedBox(height: AppSizes.sm),
              ProfileCommonTile(
                onTap: () {
                  Get.toNamed(
                    AppRoutes.privacyPolicyTemplatePage,
                    arguments: <String, String>{'title': 'Contact Us', 'bodyText': '2025-08-13'},
                  );
                },
                leadingIcon: const Icon(Icons.contact_page_sharp, color: Colors.grey),
                title: 'Contact Us',
              ),
              const SizedBox(height: AppSizes.sm),
            ],
          ),
        ),
      ),
    );
  }
}
