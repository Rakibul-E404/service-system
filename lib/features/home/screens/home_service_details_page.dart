/**
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
                        Icon(CupertinoIcons.chat_bubble_fill, size: 26),
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
}*/




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
import '../../../core/utils/api/app_url.dart';
import '../../favorite/controllers/favorite_controller.dart';
import '../controllers/service_controller.dart';
import '../model/single_service_model.dart';
import '../widget/booking_bottom_sheet.dart';

class HomeServiceDetailsPage extends StatefulWidget {
  const HomeServiceDetailsPage({super.key});

  @override
  State<HomeServiceDetailsPage> createState() => _HomeServiceDetailsPageState();
}

class _HomeServiceDetailsPageState extends State<HomeServiceDetailsPage> {
  final ServicesController servicesController = Get.find<ServicesController>();
  final FavoriteController favoriteController = Get.find<FavoriteController>();
  final TimeController timeController = Get.put(TimeController());

  final TextEditingController _additionalNoteTEController = TextEditingController();
  final TextEditingController _dateTEController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final String serviceId = Get.arguments['serviceId'] ?? '';
    if (serviceId.isNotEmpty) {
      servicesController.fetchSingleService(serviceId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Obx(() {
        final service = servicesController.singleServiceDetails.value;
        return _buildBookingButton(context, service);
      }),
      body: SafeArea(
        child: Obx(() {
          if (servicesController.isLoadingSingleService.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final service = servicesController.singleServiceDetails.value;

          if (service == null) {
            return const Center(child: Text("Service details not found."));
          }

          final profile = service.profileDetails;
          final subCategory = service.subCategory;
          final isFav = servicesController.isServiceFavorited(service.id);
          final access = service.accessibleBySubscription;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(CupertinoIcons.back),
                    ),
                    IconButton(
                      onPressed: () => favoriteController.toggleFavorite(service.id),
                      icon: Icon(
                        isFav ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                        color: isFav ? Colors.red : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.md),
                CustomCachedImage(
                  imageUrl: profile.image.startsWith('http')
                      ? profile.image
                      : "${AppUrl.imageBaseUrl}/${profile.image}",
                  width: context.screenWidth,
                  height: context.screenHeight * 0.4,
                ),
                const SizedBox(height: AppSizes.md),

                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(profile.name, style: context.txtTheme.titleLarge),
                    ),
                    _buildContactIcons(access),
                  ],
                ),

                const SizedBox(height: AppSizes.sm),
                Text(service.subCategory.name),

                _buildDetailRow(Icons.location_on_outlined, profile.location),
                _buildDetailRow(Icons.phone_outlined, profile.phone),
                _buildDetailRow(
                    Icons.star_outline,
                    "${profile.averageRating} (${profile.totalReviews} Ratings)"
                ),

                const SizedBox(height: AppSizes.md),
                _buildStaticServiceDropdown(subCategory.name),
                const SizedBox(height: AppSizes.md),
                Text('Service Provider', style: context.txtTheme.titleLarge),
                const SizedBox(height: AppSizes.sm),
                _buildProviderCard(context, service),
                const SizedBox(height: AppSizes.md),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "Description",
                      style: context.txtTheme.headlineMedium?.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text("Review", style: TextStyle(color: AppColors.primaryColor)),
                    ),
                  ],
                ),
                const Divider(color: AppColors.primaryColor, thickness: 2),
                Text(profile.description),

                const SizedBox(height: 100),
              ],
            ),
          );
        }),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildContactIcons(List<String> access) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        if (access.contains('Call')) const Icon(Icons.call, size: 26),
        const SizedBox(width: 12),
        if (access.contains('Email')) const Icon(Icons.email, size: 26),
        const SizedBox(width: 12),
        if (access.contains('Messaging')) const Icon(CupertinoIcons.chat_bubble_fill, size: 26),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        spacing: 8,
        children: <Widget>[
          Icon(icon, size: 18),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildStaticServiceDropdown(String serviceName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryColor, width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_outline, color: AppColors.primaryColor, size: 20),
          const SizedBox(width: 12),
          Text(
            serviceName,
            style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textBlackColor),
          ),
          const Spacer(),
          const Icon(Icons.keyboard_arrow_down, color: AppColors.primaryColor),
        ],
      ),
    );
  }

  Widget _buildProviderCard(BuildContext context, SingleServiceModel service) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.providerDetailsPage),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: AppSizes.md),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryColor),
          color: AppColors.primaryColor.withOpacity(0.1),
        ),
        child: Row(
          spacing: AppSizes.md,
          children: <Widget>[
            CustomCachedImage(
              imageUrl: service.profileDetails.image.startsWith('http')
                  ? service.profileDetails.image
                  : "${AppUrl.imageBaseUrl}/${service.profileDetails.image}",
              height: 70,
              width: 70,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(service.author.name, style: context.txtTheme.labelLarge),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16),
                      const SizedBox(width: 4),
                      Text(service.profileDetails.region),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.primaryColor, size: 16),
                      const SizedBox(width: 4),
                      Text("${service.profileDetails.averageRating} Ratings"),
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

  Widget _buildBookingButton(BuildContext context, SingleServiceModel? service) {
    return SizedBox(
      width: context.screenWidth * 0.9,
      height: 50,
      child: ReusableButton(
        onTap: () {
          if (service == null) return;

          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => FractionallySizedBox(
              heightFactor: 0.9,
              child: BookingBottomSheet(
                service: service,
                dateTEController: _dateTEController,
                timeController: timeController,
                additionalNoteTEController: _additionalNoteTEController,
                preSelectedServiceId: service.id,
                preSelectedDate: DateTime.now(),
                onSubmitSuccess: () {
                  Get.back(); // Close bottom sheet
                  Get.snackbar(
                    'Success',
                    'Booking submitted successfully!',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                },
              ),
            ),
          );
        },
        label: "Book A Slot",
      ),
    );
  }

}

