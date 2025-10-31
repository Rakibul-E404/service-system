/**
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/common/widgets/reusable_button.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/config/app_sizes.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Report"),
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
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Subject',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primaryColor),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Type Here',

                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primaryColor),
                  ),
                ),
                maxLines: 7,
              ),
              const SizedBox(height: AppSizes.lg),
              ReusableButton(onTap: () {}, label: 'Post Report'),
            ],
          ),
        ),
      ),
    );
  }
}
*/









import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/common/widgets/reusable_button.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_sizes.dart';

class ReportController extends GetxController {
  final String baseUrl = 'https://d7001.sobhoy.com/api/v1';
  var isLoading = false.obs;
  var userId = ''.obs;

  /// Fetch user profile to get the user ID
  Future<void> fetchUserId() async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        debugPrint('❌ No auth token found');
        return;
      }

      final url = Uri.parse('$baseUrl/user/self');
      debugPrint('🌐 Fetching user info from: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('📦 Status: ${response.statusCode}');
      debugPrint('📩 Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          userId.value = data['data']['_id'] ?? '';
          debugPrint('✅ User ID retrieved: ${userId.value}');
        } else {
          debugPrint('⚠️ Failed to parse user info');
        }
      } else {
        debugPrint('❌ Failed to fetch user info: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Exception fetching user info: $e');
    }
  }

  /// Get stored access token from SharedPreferences
  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('accessToken');
    } catch (e) {
      debugPrint('❌ Error getting token: $e');
      return null;
    }
  }

  /// Submit report to the API
  Future<void> submitReport({
    required String title,
    required String description,
  }) async {
    try {
      isLoading.value = true;

      // Ensure we have the userId
      if (userId.isEmpty) {
        await fetchUserId();
      }

      final token = await _getAuthToken();

      if (token == null || userId.isEmpty) {
        Get.snackbar(
          "Error",
          "Authentication failed. Please log in again.",
          backgroundColor: Colors.red.shade100,
          colorText: Colors.black87,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final url = Uri.parse('$baseUrl/report');
      debugPrint('📡 Posting report to: $url');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "reportBy": userId.value,
          "title": title.trim(),
          "description": description.trim(),
        }),
      );

      debugPrint('📦 Response status: ${response.statusCode}');
      debugPrint('📩 Response body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201 && responseData['success'] == true) {
        Get.dialog(
          AlertDialog(
            title: const Text('✅ Report Submitted'),
            content: const Text('Your report has been created successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back(); // close dialog
                  Get.back(); // go back
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        final message = responseData['message'] ?? 'Failed to create report.';
        throw Exception(message);
      }
    } catch (e) {
      debugPrint('❌ Report submission failed: $e');
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black87,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ReportController controller = Get.put(ReportController());
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    // Fetch user ID when the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchUserId();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Report"),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: AppSizes.lg),

              // Subject Field
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: 'Subject',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.md),

              // Description Field
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Type Here...',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
                  ),
                ),
                maxLines: 7,
              ),

              const SizedBox(height: AppSizes.lg),

              // Submit Button
              Obx(() {
                return ReusableButton(
                  label: controller.isLoading.value ? 'Submitting...' : 'Post Report',
                  onTap: () {
                    if (controller.isLoading.value) return;

                    final title = titleController.text.trim();
                    final desc = descriptionController.text.trim();

                    if (title.isEmpty || desc.isEmpty) {
                      Get.snackbar(
                        "Missing Fields",
                        "Please fill in both Subject and Description.",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.yellow.shade100,
                        colorText: Colors.black87,
                      );
                      return;
                    }

                    controller.submitReport(title: title, description: desc);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

