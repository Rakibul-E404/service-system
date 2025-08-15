import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
 import 'package:manx_mate/core/common/widgets/agreement_layout.dart';
import 'package:manx_mate/core/config/app_colors.dart' show AppColors;
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/routes/app_routes.dart';
import 'package:manx_mate/features/auth/controllers/sign_up_controller.dart' show SignUpController;
  import '../../../core/config/app_strings.dart';
import '../widgets/app_custom_textfield.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_text.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/reusable_date_picker_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _firstNameTEController = TextEditingController();
  final TextEditingController _lastNameTEController = TextEditingController();
  final TextEditingController _dateTEController = TextEditingController();
  final TextEditingController _emailTEController = TextEditingController();
  final TextEditingController _phoneTEController = TextEditingController();
  final TextEditingController _passwordTEController = TextEditingController();
  final TextEditingController _confirmPasswordTEController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  SignUpController signUpController = Get.find<SignUpController>();

  /// controller initialization

  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(headingText: ''),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.fromLTRB(32, 8, 32, 0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Center(
                        child: CustomRichText(
                          firstLabel: 'Sign up with ',
                          secondLabel: 'Email',
                          secondLabelColor: AppColors.primaryColor,
                          firstLabelColor: AppColors.blackColor,
                        ),
                      ),

                      const SizedBox(height: 14),
                      Center(
                        child: Text(
                          'Please enter your details.',
                          style: Theme.of(
                            context,
                          ).textTheme.displayMedium?.copyWith(color: AppColors.blackColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(AppStrings.name, style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 14),
                      AppCustomContainerField(
                        containerChild: MyTextFormFieldWithIcon(
                          formHintText: AppStrings.firstName,

                          controller: _firstNameTEController,
                          validator: (String? value) {
                            if (value?.isEmpty ?? true) {
                              return '${AppStrings.pleaseEnterYour} ${AppStrings.firstName} !!';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      MyTextFormFieldWithIcon(
                        formHintText: AppStrings.lastName,

                        controller: _lastNameTEController,
                        validator: (String? value) {
                          if (value?.isEmpty ?? true) {
                            return '${AppStrings.pleaseEnterYour} ${AppStrings.lastName} !!';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      Text(AppStrings.location, style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 14),

                      MyTextFormFieldWithIcon(
                        formHintText: AppStrings.enterYourLocation,
                        prefixIcon: const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.primaryColor,
                        ),
                        controller: _emailTEController,
                        validator: (String? value) {
                          if (value?.isEmpty ?? true) {
                            return '${AppStrings.pleaseEnterYour} ${AppStrings.yourEmail}!!';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      Text(AppStrings.password, style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 14),
                      MyTextFormFieldWithIcon(
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
                      ),

                      const SizedBox(height: 16),
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
                              return '${AppStrings.pleaseEnterYour} Password again !!';
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 32),
                      AgreementLayout(
                        value: _isChecked,
                        onChange: (bool? value) {
                          setState(() {
                            _isChecked = value ?? false;
                          });
                        },
                      ),
                      SizedBox(height: AppSizes.md),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isChecked
                                ? AppColors.primaryColor
                                : AppColors.primaryColor.withValues(alpha: .5),
                          ),
                          onPressed: () {
                            FocusScope.of(context).unfocus();

                            if (_isChecked) {
                              setState(() {
                                clearTextFields(); // Clear fields inside setState to trigger UI refresh
                              });

                              // TODO: Sign up logic
                              // if (_formKey.currentState!.validate()) {}
                            }
                          },
                          child: Text(
                            AppStrings.signUp,
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            const Text(AppStrings.alreadyHaveAnAccount),
                            TextButton(
                              onPressed: () {
                                Get.toNamed(AppRoutes.loginRoute);
                              },
                              child: Text(
                                AppStrings.signIn,
                                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void clearTextFields() {
    _firstNameTEController.clear();
    _lastNameTEController.clear();
    _dateTEController.clear();
    _emailTEController.clear();

    _phoneTEController.clear();

    _passwordTEController.clear();

    _confirmPasswordTEController.clear();
  }

  @override
  void dispose() {
    _firstNameTEController.dispose();
    _lastNameTEController.dispose();
    _dateTEController.dispose();
    _emailTEController.dispose();
    _phoneTEController.dispose();
    _passwordTEController.dispose();
    _confirmPasswordTEController.dispose();
    super.dispose();
  }
}
