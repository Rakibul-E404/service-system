import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import '../controllers/search_controller.dart';

class SearchResultsHeader extends StatelessWidget {
  final TextEditingController searchTEController;
  final bool initialSearchPerformed;
  final HomeSearchController controller;
  final VoidCallback onSeeAll;

  const SearchResultsHeader({
    super.key,
    required this.searchTEController,
    required this.initialSearchPerformed,
    required this.controller,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeSearchController>(
      builder: (HomeSearchController ctrl) {
        final bool showDummyData = !initialSearchPerformed &&
            ctrl.filteredServices.isEmpty &&
            searchTEController.text.isEmpty;

        final List<dynamic> displayServices = showDummyData
            ? [] // We'll handle this in the parent
            : ctrl.filteredServices;

        final shouldShowSeeAll = displayServices.length > 4;

        return Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md, vertical: AppSizes.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Search Results',
                style: context.txtTheme.headlineSmall,
              ),
              if (shouldShowSeeAll)
                TextButton(
                  onPressed: onSeeAll,
                  child: Text(
                    "See All (${displayServices.length})",
                    style: context.txtTheme.bodySmall?.copyWith(
                      color: AppColors.primaryColor,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.primaryColor,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}