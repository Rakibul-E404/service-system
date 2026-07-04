// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:flutter_signin_button/flutter_signin_button.dart';
// import 'package:manx_mate/core/config/app_images.dart';
// import 'package:manx_mate/core/config/app_sizes.dart';
// import 'package:manx_mate/core/extensions/context_extensions.dart';
// import 'package:manx_mate/core/extensions/widget_extensions.dart';
// import 'package:manx_mate/core/routes/app_routes.dart';
// import 'package:manx_mate/features/auth/controllers/sign_in_controller.dart' show SignInController;
// import '../../../core/config/app_colors.dart';
// import '../../../core/config/app_strings.dart';
// import '../widgets/app_custom_textfield.dart';
// import '../widgets/custom_text.dart';
// import '../widgets/custom_text_field.dart';
//
// class SignInScreen extends StatefulWidget {
//   const SignInScreen({super.key});
//
//   @override
//   State<SignInScreen> createState() => _SignInScreenState();
// }
//
// class _SignInScreenState extends State<SignInScreen> {
//   final TextEditingController _emailTEController = TextEditingController();
//   final TextEditingController _passwordTEController = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   SignInController signInController = Get.find<SignInController>();
//
//   // Get the role from arguments
//   String get selectedRole => Get.arguments?['role'] ?? 'user';
//
//   // Check if skip button should be visible
//   bool get showSkipButton => selectedRole.toLowerCase() == 'user';
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         toolbarHeight: 40,
//         backgroundColor: Colors.white,
//         automaticallyImplyLeading: false,
//         actions: [
//           // Show Skip button only for user role
//           if (showSkipButton)
//             TextButton(
//               onPressed: () {
//                 // Navigate to user main navigation
//                 Get.offAllNamed(
//                   AppRoutes.mainBottomNavPage,
//                   arguments: {'role': selectedRole},
//                 );
//               },
//               child: const Text("Skip"),
//             ),
//         ],
//       ),
//       body: SafeArea(
//         child: Stack(
//           children: [
//             SingleChildScrollView(
//               physics: const AlwaysScrollableScrollPhysics(),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   vertical: AppSizes.xl,
//                   horizontal: AppSizes.md,
//                 ),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: <Widget>[
//                       const Center(
//                         child: CustomRichText(
//                           firstLabel: 'Sign In',
//                           secondLabel: 'to your account',
//                         ),
//                       ),
//
//                       const SizedBox(height: 14),
//                       Center(
//                         child: Text(
//                           AppStrings.welcomeBackPleaseEnterYourDetails,
//                           style: Theme.of(context)
//                               .textTheme
//                               .displayMedium
//                               ?.copyWith(
//                             color: AppColors.blackColor.withValues(alpha: 0.7),
//                           ),
//                           maxLines: 2,
//                           textAlign: TextAlign.center,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                       const SizedBox(height: AppSizes.lg),
//
//                       // Login Image with constrained size
//                       ConstrainedBox(
//                         constraints: BoxConstraints(
//                           maxHeight: MediaQuery.of(context).size.height * 0.08,
//                         ),
//                         child: Image.asset(
//                           AppImages.loginImage,
//                           fit: BoxFit.contain,
//                         ).centered,
//                       ),
//                       const SizedBox(height: AppSizes.md),
//
//                       /// Google login using flutter_signin_button package
//                       Center(
//                         child: Obx(
//                               () => SizedBox(
//                             width: 200,
//                             child: signInController.isGoogleSignInLoading.value
//                                 ? Container(
//                               padding: const EdgeInsets.symmetric(vertical: 12),
//                               decoration: BoxDecoration(
//                                 color: Colors.grey[100],
//                                 borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
//                                 border: Border.all(
//                                   color: AppColors.greyColor.withOpacity(0.3),
//                                 ),
//                               ),
//                               child: const Center(
//                                 child: SizedBox(
//                                   height: 20,
//                                   width: 20,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                   ),
//                                 ),
//                               ),
//                             )
//                                 : SignInButton(
//                               Buttons.Google,
//                               text: 'Sign in with Google',
//                               onPressed: () {
//                                 debugPrint('🔵 Google sign-in tapped');
//                                 debugPrint('🎭 Selected Role: $selectedRole');
//                                 signInController.handleGoogleSignIn(role: selectedRole);
//                               },
//                               padding: const EdgeInsets.symmetric(vertical: 12),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
//                                 side: BorderSide(
//                                   color: AppColors.greyColor.withOpacity(0.3),
//                                 ),
//                               ),
//                               elevation: 1,
//                             ),
//                           ),
//                         ),
//                       ),
//
//                       // OR Divider
//                       const SizedBox(height: 32),
//                       Row(
//                         children: <Widget>[
//                           Expanded(
//                             child: Divider(
//                               color: AppColors.greyColor.withOpacity(0.3),
//                               thickness: 1,
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 16),
//                             child: Text(
//                               'OR',
//                               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                                 color: AppColors.greyColor,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                           Expanded(
//                             child: Divider(
//                               color: AppColors.greyColor.withOpacity(0.3),
//                               thickness: 1,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 32),
//
//                       // Email Field
//                       Text(AppStrings.email, style: Theme.of(context).textTheme.headlineMedium),
//                       const SizedBox(height: 14),
//                       AppCustomContainerField(
//                         containerChild: MyTextFormFieldWithIcon(
//                           formHintText: AppStrings.enterYourEmail,
//                           prefixIcon: const Icon(Icons.mail_outline, color: AppColors.primaryColor),
//                           controller: _emailTEController,
//                           validator: (String? value) {
//                             if (value?.isEmpty ?? true) {
//                               return '${AppStrings.pleaseEnterYour} ${AppStrings.email}!!';
//                             }
//                             if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
//                               return 'Please enter a valid email!';
//                             }
//                             return null;
//                           },
//                           onChanged: (String value) {},
//                         ),
//                       ),
//
//                       const SizedBox(height: 16),
//                       Text(AppStrings.password, style: Theme.of(context).textTheme.headlineMedium),
//                       const SizedBox(height: 14),
//                       AppCustomContainerField(
//                         containerChild: MyTextFormFieldWithIcon(
//                           isPassword: true,
//                           formHintText: AppStrings.enterPassword,
//                           prefixIcon: const Icon(Icons.lock_outlined, color: AppColors.primaryColor),
//                           controller: _passwordTEController,
//                           validator: (String? value) {
//                             if (value?.isEmpty ?? true) {
//                               return '${AppStrings.pleaseEnterYour} Password !!';
//                             }
//                             if (value!.length < 6) {
//                               return 'Password must be at least 6 characters!';
//                             }
//                             return null;
//                           },
//                           onChanged: (String value) {},
//                         ),
//                       ),
//
//                       const SizedBox(height: 16),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: <Widget>[
//                           TextButton(
//                             onPressed: () {
//                               Get.toNamed(
//                                 AppRoutes.forgotPasswordRoute,
//                                 arguments: {'role': selectedRole},
//                               );
//                             },
//                             child: Text(
//                               AppStrings.forgotPassword,
//                               style: Theme.of(context).textTheme.displayMedium?.copyWith(
//                                 decoration: TextDecoration.underline,
//                                 color: AppColors.blackColor,
//                               ),
//                               textAlign: TextAlign.end,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//
//                       // Sign In Button with Loading State
//                       Obx(
//                             () => SizedBox(
//                           width: double.infinity,
//                           child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: AppColors.primaryColor,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               elevation: 0,
//                               padding: const EdgeInsets.symmetric(vertical: 16),
//                             ),
//                             onPressed: signInController.isLoading.value
//                                 ? null
//                                 : () async {
//                               FocusScope.of(context).unfocus();
//
//                               if (_formKey.currentState!.validate()) {
//                                 await signInController.signIn(
//                                   email: _emailTEController.text.trim(),
//                                   password: _passwordTEController.text,
//                                 );
//                               }
//                             },
//                             child: signInController.isLoading.value
//                                 ? const SizedBox(
//                               height: 20,
//                               width: 20,
//                               child: CircularProgressIndicator(
//                                 color: Colors.white,
//                                 strokeWidth: 2,
//                               ),
//                             )
//                                 : Text(
//                               AppStrings.signIn,
//                               style: Theme.of(context).textTheme.labelLarge?.copyWith(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//
//                       const SizedBox(height: 16),
//                       Center(
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: <Widget>[
//                             Text(
//                               AppStrings.dontHaveAnAccount,
//                               style: Theme.of(context).textTheme.bodyMedium,
//                             ),
//                             TextButton(
//                               onPressed: () {
//                                 Get.toNamed(
//                                   AppRoutes.signUpRoute,
//                                   arguments: {'role': selectedRole},
//                                 );
//                               },
//                               child: Text(
//                                 AppStrings.signUp,
//                                 style: Theme.of(context).textTheme.labelMedium?.copyWith(
//                                   decoration: TextDecoration.underline,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//
//                       // Add some bottom padding to prevent overflow
//                       const SizedBox(height: AppSizes.xl),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//
//             // Loading Overlay for both regular and Google sign in
//             Obx(
//                   () => (signInController.isLoading.value || signInController.isGoogleSignInLoading.value)
//                   ? Container(
//                 color: Colors.black.withValues(alpha: 0.3),
//                 child: const Center(
//                   child: CircularProgressIndicator(),
//                 ),
//               )
//                   : const SizedBox.shrink(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void clearingTextField() {
//     _emailTEController.clear();
//     _passwordTEController.clear();
//   }
//
//   @override
//   void dispose() {
//     _emailTEController.dispose();
//     _passwordTEController.dispose();
//     super.dispose();
//   }
// }
//






///
///
///
/// todo:: upper has package issue
///
///
///



import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

                      /// Google login — custom button, no external sign-in package
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
                                : _GoogleSignInButton(
                              text: 'Sign in with Google',
                              onPressed: () {
                                debugPrint('🔵 Google sign-in tapped');
                                debugPrint('🎭 Selected Role: $selectedRole');
                                signInController.handleGoogleSignIn(role: selectedRole);
                              },
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

/// Custom Google sign-in button — replaces the flutter_signin_button
/// package's SignInButton(Buttons.Google, ...) with a plain OutlinedButton.
class _GoogleSignInButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _GoogleSignInButton({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
        ),
        side: BorderSide(
          color: AppColors.greyColor.withOpacity(0.3),
        ),
        elevation: 1,
        backgroundColor: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _GoogleLogo(size: 18),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Minimal 4-color "G" mark drawn with a Stack — no image asset or
/// external icon package required. Swap for Image.asset(AppImages.googleIcon)
/// if you already have a Google logo asset in your project.
class _GoogleLogo extends StatelessWidget {
  final double size;
  const _GoogleLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: CustomPaint(
        painter: _GoogleGPainter(),
      ),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Offset center = Offset(radius, radius);
    final double strokeWidth = size.width * 0.22;

    final Paint bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final Paint greenPaint = Paint()..color = const Color(0xFF34A853)..style = PaintingStyle.stroke..strokeWidth = strokeWidth;
    final Paint yellowPaint = Paint()..color = const Color(0xFFFBBC05)..style = PaintingStyle.stroke..strokeWidth = strokeWidth;
    final Paint redPaint = Paint()..color = const Color(0xFFEA4335)..style = PaintingStyle.stroke..strokeWidth = strokeWidth;

    final Rect rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    // Four arcs approximating the Google "G" ring
    canvas.drawArc(rect, -0.4, 1.6, false, bluePaint);
    canvas.drawArc(rect, 1.2, 1.4, false, greenPaint);
    canvas.drawArc(rect, 2.6, 1.2, false, yellowPaint);
    canvas.drawArc(rect, 3.8, 1.6, false, redPaint);

    // Horizontal bar of the "G"
    final Paint barPaint = Paint()..color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(radius, radius - strokeWidth / 2, radius - strokeWidth * 0.3, strokeWidth),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldPainter) => false;
}