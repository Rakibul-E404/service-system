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
