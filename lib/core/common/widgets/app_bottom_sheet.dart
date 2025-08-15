import 'package:flutter/material.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';

class CustomModalBottomSheet extends StatelessWidget {
  final Widget child;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final Color? buttonColor;
  final Color? buttonTextColor;
  final bool isButtonEnabled;
  final double? height;
  final EdgeInsets? contentPadding;
  final String? title;

  const CustomModalBottomSheet({
    super.key,
    required this.child,
    required this.buttonText,
    required this.onButtonPressed,
    this.buttonColor,
    this.buttonTextColor,
    this.isButtonEnabled = true,
    this.height,
    this.contentPadding,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title (optional)
          if (title != null) ...<Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(title ?? '', style: context.txtTheme.labelLarge),
            ),
           ],

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: child,
            ),
          ),

          // Bottom button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: isButtonEnabled ? onButtonPressed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor ?? AppColors.primaryColor,
                foregroundColor: buttonTextColor ?? AppColors.textBlackColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                disabledBackgroundColor: AppColors.greyColor,
                disabledForegroundColor: AppColors.greyColor,
              ),
              child: Text(
                buttonText,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Static method to show the modal bottom sheet
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    required String buttonText,
    required VoidCallback onButtonPressed,
    Color? buttonColor,
    Color? buttonTextColor,
    bool isButtonEnabled = true,
    double? height,
    EdgeInsets? contentPadding,
    String? title,
    bool isScrollControlled = true,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => CustomModalBottomSheet(
        buttonText: buttonText,
        onButtonPressed: onButtonPressed,
        buttonColor: buttonColor,
        buttonTextColor: buttonTextColor,
        isButtonEnabled: isButtonEnabled,
        height: height,
        contentPadding: contentPadding,
        title: title,
        child: child,
      ),
    );
  }
}
