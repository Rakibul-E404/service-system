import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:manx_mate/core/config/app_images.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import 'package:manx_mate/core/extensions/widget_extensions.dart';
import 'package:manx_mate/core/routes/app_routes.dart';
import 'package:manx_mate/features/auth/controllers/sign_in_controller.dart' show SignInController;
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_strings.dart';
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

  // Get the role from arguments
  String get selectedRole => Get.arguments?['role'] ?? 'user';

  // Check if skip button should be visible
  bool get showSkipButton => selectedRole.toLowerCase() == 'user';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          // Show Skip button only for user role
          if (showSkipButton)
            TextButton(
              onPressed: () {
                // Navigate to user main navigation
                Get.offAllNamed(
                  AppRoutes.mainBottomNavPage,
                  arguments: {'role': selectedRole},
                );
              },
              child: const Text("Skip"),
            ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSizes.xl,
                  horizontal: AppSizes.md,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Center(
                        child: CustomRichText(
                          firstLabel: 'Sign In',
                          secondLabel: 'to your account',
                        ),
                      ),

                      const SizedBox(height: 14),
                      Center(
                        child: Text(
                          AppStrings.welcomeBackPleaseEnterYourDetails,
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(
                            color: AppColors.blackColor.withValues(alpha: 0.7),
                          ),
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: AppSizes.lg),

                      // Login Image with constrained size
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.08,
                        ),
                        child: Image.asset(
                          AppImages.loginImage,
                          fit: BoxFit.contain,
                        ).centered,
                      ),
                      const SizedBox(height: AppSizes.md),

                      /// Google login using flutter_signin_button package
                      Center(
                        child: Obx(
                              () => SizedBox(
                            width: 200,
                            child: signInController.isGoogleSignInLoading.value
                                ? Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                                border: Border.all(
                                  color: AppColors.greyColor.withOpacity(0.3),
                                ),
                              ),
                              child: const Center(
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            )
                                : SignInButton(
                              Buttons.Google,
                              text: 'Sign in with Google',
                              onPressed: () {
                                debugPrint('🔵 Google sign-in tapped');
                                debugPrint('🎭 Selected Role: $selectedRole');
                                signInController.handleGoogleSignIn(role: selectedRole);
                              },
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                                side: BorderSide(
                                  color: AppColors.greyColor.withOpacity(0.3),
                                ),
                              ),
                              elevation: 1,
                            ),
                          ),
                        ),
                      ),

                      // OR Divider
                      const SizedBox(height: 32),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Divider(
                              color: AppColors.greyColor.withOpacity(0.3),
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.greyColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: AppColors.greyColor.withOpacity(0.3),
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Email Field
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
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                              return 'Please enter a valid email!';
                            }
                            return null;
                          },
                          onChanged: (String value) {},
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
                            if (value!.length < 6) {
                              return 'Password must be at least 6 characters!';
                            }
                            return null;
                          },
                          onChanged: (String value) {},
                        ),
                      ),

                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          TextButton(
                            onPressed: () {
                              Get.toNamed(
                                AppRoutes.forgotPasswordRoute,
                                arguments: {'role': selectedRole},
                              );
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

                      // Sign In Button with Loading State
                      Obx(
                            () => SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: signInController.isLoading.value
                                ? null
                                : () async {
                              FocusScope.of(context).unfocus();

                              if (_formKey.currentState!.validate()) {
                                await signInController.signIn(
                                  email: _emailTEController.text.trim(),
                                  password: _passwordTEController.text,
                                );
                              }
                            },
                            child: signInController.isLoading.value
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : Text(
                              AppStrings.signIn,
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              AppStrings.dontHaveAnAccount,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            TextButton(
                              onPressed: () {
                                Get.toNamed(
                                  AppRoutes.signUpRoute,
                                  arguments: {'role': selectedRole},
                                );
                              },
                              child: Text(
                                AppStrings.signUp,
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Add some bottom padding to prevent overflow
                      const SizedBox(height: AppSizes.xl),
                    ],
                  ),
                ),
              ),
            ),

            // Loading Overlay for both regular and Google sign in
            Obx(
                  () => (signInController.isLoading.value || signInController.isGoogleSignInLoading.value)
                  ? Container(
                color: Colors.black.withValues(alpha: 0.3),
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

