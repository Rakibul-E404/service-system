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

import '../../home/controllers/review_screen_controller.dart';

class ReviewForServiceScreen extends StatefulWidget {
  const ReviewForServiceScreen({super.key});

  @override
  State<ReviewForServiceScreen> createState() => _ReviewForServiceScreenState();
}

class _ReviewForServiceScreenState extends State<ReviewForServiceScreen> {
  final TextEditingController _reviewTextController = TextEditingController();
  late ReviewController reviewController;

  @override
  void initState() {
    super.initState();
    // Remove any existing instance and create a new one
    if (Get.isRegistered<ReviewController>()) {
      Get.delete<ReviewController>();
    }
    reviewController = Get.put(ReviewController());
  }

  @override
  void dispose() {
    _reviewTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get both bookingId and serviceId from route parameters
    final String? bookingId = Get.parameters['bookingId'];
    final String? serviceId = Get.parameters['serviceId'];

    // Print the received IDs to console
    print('🎯 ReviewForServiceScreen - Received bookingId: $bookingId');
    print('🎯 ReviewForServiceScreen - Received serviceId: $serviceId');

    // Determine which ID to use (bookingId has priority)
    final String? reviewId = bookingId ?? serviceId;

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
                // Display ID information for debugging (optional - remove in production)
                if (reviewId != null && reviewId.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSizes.sm),
                    margin: const EdgeInsets.only(bottom: AppSizes.md),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        if (bookingId != null && bookingId.isNotEmpty)
                          Text(
                            'Booking ID: $bookingId',
                            style: context.txtTheme.bodySmall?.copyWith(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        if (serviceId != null && serviceId.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              'Service ID: $serviceId',
                              style: context.txtTheme.bodySmall?.copyWith(
                                color: Colors.grey,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          bookingId != null && bookingId.isNotEmpty
                              ? '✅ Using Booking ID for review'
                              : '⚠️ Using Service ID (should be Booking ID)',
                          style: context.txtTheme.bodySmall?.copyWith(
                            color: bookingId != null ? Colors.green : Colors.orange,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: AppSizes.md,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.greyColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
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
                        style: context.txtTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSizes.lg),

                      // Rating section
                      Obx(
                            () => reviewTile(
                          label: "Rate your experience",
                          rating: reviewController.qualityRating.value,
                          onRatingChanged: (double rating) {
                            reviewController.updateQualityRating(rating);
                          },
                        ),
                      ),

                      const SizedBox(height: AppSizes.md),

                      // Review text field
                      Text(
                        "Write Your Review",
                        style: context.txtTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      TextFormField(
                        controller: _reviewTextController,
                        maxLines: 5,
                        maxLength: 500,
                        decoration: InputDecoration(
                          hintText: 'Share your experience with this service...',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.primaryColor,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),

                      const SizedBox(height: AppSizes.md),

                      // Submit button
                      Obx(() => ReusableButton(
                        label: 'Submit Review',
                        isLoading: reviewController.isLoading.value,
                        onTap: () {
                          _submitReview(reviewId);
                        },
                      )),
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

  void _submitReview(String? reviewId) {
    // Print reviewId when submitting review
    print('📤 Submitting review for ID: $reviewId');

    // Print rating and description
    print('⭐ Rating: ${reviewController.qualityRating.value}');
    print('📝 Description: ${_reviewTextController.text}');

    // Handle submit logic with reviewId
    if (reviewId == null || reviewId.isEmpty) {
      print('❌ No ID available for review submission');
      Get.snackbar(
        'Error',
        'Booking information not available',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    // Validate rating
    if (reviewController.qualityRating.value == 0) {
      Get.snackbar(
        'Error',
        'Please provide a rating',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    // Validate description
    if (_reviewTextController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please write a review',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    // Call the API to submit review with ID
    print('🚀 Calling submitReview API with ID: $reviewId');

    // Submit review via controller
    reviewController.submitReview(
      bookingId: reviewId,
      description: _reviewTextController.text.trim(),
      rating: reviewController.qualityRating.value,
    );
  }

  // Function to handle review tile with rating bar
  Widget reviewTile({
    required String label,
    required double rating,
    required ValueChanged<double> onRatingChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Review Label
        Text(
          label,
          style: Get.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        // Rating Bar
        Center(
          child: RatingBar(
            filledIcon: CupertinoIcons.star_fill,
            filledColor: AppColors.primaryColor,
            emptyIcon: CupertinoIcons.star,
            emptyColor: Colors.grey.shade300,
            onRatingChanged: onRatingChanged,
            initialRating: rating,
            maxRating: 5,
            size: 40,
          ),
        ),
      ],
    );
  }
}

 */




///
///
///
/// todo::: updating the review functionality
///
///
///
///





import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/common/widgets/reusable_button.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import 'package:manx_mate/core/extensions/widget_extensions.dart';

import '../../home/controllers/review_screen_controller.dart';

class ReviewForServiceScreen extends StatefulWidget {
  const ReviewForServiceScreen({super.key});

  @override
  State<ReviewForServiceScreen> createState() => _ReviewForServiceScreenState();
}

class _ReviewForServiceScreenState extends State<ReviewForServiceScreen> {
  final TextEditingController _reviewTextController = TextEditingController();
  late ReviewController reviewController;

  String? bookingId;
  String? serviceId;

  @override
  void initState() {
    super.initState();

    // Get both bookingId and serviceId from route parameters
    bookingId = Get.parameters['bookingId'];
    serviceId = Get.parameters['serviceId'];

    debugPrint('🎯 ReviewForServiceScreen - Received bookingId: $bookingId');
    debugPrint('🎯 ReviewForServiceScreen - Received serviceId: $serviceId');

    // Remove any existing instance and create a new one
    if (Get.isRegistered<ReviewController>()) {
      Get.delete<ReviewController>();
    }
    reviewController = Get.put(ReviewController());

    // Fetch existing review if serviceId is available
    if (serviceId != null && serviceId!.isNotEmpty) {
      reviewController.fetchExistingReview(serviceId!).then((_) {
        // Pre-fill the text field if there's an existing review
        if (reviewController.hasExistingReview.value) {
          setState(() {
            _reviewTextController.text = reviewController.existingReviewDescription.value;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _reviewTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine which ID to use (bookingId has priority)
    final String? reviewId = bookingId ?? serviceId;

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
            reviewController.hasExistingReview.value
                ? "Update Review"
                : "Review for Service"
        )),
        backgroundColor: AppColors.whiteColor,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(CupertinoIcons.back),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(() {
          // Show loading while fetching existing review
          if (reviewController.isFetchingExistingReview.value) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primaryColor),
                  SizedBox(height: 16),
                  Text('Checking for existing review...'),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Display review status banner
                  if (reviewId != null && reviewId.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSizes.sm),
                      margin: const EdgeInsets.only(bottom: AppSizes.md),
                      decoration: BoxDecoration(
                        color: reviewController.hasExistingReview.value
                            ? Colors.orange.withOpacity(0.1)
                            : Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: reviewController.hasExistingReview.value
                              ? Colors.orange.withOpacity(0.3)
                              : Colors.blue.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            reviewController.hasExistingReview.value
                                ? Icons.edit_note
                                : Icons.rate_review,
                            color: reviewController.hasExistingReview.value
                                ? Colors.orange
                                : Colors.blue,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            reviewController.hasExistingReview.value
                                ? '📝 You have already reviewed this service'
                                : '✨ Share your experience with this service',
                            style: context.txtTheme.bodySmall?.copyWith(
                              color: reviewController.hasExistingReview.value
                                  ? Colors.orange
                                  : Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (reviewController.hasExistingReview.value) ...[
                            const SizedBox(height: 4),
                            Text(
                              'You can update your review below',
                              style: context.txtTheme.bodySmall?.copyWith(
                                color: Colors.grey,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: AppSizes.md,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.greyColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Icon(
                          CupertinoIcons.star_fill,
                          color: reviewController.hasExistingReview.value
                              ? Colors.orange
                              : AppColors.primaryColor,
                          size: 48,
                        ).centered,

                        const SizedBox(height: AppSizes.md),
                        Text(
                          reviewController.hasExistingReview.value
                              ? "Update your experience with this service"
                              : "How was your experience with this service?",
                          style: context.txtTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSizes.lg),

                        // Rating section
                        Obx(
                              () => reviewTile(
                            label: reviewController.hasExistingReview.value
                                ? "Update your rating"
                                : "Rate your experience",
                            rating: reviewController.qualityRating.value,
                            onRatingChanged: (double rating) {
                              reviewController.updateQualityRating(rating);
                            },
                          ),
                        ),

                        const SizedBox(height: AppSizes.md),

                        // Review text field
                        Text(
                          reviewController.hasExistingReview.value
                              ? "Update Your Review"
                              : "Write Your Review",
                          style: context.txtTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSizes.sm),
                        TextFormField(
                          controller: _reviewTextController,
                          maxLines: 5,
                          maxLength: 500,
                          decoration: InputDecoration(
                            hintText: 'Share your experience with this service...',
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: reviewController.hasExistingReview.value
                                    ? Colors.orange
                                    : AppColors.primaryColor,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),

                        const SizedBox(height: AppSizes.md),

                        // Submit/Update button
                        Obx(() => ReusableButton(
                          label: reviewController.hasExistingReview.value
                              ? 'Update Review'
                              : 'Submit Review',
                          isLoading: reviewController.isLoading.value,
                          onTap: () {
                            _submitOrUpdateReview(reviewId);
                          },
                          bgColor: reviewController.hasExistingReview.value
                              ? Colors.orange
                              : AppColors.primaryColor,
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  void _submitOrUpdateReview(String? reviewId) {
    debugPrint('📤 ${reviewController.hasExistingReview.value ? "Updating" : "Submitting"} review for ID: $reviewId');
    debugPrint('⭐ Rating: ${reviewController.qualityRating.value}');
    debugPrint('📝 Description: ${_reviewTextController.text}');

    // Validate ID
    if (reviewId == null || reviewId.isEmpty) {
      debugPrint('❌ No ID available for review submission');
      Get.snackbar(
        'Error',
        'Booking information not available',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    // Validate rating
    if (reviewController.qualityRating.value == 0) {
      Get.snackbar(
        'Error',
        'Please provide a rating',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    // Validate description
    if (_reviewTextController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please write a review',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    // Check if updating or creating new review
    if (reviewController.hasExistingReview.value) {
      // UPDATE existing review
      debugPrint('🔄 Calling updateReview API with Review ID: ${reviewController.existingReviewId.value}');
      reviewController.updateReview(
        reviewId: reviewController.existingReviewId.value,
        description: _reviewTextController.text.trim(),
        rating: reviewController.qualityRating.value,
      );
    } else {
      // CREATE new review
      debugPrint('🚀 Calling submitReview API with Booking ID: $reviewId');
      reviewController.submitReview(
        bookingId: reviewId,
        description: _reviewTextController.text.trim(),
        rating: reviewController.qualityRating.value,
      );
    }
  }

  // Function to handle review tile with rating bar
  Widget reviewTile({
    required String label,
    required double rating,
    required ValueChanged<double> onRatingChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Review Label
        Text(
          label,
          style: Get.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        // Rating Bar
        Center(
          child: RatingBar(
            filledIcon: CupertinoIcons.star_fill,
            filledColor: reviewController.hasExistingReview.value
                ? Colors.orange
                : AppColors.primaryColor,
            emptyIcon: CupertinoIcons.star,
            emptyColor: Colors.grey.shade300,
            onRatingChanged: onRatingChanged,
            initialRating: rating,
            maxRating: 5,
            size: 40,
          ),
        ),
      ],
    );
  }
}