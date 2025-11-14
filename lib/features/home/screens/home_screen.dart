import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/common/widgets/time_picker_widget.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import 'package:manx_mate/core/routes/app_routes.dart';
import '../../../core/common/components/image_carousel.dart';
import '../../../core/common/widgets/app_bottom_sheet.dart';
import '../../../core/common/widgets/reusable_button.dart';
import '../../../core/config/app_images.dart';
import '../controllers/home_controller.dart';
import '../widget/home_top_bar.dart';
import '../widget/inquiry_bottom_sheet.dart';
import '../widget/reusable_small_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());
    final TimeController timeController = Get.put(TimeController());
    final TextEditingController serviceNameTEController = TextEditingController();
    final TextEditingController locationTEController = TextEditingController();
    final TextEditingController additionalNoteTEController = TextEditingController();
    final TextEditingController dateTEController = TextEditingController();

    // GlobalKey to access InquiryBottomSheet state
    final GlobalKey<InquiryBottomSheetState> inquirySheetKey = GlobalKey<InquiryBottomSheetState>();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            /// ===========> Top Card =================>
            const HomeTopBar(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenHorizontal),
              child: Column(
                children: <Widget>[
                  const ImageSlider(
                    imgList: <String>[
                      AppImages.loginImage1,
                      AppImages.loginImage2,
                      AppImages.loginImage3,
                      AppImages.loginImage4,
                      AppImages.loginImage5,
                    ],
                    height: 220,
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text('Categories', style: context.txtTheme.headlineLarge),
                  const SizedBox(height: AppSizes.sm),

                  /// ============================> Categories GridView ===============>
                  Obx(() {
                    // Show loading indicator
                    if (controller.isLoadingCategories.value) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSizes.xl),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    // Show error message
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

                    /// Show empty state
                    if (controller.categories.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSizes.xl),
                          child: Text('No categories available'),
                        ),
                      );
                    }

                    // Show categories grid
                    return MasonryGridView.count(
                      crossAxisCount: 4,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 15,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.categories.length,
                      itemBuilder: (BuildContext context, int index) {
                        final category = controller.categories[index];
                        return SizedBox(
                          height: 180,
                          child: ReusableSmallCard(
                            imagePath: category.fullImageUrl,
                            title: category.name,
                            onTap: () {
                              // Navigate to subcategories with both ID and name
                              Get.toNamed(
                                AppRoutes.homeSubCategoriesPage,
                                arguments: {
                                  'categoryId': category.id,
                                  'categoryName': category.name,
                                },
                              );

                              debugPrint('🚀 Navigating to subcategories');
                              debugPrint('📌 Category: ${category.name}');
                              debugPrint('🆔 Category ID: ${category.id}');
                            },
                          ),
                        );
                      },
                    );
                  }),

                  const SizedBox(height: AppSizes.md),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                      color: AppColors.whiteColor,
                      boxShadow: const <BoxShadow>[
                        BoxShadow(offset: Offset(0, 3), color: Colors.red),
                      ],
                    ),
                    child: Column(
                      children: <Widget>[
                        Row(
                          spacing: AppSizes.md,
                          children: <Widget>[
                            Image.asset(AppImages.phoneImage),
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
                                // Call the submit method from InquiryBottomSheet
                                debugPrint('🔘 Send button pressed');
                                inquirySheetKey.currentState?.submitInquiry();
                              },
                              child: InquiryBottomSheet(
                                isFromHomeScreen: true,
                                key: inquirySheetKey, // Add the key here
                                serviceNameTEController: serviceNameTEController,
                                dateTEController: dateTEController,
                                timeController: timeController,
                                locationTEController: locationTEController,
                                additionalNoteTEController: additionalNoteTEController,
                                onSubmitSuccess: () {
                                  debugPrint('✅ Inquiry submitted successfully!');
                                  // Add any additional logic after successful submission
                                },
                              ),
                            );
                          },
                          label: 'Post an Inquiry',
                        ),

                        const SizedBox(height: AppSizes.md),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}