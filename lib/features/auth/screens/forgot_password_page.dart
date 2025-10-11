import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/routes/app_routes.dart';
import 'package:manx_mate/core/utils/custom_loader.dart';
import 'package:manx_mate/features/auth/widgets/primary_button.dart';

import '../../../core/config/app_colors.dart';
import '../../../core/config/app_strings.dart';
import '../controllers/forgot_password_controller.dart';
import '../widgets/app_custom_textfield.dart';
import '../widgets/custom_text.dart';
import '../widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final ForgotPasswordController forgotPasswordController = Get.put(ForgotPasswordController());

  ForgotPasswordScreen({super.key});

  /// controller initialization

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Center(
                child: CustomRichText(firstLabel: 'Forgot', secondLabel: 'Password'),
              ),
              const SizedBox(height: 14),
              Center(
                child: Text(
                  AppStrings.pleaseEnterYourEmailAddressToResetPassword,
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                    fontSize: 14,
                    color: AppColors.blackColor.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.start,
                ),
              ),

              const SizedBox(height: 24),
              Text(AppStrings.email, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 14),
              Form(
                key: forgotPasswordController.formKey,
                child: AppCustomContainerField(
                  containerChild: MyTextFormFieldWithIcon(
                    controller: forgotPasswordController.forgotPasswordTEController,
                    validator: (String? value) {
                      return isEmailValid(value);
                    },
                    formHintText: AppStrings.enterYourEmail,
                    prefixIcon: const Icon(Icons.mail_outline, color: AppColors.primaryColor),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              Obx(() {
                return forgotPasswordController.loader.value
                    ? const Center(child: CustomLoading())
                    : PrimaryButton(
                        buttonText: AppStrings.sendOTP,
                        // Text that will appear on the button
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          forgotPasswordController.sendOtp();
                        },
                      );
              }),
            ],
          ),
        ),
      ),
    );
  }

  String? isEmailValid(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    } else if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }
}
