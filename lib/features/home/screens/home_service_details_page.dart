/**

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import 'package:manx_mate/core/extensions/widget_extensions.dart';

import '../../../core/common/components/custom_network_image.dart';
import '../../../core/common/widgets/app_bottom_sheet.dart';
import '../../../core/common/widgets/reusable_button.dart';
import '../../../core/common/widgets/time_picker_widget.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/home_service_details_controller.dart';
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
    // Extract service data from arguments
    final Map<String, dynamic> serviceData = Get.arguments ?? {};
    final String serviceImage = serviceData['serviceImage'] ?? '';
    final String serviceTitle = serviceData['serviceName'] ?? 'No Name';
    final String serviceSubtitle = serviceData['serviceDescription'] ?? 'No Description';
    final String serviceLocation = serviceData['serviceLocation'] ?? 'No Location';
    final double serviceRating = serviceData['serviceRating'] ?? 0.0;

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
                imageUrl: serviceImage,
                width: context.screenWidth,
                height: context.screenHeight * 0.4,
              ),
              const SizedBox(height: AppSizes.md),
              Text(serviceTitle, style: context.txtTheme.titleLarge),
              const SizedBox(height: AppSizes.sm),
              Text(serviceSubtitle),
              Row(
                spacing: 8,
                children: <Widget>[
                  Icon(Icons.location_on_outlined, size: 18),
                  Text(serviceLocation),
                ],
              ),
              Row(
                spacing: 8,
                children: <Widget>[
                  Icon(Icons.star_outline, size: 18),
                  Text(serviceRating.toString()),
                ],
              ),
              const SizedBox(height: AppSizes.md),
              Text('Available Date & Time', style: context.txtTheme.titleLarge),
              const SizedBox(height: AppSizes.sm),

              /// ==============> Calendar Widget
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

*/




///
///
///
///
///
/// todo::: updating to pass the authid
///
///
///
///
///


