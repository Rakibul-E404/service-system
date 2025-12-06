/**

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
import '../../../core/utils/api/app_url.dart';
import '../../../core/utils/token_service/token_storage_service.dart';
import '../../../provider_model.dart';
import '../controllers/home_service_details_controller.dart';
import '../widget/inquiry_bottom_sheet.dart';
import '../widget/one_row_calander.dart';
import '../widget/time_selection_widget.dart';
import '../../favorite/controllers/favorite_controller.dart';

class HomeServiceDetailsPage extends GetView<HomeServiceDetailsController> {
  HomeServiceDetailsPage({super.key}) {
    // Initialize controller as permanent to maintain state
    Get.put(HomeServiceDetailsController(), permanent: true);
  }

  final TextEditingController _serviceNameTEController = TextEditingController();
  final TextEditingController _locationTEController = TextEditingController();
  final TextEditingController _additionalNoteTEController = TextEditingController();
  final TextEditingController _dateTEController = TextEditingController();
  final TimeController timeController = Get.put(TimeController());
  final FavoriteController favoriteController = Get.find<FavoriteController>();
  final SharedPrefService sharedPrefService = SharedPrefService();

  final GlobalKey<InquiryBottomSheetState> inquirySheetKey = GlobalKey<InquiryBottomSheetState>();

  // Helper method to construct full image URL
  String _getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';

    // If already a full URL
    if (imagePath.startsWith('http')) return imagePath;

    // Remove 'public/' prefix if present
    String cleanPath = imagePath;
    if (cleanPath.startsWith('public/')) {
      cleanPath = cleanPath.substring(7);
    }

    // Construct full URL
    final fullUrl = '${AppUrl.imageBaseUrl}/$cleanPath';
    debugPrint('🖼️ Image Path: $imagePath -> Full URL: $fullUrl');

    return fullUrl;
  }

  // Method to check if user is logged in and show login popup if not
  Future<bool> _checkLoginAndShowPopup({String action = 'perform this action'}) async {
    bool isLoggedIn = await sharedPrefService.isLoggedIn();
    if (!isLoggedIn) {
      _showLoginRequiredPopup(action);
      return false;
    }
    return true;
  }

  // Show login required popup
  void _showLoginRequiredPopup(String action) {
    Get.dialog(
      AlertDialog(
        title: const Text('Login Required'),
        content: Text('Please login first to $action.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close the dialog
              // Get.toNamed(AppRoutes.loginPage); // Navigate to login page
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
            ),
            child: const Text(
              'Login',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: context.screenWidth * 0.9,
        height: 50,
        child: ReusableButton(
          onTap: () async {
            // Check if user is logged in
            bool isLoggedIn = await _checkLoginAndShowPopup(action: 'book a service slot');
            if (!isLoggedIn) {
              return;
            }

            final DateTime selectedDate = controller.dateTimePick.value;
            final DateTime selectedDateTime = timeController.selectedTime.value;
            final String selectedTimeString = '${selectedDateTime.hour}:${selectedDateTime.minute.toString().padLeft(2, '0')}';

            debugPrint('📅 Selected Date: $selectedDate');
            debugPrint('⏰ Selected Time: $selectedTimeString');
            debugPrint('🎯 Service ID: ${controller.serviceId}');

            CustomModalBottomSheet.show(
              title: 'Quote',
              height: context.screenHeight,
              context: context,
              buttonText: 'Send',
              onButtonPressed: () {
                debugPrint('🔘 Send button pressed');
                inquirySheetKey.currentState?.submitInquiry(
                  serviceId: controller.serviceId,
                  selectedDate: selectedDate,
                  selectedTime: selectedTimeString,
                );
              },
              child: InquiryBottomSheet(
                key: inquirySheetKey,
                isFromHomeScreen: false,
                serviceNameTEController: _serviceNameTEController,
                dateTEController: _dateTEController,
                timeController: timeController,
                locationTEController: _locationTEController,
                additionalNoteTEController: _additionalNoteTEController,
                preSelectedServiceId: controller.serviceId,
                preSelectedDate: selectedDate,
                preSelectedTime: selectedTimeString,
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
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(CupertinoIcons.back),
                  ),
                  Obx(() {
                    final bool isFavorited = favoriteController.isFavorited(controller.serviceId);
                    final bool isLoadingFav = favoriteController.isFavoriteLoading(controller.serviceId);

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: isLoadingFav
                            ? null
                            : () async {
                          if (controller.serviceId.isEmpty) {
                            Get.snackbar(
                              'Error',
                              'Service ID not found',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                            return;
                          }

                          // Check if user is logged in for favorite action
                          bool isLoggedIn = await _checkLoginAndShowPopup(action: 'add to favorites');
                          if (!isLoggedIn) {
                            return;
                          }

                          favoriteController.toggleFavorite(controller.serviceId);
                        },
                        icon: isLoadingFav
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryColor,
                            ),
                          ),
                        )
                            : Icon(
                          isFavorited
                              ? CupertinoIcons.heart_fill
                              : CupertinoIcons.heart,
                          color: isFavorited
                              ? Colors.red
                              : AppColors.textBlackColor,
                          size: 24,
                        ),
                      ),
                    );
                  }),
                ],
              ),

              // Service Image
              const SizedBox(height: AppSizes.md),
              Obx(() => ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: controller.serviceImage.isNotEmpty
                    ? CustomCachedImage(
                  imageUrl: controller.serviceImage,
                  width: context.screenWidth,
                  height: context.screenHeight * 0.4,
                  fit: BoxFit.cover,
                )
                    : Container(
                  width: context.screenWidth,
                  height: context.screenHeight * 0.4,
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 60,
                    color: Colors.grey,
                  ),
                ),
              )),

              // Service Details
              const SizedBox(height: AppSizes.md),
              Obx(() => Text(
                controller.serviceTitle,
                style: context.txtTheme.titleLarge,
              )),
              const SizedBox(height: AppSizes.sm),
              Obx(() => Text(controller.serviceSubtitle)),
              const SizedBox(height: AppSizes.xs),
              Obx(() => Row(
                children: <Widget>[
                  const Icon(Icons.location_on_outlined, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(controller.serviceLocation)),
                ],
              )),
              const SizedBox(height: AppSizes.xs),
              Obx(() => Row(
                children: <Widget>[
                  const Icon(Icons.star, size: 18, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(controller.serviceRating.toStringAsFixed(1)),
                ],
              )),

              // Date & Time
              const SizedBox(height: AppSizes.md),
              Text('Available Date & Time', style: context.txtTheme.titleLarge),
              const SizedBox(height: AppSizes.sm),
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
                  timeController.updateSelectedTime(time);
                },
              ).centered,

              // Service Provider
              const SizedBox(height: AppSizes.lg),
              Text('Service Provider', style: context.txtTheme.titleLarge),
              const SizedBox(height: AppSizes.sm),

              Obx(() {
                final bool isLoading = controller.isLoadingProvider.value;
                final String errorMsg = controller.providerErrorMessage.value;
                final ProviderModel? provider = controller.providerData.value;

                debugPrint('🔍 Provider State - Loading: $isLoading, Error: $errorMsg, HasData: ${provider != null}');
                if (provider != null) {
                  debugPrint('👤 Provider: ${provider.name}, Image: ${provider.image}');
                }

                if (isLoading) {
                  return _buildProviderLoadingCard();
                }

                if (provider != null) {
                  return _buildProviderSuccessCard(provider, context);
                }

                if (errorMsg.isNotEmpty) {
                  return _buildProviderErrorCard(errorMsg, controller.authorId);
                }

                return _buildNoProviderCard();
              }),

              // About Section
              const SizedBox(height: AppSizes.md),
              Text(
                "About",
                style: context.txtTheme.headlineMedium?.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
              const Divider(color: AppColors.primaryColor, thickness: 2),
              const SizedBox(height: AppSizes.sm),

              Obx(() {
                final provider = controller.providerData.value;
                final isLoading = controller.isLoadingProvider.value;

                if (isLoading) {
                  return _buildAboutLoading();
                }

                if (provider != null && provider.description.isNotEmpty) {
                  return _buildProviderAboutSection(provider);
                }

                return _buildFallbackAboutSection(controller.serviceSubtitle);
              }),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProviderLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryColor),
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildProviderErrorCard(String errorMsg, String authorId) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red),
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
            ),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderSuccessCard(ProviderModel provider, BuildContext context) {
    // Get full provider image URL
    final String providerImageUrl = _getFullImageUrl(provider.image);

    debugPrint('🖼️ Displaying Provider Image: $providerImageUrl');

    return GestureDetector(
      onTap: () async {
        // Check if user is logged in before navigating to provider details
        bool isLoggedIn = await _checkLoginAndShowPopup(action: 'view provider details');
        if (!isLoggedIn) {
          return;
        }

        Get.toNamed(
          AppRoutes.providerDetailsPage,
          arguments: {
            'provider': provider.toJson(),
            'authId': provider.id,
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryColor),
          color: AppColors.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: <Widget>[
            // Provider Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: providerImageUrl.isNotEmpty
                    ? CustomCachedImage(
                  imageUrl: providerImageUrl,
                  fit: BoxFit.cover,
                )
                    : const Icon(
                  Icons.person_outline,
                  size: 40,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Provider Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          provider.name,
                          style: const TextStyle(
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
                  const SizedBox(height: 6),
                  Row(
                    children: <Widget>[
                      const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          provider.location,
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        provider.rating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${provider.ratingCount})',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: provider.isAvailable ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: provider.isAvailable ? Colors.green : Colors.red,
                      ),
                    ),
                    child: Text(
                      provider.isAvailable ? 'Available' : 'Unavailable',
                      style: TextStyle(
                        fontSize: 10,
                        color: provider.isAvailable ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
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
      padding: const EdgeInsets.all(16),
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
        Text(
          provider.description,
          style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
        ),
        const SizedBox(height: 16),
        const Text(
          'Contact Information:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        if (provider.phone.isNotEmpty) ...[
          Row(
            children: [
              const Icon(Icons.phone, size: 16, color: AppColors.primaryColor),
              const SizedBox(width: 8),
              Text(provider.phone, style: const TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
        ],
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
        if (provider.isProfileComplete) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.verified, size: 16, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'Verified Profile',
                style: TextStyle(fontSize: 14, color: Colors.blue, fontWeight: FontWeight.w500),
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
          : "Professional service provider dedicated to delivering quality work.",
      style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
    );
  }
}*/












