import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String headingText;

  const CustomAppbar({super.key, required this.headingText});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
       crossAxisAlignment: CrossAxisAlignment.center,
       children: <Widget>[
         IconButton(
           onPressed: () {
             Get.back();
           },
           icon: const Icon(Icons.arrow_back_outlined),
         ),
         Text(headingText, style: Theme.of(context).textTheme.headlineMedium),
       ],
              ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