/*

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import 'package:manx_mate/core/extensions/widget_extensions.dart';

import '../../../core/common/components/custom_network_image.dart';
import '../../../core/common/widgets/app_bottom_sheet.dart';
import '../../../core/common/widgets/reusable_button.dart';
import '../../../core/common/widgets/time_picker_widget.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/home_service_details_controller.dart';
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
    // Extract service data from arguments
    final Map<String, dynamic> serviceData = Get.arguments ?? {};
    final String serviceImage = serviceData['serviceImage'] ?? '';
    final String serviceTitle = serviceData['serviceName'] ?? 'No Name';
    final String serviceSubtitle = serviceData['serviceDescription'] ?? 'No Description';
    final String serviceLocation = serviceData['serviceLocation'] ?? 'No Location';
    final double serviceRating = serviceData['serviceRating'] ?? 0.0;

    // Extract author ID for API call
    final dynamic authorData = serviceData['author'];
    final String authorId = authorData is Map<String, dynamic>
        ? (authorData['_id']?.toString() ?? '')
        : (serviceData['authorId']?.toString() ?? '');

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
                imageUrl: serviceImage,
                width: context.screenWidth,
                height: context.screenHeight * 0.4,
              ),
              const SizedBox(height: AppSizes.md),
              Text(serviceTitle, style: context.txtTheme.titleLarge),
              const SizedBox(height: AppSizes.sm),
              Text(serviceSubtitle),
              Row(
                spacing: 8,
                children: <Widget>[
                  Icon(Icons.location_on_outlined, size: 18),
                  Text(serviceLocation),
                ],
              ),
              Row(
                spacing: 8,
                children: <Widget>[
                  Icon(Icons.star_outline, size: 18),
                  Text(serviceRating.toString()),
                ],
              ),
              const SizedBox(height: AppSizes.md),
              Text('Available Date & Time', style: context.txtTheme.titleLarge),
              const SizedBox(height: AppSizes.sm),

              /// ==============> Calendar Widget
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

              ///=================> Service Provider Card (Now with API data) =====================>
              Obx(() {
                final isLoading = controller.isLoadingProvider.value;
                final errorMsg = controller.providerErrorMessage.value;
                final provider = controller.providerData.value;

                // If API fails with 403, we can show a basic card with the authorId
                final bool showFallback = errorMsg.contains('Forbidden') || errorMsg.contains('403');

                // Loading state
                if (isLoading) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.sm,
                      vertical: AppSizes.md,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primaryColor),
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                    ),
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                }

                // Error state - show fallback for 403, otherwise show error
                if (errorMsg.isNotEmpty && !showFallback) {
                  return Container(
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red),
                      color: Colors.red.withValues(alpha: 0.1),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 40),
                        const SizedBox(height: 8),
                        Text(
                          errorMsg,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            if (authorId.isNotEmpty) {
                              controller.retryFetchProvider(authorId);
                            }
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                // Fallback for 403 - show basic provider card
                if (showFallback && authorId.isNotEmpty) {
                  return GestureDetector(
                    onTap: () {
                      // Could navigate to a limited provider view
                      Get.snackbar(
                        'Provider Info',
                        'Provider ID: $authorId',
                        snackPosition: SnackPosition.BOTTOM,
                      );
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
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Service Provider',
                                  style: context.txtTheme.labelLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Provider information available on request',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Contact for details',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Success state with provider data
                if (provider != null) {
                  return GestureDetector(
                    onTap: () {
                      Get.toNamed(
                        AppRoutes.providerDetailsPage,
                        arguments: {
                          'provider': provider.toJson(),
                        },
                      );
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
                            child: CustomCachedImage(
                              imageUrl: provider.fullImageUrl.isNotEmpty
                                  ? provider.fullImageUrl
                                  : 'https://via.placeholder.com/150',
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        provider.name,
                                        style: context.txtTheme.labelLarge,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    // if (provider.isVerified)
                                    //   const Icon(
                                    //     Icons.verified,
                                    //     color: Colors.blue,
                                    //     size: 18,
                                    //   ),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    const Icon(Icons.location_on_outlined, size: 16),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        provider.location,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    const Icon(
                                      Icons.star,
                                      color: AppColors.primaryColor,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(provider.rating.toStringAsFixed(1)),
                                    Text(
                                      ' (${provider.ratingCount})',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // No provider data (shouldn't happen, but fallback)
                return const SizedBox.shrink();
              }),
              const SizedBox(height: AppSizes.md),

              ///=================> Review Section =====================>
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "About",
                    style: context.txtTheme.headlineMedium?.copyWith(
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const Text("Review"),
                ],
              ),
              const Divider(color: AppColors.primaryColor, thickness: 2),

              // Show provider bio if available
              Obx(() {
                final provider = controller.providerData.value;
                return Text(
                  provider?.bio.isNotEmpty == true
                      ? provider!.bio
                      : "I provide expert tutoring in Math and Science, tailored to your needs. From basics to advanced topics, I simplify complex concepts. Let's improve your grades and build your confidence—together!",
                );
              }),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}*/


///----------todo:: upper one is working,,,
///
///




import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import 'package:manx_mate/core/extensions/widget_extensions.dart';