///
///
///
///
///
///
/// todo:::: merging all data into this page
///
///
///
///
///
///
///












/**
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import 'package:manx_mate/core/extensions/widget_extensions.dart';
import '../../../core/common/components/custom_network_image.dart';
import '../../../core/common/widgets/reusable_button.dart';
import '../../../core/common/widgets/time_picker_widget.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/utils/api/app_url.dart';
import '../../../core/utils/token_service/token_storage_service.dart';
import '../../../provider_model.dart';
import '../controllers/home_service_details_controller.dart';
import '../widget/inquiry_bottom_sheet.dart';
import '../widget/one_row_calander.dart';
import '../widget/time_selection_widget.dart';
import '../../favorite/controllers/favorite_controller.dart';
import '../../message/controllers/message_controller.dart';

class HomeServiceDetailsPage extends GetView<HomeServiceDetailsController> {
  HomeServiceDetailsPage({super.key}) {
    Get.put(HomeServiceDetailsController(), permanent: true);
  }

  final TextEditingController _serviceNameTEController = TextEditingController();
  final TextEditingController _locationTEController = TextEditingController();
  final TextEditingController _additionalNoteTEController = TextEditingController();
  final TextEditingController _dateTEController = TextEditingController();
  final TimeController timeController = Get.put(TimeController());
  final FavoriteController favoriteController = Get.find<FavoriteController>();
  final MessageController messageController = Get.find<MessageController>();
  final SharedPrefService sharedPrefService = SharedPrefService();

  final GlobalKey<InquiryBottomSheetState> inquirySheetKey = GlobalKey<InquiryBottomSheetState>();

  String _getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    if (imagePath.startsWith('http')) return imagePath;
    String cleanPath = imagePath.startsWith('public/') ? imagePath.substring(7) : imagePath;
    return '${AppUrl.imageBaseUrl}/$cleanPath';
  }

  Future<bool> _checkLoginAndShowPopup({String action = 'perform this action'}) async {
    bool isLoggedIn = await sharedPrefService.isLoggedIn();
    if (!isLoggedIn) {
      _showLoginRequiredPopup(action);
      return false;
    }
    return true;
  }

  void _showLoginRequiredPopup(String action) {
    Get.dialog(
      AlertDialog(
        title: const Text('Login Required'),
        content: Text('Please login first to $action.'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
            child: const Text('Login', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _handleMessageButton(ProviderModel provider) {
    String receiverId = provider.author?.isNotEmpty == true ? provider.author! : provider.id;
    messageController.createConversationAndNavigate(
      receiverId: receiverId,
      receiverName: provider.name,
      receiverAvatar: _getFullImageUrl(provider.image),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String title, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Get.textTheme.bodySmall?.copyWith(
                  color: AppColors.textBlackColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textBlackColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showBookingModal(BuildContext context) {
    final DateTime selectedDate = controller.dateTimePick.value;
    final DateTime selectedDateTime = timeController.selectedTime.value;
    final String selectedTimeString =
        '${selectedDateTime.hour}:${selectedDateTime.minute.toString().padLeft(2, '0')}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Modal Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Book Service',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textBlackColor,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Date Selection
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.md,
                              vertical: AppSizes.lg,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Select Date',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textBlackColor,
                                  ),
                                ),
                                const SizedBox(height: AppSizes.sm),
                                OneRowCalendar(
                                  selectedDate: selectedDate,
                                  onDateSelected: (DateTime time) {
                                    setState(() {
                                      controller.dateTimePick.value = time;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),

                          // Time Selection
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Select Time',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textBlackColor,
                                  ),
                                ),
                                const SizedBox(height: AppSizes.sm),
                                TimeSelector(
                                  initialTime: '10am',
                                  selectedColor: AppColors.primaryColor,
                                  selectedTextColor: AppColors.textBlackColor,
                                  onTimeSelected: (String time) {
                                    setState(() {
                                      timeController.updateSelectedTime(time);
                                    });
                                  },
                                ).centered,
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSizes.lg),

                          // Divider
                          Container(
                            height: 8,
                            color: Colors.grey[100],
                          ),
                          const SizedBox(height: AppSizes.lg),

                          // Other Information (Inquiry Form)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                            child: InquiryBottomSheet(
                              key: inquirySheetKey,
                              isFromHomeScreen: false,
                              serviceNameTEController: _serviceNameTEController,
                              dateTEController: _dateTEController,
                              timeController: timeController,
                              locationTEController: _locationTEController,
                              additionalNoteTEController: _additionalNoteTEController,
                              preSelectedServiceId: controller.serviceId,
                              preSelectedDate: selectedDate,
                              preSelectedTime: selectedTimeString,
                            ),
                          ),
                          const SizedBox(height: AppSizes.xl),
                        ],
                      ),
                    ),
                  ),

                  // Continue Button
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: AppSizes.md,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Colors.grey[300]!)),
                    ),
                    child: ReusableButton(
                      onTap: () {
                        // Handle booking submission
                        inquirySheetKey.currentState?.submitInquiry(
                          serviceId: controller.serviceId,
                          selectedDate: selectedDate,
                          selectedTime: selectedTimeString,
                        );
                      },
                      label: "Continue Booking",
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: context.screenWidth * 0.9,
        height: 50,
        child: ReusableButton(
          onTap: () async {
            bool isLoggedIn = await _checkLoginAndShowPopup(action: 'book a service slot');
            if (!isLoggedIn) return;
            _showBookingModal(context);
          },
          label: "Book A Slot",
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          final bool isLoading = controller.isLoadingProvider.value;
          final String errorMsg = controller.providerErrorMessage.value;
          final ProviderModel? provider = controller.providerData.value;

          return CustomScrollView(
            slivers: [
              /// ================= HEADER =================
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(onPressed: () => Get.back(), icon: const Icon(CupertinoIcons.back)),
                      Obx(() {
                        final bool isFavorited = favoriteController.isFavorited(controller.serviceId);
                        final bool isLoadingFav = favoriteController.isFavoriteLoading(controller.serviceId);
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: isLoadingFav
                                ? null
                                : () async {
                              if (controller.serviceId.isEmpty) return;
                              bool isLoggedIn =
                              await _checkLoginAndShowPopup(action: 'add to favorites');
                              if (!isLoggedIn) return;
                              favoriteController.toggleFavorite(controller.serviceId);
                            },
                            icon: isLoadingFav
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                              ),
                            )
                                : Icon(
                              isFavorited ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                              color: isFavorited ? Colors.red : AppColors.textBlackColor,
                              size: 24,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              /// ================= SERVICE IMAGE =================
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSizes.sm),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: controller.serviceImage.isNotEmpty
                            ? CustomCachedImage(
                          imageUrl: controller.serviceImage,
                          width: context.screenWidth,
                          height: context.screenHeight * 0.4,
                          fit: BoxFit.cover,
                        )
                            : Container(
                          width: context.screenWidth,
                          height: context.screenHeight * 0.4,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported,
                              size: 60, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                    ],
                  ),
                ),
              ),

              /// ================= PROVIDER DETAILS =================
              if (isLoading)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.md),
                      child: const CircularProgressIndicator(),
                    ),
                  ),
                )
              else if (errorMsg.isNotEmpty && provider == null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.md),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 40),
                        const SizedBox(height: 8),
                        Text(errorMsg,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            if (controller.authorId.isNotEmpty) {
                              controller.retryFetchProvider(controller.authorId);
                            }
                          },
                          style:
                          ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
                          child: const Text('Retry',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                )
              else if (provider != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenHorizontal),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// 1. TOP ROW: Name + Call + Message
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      provider.name,
                                      style: context.txtTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textBlackColor,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (provider.rating > 0)
                                      Row(
                                        children: [
                                          const Icon(Icons.star, color: Colors.amber, size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${provider.rating.toStringAsFixed(1)}',
                                            style: context.txtTheme.bodyMedium?.copyWith(
                                              color: AppColors.textBlackColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),

                              // Call and Message buttons
                              Row(
                                children: [
                                  // Call Button
                                  if (provider.phone.isNotEmpty)
                                    GestureDetector(
                                      onTap: () {
                                        // Handle call
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        child: const Icon(
                                          Icons.phone,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),

                                  if (provider.phone.isNotEmpty) const SizedBox(width: 8),

                                  // Message Button
                                  GestureDetector(
                                    onTap: () async {
                                      bool isLoggedIn = await _checkLoginAndShowPopup(
                                          action: 'send a message');
                                      if (!isLoggedIn) return;
                                      _handleMessageButton(provider);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryColor,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: const Icon(
                                        CupertinoIcons.chat_bubble_text,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.lg),

                          /// 2. DESCRIPTION
                          if (provider.description.isNotEmpty) ...[
                            Text('Description', style: context.txtTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textBlackColor,
                            )),
                            const SizedBox(height: AppSizes.sm),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(AppSizes.md),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundColor,
                                borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                              ),
                              child: Text(
                                provider.description,
                                style: context.txtTheme.bodyMedium?.copyWith(
                                  color: AppColors.textBlackColor,
                                  height: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSizes.lg),
                          ],

                          /// 3. LOCATION
                          Container(
                            padding: const EdgeInsets.all(AppSizes.md),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundColor,
                              borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  color: AppColors.primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Location',
                                        style: Get.textTheme.bodySmall?.copyWith(
                                          color: AppColors.textBlackColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        provider.location,
                                        style: Get.textTheme.bodyMedium?.copyWith(
                                          color: AppColors.textBlackColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSizes.lg),

                          /// 4. REVIEWS
                          Text('Reviews', style: context.txtTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textBlackColor,
                          )),
                          const SizedBox(height: AppSizes.sm),
                          Container(
                            padding: const EdgeInsets.all(AppSizes.md),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundColor,
                              borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      provider.rating > 0
                                          ? '${provider.rating.toStringAsFixed(1)} out of 5'
                                          : 'No reviews yet',
                                      style: context.txtTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textBlackColor,
                                      ),
                                    ),
                                  ],
                                ),
                                if (provider.ratingCount > 0) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Based on ${provider.ratingCount} review${provider.ratingCount > 1 ? 's' : ''}',
                                    style: context.txtTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSizes.lg),


                          /// Debug Info
                          if (kDebugMode && provider.author?.isNotEmpty == true)
                            Container(
                              padding: const EdgeInsets.all(AppSizes.md),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.bug_report, size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 8),
                                      Text('Debug Info',
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          )),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Profile ID: ${provider.id}',
                                      style: TextStyle(
                                          color: Colors.grey[600], fontSize: 11, fontFamily: 'monospace')),
                                  const SizedBox(height: 4),
                                  Text('Author ID: ${provider.author}',
                                      style: TextStyle(
                                        color: Colors.blue[700],
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'monospace',
                                      )),
                                ],
                              ),
                            ),

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.md),
                        child: Text(
                          'No provider information available',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
            ],
          );
        }),
      ),
    );
  }
}*/






