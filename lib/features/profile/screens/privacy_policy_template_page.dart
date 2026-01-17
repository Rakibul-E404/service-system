import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:flutter_html/flutter_html.dart';  // Import flutter_html for HTML rendering
import '../../../core/config/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../controllers/privacy_policy_screen_controller.dart';

class PrivacyPolicyTemplatePage extends GetView<PrivacyPolicyTemplateController> {
  const PrivacyPolicyTemplatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Obx(() => Text(
          controller.appBarTitle,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        )),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.5, // Light shadow for depth
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: controller.goBack,
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
          }

          if (controller.content.isEmpty) {
            return _buildEmptyState();
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                if (controller.contentTitle.isNotEmpty)
                  Text(
                    controller.contentTitle,
                    style: context.txtTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      letterSpacing: -0.5,
                    ),
                  ),

                const SizedBox(height: 8),

                // Last Updated Badge
                if (controller.updatedAt.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Last Updated: ${controller.updatedAt}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(color: Color(0xFFEEEEEE), thickness: 1),
                ),

                // Render HTML content with enhanced styling
                Html(
                  data: controller.content,
                  style: {
                    "body": Style(
                      fontSize: FontSize(15),
                      lineHeight: LineHeight.em(1.6),
                      color: Colors.black87,
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                      textAlign: TextAlign.justify,
                    ),
                    "h1": Style(
                      fontSize: FontSize(20),
                      fontWeight: FontWeight.bold,
                      margin: Margins.only(top: 16, bottom: 8),
                      color: Colors.black,
                    ),
                    "strong": Style(
                      fontWeight: FontWeight.bold,
                      // The style color from your API (rgb 102, 163, 224)
                      // will be handled automatically by the library.
                    ),
                    "p": Style(
                      margin: Margins.only(bottom: 12),
                    ),
                  },
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
            child: const Icon(Icons.description_outlined, size: 64, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          const Text('No content available', style: TextStyle(fontSize: 16, color: Colors.grey)),
          TextButton(onPressed: controller.retry, child: const Text('Retry')),
        ],
      ),
    );
  }
}