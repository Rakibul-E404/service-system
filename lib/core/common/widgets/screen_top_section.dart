import 'package:flutter/widgets.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import 'package:manx_mate/core/extensions/widget_extensions.dart';

import '../../config/app_images.dart';
import '../../config/app_sizes.dart';

class ScreenTopSection extends StatelessWidget {
  final String title;

  const ScreenTopSection({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          title.toUpperCase(),
          textAlign: TextAlign.center,
          style: context.txtTheme.labelLarge,
        ).centered,

        const SizedBox(height: AppSizes.spaceBetweenItems,),

        Image.asset(
          AppImages.logo,
          width: 80.0,
          height: 70.0,
        ),
      ],
    );
  }
}