import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import 'package:manx_mate/core/extensions/widget_extensions.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/common/components/custom_network_image.dart';
import '../../../core/common/widgets/reusable_button.dart';
import '../../../core/common/widgets/time_picker_widget.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/utils/api/app_url.dart';
import '../../../core/utils/token_service/token_storage_service.dart';
import '../../../provider_model.dart';
import '../controllers/home_service_details_controller.dart';
import '../widget/inquiry_bottom_sheet.dart';
import '../widget/one_row_calander.dart';
import '../widget/time_selection_widget.dart';
import '../../favorite/controllers/favorite_controller.dart';
import '../../message/controllers/message_controller.dart';

class HomeServiceDetailsPage extends GetView<HomeServiceDetailsController> {
  HomeServiceDetailsPage({super.key}) {
    Get.put(HomeServiceDetailsController(), permanent: true);
  }

  final TextEditingController _serviceNameTEController = TextEditingController();
  final TextEditingController _locationTEController = TextEditingController();
  final TextEditingController _additionalNoteTEController = TextEditingController();
  final TextEditingController _dateTEController = TextEditingController();
  final TimeController timeController = Get.put(TimeController());
  final FavoriteController favoriteController = Get.find<FavoriteController>();
  final MessageController messageController = Get.find<MessageController>();
  final SharedPrefService sharedPrefService = SharedPrefService();

