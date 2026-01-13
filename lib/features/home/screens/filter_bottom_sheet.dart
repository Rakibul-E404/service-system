import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';

class FilterBottomSheet {
  static void show({
    required BuildContext context,
    required String selectedCategory,
    required String selectedSubCategory,
    required String selectedLocation,
    required Map<String, List<String>> categoryToSubCategories,
    required List<String> locationOptions,
    required Function(String, String, String) onApply,
    required VoidCallback onClear,
  }) {
    String tempSelectedCategory = selectedCategory;
    String tempSelectedSubCategory = selectedSubCategory;
    String tempSelectedLocation = selectedLocation;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(AppSizes.borderRadiusMd)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            List<String> getSubCategories(String category) {
              if (category == 'All Categories') {
                return <String>['All Subcategories'];
              }
              return <String>[
                'All Subcategories',
                ...?categoryToSubCategories[category]
              ];
            }

            return Padding(
              padding: EdgeInsets.fromLTRB(
                AppSizes.md,
                AppSizes.sm,
                AppSizes.md,
                MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Filters', style: context.txtTheme.headlineSmall),
                  const SizedBox(height: AppSizes.md),
                  Text('Category', style: context.txtTheme.labelMedium),
                  const SizedBox(height: AppSizes.sm),
                  _buildFilterDropdown(
                    value: tempSelectedCategory,
                    items: [
                      'All Categories',
                      ...categoryToSubCategories.keys
                          .where((k) => k != 'All Categories')
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        tempSelectedCategory = val;
                        tempSelectedSubCategory = 'All Subcategories';
                        setState(() {});
                      }
                    },
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text('Subcategory', style: context.txtTheme.labelMedium),
                  const SizedBox(height: AppSizes.sm),
                  _buildFilterDropdown(
                    value: tempSelectedSubCategory,
                    items: getSubCategories(tempSelectedCategory),
                    onChanged: (val) {
                      if (val != null) {
                        tempSelectedSubCategory = val;
                        setState(() {});
                      }
                    },
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text('Location', style: context.txtTheme.labelMedium),
                  const SizedBox(height: AppSizes.sm),
                  _buildFilterDropdown(
                    value: tempSelectedLocation,
                    items: locationOptions,
                    onChanged: (String? val) {
                      if (val != null) {
                        tempSelectedLocation = val;
                        setState(() {});
                      }
                    },
                  ),
                  const SizedBox(height: AppSizes.xl),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            onClear();
                            Get.back();
                          },
                          child: const Text('Clear'),
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            onApply(tempSelectedCategory, tempSelectedSubCategory,
                                tempSelectedLocation);
                            Get.back();
                          },
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.md),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildFilterDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryColor),
            items: items.map((item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
            onChanged: onChanged,
          ),
        ));
    }
}