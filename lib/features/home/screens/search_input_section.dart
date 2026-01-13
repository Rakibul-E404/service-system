import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../auth/widgets/custom_text_field.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';

class SearchInputSection extends StatelessWidget {
  final TextEditingController searchController;

  const SearchInputSection({
    super.key,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: AppSizes.sm),
          Text(
            'What are you looking for?',
            style: context.txtTheme.labelSmall?.copyWith(fontSize: 24),
          ),
          const SizedBox(height: AppSizes.sm),
          MyTextFormFieldWithIcon(
            formHintText: "Search by keyword...",
            prefixIcon: const Icon(CupertinoIcons.search,
                color: AppColors.primaryColor),
            controller: searchController,
            validator: (String? value) => null,
          ),
          const SizedBox(height: AppSizes.sm),
        ],
      ),
    );
  }
}