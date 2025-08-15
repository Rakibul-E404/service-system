import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/common/widgets/reusable_button.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/config/app_strings.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
 import '../controllers/role_selection_controller.dart';

// Role Selection Page
class RoleSelectionScreen extends GetView<RoleSelectionController> {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(RoleSelectionController());
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        height: 50,
        width: context.screenWidth * 0.9,
        child: Obx(
          ()=> ReusableButton(
            onTap: () {
              controller.selectedRole.value.isNotEmpty
                  ? controller.continueWithRole()
                  : controller.continueWithoutRole();
            },
            bgColor: controller.selectedRole.value.isNotEmpty
                ? AppColors.primaryColor
                : Colors.grey[200]!,
            label: "Continue",
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Choose Your Role',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenHorizontal),
        child: Column(
          children: <Widget>[
            const SizedBox(height: AppSizes.md),

            // Continue As Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: AppSizes.sm),

              child: const Column(
                children: <Widget>[
                  // Text('Continue As', style: context.txtTheme.titleLarge),
                  // const SizedBox(height: 8),
                  Text(
                    'Please select an option to begin your journey',
                    // style: context.txtTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.lg),

            // Role Options
            Expanded(
              child: Column(
                children: <Widget>[
                  // User Role
                  Obx(
                    () => _buildRoleOption(
                      icon: CupertinoIcons.person_crop_circle,
                      title: AppStrings.user,
                      subtitle: 'Create your account as a User',
                      isSelected: controller.selectedRole.value == AppStrings.user,
                      onTap: () => controller.selectRole(AppStrings.user),
                      backgroundColor: Colors.white,
                      iconColor: controller.selectedRole.value == AppStrings.user
                          ? AppColors.primaryColor
                          : Colors.grey[700]!,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Provider Role
                  Obx(
                    () => _buildRoleOption(
                      icon: Icons.business_center_outlined,
                      title: AppStrings.provider,
                      subtitle: 'Create your account as a Provider',
                      isSelected: controller.selectedRole.value == AppStrings.provider,
                      onTap: () => controller.selectRole(AppStrings.provider),
                      backgroundColor: Colors.white,
                      iconColor: controller.selectedRole.value == AppStrings.provider
                          ? AppColors.primaryColor
                          : Colors.grey[700]!,
                    ),
                  ),

                  const Spacer(),

                  // Continue Button
                  // Obx(
                  //   () => SizedBox(
                  //     width: double.infinity,
                  //     child: ElevatedButton(
                  //       onPressed: controller.selectedRole.value.isNotEmpty
                  //           ? () => controller.continueWithRole()
                  //           : null,
                  //       style: ElevatedButton.styleFrom(
                  //         backgroundColor: controller.selectedRole.value.isNotEmpty
                  //             ? Colors.amber[600]
                  //             : Colors.grey[300],
                  //         foregroundColor: controller.selectedRole.value.isNotEmpty
                  //             ? Colors.black
                  //             : Colors.grey[600],
                  //         padding: const EdgeInsets.symmetric(vertical: 16),
                  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  //         elevation: 0,
                  //       ),
                  //       child: const Text(
                  //         'Continue',
                  //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Row(
          children: <Widget>[
            // Role Icon
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 38, color: iconColor),
            ),

            const SizedBox(width: 16),

            // Role Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                ],
              ),
            ),

            // Selection Indicator
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primaryColor : Colors.grey[400]!,
                  width: 2,
                ),
                color: isSelected ? AppColors.primaryColor : Colors.white,
              ),
              child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
            ),
          ],
        ),
      ),
    );
  }
}
