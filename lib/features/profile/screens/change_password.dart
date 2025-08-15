import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/common/widgets/reusable_button.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_strings.dart';
import '../../auth/widgets/app_custom_textfield.dart';
import '../../auth/widgets/custom_text_field.dart';

class ChangePassword extends StatelessWidget {
  ChangePassword({super.key});

  final TextEditingController _oldPasswordTEController = TextEditingController();
  final TextEditingController _newPasswordTEController = TextEditingController();
  final TextEditingController _confirmPasswordTEController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Password"),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("Old Password", style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 14),
              AppCustomContainerField(
                containerChild: MyTextFormFieldWithIcon(
                  isPassword: true,
                  formHintText: "Enter Old Password",
                  prefixIcon: const Icon(Icons.lock_outlined, color: AppColors.primaryColor),
                  controller: _oldPasswordTEController,
                  validator: (String? value) {
                    if (value?.isEmpty ?? true) {
                      return '${AppStrings.pleaseEnterYour} Password !!';
                    }
                    return null;
                  },

                  onChanged: (String value) {
                    // print("Email Input: $value");
                  },
                ),
              ),
              const SizedBox(height: AppSizes.md),
              Text("New Password", style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 14),
              MyTextFormFieldWithIcon(
                isPassword: true,
                formHintText: AppStrings.enterPassword,
                prefixIcon: const Icon(Icons.lock_outlined, color: AppColors.primaryColor),
                controller: _newPasswordTEController,
                validator: (String? value) {
                  if (value?.isEmpty ?? true) {
                    return '${AppStrings.pleaseEnterYour} Password !!';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),
              Text(AppStrings.confirmPassword, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              AppCustomContainerField(
                containerChild: MyTextFormFieldWithIcon(
                  isPassword: true,
                  formHintText: AppStrings.confirmPassword,
                  prefixIcon: const Icon(Icons.lock_outlined, color: AppColors.primaryColor),
                  controller: _confirmPasswordTEController,
                  validator: (String? value) {
                    if (value?.isEmpty ?? true) {
                      return '${AppStrings.pleaseEnterYour} Password again !!';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              ReusableButton(onTap: () {}, label: "Change Password"),
            ],
          ),
        ),
      ),
    );
  }
}
