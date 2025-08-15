import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX
import 'package:manx_mate/core/common/widgets/reusable_button.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import 'package:manx_mate/core/extensions/widget_extensions.dart';
import 'package:manx_mate/features/auth/widgets/primary_button.dart';
import '../controllers/review_controller.dart'; // Import the ReviewController

class ReviewForServiceScreen extends GetView<ReviewController> {
  const ReviewForServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller using GetX
    final ReviewController reviewController = Get.put(ReviewController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Review for Service"),
        backgroundColor: AppColors.whiteColor,
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: const Icon(CupertinoIcons.back),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: AppSizes.md,
                  ),
                  decoration: BoxDecoration(color: AppColors.greyColor.withValues(alpha: 0.2)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Icon(
                        CupertinoIcons.star_fill,
                        color: AppColors.primaryColor,
                        size: 48,
                      ).centered,

                      const SizedBox(height: AppSizes.md),
                      Text(
                        "How was your experience of the event 'Service for Wedding'?",
                        style: context.txtTheme.labelLarge,
                      ),
                      const SizedBox(height: AppSizes.lg),
                      // Multiple review categories
                      Obx(
                        () => reviewTile(
                          label: "Quality of Service",
                          rating: reviewController.qualityRating.value,
                          onRatingChanged: (double rating) {
                            reviewController.updateQualityRating(rating);
                          },
                        ),
                      ),
                      Obx(
                        () => reviewTile(
                          label: "Timeliness",
                          rating: reviewController.timelinessRating.value,
                          onRatingChanged: (double rating) {
                            reviewController.updateResponseTimeRating(rating);
                          },
                        ),
                      ),
                      Obx(
                        () => reviewTile(
                          label: "Professionalism",
                          rating: reviewController.professionalismRating.value,
                          onRatingChanged: (double rating) {
                            reviewController.updateProfessionalismRating(rating);
                          },
                        ),
                      ),
                      Obx(
                        () => reviewTile(
                          label: "Value For Money",
                          rating: reviewController.valueForMoneyRating.value,
                          onRatingChanged: (double rating) {
                            reviewController.updateValurForMoney(rating);
                          },
                        ),
                      ),
                      Obx(
                        () => reviewTile(
                          label: "Flexibility",
                          rating: reviewController.flexibilityRating.value,
                          onRatingChanged: (double rating) {
                            reviewController.updateFlexibilityRating(rating);
                          },
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                      TextFormField(
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hint: Text('Write Your Review '),
                          enabledBorder: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: AppSizes.md),
                      ReusableButton(
                        label: 'Submit Review',
                        onTap: () {
                          // // Handle submit logic
                          // print("Review submitted!");
                          // print("Quality Rating: ${reviewController.qualityRating.value}");
                          // print("Timeliness Rating: ${reviewController.timelinessRating.value}");
                          // print(
                          //   "Professionalism Rating: ${reviewController.professionalismRating.value}",
                          // );
                          // print(
                          //   "Value for money Rating: ${reviewController.valueForMoneyRating.value}",
                          // );
                          // print(
                          //   "Value for money Rating: ${reviewController.valueForMoneyRating.value}",
                          // );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Function to handle multiple review tiles dynamically
  Widget reviewTile({
    required String label,
    required double rating,
    required ValueChanged<double> onRatingChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Review Label
        Text(label, style: Get.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSizes.sm),
        // Rating Bar
        RatingBar(
          filledIcon: CupertinoIcons.star_fill,
          filledColor: AppColors.primaryColor,
          emptyIcon: CupertinoIcons.star,
          onRatingChanged: onRatingChanged,
          initialRating: rating,
          // Set the initial rating dynamically
          maxRating: 5, // Max rating is 5
        ),
        const SizedBox(height: AppSizes.md),
      ],
    );
  }
}