import '../../../core/common/components/custom_network_image.dart';
import '../../../core/common/widgets/app_bottom_sheet.dart';
import '../../../core/common/widgets/reusable_button.dart';
import '../../../core/common/widgets/time_picker_widget.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../../../provider_model.dart';
import '../controllers/home_service_details_controller.dart';
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
    // Extract service data from arguments
    final Map<String, dynamic> serviceData = Get.arguments ?? {};
    final String serviceImage = serviceData['serviceImage'] ?? '';
    final String serviceTitle = serviceData['serviceName'] ?? 'No Name';
    final String serviceSubtitle = serviceData['serviceDescription'] ?? 'No Description';
    final String serviceLocation = serviceData['serviceLocation'] ?? 'No Location';
    final double serviceRating = serviceData['serviceRating'] ?? 0.0;

    // Extract author ID for API call
    final dynamic authorData = serviceData['author'];
    final String authorId = authorData is Map<String, dynamic>
        ? (authorData['_id']?.toString() ?? '')
        : (serviceData['authorId']?.toString() ?? '');

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
                imageUrl: serviceImage,
                width: context.screenWidth,
                height: context.screenHeight * 0.4,
              ),
              const SizedBox(height: AppSizes.md),
              Text(serviceTitle, style: context.txtTheme.titleLarge),
              const SizedBox(height: AppSizes.sm),
              Text(serviceSubtitle),
              const SizedBox(height: AppSizes.xs),
              Row(
                spacing: 8,
                children: <Widget>[
                  const Icon(Icons.location_on_outlined, size: 18),
                  Text(serviceLocation),
                ],
              ),
              const SizedBox(height: AppSizes.xs),
              Row(
                spacing: 8,
                children: <Widget>[
                  const Icon(Icons.star_outline, size: 18),
                  Text(serviceRating.toString()),
                ],
              ),
              const SizedBox(height: AppSizes.md),
              Text('Available Date & Time', style: context.txtTheme.titleLarge),
              const SizedBox(height: AppSizes.sm),

              /// ==============> Calendar Widget
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
                  debugPrint('Selected Time: $time');
                },
              ).centered,
              const SizedBox(height: AppSizes.lg),
              Text('Service Provider', style: context.txtTheme.titleLarge),
              const SizedBox(height: AppSizes.sm),

              ///=================> Service Provider Card =====================>
              Obx(() {
                final isLoading = controller.isLoadingProvider.value;
                final errorMsg = controller.providerErrorMessage.value;
                final provider = controller.providerData.value;

                // Check if we have limited provider data (403 case)
                final bool hasLimitedData = provider != null &&
                    errorMsg.contains('Limited provider information');

                // Loading state
                if (isLoading) {
                  return _buildProviderLoadingCard();
                }

                // Success state with full provider data
                if (provider != null && !hasLimitedData) {
                  return _buildProviderSuccessCard(provider, context);
                }

                // Limited data state (403 restricted access)
                if (hasLimitedData) {
                  return _buildLimitedProviderCard(provider!, errorMsg, context);
                }

                // Error state
                if (errorMsg.isNotEmpty) {
                  return _buildProviderErrorCard(errorMsg, authorId);
                }

                // No provider data available
                return _buildNoProviderCard();
              }),
              const SizedBox(height: AppSizes.md),

              ///=================> About & Review Section =====================>
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "About",
                    style: context.txtTheme.headlineMedium?.copyWith(
                      color: AppColors.primaryColor,
                    ),
                  ),
                  // GestureDetector(
                  //   onTap: () {
                  //     // Navigate to reviews page
                  //     if (controller.providerData.value != null) {
                  //       Get.toNamed(
                  //         AppRoutes.providerReviewsPage,
                  //         arguments: {
                  //           'provider': controller.providerData.value!.toJson(),
                  //         },
                  //       );
                  //     }
                  //   },
                  //   child: Text(
                  //     "Reviews",
                  //     style: context.txtTheme.headlineMedium?.copyWith(
                  //       color: AppColors.primaryColor,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              const Divider(color: AppColors.primaryColor, thickness: 2),
              const SizedBox(height: AppSizes.sm),

              // Show provider description/bio
              Obx(() {
                final provider = controller.providerData.value;
                final isLoading = controller.isLoadingProvider.value;

                if (isLoading) {
                  return _buildAboutLoading();
                }

                // Show provider description if available
                if (provider != null && provider.description.isNotEmpty) {
                  return _buildProviderAboutSection(provider);
                }

                // Fallback text if no provider data
                return _buildFallbackAboutSection(serviceSubtitle);
              }),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // ============ HELPER WIDGET METHODS ============

  Widget _buildProviderLoadingCard() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.md,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryColor),
        color: AppColors.primaryColor.withValues(alpha: 0.1),
      ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildProviderErrorCard(String errorMsg, String authorId) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red),
        color: Colors.red.withValues(alpha: 0.1),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 40),
          const SizedBox(height: 8),
          Text(
            errorMsg,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              if (authorId.isNotEmpty) {
                controller.retryFetchProvider(authorId);
              }
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderFallbackCard(String authorId) {
    return GestureDetector(
      onTap: () {
        Get.snackbar(
          'Provider Info',
          'Provider ID: $authorId',
          snackPosition: SnackPosition.BOTTOM,
        );
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
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Service Provider',
                    style: Get.textTheme.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Provider information available on request',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Contact for details',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderSuccessCard(ProviderModel provider, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(
          AppRoutes.providerDetailsPage,
          arguments: {
            'provider': provider.toJson(),
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.sm,
          vertical: AppSizes.md,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryColor),
          color: AppColors.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          spacing: AppSizes.md,
          children: <Widget>[
            // Provider Image
            Expanded(
              flex: 1,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CustomCachedImage(
                    imageUrl: provider.fullImageUrl.isNotEmpty
                        ? provider.fullImageUrl
                        : 'https://via.placeholder.com/150',
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Provider Details
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Name
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          provider.name,
                          style: context.txtTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: AppColors.primaryColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Location
                  Row(
                    children: <Widget>[
                      const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          provider.location,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Rating
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        provider.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${provider.ratingCount})',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Availability Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: provider.isAvailable ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: provider.isAvailable ? Colors.green : Colors.red,
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      provider.isAvailable ? 'Available' : 'Unavailable',
                      style: TextStyle(
                        fontSize: 10,
                        color: provider.isAvailable ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoProviderCard() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text(
          'No provider information available',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildAboutLoading() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildProviderAboutSection(ProviderModel provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Description
        Text(
          provider.description,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: AppSizes.md),

        // Contact Information
        const Text(
          'Contact Information:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: AppSizes.sm),

        // Phone
        if (provider.phone.isNotEmpty) ...[
          Row(
            children: [
              const Icon(Icons.phone, size: 16, color: AppColors.primaryColor),
              const SizedBox(width: 8),
              Text(
                provider.phone,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
        ],

        // Availability Status
        Row(
          children: [
            Icon(
              provider.isAvailable ? Icons.check_circle : Icons.cancel,
              size: 16,
              color: provider.isAvailable ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(
              provider.isAvailable ? 'Available Now' : 'Currently Unavailable',
              style: TextStyle(
                fontSize: 14,
                color: provider.isAvailable ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        // Profile Completion Status
        if (provider.isProfileComplete) ...[
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              const Icon(Icons.verified, size: 16, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'Verified Profile',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildFallbackAboutSection(String serviceSubtitle) {
    return Text(
      serviceSubtitle.isNotEmpty
          ? serviceSubtitle
          : "Professional service provider dedicated to delivering quality work. Contact us for more information about our services and availability.",
      style:  TextStyle(
        fontSize: 14,
        height: 1.5,
        color: Colors.grey[800],
      ),
    );
  }
}

Widget _buildLimitedProviderCard(ProviderModel provider, String message, BuildContext context) {
  return GestureDetector(
    onTap: () {
      Get.snackbar(
        'Limited Access',
        'Full provider details are restricted',
        snackPosition: SnackPosition.BOTTOM,
      );
    },
    child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.md,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange),
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            spacing: AppSizes.md,
            children: <Widget>[
              // Provider Image
              Expanded(
                flex: 1,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    size: 40,
                    color: Colors.orange,
                  ),
                ),
              ),
              // Provider Details
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Name
                    Text(
                      provider.name,
                      style: context.txtTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Limited access message
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Contact button
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Contact Provider',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: Colors.orange),
          const SizedBox(height: 8),
          // Additional info
          const Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.orange),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Some provider details are restricted due to privacy settings',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}


