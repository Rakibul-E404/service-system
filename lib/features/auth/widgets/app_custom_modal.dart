import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_colors.dart' show AppColors;
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/config/app_strings.dart' show AppStrings;
import 'package:manx_mate/core/extensions/widget_extensions.dart';
import 'package:manx_mate/shared/widgets/custom_button.dart';

import '../screens/sign_in_page.dart';

class AppCustomModal extends StatelessWidget {
  const AppCustomModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height / 2,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: AppColors.primaryColor.withValues(alpha: 0.6),
            // Color only on top
            width: 5, // Border thickness
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 8), // Spacer
              Container(
                height: 6,
                width: 50,
                decoration: BoxDecoration(
                  color: AppColors.greyColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 32),

              CircleAvatar(
                radius: 66,
                backgroundColor: AppColors.primaryColor.withValues(alpha: .05),
                child: const CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.primaryColor,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.whiteColor,
                    child: Icon(Icons.check, size: 26, color: AppColors.primaryColor),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(AppStrings.passwordChanged, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 10),
              Text(
                AppStrings.returnToTheLoginPageToEnterYourAccountWithYourNewPassword,
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              PrimaryButton(
                buttonText: AppStrings.returnText,
                // Text that will appear on the button
                onPressed: () {
                  Get.offAll(() => const SignInScreen());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppDeleteModal extends StatelessWidget {
  final VoidCallback onTap;

  const AppDeleteModal({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height / 2,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: AppColors.primaryColor.withValues(alpha: 0.6),
            // Color only on top
            width: 5, // Border thickness
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 8), // Spacer
              Container(
                height: 6,
                width: 50,
                decoration: BoxDecoration(
                  color: AppColors.greyColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 32),

              CircleAvatar(
                radius: 66,
                backgroundColor: AppColors.primaryColor.withValues(alpha: .05),
                child: const CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.primaryColor,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.whiteColor,
                    child: Icon(Icons.check, size: 26, color: AppColors.primaryColor),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              Text(
                "Are You Sure You Want to remove this item ?",
                style: Theme.of(context).textTheme.labelLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.md),
              Row(
                spacing: AppSizes.md,
                children: <Widget>[
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSizes.sm,
                          horizontal: AppSizes.sm,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor,
                          border: Border.all(color: AppColors.primaryColor),
                        ),
                        child: const Text("Cancel").centered,
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: onTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSizes.sm,
                          horizontal: AppSizes.sm,
                        ),

                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          border: Border.all(color: AppColors.primaryColor),
                        ),
                        child: const Text("Delete").centered,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
