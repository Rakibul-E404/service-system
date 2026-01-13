/**

import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/common/widgets/reusable_button.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import 'package:manx_mate/core/extensions/widget_extensions.dart';
import '../controllers/review_controller.dart';

class ReviewForServiceScreen extends GetView<ReviewController> {
  const ReviewForServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the bookingId and serviceId from route parameters
    final String bookingId = Get.parameters['bookingId'] ?? '';
    final String serviceId = Get.parameters['serviceId'] ?? '';

    // Initialize the controller using GetX
    final ReviewController reviewController = Get.put(ReviewController());

    debugPrint('📝 Review Screen - Booking ID: $bookingId');
    debugPrint('📝 Review Screen - Service ID: $serviceId');

    if (bookingId.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Error',
          'Booking ID not found',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        Get.back();
      });
    }

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
                  decoration: BoxDecoration(
                    color: AppColors.greyColor.withValues(alpha: 0.2),
                  ),
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
                        "How was your experience with this service?",
                        style: context.txtTheme.labelLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSizes.lg),

                      // Single Rating Bar
                      Text(
                        "Overall Rating",
                        style: Get.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),

                      Obx(
                            () => Column(
                          children: [
                            RatingBar(
                              filledIcon: CupertinoIcons.star_fill,
                              filledColor: AppColors.primaryColor,
                              emptyIcon: CupertinoIcons.star,
                              onRatingChanged: (double rating) {
                                reviewController.updateRating(rating);
                              },
                              initialRating: reviewController.rating.value,
                              maxRating: 5,
                              size: 40,
                            ),
                            const SizedBox(height: AppSizes.sm),
                            Text(
                              '${reviewController.rating.value.toStringAsFixed(1)} out of 5',
                              style: Get.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSizes.lg),

                      // Review Description
                      Text(
                        "Write Your Review",
                        style: Get.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),

                      TextFormField(
                        controller: reviewController.descriptionController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText: 'Share your experience with this service...',
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primaryColor,
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSizes.lg),

                      // Submit Button
                      Obx(() => reviewController.isSubmitting.value
                          ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      )
                          : ReusableButton(
                        label: 'Submit Review',
                        onTap: () async {
                          final success = await reviewController.submitReview(bookingId);
                          if (success) {
                            // Navigate back after successful submission
                            Get.back();
                          }
                        },
                      ),
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
}

*/








///
///
///
/// todo:::: fixingthe close
///
///
///
///



import 'dart:math';

import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/common/widgets/reusable_button.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import 'package:manx_mate/core/extensions/widget_extensions.dart';
import '../controllers/review_controller.dart';

class ReviewForServiceScreen extends GetView<ReviewController> {
  const ReviewForServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the bookingId and serviceId from route parameters
    final String bookingId = Get.parameters['bookingId'] ?? '';
    final String serviceId = Get.parameters['serviceId'] ?? '';

    // Initialize the controller using GetX
    final ReviewController reviewController = Get.put(ReviewController());

    debugPrint('📝 Review Screen - Booking ID: $bookingId');
    debugPrint('📝 Review Screen - Service ID: $serviceId');

    if (bookingId.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Error',
          // 'Booking ID not found',
          '${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        Get.back();
      });
    }

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
                  decoration: BoxDecoration(
                    color: AppColors.greyColor.withValues(alpha: 0.2),
                  ),
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
                        "How was your experience with this service?",
                        style: context.txtTheme.labelLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSizes.lg),

                      // Single Rating Bar
                      Text(
                        "Overall Rating",
                        style: Get.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),

                      Obx(
                            () => Column(
                          children: [
                            RatingBar(
                              filledIcon: CupertinoIcons.star_fill,
                              filledColor: AppColors.primaryColor,
                              emptyIcon: CupertinoIcons.star,
                              onRatingChanged: (double rating) {
                                reviewController.updateRating(rating);
                              },
                              initialRating: reviewController.rating.value,
                              maxRating: 5,
                              size: 40,
                            ),
                            const SizedBox(height: AppSizes.sm),
                            Text(
                              '${reviewController.rating.value.toStringAsFixed(1)} out of 5',
                              style: Get.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSizes.lg),

                      // Review Description
                      Text(
                        "Write Your Review",
                        style: Get.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),

                      TextFormField(
                        controller: reviewController.descriptionController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText: 'Share your experience with this service...',
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primaryColor,
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSizes.lg),

                      // Submit Button
                      Obx(() => reviewController.isSubmitting.value
                          ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      )
                          : ReusableButton(
                        label: 'Submit Review',
                        onTap: () async {
                          final success = await reviewController.submitReview(bookingId);
                          if (success) {
                            // Show success dialog
                            await Get.dialog(
                              AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 60,
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Review Submitted!',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Thank you for your feedback',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                              barrierDismissible: false,
                            );

                            // Close dialog and navigate back
                            await Future.delayed(const Duration(seconds: 1));
                            Get.back(); // Close dialog
                            Get.back(); // Close review page
                          }
                        },
                      ),
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
}