


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/common/widgets/reusable_button.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_sizes.dart';



class ReportController extends GetxController {
  // final String baseUrl = 'https://d7001.sobhoy.com/api/v1';
  final String baseUrl = 'https://5003.dipudebnath.tech/api/v1';
  var isLoading = false.obs;
  var reportedUserId = ''.obs; // This is the author ID we need to pass as reportBy
  var userName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeWithArguments();
    // No need to fetch current user ID since we're using the reported user's ID
  }

  void _initializeWithArguments() {
    final dynamic args = Get.arguments;
    debugPrint('🔍 ReportController - Received arguments: $args');

    if (args != null && args is Map<String, dynamic>) {
      reportedUserId.value = args['reportedUserId']?.toString() ?? '';
      userName.value = args['userName']?.toString() ?? 'Unknown User';
      debugPrint('🎯 Reported User ID (will be used as reportBy): ${reportedUserId.value}');
      debugPrint('👤 Reported User Name: ${userName.value}');
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

  /// Submit report to the API - using the reported user's ID as reportBy
  Future<void> submitReport({
    required String title,
    required String description,
  }) async {
    try {
      isLoading.value = true;

      // Check if we have the reported user ID
      if (reportedUserId.isEmpty) {
        Get.snackbar(
          "Error",
          "No user selected to report.",
          backgroundColor: Colors.red.shade100,
          colorText: Colors.black87,
          snackPosition: SnackPosition.BOTTOM,
        );
        isLoading.value = false;
        return;
      }

      final token = await _getAuthToken();

      if (token == null) {
        Get.snackbar(
          "Error",
          "Authentication failed. Please log in again.",
          backgroundColor: Colors.red.shade100,
          colorText: Colors.black87,
          snackPosition: SnackPosition.BOTTOM,
        );
        isLoading.value = false;
        return;
      }

      final url = Uri.parse('$baseUrl/report');
      debugPrint('📡 Posting report to: $url');

      // Prepare request body - using the reported user's ID as reportBy
      final requestBody = {
        "reportBy": reportedUserId.value, // Use the reported user's ID (author ID)
        "title": title.trim(),
        "description": description.trim(),
        // Removed reportedUserId as it's not needed by the API
      };

      debugPrint('📤 Request Body: $requestBody');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
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
                  Get.back(); // go back to previous screen
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Report User"),
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

              // Show reported user info if available
              Obx(() {
                if (controller.reportedUserId.value.isNotEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Reporting: ${controller.userName.value}',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox();
              }),

              const SizedBox(height: AppSizes.lg),

              // Subject Field
              const Text(
                'Subject',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: 'Enter report subject...',
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
              const Text(
                'Description',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Describe the issue in detail...',
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
                  label: controller.isLoading.value ? 'Submitting...' : 'Submit Report',
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

                    controller.submitReport(
                      title: title,
                      description: desc,
                    );
                  },
                );
              }),

              const SizedBox(height: AppSizes.xl),
            ],
          ),
        ),
      ),
    );
  }
}