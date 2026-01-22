import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/common/widgets/time_picker_widget.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import 'package:manx_mate/core/routes/app_routes.dart';
import 'package:manx_mate/features/home/model/categor_model.dart';
import 'package:manx_mate/features/home/screens/user_advertisement.dart';
import '../../../core/common/components/image_carousel.dart';
import '../../../core/common/widgets/app_bottom_sheet.dart';
import '../../../core/common/widgets/reusable_button.dart';
import '../../../core/config/app_images.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../provider/controllers/category_controller.dart';
import '../controllers/home_controller.dart';
import '../widget/home_top_bar.dart';
import '../widget/inquiry_bottom_sheet.dart';
import '../widget/reusable_small_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controllers properly (only once)
    final ProfileController profileController =
    Get.put(ProfileController(), permanent: true);
    final HomeController controller = Get.put(HomeController());
    final CategoryController catController = Get.put(CategoryController());
    final TimeController timeController = Get.put(TimeController());

    // Text controllers for inquiry sheet
    final TextEditingController serviceNameTEController = TextEditingController();
    final TextEditingController locationTEController = TextEditingController();
    final TextEditingController additionalNoteTEController =
    TextEditingController();
    final TextEditingController dateTEController = TextEditingController();

    final GlobalKey<InquiryBottomSheetState> inquirySheetKey =
    GlobalKey<InquiryBottomSheetState>();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh all reactive data
          await profileController.refreshProfile(); // <-- Top bar
          await controller.refreshAll();            // <-- Categories, etc
          await catController.refreshBanners();     // <-- Banners
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ///================== Top Bar (reactive) =============
              const HomeTopBar(),

              /// ================= BANNER SECTION =================
              Obx(() {
                if (catController.isLoadingBanners.value &&
                    catController.banners.isEmpty) {
                  return const SizedBox(
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  );
                }

                final List<String> bannerImages = catController.banners.toList();

                if (bannerImages.isEmpty) {
                  return Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryColor.withOpacity(0.05),
                          AppColors.greyColor.withOpacity(0.02),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.campaign_outlined,
                            size: 48,
                            color: AppColors.greyColor.withOpacity(0.5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Promotions will appear here',
                            style: TextStyle(
                              color: AppColors.greyColor.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ImageSlider(
                  imgList: bannerImages,
                  height: 200,
                  onImageTap: (int index) {
                    final String? categoryName =
                    catController.getCategoryNameByBannerIndex(index);
                    final String? categoryId =
                    catController.getCategoryIdByBannerIndex(index);

                    debugPrint('🎯 Banner tapped - Index: $index');
                    debugPrint('   Category Name: $categoryName');
                    debugPrint('   Category ID: $categoryId');

                    if (categoryName != null && categoryId != null) {
                      Get.toNamed(
                        AppRoutes.homeServiceSearchScreen,
                        arguments: {
                          'initialCategory': categoryName,
                          'initialCategoryId': categoryId,
                          'fromBanner': true,
                        },
                      );
                    } else {
                      Get.toNamed(AppRoutes.homeServiceSearchScreen);
                    }
                  },
                );
              }),
              // ================= END BANNER =================

              const SizedBox(height: AppSizes.xl),

              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.screenHorizontal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Categories',
                            style: context.txtTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Obx(() {
                      if (controller.isLoadingCategories.value) {
                        return const SizedBox(
                          height: 150,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (controller.errorMessage.value.isNotEmpty) {
                        return SizedBox(
                          height: 150,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.error_outline,
                                    size: 32, color: Colors.grey[400]),
                                const SizedBox(height: 8),
                                Text(
                                  controller.errorMessage.value,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () => controller.retry(),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                  ),
                                  child: const Text('Retry',
                                      style: TextStyle(fontSize: 14)),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (controller.categories.isEmpty) {
                        return const SizedBox(
                          height: 150,
                          child: Center(
                              child: Text('No categories available',
                                  style: TextStyle(color: AppColors.greyColor))),
                        );
                      }

                      final int totalItems = controller.categories.length;
                      const int itemsPerPage = 3;
                      final int totalPages = (totalItems / itemsPerPage).ceil();

                      return Column(
                        children: [
                          SizedBox(
                            height: 140,
                            child: PageView.builder(
                              controller: controller.pageController,
                              itemCount: totalPages,
                              onPageChanged: (int page) {
                                controller.currentPage.value = page;
                              },
                              itemBuilder: (BuildContext context, int pageIndex) {
                                final int startIndex = pageIndex * itemsPerPage;
                                final int endIndex =
                                min(startIndex + itemsPerPage, totalItems);

                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  child: GridView.builder(
                                    physics:
                                    const NeverScrollableScrollPhysics(),
                                    padding: EdgeInsets.zero,
                                    gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 6,
                                      mainAxisSpacing: 6,
                                      childAspectRatio: 0.9,
                                    ),
                                    itemCount: endIndex - startIndex,
                                    itemBuilder:
                                        (BuildContext context, int gridIndex) {
                                      final int actualIndex = startIndex + gridIndex;
                                      final CategoryModel category =
                                      controller.categories[actualIndex];

                                      return ReusableSmallCard(
                                        imagePath: category.fullImageUrl,
                                        title: category.name,
                                        elevation: 2.0,
                                        onTap: () {
                                          Get.toNamed(
                                            AppRoutes.homeSubCategoriesPage,
                                            arguments: {
                                              'categoryId': category.id,
                                              'categoryName': category.name,
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),

                          // Pagination Indicators
                          Obx(() {
                            if (totalPages <= 1) return const SizedBox.shrink();

                            return Container(
                              margin: const EdgeInsets.only(top: 2),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List<Widget>.generate(
                                  totalPages,
                                      (int index) {
                                    return GestureDetector(
                                      onTap: () {
                                        controller.pageController.animateToPage(
                                          index,
                                          duration:
                                          const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      },
                                      child: AnimatedContainer(
                                        duration:
                                        const Duration(milliseconds: 200),
                                        width: controller.currentPage.value == index
                                            ? 24
                                            : 6,
                                        height: 6,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 3),
                                        decoration: BoxDecoration(
                                          color: controller.currentPage.value ==
                                              index
                                              ? AppColors.primaryColor
                                              : AppColors.greyColor
                                              .withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          }),
                        ],
                      );
                    }),

                    const SizedBox(height: 20),

                    // ================= Inquiry Section =================
                    Container(
                      decoration: BoxDecoration(
                        borderRadius:
                        BorderRadius.circular(AppSizes.borderRadiusMd),
                        color: AppColors.whiteColor,
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.md),
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Image.asset(AppImages.phoneImage, height: 50),
                                const SizedBox(width: AppSizes.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        "Looking for immediate expert help?",
                                        style: context.txtTheme.labelLarge
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.blackColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        "Share more details and let businesses get in touch with you.",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.greyColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSizes.md),
                            ReusableButton(
                              onTap: () {
                                CustomModalBottomSheet.show(
                                  title: 'Quote',
                                  height: context.screenHeight * 0.9,
                                  context: context,
                                  buttonText: 'Send',
                                  onButtonPressed: () {
                                    inquirySheetKey.currentState?.submitInquiry();
                                    Get.back();
                                  },
                                  child: InquiryBottomSheet(
                                    isFromHomeScreen: true,
                                    key: inquirySheetKey,
                                    serviceNameTEController: serviceNameTEController,
                                    dateTEController: dateTEController,
                                    timeController: timeController,
                                    locationTEController: locationTEController,
                                    additionalNoteTEController:
                                    additionalNoteTEController,
                                    onSubmitSuccess: () {
                                      debugPrint(
                                          '✅ Inquiry submitted successfully !');
                                    },
                                  ),
                                );
                              },
                              label: 'Post an Inquiry',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.xl),
                  ],
                ),
              ),

              const AdvertisementsSection(),
              const SizedBox(height: AppSizes.xl),
            ],
          ),
        ),
      ),
    );
  }
}
