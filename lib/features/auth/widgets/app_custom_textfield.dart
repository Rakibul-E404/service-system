import 'package:flutter/material.dart';

class AppCustomContainerField extends StatelessWidget {
  const AppCustomContainerField({super.key, this.containerChild});

  final Widget? containerChild;

  @override
  Widget build(BuildContext context) {
    return Container(child: containerChild);
  }
}
