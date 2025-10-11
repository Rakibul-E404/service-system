import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/common/widgets/agreement_layout.dart';
import 'package:manx_mate/core/config/app_colors.dart' show AppColors;
import 'package:manx_mate/core/config/app_constants.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/data/secured_storage.dart';
import 'package:manx_mate/core/routes/app_routes.dart';
import 'package:manx_mate/features/auth/controllers/sign_up_controller.dart' show SignUpController;
import '../../../core/config/app_strings.dart';
import '../widgets/app_custom_textfield.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_text.dart';
import '../widgets/custom_text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameTEController = TextEditingController();
  final TextEditingController _emailTEController = TextEditingController();
  final TextEditingController _passwordTEController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  SignUpController signUpController = Get.find<SignUpController>();

  bool _isChecked = false;
  String? selectedRole;
  String? selectedLocation;

  // List of locations for dropdown (stored as lowercase)
  final List<String> locations = <String>[
    'north',
    'south',
    'east',
    'west',
  ];

  @override
  void initState() {
    super.initState();
    _initializeRole();
  }

  /// Initialize role from arguments or secured storage
  Future<void> _initializeRole() async {
    // First, try to get role from navigation arguments
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null && arguments['role'] != null) {
      selectedRole = arguments['role'] as String;
      signUpController.setRole(selectedRole!);
    } else {
      // If not in arguments, try to get from secure storage
      selectedRole = await SecureStorageService().read(AppConstants.roleType);
      if (selectedRole != null && selectedRole!.isNotEmpty) {
        signUpController.setRole(selectedRole!);
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  /// Capitalize first letter of string
  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) {
      return text;
    }
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(headingText: ''),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
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
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(color: AppColors.blackColor),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          const SizedBox(height: 32),

                          /// Name Field
                          Text(
                            AppStrings.name,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 14),
                          AppCustomContainerField(
                            containerChild: MyTextFormFieldWithIcon(
                              formHintText: 'Enter your name',
                              controller: _nameTEController,
                              validator: (String? value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Please enter your name!';
                                }
                                return null;
                              },
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Email Field
                          Text(
                            'Email',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 14),
                          MyTextFormFieldWithIcon(
                            formHintText: 'Enter your email',
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: AppColors.primaryColor,
                            ),
                            controller: _emailTEController,
                            validator: (String? value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter your email!';
                              }
                              // Basic email validation
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value!)) {
                                return 'Please enter a valid email!';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Location Dropdown
                          Text(
                            AppStrings.location,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 14),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.primaryColor),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                hintText: 'Select your location',
                                prefixIcon: Icon(
                                  Icons.location_on_outlined,
                                  color: AppColors.primaryColor,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              value: selectedLocation,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down),
                              items: locations.map((String location) {
                                return DropdownMenuItem<String>(
                                  value: location, // Stores as lowercase: 'north'
                                  child: Text(
                                    _capitalizeFirstLetter(
                                        location), // Displays as: 'North'
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedLocation = newValue;
                                });
                              },
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select your location!';
                                }
                                return null;
                              },
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Password Field
                          Text(
                            AppStrings.password,
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
                            controller: _passwordTEController,
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

                          const SizedBox(height: 32),

                          // Terms and Conditions
                          AgreementLayout(
                            value: _isChecked,
                            onChange: (bool? value) {
                              setState(() {
                                _isChecked = value ?? false;
                              });
                            },
                          ),

                          const SizedBox(height: AppSizes.md),

                          // Sign Up Button with Loading State
                          Obx(
                                () => SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isChecked
                                      ? AppColors.primaryColor
                                      : AppColors.primaryColor
                                      .withValues(alpha: .5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: signUpController.isLoading.value
                                    ? null
                                    : () {
                                  FocusScope.of(context).unfocus();

                                  if (_isChecked) {
                                    if (_formKey.currentState!
                                        .validate()) {
                                      _handleSignUp();
                                    }
                                  }
                                },
                                child: signUpController.isLoading.value
                                    ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                    : Text(
                                  AppStrings.signUp,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Sign In Link
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium!
                                        .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.blackColor,
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

            // Loading Overlay
            Obx(
                  () => signUpController.isLoading.value
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

  /// Handle sign up with all form data including role
  Future<void> _handleSignUp() async {
    debugPrint('═══════════════════════════════════════');
    debugPrint('📝 SIGN UP FORM DATA');
    debugPrint('Name: ${_nameTEController.text.trim()}');
    debugPrint('Email: ${_emailTEController.text.trim()}');
    debugPrint('Location (displayed): ${_capitalizeFirstLetter(selectedLocation!)}');
    debugPrint('Location (sent to API): $selectedLocation');
    debugPrint('Role: ${signUpController.selectedRole.value}');
    debugPrint('═══════════════════════════════════════');

    // Call the sign up method from controller
    await signUpController.signUp(
      name: _nameTEController.text.trim(),
      email: _emailTEController.text.trim(),
      location: selectedLocation!, // Sends lowercase: 'north'
      password: _passwordTEController.text,
    );

    // Note: Don't clear fields here - let the controller handle navigation
    // Fields will be cleared if user navigates back to this screen
  }

  void clearTextFields() {
    _nameTEController.clear();
    _emailTEController.clear();
    _passwordTEController.clear();
    setState(() {
      selectedLocation = null;
      _isChecked = false;
    });
  }

  @override
  void dispose() {
    _nameTEController.dispose();
    _emailTEController.dispose();
    _passwordTEController.dispose();
    super.dispose();
  }
}