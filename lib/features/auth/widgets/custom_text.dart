import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:manx_mate/core/config/app_colors.dart' show AppColors;

class CustomRichText extends StatelessWidget {
  const CustomRichText({
    super.key,
    required this.firstLabel,
    required this.secondLabel,
    this.isExpanded = false,
    this.onPress = emptyCallback,
    this.firstLabelColor = AppColors.primaryColor,
    this.secondLabelColor = AppColors.blackColor,
  });

  final String firstLabel;
  final String secondLabel;
  final VoidCallback onPress;
  final Color firstLabelColor;
  final Color secondLabelColor;


  final bool isExpanded;

  static void emptyCallback() {}

  @override
  Widget build(BuildContext context) {
    return isExpanded
        ? Expanded(
          child: RichText(
            text: TextSpan(
              text: firstLabel,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w400),
              children: <TextSpan>[
                TextSpan(
                  text: " $secondLabel",
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(color: secondLabelColor),
                  recognizer: TapGestureRecognizer()..onTap = onPress,
                ),
              ],
            ),
          ),
        )
        : RichText(
          text: TextSpan(
            text: firstLabel,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: firstLabelColor,
            ),
            children: <TextSpan>[
              TextSpan(
                text: " $secondLabel",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: secondLabelColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
                recognizer: TapGestureRecognizer()..onTap = onPress,
              ),
            ],
          ),
        );
  }
}
