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
              // Get subcategories for the selected category
              final subCats = categoryToSubCategories[category];
              if (subCats == null || subCats.isEmpty) {
                return <String>['All Subcategories'];
              }
              // Ensure "All Subcategories" is always first
              if (subCats.first != 'All Subcategories') {
                return <String>['All Subcategories', ...subCats];
              }
              return subCats;
            }

            // Get available categories (excluding 'All Categories' key)
            List<String> getCategoryList() {
              return <String>[
                'All Categories',
                ...categoryToSubCategories.keys.where((k) => k != 'All Categories')
              ];
            }

            return Padding(
              padding: EdgeInsets.fromLTRB(
                AppSizes.md,
                AppSizes.sm,
                AppSizes.md,
                MediaQuery.of(context).viewInsets.bottom + AppSizes.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: AppSizes.md),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text('Filters', style: context.txtTheme.headlineSmall),
                  const SizedBox(height: AppSizes.md),

                  // Category Dropdown
                  Text('Category', style: context.txtTheme.labelMedium),
                  const SizedBox(height: AppSizes.sm),
                  _buildFilterDropdown(
                    value: tempSelectedCategory,
                    items: getCategoryList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          tempSelectedCategory = val;
                          // Reset subcategory when category changes
                          tempSelectedSubCategory = 'All Subcategories';
                        });
                      }
                    },
                  ),
                  const SizedBox(height: AppSizes.md),

                  // Subcategory Dropdown
                  Text('Subcategory', style: context.txtTheme.labelMedium),
                  const SizedBox(height: AppSizes.sm),
                  _buildFilterDropdown(
                    value: tempSelectedSubCategory,
                    items: getSubCategories(tempSelectedCategory),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          tempSelectedSubCategory = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: AppSizes.md),

                  // Location Dropdown
                  Text('Location', style: context.txtTheme.labelMedium),
                  const SizedBox(height: AppSizes.sm),
                  _buildFilterDropdown(
                    value: tempSelectedLocation,
                    items: locationOptions,
                    onChanged: (String? val) {
                      if (val != null) {
                        setState(() {
                          tempSelectedLocation = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: AppSizes.xl),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Get.back();
                            onClear();
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Clear'),
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            onApply(
                              tempSelectedCategory,
                              tempSelectedSubCategory,
                              tempSelectedLocation,
                            );
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
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
    // Ensure the value exists in items, otherwise use first item
    final String safeValue = items.contains(value) ? value : items.first;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: safeValue,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryColor),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}