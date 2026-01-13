
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/common/widgets/reusable_button.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_strings.dart';
import '../../auth/controllers/change_password_controller.dart';
import '../../auth/widgets/app_custom_textfield.dart';
import '../../auth/widgets/custom_text_field.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController _oldPasswordTEController = TextEditingController();
  final TextEditingController _newPasswordTEController = TextEditingController();
  final TextEditingController _confirmPasswordTEController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late ChangePasswordController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ChangePasswordController());
  }

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
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.screenHorizontal,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 20),

                    // Old Password
                    Text(
                      "Old Password",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 14),
                    AppCustomContainerField(
                      containerChild: MyTextFormFieldWithIcon(
                        isPassword: true,
                        formHintText: "Enter Old Password",
                        prefixIcon: const Icon(
                          Icons.lock_outlined,
                          color: AppColors.primaryColor,
                        ),
                        controller: _oldPasswordTEController,
                        validator: (String? value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your old password!';
                          }
                          return null;
                        },
                        onChanged: (String value) {},
                      ),
                    ),

                    const SizedBox(height: AppSizes.md),

                    // New Password
                    Text(
                      "New Password",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 14),
                    MyTextFormFieldWithIcon(
                      isPassword: true,
                      formHintText: AppStrings.enterPassword,
                      prefixIcon: const Icon(
                        Icons.lock_outlined,
                        color: AppColors.primaryColor,
                      ),
                      controller: _newPasswordTEController,
                      validator: (String? value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter new password!';
                        }
                        if (value!.length < 6) {
                          return 'Password must be at least 6 characters!';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Confirm Password
                    Text(
                      AppStrings.confirmPassword,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    AppCustomContainerField(
                      containerChild: MyTextFormFieldWithIcon(
                        isPassword: true,
                        formHintText: AppStrings.confirmPassword,
                        prefixIcon: const Icon(
                          Icons.lock_outlined,
                          color: AppColors.primaryColor,
                        ),
                        controller: _confirmPasswordTEController,
                        validator: (String? value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please confirm your password!';
                          }
                          if (value != _newPasswordTEController.text) {
                            return 'Passwords do not match!';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: AppSizes.lg),

                    // Change Password Button
                    // Change Password Button
                    Obx(
                          () => AbsorbPointer(
                        absorbing: controller.isLoading.value,
                        child: ReusableButton(
                          onTap: () {
                            if (!controller.isLoading.value) {
                              FocusScope.of(context).unfocus();
                              if (_formKey.currentState!.validate()) {
                                controller.changePassword(
                                  oldPassword: _oldPasswordTEController.text,
                                  newPassword: _newPasswordTEController.text,
                                  confirmPassword: _confirmPasswordTEController.text,
                                );
                              }
                            }
                          },
                          label: controller.isLoading.value
                              ? "Changing..."
                              : "Change Password",
                          bgColor: controller.isLoading.value
                              ? AppColors.primaryColor.withOpacity(0.6)
                              : AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Loading Overlay
            Obx(
                  () => controller.isLoading.value
                  ? Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _oldPasswordTEController.dispose();
    _newPasswordTEController.dispose();
    _confirmPasswordTEController.dispose();
    super.dispose();
  }
}