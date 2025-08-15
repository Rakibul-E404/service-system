import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_sizes.dart';

class PrivacyPolicyTemplatePage extends StatelessWidget {
  const PrivacyPolicyTemplatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, String> pageData = Get.arguments as Map<String, String>;
    return Scaffold(
      appBar: AppBar(
        title: Text(pageData['title'] ?? ''),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenHorizontal),
          child: Text(pageData['bodyText'] ?? ''),
        ),
      ),
    );
  }
}
