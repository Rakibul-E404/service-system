import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/common/components/custom_network_image.dart';
import 'package:manx_mate/core/common/widgets/reusable_button.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import 'package:manx_mate/core/extensions/widget_extensions.dart';
import 'package:manx_mate/core/routes/app_routes.dart';
import 'package:manx_mate/features/home/controllers/home_service_details_controller.dart';

import '../../../core/common/widgets/app_bottom_sheet.dart';
import '../../../core/common/widgets/time_picker_widget.dart';
import '../widget/inquiry_bottom_sheet.dart';
import '../widget/one_row_calander.dart';
import '../widget/time_selection_widget.dart';

class HomeServiceDetailsPage extends GetView<HomeServiceDetailsController> {
  HomeServiceDetailsPage({super.key});

  final TextEditingController _serviceNameTEController = TextEditingController();
  final TextEditingController _locationTEController = TextEditingController();
  final TextEditingController _additionalNoteTEController = TextEditingController();
  final TextEditingController _dateTEController = TextEditingController();
  final TimeController timeController = Get.put(TimeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: context.screenWidth * 0.9,
        height: 50,

        child: ReusableButton(
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
          label: "Book A Slot",
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: const Icon(CupertinoIcons.back),
                  ),
                  IconButton(onPressed: () {}, icon: const Icon(CupertinoIcons.heart)),
                ],
              ),

              ///====================> Main Body ================>
              const SizedBox(height: AppSizes.md),
              CustomCachedImage(
                imageUrl: 'imageUrl',
                width: context.screenWidth,
                height: context.screenHeight * 0.4,
              ),
              const SizedBox(height: AppSizes.md),
              Text('Tutor Pro Academy', style: context.txtTheme.titleLarge),
              const SizedBox(height: AppSizes.sm),
              const Text('Children and Educcation'),
              const Row(
                spacing: 8,
                children: <Widget>[
                  Icon(Icons.location_on_outlined, size: 18),
                  Text("Cork, Ireland"),
                ],
              ),
              const Row(
                spacing: 8,
                children: <Widget>[Icon(Icons.phone_outlined, size: 18), Text("0-5680684657")],
              ),
              const Row(
                spacing: 8,
                children: <Widget>[Icon(Icons.star_outline, size: 18), Text("4.9(200 Ratings)")],
              ),
              const SizedBox(height: AppSizes.md),
              Text('Available Date & Time', style: context.txtTheme.titleLarge),
              const SizedBox(height: AppSizes.sm),

              /// ==============> Calender Widget
              Obx(
                    () => OneRowCalendar(
                  selectedDate: controller.dateTimePick.value,
                  onDateSelected: (DateTime time) {
                    controller.dateTimePick.value = time;
                  },
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              TimeSelector(
                initialTime: '10am',
                selectedColor: AppColors.primaryColor,
                selectedTextColor: AppColors.textBlackColor,
                onTimeSelected: (String time) {
                  // print('Selected: $time');
                },
              ).centered,
              const SizedBox(height: AppSizes.lg),
              Text('Service Provider', style: context.txtTheme.titleLarge),
              const SizedBox(height: AppSizes.sm),

              ///=================> Service Provider Card =====================>
              GestureDetector(
                onTap: () {
                  Get.toNamed(AppRoutes.providerDetailsPage);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.sm,
                    vertical: AppSizes.md,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primaryColor),
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                  ),
                  child: Row(
                    spacing: AppSizes.md,
                    children: <Widget>[
                      Expanded(flex: 1, child: CachedNetworkImage(imageUrl: '', height: 100)),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(" James Jayan", style: context.txtTheme.labelLarge),
                            const Row(
                              children: <Widget>[
                                Icon(Icons.location_on_outlined),
                                Text("Cork Ireland"),
                              ],
                            ),
                            const Row(
                              children: <Widget>[
                                Icon(Icons.star, color: AppColors.primaryColor),
                                Text("4.9"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),

              ///=================> Review Section =====================>
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "About",
                    style: context.txtTheme.headlineMedium?.copyWith(color: AppColors.primaryColor),
                  ),
                  const Text("Review"),
                ],
              ),
              const Divider(color: AppColors.primaryColor, thickness: 2),
              const Text(
                "I provide expert tutoring in Math and Science, tailored to your needs.From basics to advanced topics, I simplify complex concepts.Let’s improve your grades and build your confidence—together!",
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}