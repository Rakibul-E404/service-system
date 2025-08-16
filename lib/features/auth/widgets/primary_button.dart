import 'package:flutter/material.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/utils/device/device_utility.dart';

class PrimaryButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final num width;

  const PrimaryButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width.toDouble(),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: const <BoxShadow>[
          // BoxShadow(
          //   color: AppColors.blackColor,
          //   // Blue shadow with opacity
          //   offset: Offset(0, 6),
          // ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          DeviceUtility.hapticFeedback();
          onPressed();
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // Adjust the radius as needed
          ),
        ),
        child: Text(buttonText, style: Theme.of(context).textTheme.labelMedium),
      ),
    );
  }
}
