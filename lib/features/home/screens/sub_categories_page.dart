import 'package:get/get.dart';
import '../model/categor_model.dart';
import 'package:flutter/material.dart';
import '../../auth/widgets/service_card.dart';
import '../../../core/routes/app_routes.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import '../controllers/sub_categories_controller.dart';
import 'package:manx_mate/core/extensions/widget_extensions.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import 'package:manx_mate/features/home/controllers/home_controller.dart';
import 'package:manx_mate/core/common/components/custom_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class SubCategoriesPage extends GetView<SubCategoriesController> {
  SubCategoriesPage({super.key});

  final HomeController homeController = Get.find<HomeController>();
  final RxString _selectedCategoryId = ''.obs;
  final RxString _selectedCategoryName = ''.obs;

  // Method to update UI when category changes
  void _updateUIForNewCategory(String categoryId, String categoryName) {
    debugPrint('🔄 Updating UI for new category: $categoryName ($categoryId)');

    // Update local state
    _selectedCategoryId.value = categoryId;
    _selectedCategoryName.value = categoryName;

    // Update controller with new category
    controller.refreshWithNewCategory(categoryId, categoryName);
  }

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

    // Initialize local state with current arguments if empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedCategoryId.value.isEmpty && selectedCategoryId.isNotEmpty) {
        _selectedCategoryId.value = selectedCategoryId;
        _selectedCategoryName.value = selectedCategoryName;
      }
    });

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
            Obx(() {
              // Use local state for selected category display
              final String displayCategoryId = _selectedCategoryId.value;
              final String displayCategoryName = _selectedCategoryName.value;

              // Fallback to arguments if local state is empty
              final String currentCategoryId = displayCategoryId.isNotEmpty
                  ? displayCategoryId
                  : selectedCategoryId;
              final String currentCategoryName = displayCategoryName.isNotEmpty
                  ? displayCategoryName
                  : selectedCategoryName;

              // Find the category to display
              CategoryModel? displayCategory;
              if (currentCategoryId.isNotEmpty) {
                displayCategory = homeController.categories.firstWhere(
                      (cat) => cat.id == currentCategoryId,
                  orElse: () => CategoryModel(
                    id: currentCategoryId,
                    name: currentCategoryName,
                    description: '',
                    image: '',
                  ),
                );
              }

              return displayCategory != null
                  ? Container(
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
                        color: AppColors.textBlackColor.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(AppSizes.sm),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                        border: Border.all(
                          color: AppColors.primaryColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
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
                              child: displayCategory.fullImageUrl.isNotEmpty
                                  ? CustomCachedImage(
                                imageUrl: displayCategory.fullImageUrl,
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
                                  displayCategory.name,
                                  style: context.txtTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textBlackColor,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (displayCategory.description.isNotEmpty)
                                  Text(
                                    displayCategory.description,
                                    style: context.txtTheme.bodySmall?.copyWith(
                                      color: AppColors.textBlackColor.withValues(alpha: 0.6),
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
              )
                  : const SizedBox.shrink();
            }),

            const SizedBox(height: AppSizes.sm),

            // Other Categories Horizontal List
            Container(
              padding: const EdgeInsets.only(left: AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: AppSizes.md),
                    child: Text(
                      'Other categories',
                      style: context.txtTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textBlackColor.withValues(alpha: 0.7),
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

                      // Get current category ID (use local state first, then arguments)
                      final String currentCategoryId = _selectedCategoryId.value.isNotEmpty
                          ? _selectedCategoryId.value
                          : selectedCategoryId;

                      // Filter out selected category
                      final List<CategoryModel> otherCategories = homeController.categories
                          .where((CategoryModel cat) => cat.id != currentCategoryId)
                          .toList();

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: otherCategories.length,
                        itemBuilder: (context, index) {
                          final category = otherCategories[index];
                          return GestureDetector(
                            onTap: () {
                              debugPrint('🔄 Switching to category: ${category.name} (${category.id})');
                              debugPrint('🔄 Previous category: ${_selectedCategoryName.value} (${_selectedCategoryId.value})');

                              // Update UI for new category
                              _updateUIForNewCategory(category.id, category.name);
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
                                          color: Colors.black.withValues(alpha: 0.1),
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
              child: Obx(() {
                final String displayCategoryName = _selectedCategoryName.value.isNotEmpty
                    ? _selectedCategoryName.value
                    : selectedCategoryName;

                return Text(
                  'Select a subcategory for $displayCategoryName',
                  style: context.txtTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textBlackColor,
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSizes.sm),

            // Subcategories Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                child: Obx(() {
                  // Show debug info
                  debugPrint('📊 Current category in controller: ${controller.categoryName.value}');
                  debugPrint('📊 Current category ID in controller: ${controller.categoryId.value}');
                  debugPrint('📊 Local selected category: ${_selectedCategoryName.value}');
                  debugPrint('📊 Subcategories count: ${controller.subCategories.length}');

                  // Loading State
                  if (controller.isLoadingSubCategories.value) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            'Loading subcategories...',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
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
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
                            child: Text(
                              controller.errorMessage.value,
                              style: TextStyle(
                                color: Colors.red[600],
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
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
                          Obx(() {
                            final String displayCategoryName = _selectedCategoryName.value.isNotEmpty
                                ? _selectedCategoryName.value
                                : selectedCategoryName;

                            return Text(
                              'No subcategories found for "$displayCategoryName"',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                              ),
                            );
                          }),
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
                              'Refresh',
                              style: TextStyle(color: Colors.white),
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
                              'categoryId': controller.categoryId.value,
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