
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/features/favorite/screens/fav_model.dart';
import '../../../core/common/widgets/app_bottom_sheet.dart';
import '../../../core/common/widgets/time_picker_widget.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/common/components/custom_network_image.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/network/network_response.dart';
import '../../../core/utils/api/app_url.dart';
import '../../../core/utils/token_service/token_storage_service.dart';
import '../../booking/widgets/booking_card.dart';
import '../../home/controllers/home_top_bar_controller.dart';
import '../../home/widget/inquiry_bottom_sheet.dart';
import '../../home/widget/one_row_calander.dart';
import '../../home/widget/time_selection_widget.dart';
import '../controllers/favorite_controller.dart';
import 'package:manx_mate/features/auth/screens/profile_service.dart';

class FavoriteScreen extends GetView<FavoriteController> {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeTopBarController profileController = Get.put(HomeTopBarController());
    final ProfileService profileService = Get.find<ProfileService>();

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          // CHECK IF USER IS LOGGED IN
          if (!profileService.isLoggedIn.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(Icons.person_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Not Logged In',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please login to view your favorites',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Get.offAllNamed(AppRoutes.roleSelectionRoute);
                    },
                    child: const Text('Go to Login'),
                  ),
                ],
              ),
            );
          }

          // USER IS LOGGED IN - SHOW FAVORITES
          return RefreshIndicator(
            onRefresh: () async {
              await controller.refreshFavorites();
            },
            color: AppColors.primaryColor,
            child: _buildContent(context, profileController),
          );
        }),
      ),
    );
  }

  Widget _buildContent(BuildContext context, HomeTopBarController profileController) {
    // Fetch favorites when content is built (only once)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.favorites.isEmpty && !controller.isLoading.value) {
        controller.fetchFavorites();
      }
    });

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: <Widget>[
        // Top Bar with Profile and Notification
        SliverToBoxAdapter(
          child: Card(
            elevation: 2,
            color: AppColors.whiteColor,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  // Profile Image
                  Obx(() {
                    final String imageUrl = profileController.getImageUrl();
                    return CircleAvatar(
                      radius: 30,
                      backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                      child: imageUrl.isEmpty
                          ? const Icon(Icons.person, size: 50, color: Colors.grey)
                          : null,
                    );
                  }),
                  // Notification Button
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      border: Border.all(color: AppColors.primaryColor),
                      borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Get.toNamed(AppRoutes.notificationPage);
                      },
                      icon: const Icon(CupertinoIcons.bell, color: AppColors.primaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: AppSizes.md),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                child: Text('My Favorite', style: context.txtTheme.titleLarge),
              ),
              const SizedBox(height: AppSizes.md),
            ],
          ),
        ),

        // Favorites List
        Obx(() {
          if (controller.isLoading.value && controller.favorites.isEmpty) {
            return const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (controller.errorMessage.value.isNotEmpty && controller.favorites.isEmpty) {
            return SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.lg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        controller.errorMessage.value,
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => controller.refreshFavorites(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          if (controller.favorites.isEmpty) {
            return SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.lg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No favorites yet',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start adding services to your favorites\nto see them here',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return SliverList(
            delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                if (index == controller.favorites.length) {
                  // Show loading indicator at the bottom if loading more
                  if (controller.isLoading.value) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }

                final FavoriteModel favorite = controller.favorites[index];
                final ProviderService? service = favorite.providerService;

                if (service == null) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.screenHorizontal,
                    vertical: AppSizes.md,
                  ),
                  child: HorizontalServiceCard(
                    imageUrl: service.imageUrl,
                    title: service.title,
                    subtitle: service.subcategoryName,
                    description: service.location,
                    bookingId: favorite.id,
                    status: 'Favorite',
                    tabIndex: 3,
                    showStatus: false,
                    onTap: () {
                      // Show service details
                      final String serviceId = service.id;
                      if (serviceId.isNotEmpty) {
                        _showServiceDetails(context, serviceId);
                      }
                    },
                    onDelete: () async {
                      final bool? confirmDelete = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            title: Row(
                              children: <Widget>[
                                Icon(Icons.favorite_border, color: Colors.red[400]),
                                const SizedBox(width: 8),
                                const Text('Remove Favorite'),
                              ],
                            ),
                            content: const Text(
                              'Are you sure you want to remove this service from your favorites?',
                              style: TextStyle(fontSize: 16),
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                ),
                                child: const Text('Remove', style: TextStyle(fontSize: 16)),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmDelete == true) {
                        Get.dialog(
                          const Center(
                            child: CircularProgressIndicator(),
                          ),
                          barrierDismissible: false,
                        );

                        try {
                          // Get the favorite ID from the favorite object
                          final String favoriteId = favorite.id;

                          if (favoriteId.isEmpty) {
                            Get.back();
                            Get.snackbar(
                              'Error',
                              'Unable to remove favorite: Invalid favorite ID',
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            return;
                          }

                          debugPrint('🗑️ Deleting favorite with ID: $favoriteId');
                          debugPrint('🗑️ Service ID: ${service.id}');
                          debugPrint('🗑️ Service Title: ${service.title}');

                          // Call the removeFavorite method which uses AppUrl.deleteFavoriteUrl
                          final bool success = await controller.removeFavorite(favoriteId);

                          Get.back();

                          if (success) {
                            // The controller already updates the list in removeFavorite() method
                            // Refresh the UI
                            controller.favorites.refresh();

                            debugPrint('✅ Favorite deleted successfully');

                            Get.snackbar(
                              'Success',
                              'Service removed from favorites',
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                              duration: const Duration(seconds: 2),
                              icon: const Icon(Icons.check_circle, color: Colors.white),
                            );
                          } else {
                            debugPrint('❌ Delete failed');

                            Get.snackbar(
                              'Error',
                              'Failed to remove from favorites',
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                              icon: const Icon(Icons.error, color: Colors.white),
                            );
                          }
                        } catch (e) {
                          Get.back();

                          debugPrint('❌ Exception: $e');

                          Get.snackbar(
                            'Error',
                            'An error occurred: ${e.toString()}',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                            icon: const Icon(Icons.error, color: Colors.white),
                          );
                        }
                      }
                    },
                  ),
                );
              },
              childCount: controller.favorites.length + (controller.hasMoreData.value ? 1 : 0),
            ),
          );
        }),
      ],
    );
  }

  // Show service details in a bottom sheet
  void _showServiceDetails(BuildContext context, String serviceId) async {
    debugPrint('📦 Fetching service details for: $serviceId');

    // Show loading
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final NetworkCaller networkCaller = NetworkCaller();
      final SharedPrefService sharedPrefService = SharedPrefService();

      final String? accessToken = await sharedPrefService.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        Get.back();
        Get.snackbar(
          'Error',
          'Please login to view details',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Fetch service details
      final String serviceUrl = '${AppUrl.baseUrl}/service/single/$serviceId';
      final NetworkResponse serviceResponse = await networkCaller.getRequest(
        serviceUrl,
        headers: <String, String>{'Authorization': 'Bearer $accessToken'},
      );

      debugPrint('📥 Service Response: ${serviceResponse.jsonResponse}');

      if (!serviceResponse.isSuccess || serviceResponse.jsonResponse == null) {
        Get.back();
        Get.snackbar(
          'Error',
          'Failed to load service details',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final Map<String, dynamic>? serviceData = serviceResponse.jsonResponse!['data'] as Map<String, dynamic>?;
      if (serviceData == null) {
        Get.back();
        Get.snackbar(
          'Error',
          'Service not found',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Extract author ID
      String? authorId;
      final author = serviceData['author'];
      if (author is String) {
        authorId = author;
      } else if (author is Map<String, dynamic>) {
        authorId = author['_id']?.toString();
      }

      debugPrint('👤 Author ID: $authorId');

      // Fetch business profile
      Map<String, dynamic>? profileData;
      if (authorId != null && authorId.isNotEmpty) {
        final String profileUrl = '${AppUrl.baseUrl}/business_profile/$authorId';
        final NetworkResponse profileResponse = await networkCaller.getRequest(
          profileUrl,
          headers: <String, String>{'Authorization': 'Bearer $accessToken'},
        );

        debugPrint('📥 Profile Response: ${profileResponse.jsonResponse}');

        if (profileResponse.isSuccess && profileResponse.jsonResponse != null) {
          profileData = profileResponse.jsonResponse!['data'] as Map<String, dynamic>?;
        }
      }

      Get.back(); // Close loading

      // Show details in bottom sheet with transparent background
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withValues(alpha: 0.5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext context) => _buildServiceDetailsSheet(
          context,
          serviceData,
          profileData,
        ),
      );
    } catch (e) {
      Get.back();
      debugPrint('❌ Error: $e');
      Get.snackbar(
        'Error',
        'Failed to load details: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Build service details bottom sheet
  Widget _buildServiceDetailsSheet(
      BuildContext context,
      Map<String, dynamic> serviceData,
      Map<String, dynamic>? profileData,
      ) {
    // Controllers for booking
    final TextEditingController serviceNameTEController = TextEditingController();
    final TextEditingController locationTEController = TextEditingController();
    final TextEditingController additionalNoteTEController = TextEditingController();
    final TextEditingController dateTEController = TextEditingController();
    final TimeController timeController = Get.put(TimeController());
    final RxBool isBookingLoading = false.obs;

    // Date picker
    final Rx<DateTime> selectedDate = DateTime.now().obs;

    // Extract service info
    final String serviceId = serviceData['_id']?.toString() ?? '';
    final String serviceTitle = serviceData['title']?.toString() ?? 'Service';
    final String serviceDescription = serviceData['description']?.toString() ?? '';
    final String serviceLocation = serviceData['location']?.toString() ?? '';
    final String serviceImagePath = serviceData['image']?.toString() ?? '';
    final double serviceRating = (serviceData['rating'] as num?)?.toDouble() ?? 0.0;
    final int ratingCount = (serviceData['ratingCount'] as num?)?.toInt() ?? 0;

    // Build full image URL for service
    final String serviceImage = serviceImagePath.isNotEmpty
        ? '${AppUrl.imageBaseUrl}/$serviceImagePath'
        : '';

    debugPrint('🖼️ Service Image URL: $serviceImage');

    // Extract provider info
    String providerName = 'Service Provider';
    String providerImagePath = '';
    String providerLocation = serviceLocation;
    String providerPhone = '';
    bool isAvailable = true;

    if (profileData != null) {
      providerName = profileData['name']?.toString() ?? providerName;
      providerImagePath = profileData['image']?.toString() ?? '';
      providerLocation = profileData['location']?.toString() ?? providerLocation;
      providerPhone = profileData['phone']?.toString() ?? '';
      isAvailable = profileData['isAvailable'] ?? true;
    } else {
      final author = serviceData['author'];
      if (author is Map<String, dynamic>) {
        providerName = author['name']?.toString() ?? providerName;
        providerImagePath = author['image']?.toString() ?? '';
      }
    }

    // Build full image URL for provider
    final String providerImage = providerImagePath.isNotEmpty
        ? '${AppUrl.imageBaseUrl}/$providerImagePath'
        : '';

    debugPrint('🖼️ Provider Image URL: $providerImage');

    // Pre-fill service name controller
    serviceNameTEController.text = serviceTitle;

    // Create GlobalKey for InquiryBottomSheet
    final GlobalKey<InquiryBottomSheetState> inquirySheetKey = GlobalKey<InquiryBottomSheetState>();

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: <Widget>[
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Service Image
                      if (serviceImage.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CustomCachedImage(
                            imageUrl: serviceImage,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 60,
                            color: Colors.grey,
                          ),
                        ),
                      const SizedBox(height: 16),

                      // Service Title
                      Text(
                        serviceTitle,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Location
                      Row(
                        children: <Widget>[
                          const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              serviceLocation,
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Rating
                      Row(
                        children: <Widget>[
                          const Icon(Icons.star, size: 18, color: Colors.amber),
                          const SizedBox(width: 8),
                          Text(
                            '${serviceRating.toStringAsFixed(1)} ($ratingCount reviews)',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Date & Time Selection Section
                      const Text(
                        'Select Date & Time',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const Divider(color: AppColors.primaryColor, thickness: 1),
                      const SizedBox(height: 12),

                      // Calendar
                      Obx(
                            () => OneRowCalendar(
                          selectedDate: selectedDate.value,
                          onDateSelected: (DateTime date) {
                            selectedDate.value = date;
                            debugPrint('📅 Date selected: $date');
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Time Selector
                      TimeSelector(
                        initialTime: '10am',
                        selectedColor: AppColors.primaryColor,
                        selectedTextColor: AppColors.textBlackColor,
                        onTimeSelected: (String time) {
                          debugPrint('⏰ Time selected: $time');
                          timeController.updateSelectedTime(time);
                        },
                      ),
                      const SizedBox(height: 20),

                      // Description
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const Divider(color: AppColors.primaryColor, thickness: 1),
                      const SizedBox(height: 8),
                      Text(
                        serviceDescription.isNotEmpty
                            ? serviceDescription
                            : 'No description available',
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Provider Section
                      const Text(
                        'Service Provider',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const Divider(color: AppColors.primaryColor, thickness: 1),
                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primaryColor),
                          color: AppColors.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: <Widget>[
                            // Provider Image
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[200],
                              ),
                              child: providerImage.isNotEmpty
                                  ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CustomCachedImage(
                                  imageUrl: providerImage,
                                  fit: BoxFit.cover,
                                ),
                              )
                                  : const Icon(
                                Icons.person_outline,
                                size: 35,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Provider Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    providerName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),

                                  // Location
                                  Row(
                                    children: <Widget>[
                                      const Icon(
                                        Icons.location_on_outlined,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          providerLocation,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Phone
                                  if (providerPhone.isNotEmpty) ...<Widget>[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: <Widget>[
                                        const Icon(
                                          Icons.phone,
                                          size: 14,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          providerPhone,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],

                                  const SizedBox(height: 6),

                                  // Availability Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isAvailable
                                          ? Colors.green.withValues(alpha: 0.1)
                                          : Colors.red.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: isAvailable ? Colors.green : Colors.red,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Icon(
                                          isAvailable ? Icons.check_circle : Icons.cancel,
                                          size: 12,
                                          color: isAvailable ? Colors.green : Colors.red,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          isAvailable ? 'Available' : 'Unavailable',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isAvailable ? Colors.green : Colors.red,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Book Button
                      Obx(() => SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isBookingLoading.value
                              ? null
                              : () {
                            // Get selected date and time
                            final DateTime bookingDate = selectedDate.value;
                            final DateTime selectedDateTime = timeController.selectedTime.value;
                            final String selectedTimeString =
                                '${selectedDateTime.hour}:${selectedDateTime.minute.toString().padLeft(2, '0')}';

                            debugPrint('📅 Booking Date: $bookingDate');
                            debugPrint('⏰ Booking Time: $selectedTimeString');
                            debugPrint('🎯 Service ID: $serviceId');

                            // Close current bottom sheet
                            Get.back();

                            // Show booking bottom sheet
                            CustomModalBottomSheet.show(
                              title: 'Quote',
                              height: MediaQuery.of(context).size.height,
                              context: context,
                              buttonText: 'Send',
                              onButtonPressed: () {
                                debugPrint('🔘 Send button pressed');
                                inquirySheetKey.currentState?.submitInquiry(
                                  serviceId: serviceId,
                                  selectedDate: bookingDate,
                                  selectedTime: selectedTimeString,
                                );
                              },
                              child: InquiryBottomSheet(
                                key: inquirySheetKey,
                                isFromHomeScreen: false,
                                serviceNameTEController: serviceNameTEController,
                                dateTEController: dateTEController,
                                timeController: timeController,
                                locationTEController: locationTEController,
                                additionalNoteTEController: additionalNoteTEController,
                                preSelectedServiceId: serviceId,
                                preSelectedDate: bookingDate,
                                preSelectedTime: selectedTimeString,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                          ),
                          child: isBookingLoading.value
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                              : const Text(
                            'Book Now',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}










