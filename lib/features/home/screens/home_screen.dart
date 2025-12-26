/**
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
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
    final TextEditingController serviceNameTEController = TextEditingController();
    final TextEditingController locationTEController = TextEditingController();
    final TextEditingController additionalNoteTEController = TextEditingController();
    final TextEditingController dateTEController = TextEditingController();

    final GlobalKey<InquiryBottomSheetState> inquirySheetKey = GlobalKey<InquiryBottomSheetState>();

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

              ImageSlider(
                imgList: const <String>[
                  AppImages.loginImage1,
                  AppImages.loginImage2,
                  AppImages.loginImage3,
                  AppImages.loginImage4,
                  AppImages.loginImage5,
                  AppImages.loginImage6,
                  AppImages.loginImage7,
                ],
                height: 220,
                onImageTap: (int index) {
                  final Map<String, String>? data = imageIndexToSearchMap[index];
                  if (data != null) {
                    Get.toNamed(
                      AppRoutes.homeSearchRoute,
                      arguments: {
                        'initialCategory': data['category'],
                        'initialSubCategory': data['subcategory'],
                      },
                    );
                  }
                },
              ),

              const SizedBox(height: AppSizes.sm),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenHorizontal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Categories', style: context.txtTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold
                    )),
                    const SizedBox(height: 20),

                    Obx(() {
                      if (controller.isLoadingCategories.value) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (controller.errorMessage.value.isNotEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error_outline, size: 32, color: Colors.grey[400]),
                              const SizedBox(height: 8),
                              Text(
                                controller.errorMessage.value,
                                style: const TextStyle(color: Colors.red, fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () => controller.retry(),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                ),
                                child: const Text('Retry', style: TextStyle(fontSize: 14)),
                              ),
                            ],
                          ),
                        );
                      }
                      if (controller.categories.isEmpty) {
                        return const SizedBox(
                          height: 100,
                          child: Center(child: Text('No categories available')),
                        );
                      }

                      // return MasonryGridView.count(
                      //   crossAxisCount: 4,
                      //   mainAxisSpacing: 15,
                      //   crossAxisSpacing: 15,
                      //   shrinkWrap: true,
                      //   physics: const NeverScrollableScrollPhysics(),
                      //   padding: EdgeInsets.zero,
                      //   itemCount: controller.categories.length,
                      //   itemBuilder: (BuildContext context, int index) {
                      //     final CategoryModel category = controller.categories[index];
                      //     return SizedBox(
                      //       height: 150,
                      //       child: ReusableSmallCard(
                      //         imagePath: category.fullImageUrl,
                      //         title: category.name,
                      //         onTap: () {
                      //           Get.toNamed(
                      //             AppRoutes.homeSubCategoriesPage,
                      //             arguments: {
                      //               'categoryId': category.id,
                      //               'categoryName': category.name,
                      //             },
                      //           );
                      //         },
                      //       ),
                      //     );
                      //   },
                      // );

                      return MasonryGridView.count(
                        crossAxisCount: 3, // Changed from 4 to 3 for better spacing
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: controller.categories.length,
                        itemBuilder: (BuildContext context, int index) {
                          final CategoryModel category = controller.categories[index];
                          return AspectRatio(
                            aspectRatio: 1, // Makes it square (1:1 ratio)
                            child: ReusableSmallCard(
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
                            ),
                          );
                        },
                      );

                    }),

                    const SizedBox(height: 16),

                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                        color: AppColors.whiteColor,
                        boxShadow: const <BoxShadow>[
                          BoxShadow(offset: Offset(0, 3), color: Colors.grey),
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
                                        style: context.txtTheme.labelLarge,
                                      ),
                                      const Text(
                                        "Share more details and let businesses get in touch with you.",
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
                                  height: context.screenHeight,
                                  context: context,
                                  buttonText: 'Send',
                                  onButtonPressed: () {
                                    inquirySheetKey.currentState?.submitInquiry();
                                  },
                                  child: InquiryBottomSheet(
                                    isFromHomeScreen: true,
                                    key: inquirySheetKey,
                                    serviceNameTEController: serviceNameTEController,
                                    dateTEController: dateTEController,
                                    timeController: timeController,
                                    locationTEController: locationTEController,
                                    additionalNoteTEController: additionalNoteTEController,
                                    onSubmitSuccess: () {
                                      debugPrint('✅ Inquiry submitted successfully!');
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
}*/