  final GlobalKey<InquiryBottomSheetState> inquirySheetKey = GlobalKey<InquiryBottomSheetState>();

  String _getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    if (imagePath.startsWith('http')) return imagePath;
    String cleanPath = imagePath.startsWith('public/') ? imagePath.substring(7) : imagePath;
    return '${AppUrl.imageBaseUrl}/$cleanPath';
  }

  Future<bool> _checkLoginAndShowPopup({String action = 'perform this action'}) async {
    bool isLoggedIn = await sharedPrefService.isLoggedIn();
    if (!isLoggedIn) {
      _showLoginRequiredPopup(action);
      return false;
    }
    return true;
  }

  void _showLoginRequiredPopup(String action) {
    Get.dialog(
      AlertDialog(
        title: const Text('Login Required'),
        content: Text('Please login first to $action.'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
            child: const Text('Login', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _handleMessageButton(ProviderModel provider) {
    String receiverId = provider.author?.isNotEmpty == true ? provider.author! : provider.id;
    messageController.createConversationAndNavigate(
      receiverId: receiverId,
      receiverName: provider.name,
      receiverAvatar: _getFullImageUrl(provider.image),
    );
  }

  // void _showContactInfoDialog(ProviderModel provider) {
  //   Get.dialog(
  //     AlertDialog(
  //       title: const Text('Contact Information'),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           if (provider.phone.isNotEmpty) ...[
  //             const Text('Phone Number:', style: TextStyle(fontWeight: FontWeight.bold)),
  //             const SizedBox(height: 4),
  //             Row(
  //               children: [
  //                 const Icon(Icons.phone, color: Colors.green, size: 18),
  //                 const SizedBox(width: 8),
  //                 SelectableText(
  //                   provider.phone,
  //                   style: const TextStyle(fontSize: 16),
  //                 ),
  //               ],
  //             ),
  //             const SizedBox(height: 16),
  //           ],
  //           if (provider.email?.isNotEmpty == true) ...[
  //             const Text('Email:', style: TextStyle(fontWeight: FontWeight.bold)),
  //             const SizedBox(height: 4),
  //             Row(
  //               children: [
  //                 const Icon(Icons.email, color: Colors.blue, size: 18),
  //                 const SizedBox(width: 8),
  //                 SelectableText(
  //                   provider.email!,
  //                   style: const TextStyle(fontSize: 16),
  //                 ),
  //               ],
  //             ),
  //           ],
  //           if (provider.phone.isEmpty && (provider.email?.isEmpty ?? true)) ...[
  //             const Text('No contact information available'),
  //           ],
  //         ],
  //       ),
  //       actions: [
  //         // TextButton(
  //         //   onPressed: () => Get.back(),
  //         //   child: const Text('Close'),
  //         // ),
  //         if (provider.phone.isNotEmpty)
  //           ElevatedButton(
  //             onPressed: () {
  //               Get.back();
  //               // Launch phone call
  //               // You can use url_launcher package here
  //               // launchUrl(Uri.parse('tel:${provider.phone}'));
  //             },
  //             style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
  //             child: const Row(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Icon(Icons.phone, color: Colors.white, size: 16),
  //                 SizedBox(width: 4),
  //                 Text('Call', style: TextStyle(color: Colors.white)),
  //               ],
  //             ),
  //           ),
  //       ],
  //     ),
  //   );
  // }


  void _showContactInfoDialog(ProviderModel provider) {
    Get.dialog(
      AlertDialog(
        title: const Text('Contact Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (provider.phone.isNotEmpty) ...[
              const Text('Phone Number:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.phone, color: Colors.green, size: 18),
                  const SizedBox(width: 8),
                  SelectableText(
                    provider.phone,
                    style: const TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: provider.phone));
                      _showSnackBar('Phone number copied to clipboard');
                    },
                    icon: const Icon(Icons.copy, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            if (provider.email != null && provider.email!.isNotEmpty) ...[
              const Text('Email:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.email, color: Colors.blue, size: 18),
                  const SizedBox(width: 8),
                  SelectableText(
                    provider.email!,
                    style: const TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: provider.email!));
                      _showSnackBar('Email copied to clipboard');
                    },
                    icon: const Icon(Icons.copy, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
            if (provider.phone.isEmpty && (provider.email == null || provider.email!.isEmpty)) ...[
              const Text('No contact information available'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
          if (provider.phone.isNotEmpty)
            ElevatedButton(
              onPressed: () async {
                Get.back();
                await _makePhoneCall(provider.phone);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.phone, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text('Call', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
        ],
      ),
    );
  }

// Helper method to show snackbar safely
  void _showSnackBar(String message) {
    if (Get.context != null) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

// Robust phone call method with fallback
  Future<void> _makePhoneCall(String phoneNumber) async {
    try {
      // Clean the phone number (remove any non-digit characters except +)
      String cleanPhoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      // Create the phone URI
      final Uri phoneUri = Uri.parse('tel:$cleanPhoneNumber');

      // Try to launch with error handling
      try {
        if (await canLaunchUrl(phoneUri)) {
          await launchUrl(phoneUri);
        } else {
          _showCallErrorDialog(phoneNumber);
        }
      } catch (e) {
        // If canLaunchUrl fails, try direct launch as fallback
        debugPrint('canLaunchUrl failed: $e');
        try {
          await launchUrl(phoneUri);
        } catch (launchError) {
          debugPrint('Direct launch also failed: $launchError');
          _showCallErrorDialog(phoneNumber);
        }
      }
    } catch (e) {
      debugPrint('Error making phone call: $e');
      _showCallErrorDialog(phoneNumber);
    }
  }

  void _showCallErrorDialog(String phoneNumber) {
    Get.dialog(
      AlertDialog(
        title: const Text('Call Not Available'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Unable to open phone dialer.'),
            const SizedBox(height: 12),
            const Text('Phone number:'),
            Text(
              phoneNumber,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            const Text('You can manually dial this number.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: phoneNumber));
              Get.back();
              _showSnackBar('Phone number copied to clipboard');
            },
            child: const Text('Copy Number'),
          ),
          ElevatedButton(
            onPressed: Get.back,
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }



  Widget _buildInfoRow({required IconData icon, required String title, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Get.textTheme.bodySmall?.copyWith(
                  color: AppColors.textBlackColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textBlackColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showBookingModal(BuildContext context) {
    final DateTime selectedDate = controller.dateTimePick.value;
    final DateTime selectedDateTime = timeController.selectedTime.value;
    final String selectedTimeString =
        '${selectedDateTime.hour}:${selectedDateTime.minute.toString().padLeft(2, '0')}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Modal Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Book Service',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textBlackColor,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Date Selection
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.md,
                              vertical: AppSizes.lg,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Select Date',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textBlackColor,
                                  ),
                                ),
                                const SizedBox(height: AppSizes.sm),
                                OneRowCalendar(
                                  selectedDate: selectedDate,
                                  onDateSelected: (DateTime time) {
                                    setState(() {
                                      controller.dateTimePick.value = time;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),

                          // Time Selection
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Select Time',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textBlackColor,
                                  ),
                                ),
                                const SizedBox(height: AppSizes.sm),
                                TimeSelector(
                                  initialTime: '10am',
                                  selectedColor: AppColors.primaryColor,
                                  selectedTextColor: AppColors.textBlackColor,
                                  onTimeSelected: (String time) {
                                    setState(() {
                                      timeController.updateSelectedTime(time);
                                    });
                                  },
                                ).centered,
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSizes.lg),

                          // Divider
                          Container(
                            height: 8,
                            color: Colors.grey[100],
                          ),
                          const SizedBox(height: AppSizes.lg),

                          // Other Information (Inquiry Form)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                            child: InquiryBottomSheet(
                              key: inquirySheetKey,
                              isFromHomeScreen: false,
                              serviceNameTEController: _serviceNameTEController,
                              dateTEController: _dateTEController,
                              timeController: timeController,
                              locationTEController: _locationTEController,
                              additionalNoteTEController: _additionalNoteTEController,
                              preSelectedServiceId: controller.serviceId,
                              preSelectedDate: selectedDate,
                              preSelectedTime: selectedTimeString,
                            ),
                          ),
                          const SizedBox(height: AppSizes.xl),
                        ],
                      ),
                    ),
                  ),

                  // Continue Button
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: AppSizes.md,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Colors.grey[300]!)),
                    ),
                    child: ReusableButton(
                      onTap: () {
                        // Handle booking submission
                        inquirySheetKey.currentState?.submitInquiry(
                          serviceId: controller.serviceId,
                          selectedDate: selectedDate,
                          selectedTime: selectedTimeString,
                        );
                      },
                      label: "Continue Booking",
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: context.screenWidth * 0.9,
        height: 50,
        child: ReusableButton(
          onTap: () async {
            bool isLoggedIn = await _checkLoginAndShowPopup(action: 'book a service slot');
            if (!isLoggedIn) return;
            _showBookingModal(context);
          },
          label: "Book A Slot",
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          final bool isLoading = controller.isLoadingProvider.value;
          final String errorMsg = controller.providerErrorMessage.value;
          final ProviderModel? provider = controller.providerData.value;

          return CustomScrollView(
            slivers: [
              /// ================= HEADER =================
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(onPressed: () => Get.back(), icon: const Icon(CupertinoIcons.back)),
                      Obx(() {
                        final bool isFavorited = favoriteController.isFavorited(controller.serviceId);
                        final bool isLoadingFav = favoriteController.isFavoriteLoading(controller.serviceId);
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: isLoadingFav
                                ? null
                                : () async {
                              if (controller.serviceId.isEmpty) return;
                              bool isLoggedIn =
                              await _checkLoginAndShowPopup(action: 'add to favorites');
                              if (!isLoggedIn) return;
                              favoriteController.toggleFavorite(controller.serviceId);
                            },
                            icon: isLoadingFav
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                              ),
                            )
                                : Icon(
                              isFavorited ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                              color: isFavorited ? Colors.red : AppColors.textBlackColor,
                              size: 24,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              /// ================= SERVICE IMAGE =================
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSizes.sm),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: controller.serviceImage.isNotEmpty
                            ? CustomCachedImage(
                          imageUrl: controller.serviceImage,
                          width: context.screenWidth,
                          height: context.screenHeight * 0.4,
                          fit: BoxFit.cover,
                        )
                            : Container(
                          width: context.screenWidth,
                          height: context.screenHeight * 0.4,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported,
                              size: 60, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                    ],
                  ),
                ),
              ),

              /// ================= PROVIDER DETAILS =================
              if (isLoading)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.md),
                      child: const CircularProgressIndicator(),
                    ),
                  ),
                )
              else if (errorMsg.isNotEmpty && provider == null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.md),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 40),
                        const SizedBox(height: 8),
                        Text(errorMsg,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            if (controller.authorId.isNotEmpty) {
                              controller.retryFetchProvider(controller.authorId);
                            }
                          },
                          style:
                          ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
                          child: const Text('Retry',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                )
              else if (provider != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenHorizontal),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// 1. TOP ROW: Name + Call + Message
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      provider.name,
                                      style: context.txtTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textBlackColor,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (provider.rating > 0)
                                      Row(
                                        children: [
                                          const Icon(Icons.star, color: Colors.amber, size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${provider.rating.toStringAsFixed(1)}',
                                            style: context.txtTheme.bodyMedium?.copyWith(
                                              color: AppColors.textBlackColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),

                              // Call and Message buttons
                              Row(
                                children: [
                                  // Call Button
                                  if (provider.phone.isNotEmpty)
                                    GestureDetector(
                                      onTap: () => _showContactInfoDialog(provider),
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        child: const Icon(
                                          Icons.phone,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),

                                  if (provider.phone.isNotEmpty) const SizedBox(width: 8),

                                  // Message Button
                                  GestureDetector(
                                    onTap: () async {
                                      bool isLoggedIn = await _checkLoginAndShowPopup(
                                          action: 'send a message');
                                      if (!isLoggedIn) return;
                                      _handleMessageButton(provider);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryColor,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: const Icon(
                                        CupertinoIcons.chat_bubble_text,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.lg),

                          /// 2. DESCRIPTION
                          if (provider.description.isNotEmpty) ...[
                            Text('Description', style: context.txtTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textBlackColor,
                            )),
                            const SizedBox(height: AppSizes.sm),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(AppSizes.md),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundColor,
                                borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                              ),
                              child: Text(
                                provider.description,
                                style: context.txtTheme.bodyMedium?.copyWith(
                                  color: AppColors.textBlackColor,
                                  height: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSizes.lg),
                          ],

                          /// 3. LOCATION
                          Container(
                            padding: const EdgeInsets.all(AppSizes.md),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundColor,
                              borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  color: AppColors.primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Location',
                                        style: Get.textTheme.bodySmall?.copyWith(
                                          color: AppColors.textBlackColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        provider.location,
                                        style: Get.textTheme.bodyMedium?.copyWith(
                                          color: AppColors.textBlackColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSizes.lg),

                          /// 4. REVIEWS
                          Text('Reviews', style: context.txtTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textBlackColor,
                          )),
                          const SizedBox(height: AppSizes.sm),
                          Container(
                            padding: const EdgeInsets.all(AppSizes.md),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundColor,
                              borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      provider.rating > 0
                                          ? '${provider.rating.toStringAsFixed(1)} out of 5'
                                          : 'No reviews yet',
                                      style: context.txtTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textBlackColor,
                                      ),
                                    ),
                                  ],
                                ),
                                if (provider.ratingCount > 0) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Based on ${provider.ratingCount} review${provider.ratingCount > 1 ? 's' : ''}',
                                    style: context.txtTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSizes.lg),


                          /// Debug Info
                          if (kDebugMode && provider.author?.isNotEmpty == true)
                            Container(
                              padding: const EdgeInsets.all(AppSizes.md),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.bug_report, size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 8),
                                      Text('Debug Info',
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          )),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Profile ID: ${provider.id}',
                                      style: TextStyle(
                                          color: Colors.grey[600], fontSize: 11, fontFamily: 'monospace')),
                                  const SizedBox(height: 4),
                                  Text('Author ID: ${provider.author}',
                                      style: TextStyle(
                                        color: Colors.blue[700],
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'monospace',
                                      )),
                                ],
                              ),
                            ),

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.md),
                        child: Text(
                          'No provider information available',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
            ],
          );
        }),
      ),
    );
  }
}