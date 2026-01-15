
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import '../../auth/widgets/custom_text_field.dart';

class SearchInputSection extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback onSearch;

  const SearchInputSection({
    super.key,
    required this.searchController,
    required this.onSearch,
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
          Row(
            children: [
              Expanded(
                child: MyTextFormFieldWithIcon(
                  formHintText: "Search by keyword...",
                  prefixIcon: const Icon(CupertinoIcons.search,
                      color: AppColors.primaryColor),
                  controller: searchController,
                  validator: (String? value) => null,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  if (searchController.text.isNotEmpty) {
                    onSearch();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                child: const Text('Search'),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
        ],
      ),
    );
  }
}