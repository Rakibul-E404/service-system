/**
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_colors.dart' show AppColors;
import 'package:manx_mate/core/config/app_strings.dart' show AppStrings;
import 'package:manx_mate/features/auth/controllers/reset_password_controller.dart' show ResetPasswordController;
import 'package:manx_mate/features/auth/widgets/primary_button.dart';
import '../widgets/app_custom_modal.dart';
import '../widgets/app_custom_textfield.dart';
import '../widgets/custom_text.dart';
import '../widgets/custom_text_field.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _resetPassTEController = TextEditingController();
  final TextEditingController _confirmPassTeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ResetPasswordController resetPasswordController = Get.find<ResetPasswordController>();

  /// controller initialization

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.fromLTRB(32, 108, 32, 0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: CustomRichText(firstLabel: 'Reset', secondLabel: 'Password'),
                  ),
                  const SizedBox(height: 14),

                  Center(
                    child: Text(
                      AppStrings.enterANewPassword,
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: AppColors.blackColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(AppStrings.password, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 14),
                  AppCustomContainerField(
                    containerChild: MyTextFormFieldWithIcon(
                      isPassword: true,
                      formHintText: AppStrings.enterPassword,
                      prefixIcon: const Icon(Icons.lock, color: AppColors.primaryColor),
                      controller: _resetPassTEController,
                      validator: (String? value) {
                        if (value?.isEmpty ?? true) {
                          return '${AppStrings.pleaseEnterYour} Password !!';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 16),
                  Text(
                    AppStrings.confirmPassword,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 14),
                  AppCustomContainerField(
                    containerChild: MyTextFormFieldWithIcon(
                      isPassword: true,
                      formHintText: AppStrings.confirmPassword,
                      prefixIcon: const Icon(Icons.lock, color: AppColors.primaryColor),
                      controller: _confirmPassTeController,
                      validator: (String? value) {
                        if (value?.isEmpty ?? true) {
                          return '${AppStrings.pleaseEnterYour} Password again !!';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 32),
                  PrimaryButton(
                    buttonText: AppStrings.resetPasswordBtn,
                    // Text that will appear on the button
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      clearingTextField();
                      if (_resetPassTEController.text.trim() !=
                          _confirmPassTeController.text.trim()) {
                        return;
                      }
                      // TODO: password Reset logic
                      // if (_formKey.currentState!.validate()) {}
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ), // Curved top border
                        ),
                        builder: (BuildContext context) {
                          return const AppCustomModal();
                        },
                      ).whenComplete(() {
                        // This callback is called when the modal is dismissed
                        FocusScope.of(context).unfocus();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void clearingTextField() {
    _resetPassTEController.clear();
    _confirmPassTeController.clear();
  }

  @override
  void dispose() {
    _confirmPassTeController.dispose();
    _resetPassTEController.dispose();
    super.dispose();
  }
}
*/









///
///
///
///
///
///
///
///
///
///
///
///
///
///







import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_colors.dart' show AppColors;
import 'package:manx_mate/core/config/app_strings.dart' show AppStrings;
import 'package:manx_mate/features/auth/controllers/reset_password_controller.dart' show ResetPasswordController;
import '../widgets/app_custom_textfield.dart';
import '../widgets/custom_text.dart';
import '../widgets/custom_text_field.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _resetPassTEController = TextEditingController();
  final TextEditingController _confirmPassTeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late ResetPasswordController resetPasswordController;

  @override
  void initState() {
    super.initState();
    resetPasswordController = Get.put(ResetPasswordController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.fromLTRB(32, 108, 32, 0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: CustomRichText(
                          firstLabel: 'Reset',
                          secondLabel: 'Password',
                        ),
                      ),
                      const SizedBox(height: 14),
                      Center(
                        child: Text(
                          AppStrings.enterANewPassword,
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(
                            color:
                            AppColors.blackColor.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(AppStrings.password,
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 14),
                      AppCustomContainerField(
                        containerChild: MyTextFormFieldWithIcon(
                          isPassword: true,
                          formHintText: AppStrings.enterPassword,
                          prefixIcon: const Icon(Icons.lock,
                              color: AppColors.primaryColor),
                          controller: _resetPassTEController,
                          validator: (String? value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter your password!';
                            }
                            if (value!.length < 6) {
                              return 'Password must be at least 6 characters!';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.confirmPassword,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 14),
                      AppCustomContainerField(
                        containerChild: MyTextFormFieldWithIcon(
                          isPassword: true,
                          formHintText: AppStrings.confirmPassword,
                          prefixIcon: const Icon(Icons.lock,
                              color: AppColors.primaryColor),
                          controller: _confirmPassTeController,
                          validator: (String? value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please confirm your password!';
                            }
                            if (value != _resetPassTEController.text) {
                              return 'Passwords do not match!';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                      Obx(
                            () => SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: resetPasswordController.isLoading.value
                                ? null
                                : () {
                              FocusScope.of(context).unfocus();
                              if (_formKey.currentState!.validate()) {
                                resetPasswordController.resetPassword(
                                  newPassword:
                                  _resetPassTEController.text,
                                  confirmPassword:
                                  _confirmPassTeController.text,
                                );
                              }
                            },
                            child: resetPasswordController.isLoading.value
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : Text(
                              AppStrings.resetPasswordBtn,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Loading Overlay
            Obx(
                  () => resetPasswordController.isLoading.value
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
    _confirmPassTeController.dispose();
    _resetPassTEController.dispose();
    super.dispose();
  }
}