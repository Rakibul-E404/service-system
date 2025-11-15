/**
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
*/












///
///
///
///
/// todo gettong the serviceId
///
///
///
///






// import 'package:custom_rating_bar/custom_rating_bar.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart'; // Import GetX
// import 'package:manx_mate/core/common/widgets/reusable_button.dart';
// import 'package:manx_mate/core/config/app_colors.dart';
// import 'package:manx_mate/core/config/app_sizes.dart';
// import 'package:manx_mate/core/extensions/context_extensions.dart';
// import 'package:manx_mate/core/extensions/widget_extensions.dart';
// import '../controllers/review_controller.dart'; // Import the ReviewController
//
// class ReviewForServiceScreen extends GetView<ReviewController> {
//   const ReviewForServiceScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     // Get the serviceId from route parameters
//     final String? serviceId = Get.parameters['serviceId'];
//
//     // Print the received serviceId to console
//     print('🎯 ReviewForServiceScreen - Received serviceId: $serviceId');
//
//     // Initialize the controller using GetX
//     final ReviewController reviewController = Get.put(ReviewController());
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Review for Service"),
//         backgroundColor: AppColors.whiteColor,
//         leading: GestureDetector(
//           onTap: () {
//             Get.back();
//           },
//           child: const Icon(CupertinoIcons.back),
//         ),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(AppSizes.md),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 // Display serviceId for debugging (optional)
//                 if (serviceId != null && serviceId.isNotEmpty)
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(AppSizes.sm),
//                     margin: const EdgeInsets.only(bottom: AppSizes.md),
//                     decoration: BoxDecoration(
//                       color: Colors.blue.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       'Service ID: $serviceId',
//                       style: context.txtTheme.bodySmall?.copyWith(
//                         color: Colors.blue,
//                         fontWeight: FontWeight.w600,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: AppSizes.md,
//                     vertical: AppSizes.md,
//                   ),
//                   decoration: BoxDecoration(color: AppColors.greyColor.withValues(alpha: 0.2)),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: <Widget>[
//                       const Icon(
//                         CupertinoIcons.star_fill,
//                         color: AppColors.primaryColor,
//                         size: 48,
//                       ).centered,
//
//                       const SizedBox(height: AppSizes.md),
//                       Text(
//                         serviceId != null && serviceId.isNotEmpty
//                             ? "How was your experience of the service?"
//                             : "How was your experience of the event 'Service for Wedding'?",
//                         style: context.txtTheme.labelLarge,
//                       ),
//                       const SizedBox(height: AppSizes.lg),
//                       // Multiple review categories
//                       Obx(
//                             () => reviewTile(
//                           label: "Quality of Service",
//                           rating: reviewController.qualityRating.value,
//                           onRatingChanged: (double rating) {
//                             reviewController.updateQualityRating(rating);
//                           },
//                         ),
//                       ),
//                       const SizedBox(height: AppSizes.md),
//                       TextFormField(
//                         maxLines: 5,
//                         decoration: const InputDecoration(
//                           hint: Text('Write Your Review '),
//                           enabledBorder: OutlineInputBorder(),
//                           focusedBorder: OutlineInputBorder(),
//                         ),
//                       ),
//                       SizedBox(height: AppSizes.md),
//                       ReusableButton(
//                         label: 'Submit Review',
//                         onTap: () {
//                           // Print serviceId when submitting review
//                           print('📤 Submitting review for serviceId: $serviceId');
//
//                           // Print all ratings
//                           print('⭐ Quality Rating: ${reviewController.qualityRating.value}');
//                           print('⏰ Timeliness Rating: ${reviewController.timelinessRating.value}');
//                           print('👔 Professionalism Rating: ${reviewController.professionalismRating.value}');
//                           print('💰 Value for Money Rating: ${reviewController.valueForMoneyRating.value}');
//                           print('🔄 Flexibility Rating: ${reviewController.flexibilityRating.value}');
//
//                           // Handle submit logic with serviceId
//                           if (serviceId != null && serviceId.isNotEmpty) {
//                             // Call your API to submit review with serviceId
//                             print('🚀 Calling submitReview API with serviceId: $serviceId');
//
//                             // You can call your review submission method here:
//                             // reviewController.submitReview(serviceId: serviceId);
//                           } else {
//                             print('❌ No serviceId available for review submission');
//                             Get.snackbar(
//                               'Error',
//                               'Service information not available',
//                               backgroundColor: Colors.red,
//                               colorText: Colors.white,
//                             );
//                           }
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Function to handle multiple review tiles dynamically
//   Widget reviewTile({
//     required String label,
//     required double rating,
//     required ValueChanged<double> onRatingChanged,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         // Review Label
//         Text(label, style: Get.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
//         const SizedBox(height: AppSizes.sm),
//         // Rating Bar
//         RatingBar(
//           filledIcon: CupertinoIcons.star_fill,
//           filledColor: AppColors.primaryColor,
//           emptyIcon: CupertinoIcons.star,
//           onRatingChanged: onRatingChanged,
//           initialRating: rating,
//           // Set the initial rating dynamically
//           maxRating: 5, // Max rating is 5
//         ),
//         const SizedBox(height: AppSizes.md),
//       ],
//     );
//   }
// }



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














