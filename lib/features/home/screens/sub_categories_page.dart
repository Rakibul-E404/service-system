import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../../auth/widgets/service_card.dart';
import '../controllers/sub_categories_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import 'package:manx_mate/core/extensions/widget_extensions.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_strings.dart';
import '../../auth/widgets/custom_text_field.dart';

class SubCategoriesPage extends GetView<SubCategoriesController> {
  SubCategoriesPage({super.key});

  final TextEditingController _searchTEController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Safely get arguments with null checking
    final dynamic args = Get.arguments;
    final String appbarHeading = (args is Map<String, dynamic>)
        ? (args['categoryName']?.toString() ?? 'Subcategories')
        : 'Subcategories';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // App Bar
              Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: const Icon(CupertinoIcons.back),
                  ),
                  Expanded(
                    child: Text(
                      appbarHeading,
                      style: context.txtTheme.headlineMedium,
                    ).centered,
                  ),
                  const SizedBox(width: 40),
                ],
              ),

              // Search Field
              MyTextFormFieldWithIcon(
                formHintText: "Search",
                prefixIcon: const Icon(
                  CupertinoIcons.search,
                  color: AppColors.primaryColor,
                ),
                controller: _searchTEController,
                validator: (String? value) {
                  if (value?.isEmpty ?? true) {
                    return '${AppStrings.pleaseEnterYour} ${AppStrings.email}!!';
                  }
                  return null;
                },
                onChanged: (String value) {
                  // Implement search filtering if needed
                },
              ),
              const SizedBox(height: AppSizes.md),

              // Subcategories Grid
              Obx(() {
                // Loading State
                if (controller.isLoadingSubCategories.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSizes.xl),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                // Error State
                if (controller.errorMessage.isNotEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.xl),
                      child: Column(
                        children: [
                          Text(
                            controller.errorMessage.value,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSizes.md),
                          ElevatedButton(
                            onPressed: () => controller.retry(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Empty State
                if (controller.subCategories.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSizes.xl),
                      child: Text('No subcategories available'),
                    ),
                  );
                }

                // Grid with subcategories
                return MasonryGridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 18,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.subCategories.length,
                  itemBuilder: (BuildContext context, int index) {
                    final subCategory = controller.subCategories[index];

                    return SizedBox(
                      height: 200,
                      child: ServiceCard(
                        imageUrl: subCategory.fullImageUrl,
                        title: subCategory.name,
                        subtitle: subCategory.description,
                        location: '', // Not needed for subcategories
                        rating: 0.0, // Not needed for subcategories
                        showFavorite: false, // Hide favorite button for subcategories
                        showLocationAndRating: false, // Hide location and rating for subcategories
                        onTap: () {
                          Get.toNamed(
                            AppRoutes.homeServiceDetailsRoute,
                            arguments: {
                              'subCategoryId': subCategory.id,
                              'subCategoryName': subCategory.name,
                            },
                          );
                        },
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
