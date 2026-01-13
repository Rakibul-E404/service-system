import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/common/components/custom_network_image.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import 'package:manx_mate/core/extensions/widget_extensions.dart';
import 'package:manx_mate/features/home/controllers/home_controller.dart';
// import 'package:manx_mate/features/home/model/category_model.dart';
import '../controllers/sub_categories_controller.dart';
import '../../auth/widgets/service_card.dart';
import '../../../core/routes/app_routes.dart';
import '../model/categor_model.dart';

class SubCategoriesPage extends GetView<SubCategoriesController> {
  SubCategoriesPage({super.key});

  final HomeController homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    // Safely get arguments with null checking
    final dynamic args = Get.arguments;
    final String selectedCategoryName = (args is Map<String, dynamic>)
        ? (args['categoryName']?.toString() ?? 'Category')
        : 'Category';
    final String selectedCategoryId = (args is Map<String, dynamic>)
        ? (args['categoryId']?.toString() ?? '')
        : '';

    // Find selected category
    CategoryModel? selectedCategory;
    if (selectedCategoryId.isNotEmpty) {
      selectedCategory = homeController.categories.firstWhere(
            (cat) => cat.id == selectedCategoryId,
        orElse: () => CategoryModel(
          id: selectedCategoryId,
          name: selectedCategoryName,
          description: '',
          image: '',
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // App Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md,
                vertical: AppSizes.sm,
              ),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textBlackColor,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Select Sub-category',
                      style: context.txtTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textBlackColor,
                      ),
                    ).centered,
                  ),
                  const SizedBox(width: 40), // For symmetry
                ],
              ),
            ),

            // Selected Category Section
            if (selectedCategory != null)
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected category',
                      style: context.txtTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textBlackColor.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(AppSizes.sm),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                        border: Border.all(
                          color: AppColors.primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Category Image
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
                              color: Colors.white,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
                              child: selectedCategory.fullImageUrl.isNotEmpty
                                  ? CustomCachedImage(
                                imageUrl: selectedCategory.fullImageUrl,
                                fit: BoxFit.cover,
                              )
                                  : Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.category,
                                  color: Colors.grey,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Category Name
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedCategory.name,
                                  style: context.txtTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textBlackColor,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (selectedCategory.description.isNotEmpty)
                                  Text(
                                    selectedCategory.description,
                                    style: context.txtTheme.bodySmall?.copyWith(
                                      color: AppColors.textBlackColor.withOpacity(0.6),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.primaryColor,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: AppSizes.sm),

            // Other Categories Horizontal List
            Container(
              padding: const EdgeInsets.only(left: AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: AppSizes.md),
                    child: Text(
                      'Other categories',
                      style: context.txtTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textBlackColor.withOpacity(0.7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: Obx(() {
                      if (homeController.isLoadingCategories.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (homeController.categories.isEmpty) {
                        return Center(
                          child: Text(
                            'No categories available',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        );
                      }

                      // Filter out selected category
                      final otherCategories = homeController.categories
                          .where((cat) => cat.id != selectedCategoryId)
                          .toList();

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: otherCategories.length,
                        itemBuilder: (context, index) {
                          final category = otherCategories[index];
                          return GestureDetector(
                            onTap: () {
                              // Navigate to same screen with new category
                              Get.offAndToNamed(
                                AppRoutes.homeSubCategoriesPage,
                                arguments: {
                                  'categoryId': category.id,
                                  'categoryName': category.name,
                                },
                              );
                            },
                            child: Container(
                              width: 90,
                              margin: EdgeInsets.only(
                                right: index == otherCategories.length - 1
                                    ? AppSizes.md
                                    : 12,
                              ),
                              child: Column(
                                children: [
                                  // Category Image
                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                                      child: category.fullImageUrl.isNotEmpty
                                          ? CustomCachedImage(
                                        imageUrl: category.fullImageUrl,
                                        fit: BoxFit.cover,
                                      )
                                          : Container(
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.category,
                                          color: Colors.grey,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  // Category Name
                                  Text(
                                    category.name,
                                    style: context.txtTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textBlackColor,
                                    ),
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.sm),
            const Divider(height: 1, color: Colors.grey),
            const SizedBox(height: AppSizes.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: Text(
                'Select a subcategory',
                style: context.txtTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textBlackColor,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.sm),

            // Subcategories Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                child: Obx(() {
                  // Loading State
                  if (controller.isLoadingSubCategories.value) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  // Error State
                  if (controller.errorMessage.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 60,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: AppSizes.md),
                          Text(
                            controller.errorMessage.value,
                            style: TextStyle(
                              color: Colors.red[600],
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSizes.md),
                          ElevatedButton(
                            onPressed: () => controller.retry(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                              ),
                            ),
                            child: const Text(
                              'Retry',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Empty State
                  if (controller.subCategories.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.category_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: AppSizes.md),
                          Text(
                            'No subcategories available',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: AppSizes.sm),
                          Text(
                            'Check back later or try another category',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Grid with subcategories
                  return MasonryGridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: controller.subCategories.length,
                    itemBuilder: (BuildContext context, int index) {
                      final subCategory = controller.subCategories[index];

                      return ServiceCard(
                        imageUrl: subCategory.fullImageUrl,
                        title: subCategory.name,
                        subtitle: subCategory.description,
                        location: '',
                        rating: 0.0,
                        showFavorite: false,
                        showLocationAndRating: false,
                        onTap: () {
                          debugPrint('🎯 Navigating to services for subcategory: ${subCategory.name}');

                          Get.toNamed(
                            AppRoutes.servicesRoute,
                            arguments: {
                              'subCategoryId': subCategory.id,
                              'subCategoryName': subCategory.name,
                            },
                          );
                        },
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}