///
///
///
/// todo:: set pagination with scroll-->
///
///
///
///




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
    final TextEditingController serviceNameTEController = TextEditingController();
    final TextEditingController locationTEController = TextEditingController();
    final TextEditingController additionalNoteTEController = TextEditingController();
    final TextEditingController dateTEController = TextEditingController();

    final GlobalKey<InquiryBottomSheetState> inquirySheetKey = GlobalKey<InquiryBottomSheetState>();

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

              ImageSlider(
                imgList: const <String>[
                  AppImages.loginImage1,
                  AppImages.loginImage2,
                  AppImages.loginImage3,
                  AppImages.loginImage4,
                  AppImages.loginImage5,
                  AppImages.loginImage6,
                  AppImages.loginImage7,
                ],
                height: 220,
                onImageTap: (int index) {
                  final Map<String, String>? data = imageIndexToSearchMap[index];
                  if (data != null) {
                    Get.toNamed(
                      AppRoutes.homeSearchRoute,
                      arguments: {
                        'initialCategory': data['category'],
                        'initialSubCategory': data['subcategory'],
                      },
                    );
                  }
                },
              ),

              const SizedBox(height: AppSizes.sm),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenHorizontal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Categories', style: context.txtTheme.headlineLarge),
                    const SizedBox(height: 12),

                    Obx(() {
                      if (controller.isLoadingCategories.value) {
                        return const SizedBox(
                          height: 180,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (controller.errorMessage.value.isNotEmpty) {
                        return SizedBox(
                          height: 180,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.error_outline, size: 32, color: Colors.grey[400]),
                                const SizedBox(height: 8),
                                Text(
                                  controller.errorMessage.value,
                                  style: const TextStyle(color: Colors.red, fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () => controller.retry(),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  ),
                                  child: const Text('Retry', style: TextStyle(fontSize: 14)),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      if (controller.categories.isEmpty) {
                        return const SizedBox(
                          height: 180,
                          child: Center(child: Text('No categories available')),
                        );
                      }

                      // Calculate page count for pagination
                      final int itemCount = controller.categories.length;
                      final int itemsPerPage = 6; // 2 rows × 3 columns
                      final int pageCount = (itemCount / itemsPerPage).ceil();

                      return Column(
                        children: [
                          SizedBox(
                            height: 280, // Fixed height for horizontal scroll
                            child: PageView.builder(
                              controller: PageController(viewportFraction: 0.98),
                              itemCount: pageCount,
                              onPageChanged: (int page) {
                                controller.currentPage.value = page;
                              },
                              itemBuilder: (BuildContext context, int pageIndex) {
                                // Calculate start and end indices for this page
                                final int startIndex = pageIndex * itemsPerPage;
                                final int endIndex = (startIndex + itemsPerPage) < itemCount
                                    ? startIndex + itemsPerPage
                                    : itemCount;

                                return GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3, // 3 items per row
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: 1, // Square items
                                  ),
                                  itemCount: endIndex - startIndex,
                                  itemBuilder: (BuildContext context, int gridIndex) {
                                    final int actualIndex = startIndex + gridIndex;
                                    final CategoryModel category = controller.categories[actualIndex];

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
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Pagination Indicators
                          Obx(() {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List<Widget>.generate(
                                pageCount,
                                    (int index) {
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: controller.currentPage.value == index ? 24 : 8,
                                    height: 8,
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    decoration: BoxDecoration(
                                      color: controller.currentPage.value == index
                                          ? AppColors.primaryColor
                                          : AppColors.greyColor.withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  );
                                },
                              ),
                            );
                          }),
                        ],
                      );
                    }),

                    const SizedBox(height: 24),

                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                        color: AppColors.whiteColor,
                        boxShadow: const <BoxShadow>[
                          BoxShadow(offset: Offset(0, 3), color: Colors.grey),
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
                                        style: context.txtTheme.labelLarge,
                                      ),
                                      const Text(
                                        "Share more details and let businesses get in touch with you.",
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
                                  title: '\nQuote',
                                  height: context.screenHeight * 0.9,
                                  context: context,
                                  buttonText: 'Send',
                                  onButtonPressed: () {
                                    inquirySheetKey.currentState?.submitInquiry();
                                  },
                                  child: InquiryBottomSheet(
                                    isFromHomeScreen: true,
                                    key: inquirySheetKey,
                                    serviceNameTEController: serviceNameTEController,
                                    dateTEController: dateTEController,
                                    timeController: timeController,
                                    locationTEController: locationTEController,
                                    additionalNoteTEController: additionalNoteTEController,
                                    onSubmitSuccess: () {
                                      debugPrint('✅ Inquiry submitted successfully!');
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