import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_images.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import 'package:manx_mate/core/extensions/widget_extensions.dart';
import 'package:manx_mate/core/routes/app_routes.dart';
import 'package:manx_mate/features/auth/controllers/sign_in_controller.dart' show SignInController;

import '../../../core/config/app_colors.dart';
import '../../../core/config/app_constants.dart';
import '../../../core/config/app_strings.dart';
import '../../../core/data/secured_storage.dart';
import '../../../shared/widgets/custom_button.dart';
import '../widgets/app_custom_textfield.dart';
import '../widgets/custom_text.dart';
import '../widgets/custom_text_field.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailTEController = TextEditingController();
  final TextEditingController _passwordTEController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  SignInController signInController = Get.find<SignInController>();

  /// controller initialization

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.xl, horizontal: AppSizes.md),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Center(
                    child: CustomRichText(firstLabel: 'Sign In', secondLabel: 'to your account'),
                  ),

                  const SizedBox(height: 14),
                  Center(
                    child: Text(
                      AppStrings.welcomeBackPleaseEnterYourDetails,
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: AppColors.blackColor.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),
                  Image.asset(AppImages.loginImage).centered,
                  const SizedBox(height: AppSizes.md),

                  ///  ==========================> Google login container ==============>
                  InkWell(
                    onTap: () {
                      /// TODO : Google sign-in
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm, horizontal: AppSizes.lg),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                        border: Border.all(color: AppColors.primaryColor, width: 2),
                        color: AppColors.primaryColorLight,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Text('Google'),
                          Text('  G', style: context.txtTheme.labelMedium),
                        ],
                      ),
                    ).centered,
                  ),





                  const SizedBox(height: 32),
                  Text(AppStrings.email, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 14),
                  AppCustomContainerField(
                    containerChild: MyTextFormFieldWithIcon(
                      formHintText: AppStrings.enterYourEmail,
                      prefixIcon: const Icon(Icons.mail_outline, color: AppColors.primaryColor),
                      controller: _emailTEController,
                      validator: (String? value) {
                        if (value?.isEmpty ?? true) {
                          return '${AppStrings.pleaseEnterYour} ${AppStrings.email}!!';
                        }
                        return null;
                      },
                      onChanged: (String value) {
                        // print("Email Input: $value");
                      },
                    ),
                  ),

                  const SizedBox(height: 16),
                  Text(AppStrings.password, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 14),
                  AppCustomContainerField(
                    containerChild: MyTextFormFieldWithIcon(
                      isPassword: true,
                      formHintText: AppStrings.enterPassword,
                      prefixIcon: const Icon(Icons.lock_outlined, color: AppColors.primaryColor),
                      controller: _passwordTEController,
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

                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      TextButton(
                        onPressed: () {
                          Get.toNamed(AppRoutes.forgotPasswordRoute);
                        },
                        child: Text(
                          AppStrings.forgotPassword,

                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            decoration: TextDecoration.underline,
                            color: AppColors.blackColor,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  PrimaryButton(
                    buttonText: AppStrings.signIn,
                    // Text that will appear on the button
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      clearingTextField(); // Your text clearing function
                    signInController.handleSignIn();
                    },
                  ),

                  const SizedBox(height: 16),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const Text(AppStrings.dontHaveAnAccount),
                        TextButton(
                          onPressed: () {
                            Get.toNamed(AppRoutes.signUpRoute);
                          },
                          child: Text(
                            AppStrings.signUp,

                            style: Theme.of(
                              context,
                            ).textTheme.labelMedium?.copyWith(decoration: TextDecoration.underline),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // validate Email Address
  String? isEmailValid(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    } else if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  void clearingTextField() {
    _emailTEController.clear();
    _passwordTEController.clear();
  }

  @override
  void dispose() {
    _emailTEController.dispose();
    _passwordTEController.dispose();
    super.dispose();
  }
}
