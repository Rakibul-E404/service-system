import 'package:flutter/material.dart';
import 'package:get/get.dart';
 import 'package:manx_mate/core/routes/app_routes.dart';
import 'package:manx_mate/features/auth/widgets/primary_button.dart';

import '../../../core/config/app_colors.dart';
import '../../../core/config/app_strings.dart';
import '../controllers/taking_email_controller.dart';
import '../widgets/app_custom_textfield.dart';
import '../widgets/custom_text.dart';
import '../widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _forgotPasswordTEController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ForgotPasswordController forgotPasswordController = Get.find<ForgotPasswordController>();

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
              AppCustomContainerField(
                containerChild: MyTextFormFieldWithIcon(
                  controller: _forgotPasswordTEController,
                  validator: (String? value) {
                    return isEmailValid(value);
                  },
                  formHintText: AppStrings.enterYourEmail,
                  prefixIcon: const Icon(Icons.mail_outline, color: AppColors.primaryColor),
                ),
              ),

              const SizedBox(height: 32),

              PrimaryButton(
                buttonText: AppStrings.sendOTP,
                // Text that will appear on the button
                onPressed: () {
                  /// TODO: OTP logic
                  // // if (_formKey.currentState!.validate()) {}
                  Get.toNamed(AppRoutes.verifyEmailRoute);
                },
              ),
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

  void clearTextFields() {
    _forgotPasswordTEController.clear();
  }

  @override
  void dispose() {
    _forgotPasswordTEController.dispose();

    super.dispose();
  }
}
