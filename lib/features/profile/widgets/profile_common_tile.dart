import 'package:flutter/material.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_sizes.dart';

class ProfileCommonTile extends StatelessWidget {
  final VoidCallback onTap;
  final Widget leadingIcon;
  final String title;

  const ProfileCommonTile({
    super.key,
    required this.onTap,
    required this.leadingIcon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),

      color: AppColors.whiteColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),

        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.md, horizontal: AppSizes.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.5)),
          ),
          child: Row(
            spacing: 8,
            children: <Widget>[
              leadingIcon,
              Expanded(child: Text(title)),
              const Icon(Icons.arrow_forward_ios_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
