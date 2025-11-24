
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
}