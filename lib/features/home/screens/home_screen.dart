import 'package:flutter/cupertino.dart';
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

class HomeScreen extends GetView<HomeController> {
  HomeScreen({super.key});

  final TextEditingController _serviceNameTEController = TextEditingController();
  final TextEditingController _locationTEController = TextEditingController();
  final TextEditingController _additionalNoteTEController = TextEditingController();
  final TextEditingController _dateTEController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final TimeController timeController = Get.put(TimeController());

    return Scaffold(
      body: Scaffold(
        body: SingleChildScrollView(
          // padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenHorizontal),
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
                        AppImages.loginImage,
                        AppImages.loginImage,
                        AppImages.loginImage,
                        AppImages.loginImage,
                        AppImages.loginImage,
                      ],
                      height: 220,
                    ),
                    const SizedBox(height: AppSizes.md),
                    Text('Categories', style: context.txtTheme.headlineLarge),
                    const SizedBox(height: AppSizes.md),

                    /// ============================> Gridview ===============>
                    MasonryGridView.count(
                      crossAxisCount: 4,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 18,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 10,
                      itemBuilder: (BuildContext context, int index) {
                        return SizedBox(
                          height: 150,
                          child: ReusableSmallCard(
                            imagePath: '',
                            title: 'Service ',
                            onTap: () {
                              Get.toNamed(
                                AppRoutes.homeSubCategoriesPage,
                                arguments: "Main Category ",
                              );
                            },
                          ),
                        );
                      },
                    ),
                    /* GridView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: .6,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: AppSizes.md.toInt(),

                      /// for fun
                      itemBuilder: (BuildContext context, int index) {
                        return const ReusableSmallCard(imagePath: '', title: 'Service ');
                      },
                    ),*/
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
                                title: 'Immediate Help',
                                height: context.screenHeight * 0.6,
                                context: context,
                                buttonText: 'Send',
                                onButtonPressed: () {
                                  // Your action here
                                  Navigator.pop(context);
                                },
                                child: InquiryBottomSheet(
                                  serviceNameTEController: _serviceNameTEController,
                                  dateTEController: _dateTEController,
                                  timeController: timeController,
                                  locationTEController: _locationTEController,
                                  additionalNoteTEController: _additionalNoteTEController,
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
      ),
    );
  }
}
