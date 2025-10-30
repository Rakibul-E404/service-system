import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:flutter_html/flutter_html.dart';  // Import flutter_html for HTML rendering
import '../controllers/privacy_policy_screen_controller.dart';

class PrivacyPolicyTemplatePage extends GetView<PrivacyPolicyTemplateController> {
  const PrivacyPolicyTemplatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.appBarTitle)),  // Use appBarTitle instead
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: controller.goBack,
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.content.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.description_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No content available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: controller.retry,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.screenHorizontal,
              vertical: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title (Bold) - from API
                if (controller.contentTitle.isNotEmpty)
                  Text(
                    controller.contentTitle,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                const SizedBox(height: 8),

                // Updated Date
                if (controller.updatedAt.isNotEmpty)
                  Text(
                    'Last Updated: ${controller.updatedAt}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                const SizedBox(height: 20),

                // Render HTML content
                Html(
                  data: controller.content,  // Display the content with HTML rendering
                  style: {
                    "body": Style(
                      fontSize: FontSize(14),
                      // height: LineHeight(1.6),
                      color: Colors.black87,
                    ),
                  },
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
