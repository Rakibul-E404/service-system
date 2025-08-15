import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_images.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import '../../../core/common/widgets/reusable_button.dart';
import '../controllers/splash_screen_controller.dart';

class SplashScreenScreen extends GetView<SplashScreenController> {
  const SplashScreenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    controller.navigateToNextScreen();
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.splashScreenImage),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
