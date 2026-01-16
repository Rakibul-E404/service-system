import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/common/components/custom_network_image.dart';
import 'package:manx_mate/core/common/widgets/reusable_button.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import 'package:manx_mate/core/routes/app_routes.dart';
import 'package:manx_mate/features/home/controllers/home_service_details_controller.dart';
import '../../../core/common/widgets/app_bottom_sheet.dart';
import '../../../core/common/widgets/time_picker_widget.dart';
import '../widget/booking_bottom_sheet.dart';

class HomeServiceDetailsPage extends GetView<HomeServiceDetailsController> {
  HomeServiceDetailsPage({super.key});

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
              title: 'Book A Slot',
              height: context.screenHeight * 0.9,
              context: context,
              buttonText: 'Confirm Booking',
              onButtonPressed: () {
                // The booking will be submitted from within the BookingBottomSheet
                // using its own submit method
              },
              child: BookingBottomSheet(
                // isFromHomeScreen: false,
                // serviceNameTEController: _serviceNameTEController,
                dateTEController: _dateTEController,
                timeController: timeController,
                // locationTEController: _locationTEController,
                additionalNoteTEController: _additionalNoteTEController,
                // These would be the actual values from your service details
                preSelectedServiceId: 'service_id_from_details', // Replace with actual service ID
                preSelectedDate: DateTime.now(),
                preSelectedTime: '10:00 AM',
                onSubmitSuccess: () {
                  // Handle successful booking submission
                  Navigator.pop(context);
                  // Show success message or navigate
                  Get.snackbar(
                    'Success',
                    'Booking submitted successfully!',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                },
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
              Row(
                 children: <Widget>[
                  Text('Tutor Pro Academy', style: context.txtTheme.titleLarge),
                  const Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Icon(Icons.call, size: 26),
                        SizedBox(width: 12,),
                        Icon(Icons.email, size: 26),
                        SizedBox(width: 12,),
                        Icon(Icons.chat_bubble, size: 26),
                      ],
                    ),
                  ),

                ],
              ),
              const SizedBox(height: AppSizes.sm),
              const Text('Children and Education'),
              const Row(
                spacing: 8,
                children: <Widget>[
                  Icon(Icons.location_on_outlined, size: 18),
                  Text("Cork, Ireland"),
                ],
              ),
              const Row(
                spacing: 8,
                children: <Widget>[
                  Icon(Icons.phone_outlined, size: 18),
                  Text("0-5680684657")
                ],
              ),
              const Row(
                spacing: 8,
                children: <Widget>[
                  Icon(Icons.star_outline, size: 18),
                  Text("4.9(200 Ratings)")
                ],
              ),
              const SizedBox(height: AppSizes.md),
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
                      Expanded(
                        flex: 1,
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[200],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("James Jayan", style: context.txtTheme.labelLarge),
                            const SizedBox(height: 4),
                            const Row(
                              children: <Widget>[
                                Icon(Icons.location_on_outlined, size: 16),
                                SizedBox(width: 4),
                                Text("Cork Ireland"),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Row(
                              children: <Widget>[
                                Icon(Icons.star, color: AppColors.primaryColor, size: 16),
                                SizedBox(width: 4),
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
                    "Description",
                    style: context.txtTheme.headlineMedium?.copyWith(color: AppColors.primaryColor),
                  ),
                  // const Text("Review"),
                ],
              ),
              const Divider(color: AppColors.primaryColor, thickness: 2),
              const Text(
                "I provide expert tutoring in Math and Science, tailored to your needs. From basics to advanced topics, I simplify complex concepts. Let's improve your grades and build your confidence—together!",
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}