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
import '../../../core/utils/api/app_url.dart';
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
    Get.lazyPut(() => ProfileController());
    final HomeController controller = Get.put(HomeController());
    final TimeController timeController = Get.put(TimeController());
    final TextEditingController serviceNameTEController =
    TextEditingController();
    final TextEditingController locationTEController = TextEditingController();
    final TextEditingController additionalNoteTEController =
    TextEditingController();
    final TextEditingController dateTEController = TextEditingController();

    final GlobalKey<InquiryBottomSheetState> inquirySheetKey =
    GlobalKey<InquiryBottomSheetState>();

    // ✅ Now includes both category and subcategory
    final Map<int, Map<String, String>> imageIndexToSearchMap = {
      0: {'category': 'Cleaning', 'subcategory': 'Home Cleaning'},
      1: {'category': 'Gardening', 'subcategory': 'Garden Maintenance'},
      2: {'category': 'Electrical', 'subcategory': 'Electrical Services'},
      3: {'category': 'Plumbing', 'subcategory': 'Plumbing Services'},
      4: {'category': 'Painting', 'subcategory': 'Painting Services'},
      5: {'category': 'Carpentry', 'subcategory': 'Carpentry Services'},
      6: {'category': 'Moving', 'subcategory': 'Moving Services'},
    };

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => controller.refreshAll(),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const HomeTopBar(),


              Obx(() {
                // 1. Safely find the controller
                final CategoryController catController = Get.isRegistered<CategoryController>()
                    ? Get.find<CategoryController>()
                    : Get.put(CategoryController());

                // 2. Show loading state
                if (catController.isLoading.value && catController.categories.isEmpty) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                // 3. Prepare the list of banner images with explicit URL logic
                final List<String> dynamicImages = catController.categories.map((cat) {
                  // Determine which raw string to use (Banner preferred, then Main Image)
                  String rawPath = (cat.bannerImage != null && cat.bannerImage!.isNotEmpty)
                      ? cat.bannerImage!
                      : cat.image;

                  if (rawPath.isEmpty) return "";

                  // LOGIC: If it doesn't start with http, prepend the Base URL
                  if (!rawPath.startsWith('http')) {
                    // Ensure there is a single slash between base URL and path
                    final cleanPath = rawPath.startsWith('/') ? rawPath.substring(1) : rawPath;
                    return '${AppUrl.imageBaseUrl}/$cleanPath';
                  }

                  return rawPath;
                }).where((img) => img.isNotEmpty).toList();

                // 4. Fallback if list is empty
                if (dynamicImages.isEmpty) {
                  return const SizedBox(
                      height: 200,
                      child: Center(child: Text("No Promotions Available"))
                  );
                }

                return ImageSlider(
                  imgList: dynamicImages,
                  height: 200,
                  onImageTap: (int index) {
                    final category = catController.categories[index];
                    Get.toNamed(
                      AppRoutes.homeSubCategoriesPage,
                      arguments: {
                        'categoryId': category.id,
                        'categoryName': category.name,
                      },
                    );
                  },
                );
              }),

// ...

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

                      // Calculate page count for pagination
                      final int totalItems = controller.categories.length;
                      const int itemsPerPage = 3;
                      final int totalPages = (totalItems / itemsPerPage).ceil();

                      return Column(
                        children: [
                          // Categories Grid with Pagination
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
                                    physics: const NeverScrollableScrollPhysics(),
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


                          /// Pagination Indicators :::::
                          Obx(() {
                            if (totalPages <= 1) {
                              return const SizedBox.shrink();
                            }

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
                                        duration: const Duration(milliseconds: 200),
                                        width: controller.currentPage.value == index
                                            ? 24
                                            : 6,
                                        height: 6,
                                        margin:
                                        const EdgeInsets.symmetric(horizontal: 3),
                                        decoration: BoxDecoration(
                                          color: controller.currentPage.value ==
                                              index
                                              ? AppColors.primaryColor
                                              : AppColors.greyColor.withValues(alpha: 0.3),
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        "Looking for immediate expert help?",
                                        style:
                                        context.txtTheme.labelLarge?.copyWith(
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
                                    inquirySheetKey.currentState
                                        ?.submitInquiry();
                                  },
                                  child: InquiryBottomSheet(
                                    isFromHomeScreen: true,
                                    key: inquirySheetKey,
                                    serviceNameTEController:
                                    serviceNameTEController,
                                    dateTEController: dateTEController,
                                    timeController: timeController,
                                    locationTEController: locationTEController,
                                    additionalNoteTEController:
                                    additionalNoteTEController,
                                    onSubmitSuccess: () {
                                      debugPrint(
                                          '✅ Inquiry submitted successfully!');
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