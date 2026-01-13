import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/data/secured_storage.dart';
import 'package:manx_mate/core/network/network_caller.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final TextEditingController _reasonController = TextEditingController();
  final NetworkCaller _networkCaller = NetworkCaller();
  bool _isLoading = false;
  bool _isConfirmed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Delete Account"),
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
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.screenHorizontal,
            vertical: AppSizes.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Warning Icon and Title
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        size: 40,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),
                    Text(
                      'Delete Your Account',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.lg),

              // Warning Message
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                  border: Border.all(color: Colors.red.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Important Notice',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.sm),
                    Text(
                      'Deleting your account is permanent and cannot be undone. All your data, including profile information, bookings, and history will be permanently removed.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.xl),

              // Confirmation Checkbox
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Theme(
                      data: ThemeData(
                        unselectedWidgetColor: Colors.grey,
                      ),
                      child: Checkbox(
                        value: _isConfirmed,
                        onChanged: (value) {
                          setState(() {
                            _isConfirmed = value ?? false;
                          });
                        },
                        activeColor: Colors.red,
                        checkColor: Colors.white,
                        fillColor: MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return Colors.red;
                            }
                            return Colors.grey;
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'I understand that this action cannot be undone and all my data will be permanently deleted.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.xl),

              // Action Buttons
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppColors.greyColor.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.greyColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),

                  // Delete Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (_isLoading || !_isConfirmed) ? null : _deleteAccount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : Text(
                        'Delete Account',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.xl),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteAccount() {
    // Show confirmation dialog
    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Account Deletion'),
        content: const Text(
          'Are you sure you want to permanently delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _performAccountDeletion();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _performAccountDeletion() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get auth token from secure storage
      final String? authToken = await SecureStorageService().read('authToken');

      if (authToken == null) {
        Get.snackbar(
          'Error',
          'Authentication required. Please log in again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Prepare headers with authorization
      final Map<String, String> headers = {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      };

      debugPrint('🗑️ Deleting user account...');
      debugPrint('📍 URL: ${AppUrl.baseUrl}/user/delete-account');

      // Make DELETE API call
      final response = await _networkCaller.deleteRequest(
        '${AppUrl.baseUrl}/user/delete-account',
        headers: headers,
      );

      debugPrint('📡 Delete Account Response:');
      debugPrint('   - Success: ${response.isSuccess}');
      debugPrint('   - Status Code: ${response.statusCode}');
      debugPrint('   - Message: ${response.jsonResponse?['message']}');

      if (response.isSuccess) {
        // Clear all stored data
        await _clearUserData();

        // Show success message
        Get.snackbar(
          'Success',
          'Your account has been deleted successfully.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // Navigate to role selection or login screen
        Get.offAllNamed('/role-selection-screen');
      } else {
        // Handle API error
        final errorMessage = response.jsonResponse?['message'] ??
            response.errorMessage ??
            'Failed to delete account';

        Get.snackbar(
          'Error',
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('❌ Exception during account deletion: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearUserData() async {
    try {
      // Clear all stored user data
      await SecureStorageService().delete('authToken');
      await SecureStorageService().delete('refreshToken');
      await SecureStorageService().delete('userId');
      await SecureStorageService().delete('userName');
      await SecureStorageService().delete('userEmail');
      await SecureStorageService().delete('roleType');

      // Clear any other stored user data
      debugPrint('✅ All user data cleared from storage');
    } catch (e) {
      debugPrint('⚠️ Error clearing user data: $e');
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }
}