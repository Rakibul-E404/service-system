import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_images.dart';
import '../controllers/splash_screen_controller.dart';

class SplashScreenScreen extends GetView<SplashScreenController> {
  const SplashScreenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure navigation logic happens only once on the first build
    controller.navigateToNextScreen();

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImages.splashScreenImage),
                fit: BoxFit.fill,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

