/**
import 'package:flutter/material.dart';

// Reusable Logout Modal
class LogoutModal {
  static void show({
    required BuildContext context,
    String? title,
    String? message,
    String? confirmButtonText,
    String? cancelButtonText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    Color? confirmButtonColor,
    Color? cancelButtonColor,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Title
                Text(
                  title ?? 'Logout',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 16),

                // Message
                Text(
                  message ?? 'Are you sure you want to logout?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: <Widget>[
                    // Cancel Button
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          if (onCancel != null) {
                            onCancel();
                          }
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: Text(
                          cancelButtonText ?? 'No',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: cancelButtonColor ?? Colors.grey[700],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Confirm Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          if (onConfirm != null) {
                            onConfirm();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: confirmButtonColor ?? Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          confirmButtonText ?? 'Yes',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}*/






///
///
///
/// todo:: token clearing working down and fixed
///
///
///


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/features/profile/controllers/profile_controller.dart';

// Reusable Logout Modal with Token Clearing
class LogoutModal {
  static void show({
    required BuildContext context,
    String? title,
    String? message,
    String? confirmButtonText,
    String? cancelButtonText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    Color? confirmButtonColor,
    Color? cancelButtonColor,
    bool clearTokens = true, // Option to clear tokens on confirm
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout,
                    color: Colors.red,
                    size: 28,
                  ),
                ),

                const SizedBox(height: 20),

                // Title
                Text(
                  title ?? 'Logout',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),

                const SizedBox(height: 12),

                // Message
                Text(
                  message ?? 'Are you sure you want to logout?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                    height: 1.5,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),

                const SizedBox(height: 28),

                // Buttons
                Row(
                  children: <Widget>[
                    // Cancel Button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          if (onCancel != null) {
                            onCancel();
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: cancelButtonColor ?? Colors.grey[300]!,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          cancelButtonText ?? 'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: cancelButtonColor ?? Colors.grey[700],
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Confirm Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();

                          // Clear tokens and logout if enabled
                          if (clearTokens) {
                            try {
                              final ProfileController controller = Get.find<ProfileController>();
                              await controller.logout();
                            } catch (e) {
                              debugPrint('❌ Error during logout: $e');
                              // Show error message if needed
                              Get.snackbar(
                                'Error',
                                'Failed to logout. Please try again.',
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                                snackPosition: SnackPosition.TOP,
                              );
                            }
                          }

                          // Call custom onConfirm callback if provided
                          if (onConfirm != null) {
                            onConfirm();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: confirmButtonColor ?? Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          confirmButtonText ?? 'Logout',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


