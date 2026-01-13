/**
import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final num width;
  final double radius;

  const PrimaryButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
    this.width = double.infinity,
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width.toDouble(),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        // boxShadow: const <BoxShadow>[
        //   BoxShadow(
        //     color: Color(0xFF529AD9),
        //     // Blue shadow with opacity
        //     offset: Offset(0, 6),
        //   ),
        // ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius), // Change the radius as needed
          ),
        ),
        child: Text(buttonText, style: Theme.of(context).textTheme.labelMedium),
      ),
    );
  }
}
*/







///
///
///
///
///
///
///




import 'package:flutter/material.dart';
import 'package:manx_mate/core/config/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;

  const PrimaryButton({
    super.key,
    required this.buttonText,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : Text(
          buttonText,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: textColor ?? Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}