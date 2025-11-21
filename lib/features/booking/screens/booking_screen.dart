/**

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/routes/app_routes.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/features/home/controllers/home_top_bar_controller.dart';
import 'package:manx_mate/features/booking/widgets/booking_card.dart';
import 'booking_screen_controller.dart';

/// ============================================================================
/// BOOKING SCREEN
/// ============================================================================
class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ActiveSlotBookingsController activeSlotBookingsController = Get.put(ActiveSlotBookingsController());
  final PendingBookingsController pendingBookingsController = Get.put(PendingBookingsController());
  final CompletedBookingsController completedBookingsController = Get.put(CompletedBookingsController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Add listener to fetch data when tab changes
    _tabController.addListener(_handleTabChange);

    // Fetch initial data for first tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🚀 Initializing booking screen...');
      activeSlotBookingsController.fetchActiveSlotBookings();
      pendingBookingsController.fetchPendingBookings();
      completedBookingsController.fetchCompletedBookings();
    });
  }

  void _handleTabChange() {
    print('🔁 Tab changed to index: ${_tabController.index}');
    if (_tabController.index == 0) {
      print('📥 Fetching active bookings for Active Slot...');
      activeSlotBookingsController.fetchActiveSlotBookings();
    } else if (_tabController.index == 1) {
      print('📥 Fetching pending bookings for Ongoing Slot...');
      pendingBookingsController.fetchPendingBookings();
    } else if (_tabController.index == 2) {
      print('📥 Fetching completed bookings for Past Slot...');
      completedBookingsController.fetchCompletedBookings();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  /// Helper method to build booking card from API data
  Widget _buildBookingCard(
      Map<String, dynamic> booking,
      String status,
      VoidCallback? onTap,
      ) {
    final service = booking['service'] ?? {};
    final subCategory = service['subCategory'] ?? {};
    final bookingId = booking['_id'] ?? '';
    final serviceId = service['_id'] ?? '';

    print('🎴 Building card for booking: $bookingId');

    // Construct full image URL
    String imageUrl;
    final imagePath = service['image'];

    if (imagePath != null && imagePath.toString().isNotEmpty) {
      if (imagePath.toString().startsWith('http')) {
        imageUrl = imagePath;
      } else {
        String cleanPath = imagePath.toString().replaceFirst(RegExp(r'^/'), '');
        imageUrl = 'https://d7001.sobhoy.com/$cleanPath';
      }
    } else {
      imageUrl = 'https://images.unsplash.com/photo-1494790108755-2616b772390e?w=400&h=300&fit=crop';
    }

    return HorizontalServiceCard(
      imageUrl: imageUrl,
      title: service['name'] ?? 'Unknown Service',
      subtitle: subCategory['name'] ?? 'General',
      description: service['description'] ?? 'No description available',
      bookingId: bookingId,
      serviceId: serviceId,
      status: status,
      tabIndex: _tabController.index,
      controller: activeSlotBookingsController,
      onTap: onTap ?? () {
        print('👆 Card tapped for booking: $bookingId');
      },
      onDelete: () async {
        print('✅ Booking deleted successfully from UI callback');
      },
    );
  }

  // Helper method to build API data list view
  Widget _buildApiListView({
    required RxList<Map<String, dynamic>> bookings,
    required RxBool isLoading,
    required RxString errorMessage,
    required String emptyMessage,
    required String status,
    required VoidCallback onRetry,
    required Function(Map<String, dynamic>) onCardTap,
  }) {
    print('📱 Building $status list view');
    print('📊 Bookings count: ${bookings.length}');
    print('🔄 Loading: ${isLoading.value}');
    print('❌ Error: ${errorMessage.value}');

    // LOADING STATE
    if (isLoading.value && bookings.isEmpty) {
      print('⏳ Showing loading indicator for $status');
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primaryColor),
            SizedBox(height: 16),
            Text('Loading bookings...', style: TextStyle(fontSize: 16, color: Colors.black54)),
          ],
        ),
      );
    }

    // ERROR STATE
    if (errorMessage.isNotEmpty && bookings.isEmpty) {
      print('🚨 Showing error state for $status: ${errorMessage.value}');
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(errorMessage.value, style: const TextStyle(fontSize: 16, color: Colors.black54), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // EMPTY STATE
    if (bookings.isEmpty) {
      print('📭 Showing empty state for $status');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(emptyMessage, style: const TextStyle(fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 8),
            Text('Your $status bookings will appear here', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor, foregroundColor: Colors.white),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    // SUCCESS STATE - Display bookings
    print('✅ Showing ${bookings.length} $status bookings');
    return RefreshIndicator(
      onRefresh: () async {
        print('🔄 Pull to refresh triggered for $status');
        onRetry();
      },
      color: AppColors.primaryColor,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.lg),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: bookings.length,
        itemBuilder: (BuildContext context, int index) {
          print('📦 Building item $index for $status');
          return _buildBookingCard(bookings[index], status, () => onCardTap(bookings[index]));
        },
        separatorBuilder: (BuildContext context, int index) {
          return const Column(children: <Widget>[Divider(), SizedBox(height: AppSizes.md)]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final HomeTopBarController controller = Get.put(HomeTopBarController());

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // TOP BAR
            Card(
              elevation: 2,
              color: AppColors.whiteColor,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Obx(() {
                      final imageUrl = controller.getImageUrl();
                      return CircleAvatar(
                        radius: 30,
                        backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                        child: imageUrl.isEmpty ? const Icon(Icons.person, size: 50, color: Colors.grey) : null,
                      );
                    }),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor,
                        border: Border.all(color: AppColors.primaryColor),
                        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                      ),
                      child: IconButton(
                        onPressed: () => Get.toNamed(AppRoutes.notificationPage),
                        icon: const Icon(CupertinoIcons.bell, color: AppColors.primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // TAB BAR
            PreferredSize(
              preferredSize: const Size.fromHeight(50.0),
              child: Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  isScrollable: true,
                  indicatorColor: AppColors.primaryColor,
                  indicatorWeight: 5,
                  tabAlignment: TabAlignment.center,
                  labelColor: Colors.black87,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
                  tabs: const <Widget>[
                    Tab(text: "Active Slot"),
                    Tab(text: "Ongoing Slot"),
                    Tab(text: "Past Slot"),
                  ],
                ),
              ),
            ),

            // Divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: Divider(thickness: 1, color: Colors.grey.withOpacity(0.3)),
            ),

            // TAB BAR VIEW
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  // TAB 1: ACTIVE SLOT
                  Obx(() {
                    print('🔄 Rebuilding Active Slot tab');
                    return _buildApiListView(
                      bookings: activeSlotBookingsController.activeSlotBookings,
                      isLoading: activeSlotBookingsController.isLoading,
                      errorMessage: activeSlotBookingsController.errorMessage,
                      emptyMessage: 'No active bookings yet',
                      status: 'Active',
                      onRetry: () => activeSlotBookingsController.fetchActiveSlotBookings(),
                      onCardTap: (booking) {
                        print('👆 Active booking tapped: ${booking['_id']}');
                        // Add navigation for active bookings if needed
                      },
                    );
                  }),

                  // TAB 2: ONGOING SLOT
                  Obx(() {
                    print('🔄 Rebuilding Ongoing Slot tab');
                    return _buildApiListView(
                      bookings: pendingBookingsController.pendingBookings,
                      isLoading: pendingBookingsController.isLoading,
                      errorMessage: pendingBookingsController.errorMessage,
                      emptyMessage: 'No ongoing bookings yet',
                      status: 'Pending',
                      onRetry: () => pendingBookingsController.fetchPendingBookings(),
                      onCardTap: (booking) {
                        print('👆 Ongoing booking tapped: ${booking['_id']}');
                        // Add navigation for ongoing bookings if needed
                      },
                    );
                  }),

                  // TAB 3: PAST SLOT - Navigate to review without ownership check
                  // Only the relevant updated section for Past Slot navigation:

                  /// ============================================================
                  /// TAB 3: PAST SLOT (API INTEGRATED - COMPLETED BOOKINGS)
                  /// ============================================================
                  Obx(() {
                    print('🔄 Rebuilding Past Slot tab');
                    return _buildApiListView(
                      bookings: completedBookingsController.completedBookings,
                      isLoading: completedBookingsController.isLoading,
                      errorMessage: completedBookingsController.errorMessage,
                      emptyMessage: 'No completed bookings yet',
                      status: 'Completed',
                      onRetry: () {
                        completedBookingsController.fetchCompletedBookings();
                      },
                      onCardTap: (Map<String, dynamic> booking) {
                        // Extract BOTH bookingId and serviceId from the booking
                        final bookingId = booking['_id'] ?? '';
                        final service = booking['service'] ?? {};
                        final serviceId = service['_id'] ?? '';

                        print('🎯 Completed booking tapped:');
                        print('   📋 Booking ID: $bookingId');
                        print('   🔧 Service ID: $serviceId');

                        if (bookingId.isNotEmpty) {
                          // Navigate with BOTH IDs - bookingId is the primary one for review API
                          Get.toNamed(
                            AppRoutes.reviewPage,
                            parameters: {
                              'bookingId': bookingId,  // Primary ID for review submission
                              'serviceId': serviceId,   // Secondary ID for reference
                            },
                          );
                          print('✅ Navigating to review page with bookingId: $bookingId');
                        } else {
                          print('❌ Booking ID not found for review');
                          Get.snackbar(
                            'Error',
                            'Booking information not available for review',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                            margin: const EdgeInsets.all(16),
                          );
                        }
                      },
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/






///
///
///
///
/// todo:: showing a details card
///
///
///
///


/**
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/routes/app_routes.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';
import 'package:manx_mate/features/home/controllers/home_top_bar_controller.dart';
import 'package:manx_mate/features/booking/widgets/booking_card.dart';
import 'package:manx_mate/core/common/components/custom_network_image.dart';
import 'package:manx_mate/core/network/network_caller.dart';
import 'package:manx_mate/core/network/network_response.dart';
import 'package:manx_mate/core/utils/token_service/token_storage_service.dart';
import 'package:manx_mate/core/common/widgets/app_bottom_sheet.dart';
import 'package:manx_mate/core/common/widgets/time_picker_widget.dart';
import 'package:manx_mate/features/home/widget/inquiry_bottom_sheet.dart';
import 'package:manx_mate/features/home/widget/one_row_calander.dart';
import 'package:manx_mate/features/home/widget/time_selection_widget.dart';
import 'booking_screen_controller.dart';

/// ============================================================================
/// BOOKING SCREEN
/// ============================================================================
class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ActiveSlotBookingsController activeSlotBookingsController = Get.put(ActiveSlotBookingsController());
  final PendingBookingsController pendingBookingsController = Get.put(PendingBookingsController());
  final CompletedBookingsController completedBookingsController = Get.put(CompletedBookingsController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Add listener to fetch data when tab changes
    _tabController.addListener(_handleTabChange);

    // Fetch initial data for first tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🚀 Initializing booking screen...');
      activeSlotBookingsController.fetchActiveSlotBookings();
      pendingBookingsController.fetchPendingBookings();
      completedBookingsController.fetchCompletedBookings();
    });
  }

  void _handleTabChange() {
    print('🔁 Tab changed to index: ${_tabController.index}');
    if (_tabController.index == 0) {
      print('📥 Fetching active bookings for Active Slot...');
      activeSlotBookingsController.fetchActiveSlotBookings();
    } else if (_tabController.index == 1) {
      print('📥 Fetching pending bookings for Ongoing Slot...');
      pendingBookingsController.fetchPendingBookings();
    } else if (_tabController.index == 2) {
      print('📥 Fetching completed bookings for Past Slot...');
      completedBookingsController.fetchCompletedBookings();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  // Helper method to construct full image URL
  String _getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';

    if (imagePath.startsWith('http')) return imagePath;

    String cleanPath = imagePath;
    if (cleanPath.startsWith('public/')) {
      cleanPath = cleanPath.substring(7);
    }

    return '${AppUrl.imageBaseUrl}/$cleanPath';
  }

  // Show service details in bottom sheet
  void _showServiceDetails(BuildContext context, Map<String, dynamic> booking) async {
    debugPrint('📦 Showing service details for booking');

    final service = booking['service'] ?? {};
    final serviceId = service['_id']?.toString() ?? '';

    if (serviceId.isEmpty) {
      Get.snackbar(
        'Error',
        'Service information not available',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

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
        headers: {'Authorization': 'Bearer $accessToken'},
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

      final serviceData = serviceResponse.jsonResponse!['data'] as Map<String, dynamic>?;
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
          headers: {'Authorization': 'Bearer $accessToken'},
        );

        debugPrint('📥 Profile Response: ${profileResponse.jsonResponse}');

        if (profileResponse.isSuccess && profileResponse.jsonResponse != null) {
          profileData = profileResponse.jsonResponse!['data'] as Map<String, dynamic>?;
        }
      }

      Get.back(); // Close loading

      // Show details in bottom sheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withOpacity(0.5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => _buildServiceDetailsSheet(
          context,
          serviceData,
          profileData,
          booking,
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
      Map<String, dynamic> booking,
      ) {
    // Controllers for booking
    final TextEditingController serviceNameTEController = TextEditingController();
    final TextEditingController locationTEController = TextEditingController();
    final TextEditingController additionalNoteTEController = TextEditingController();
    final TextEditingController dateTEController = TextEditingController();
    final TimeController timeController = Get.put(TimeController());

    // Date picker
    final Rx<DateTime> selectedDate = DateTime.now().obs;

    // Extract service info
    final serviceId = serviceData['_id']?.toString() ?? '';
    final serviceTitle = serviceData['title']?.toString() ?? 'Service';
    final serviceDescription = serviceData['description']?.toString() ?? '';
    final serviceLocation = serviceData['location']?.toString() ?? '';
    final serviceImagePath = serviceData['image']?.toString() ?? '';
    final serviceRating = (serviceData['rating'] as num?)?.toDouble() ?? 0.0;
    final ratingCount = (serviceData['ratingCount'] as num?)?.toInt() ?? 0;

    // Build full image URL for service
    final serviceImage = _getFullImageUrl(serviceImagePath);

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
    final providerImage = _getFullImageUrl(providerImagePath);

    // Pre-fill service name controller
    serviceNameTEController.text = serviceTitle;

    // Create GlobalKey for InquiryBottomSheet
    final GlobalKey<InquiryBottomSheetState> inquirySheetKey = GlobalKey<InquiryBottomSheetState>();

    // Extract booking status
    final bookingStatus = booking['status']?.toString() ?? 'Unknown';

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
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
                    children: [
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

                      // Booking Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(bookingStatus).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getStatusColor(bookingStatus),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getStatusIcon(bookingStatus),
                              size: 16,
                              color: _getStatusColor(bookingStatus),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              bookingStatus.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(bookingStatus),
                              ),
                            ),
                          ],
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
                        children: [
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
                        children: [
                          const Icon(Icons.star, size: 18, color: Colors.amber),
                          const SizedBox(width: 8),
                          Text(
                            '${serviceRating.toStringAsFixed(1)} ($ratingCount reviews)',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Only show booking section for active/pending bookings
                      if (bookingStatus.toLowerCase() != 'completed' && bookingStatus.toLowerCase() != 'cancelled') ...[
                        // Date & Time Selection Section
                        const Text(
                          'Book Again',
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
                            timeController.updateSelectedTime(time);
                          },
                        ),
                        const SizedBox(height: 20),
                      ],

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
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
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
                                children: [
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

                                  Row(
                                    children: [
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

                                  if (providerPhone.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
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

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isAvailable
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: isAvailable ? Colors.green : Colors.red,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
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

                      // Action button based on booking status
                      if (bookingStatus.toLowerCase() == 'completed') ...[
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              Get.back();
                              final bookingId = booking['_id'] ?? '';
                              if (bookingId.isNotEmpty) {
                                Get.toNamed(
                                  AppRoutes.reviewPage,
                                  parameters: {
                                    'bookingId': bookingId,
                                    'serviceId': serviceId,
                                  },
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Write Review',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ] else if (bookingStatus.toLowerCase() != 'cancelled') ...[
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              final DateTime bookingDate = selectedDate.value;
                              final DateTime selectedDateTime = timeController.selectedTime.value;
                              final String selectedTimeString =
                                  '${selectedDateTime.hour}:${selectedDateTime.minute.toString().padLeft(2, '0')}';

                              Get.back();

                              CustomModalBottomSheet.show(
                                title: 'Book Again',
                                height: MediaQuery.of(context).size.height,
                                context: context,
                                buttonText: 'Confirm',
                                onButtonPressed: () {
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
                            ),
                            child: const Text(
                              'Book Again',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
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

  // Helper method to get status color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Helper method to get status icon
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'accepted':
        return Icons.check_circle_outline;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info_outline;
    }
  }

  /// Helper method to build booking card from API data
  Widget _buildBookingCard(
      Map<String, dynamic> booking,
      String status,
      VoidCallback? onTap,
      ) {
    final service = booking['service'] ?? {};
    final subCategory = service['subCategory'] ?? {};
    final bookingId = booking['_id'] ?? '';
    final serviceId = service['_id'] ?? '';

    // Construct full image URL
    final imagePath = service['image'];
    final imageUrl = _getFullImageUrl(imagePath);

    return HorizontalServiceCard(
      imageUrl: imageUrl.isNotEmpty
          ? imageUrl
          : 'https://images.unsplash.com/photo-1494790108755-2616b772390e?w=400&h=300&fit=crop',
      title: service['name'] ?? 'Unknown Service',
      subtitle: subCategory['name'] ?? 'General',
      description: service['description'] ?? 'No description available',
      bookingId: bookingId,
      serviceId: serviceId,
      status: status,
      tabIndex: _tabController.index,
      controller: activeSlotBookingsController,
      onTap: onTap ?? () {
        print('👆 Card tapped for booking: $bookingId');
      },
      onDelete: () async {
        print('✅ Booking deleted successfully from UI callback');
      },
    );
  }

  // Helper method to build API data list view
  Widget _buildApiListView({
    required RxList<Map<String, dynamic>> bookings,
    required RxBool isLoading,
    required RxString errorMessage,
    required String emptyMessage,
    required String status,
    required VoidCallback onRetry,
    required Function(Map<String, dynamic>) onCardTap,
  }) {
    // LOADING STATE
    if (isLoading.value && bookings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primaryColor),
            SizedBox(height: 16),
            Text('Loading bookings...', style: TextStyle(fontSize: 16, color: Colors.black54)),
          ],
        ),
      );
    }

    // ERROR STATE
    if (errorMessage.isNotEmpty && bookings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(errorMessage.value, style: const TextStyle(fontSize: 16, color: Colors.black54), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // EMPTY STATE
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(emptyMessage, style: const TextStyle(fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 8),
            Text('Your $status bookings will appear here', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor, foregroundColor: Colors.white),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    // SUCCESS STATE - Display bookings
    return RefreshIndicator(
      onRefresh: () async {
        onRetry();
      },
      color: AppColors.primaryColor,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.lg),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: bookings.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildBookingCard(bookings[index], status, () => onCardTap(bookings[index]));
        },
        separatorBuilder: (BuildContext context, int index) {
          return const Column(children: <Widget>[Divider(), SizedBox(height: AppSizes.md)]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final HomeTopBarController controller = Get.put(HomeTopBarController());

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // TOP BAR
            Card(
              elevation: 2,
              color: AppColors.whiteColor,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Obx(() {
                      final imageUrl = controller.getImageUrl();
                      return CircleAvatar(
                        radius: 30,
                        backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                        child: imageUrl.isEmpty ? const Icon(Icons.person, size: 50, color: Colors.grey) : null,
                      );
                    }),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor,
                        border: Border.all(color: AppColors.primaryColor),
                        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                      ),
                      child: IconButton(
                        onPressed: () => Get.toNamed(AppRoutes.notificationPage),
                        icon: const Icon(CupertinoIcons.bell, color: AppColors.primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // TAB BAR
            PreferredSize(
              preferredSize: const Size.fromHeight(50.0),
              child: Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  isScrollable: true,
                  indicatorColor: AppColors.primaryColor,
                  indicatorWeight: 5,
                  tabAlignment: TabAlignment.center,
                  labelColor: Colors.black87,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
                  tabs: const <Widget>[
                    Tab(text: "Active Slot"),
                    Tab(text: "Ongoing Slot"),
                    Tab(text: "Past Slot"),
                  ],
                ),
              ),
            ),

            // Divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: Divider(thickness: 1, color: Colors.grey.withOpacity(0.3)),
            ),

            // TAB BAR VIEW
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  // TAB 1: ACTIVE SLOT
                  Obx(() {
                    return _buildApiListView(
                      bookings: activeSlotBookingsController.activeSlotBookings,
                      isLoading: activeSlotBookingsController.isLoading,
                      errorMessage: activeSlotBookingsController.errorMessage,
                      emptyMessage: 'No active bookings yet',
                      status: 'Active',
                      onRetry: () => activeSlotBookingsController.fetchActiveSlotBookings(),
                      onCardTap: (booking) {
                        _showServiceDetails(context, booking);
                      },
                    );
                  }),

                  // TAB 2: ONGOING SLOT
                  Obx(() {
                    return _buildApiListView(
                      bookings: pendingBookingsController.pendingBookings,
                      isLoading: pendingBookingsController.isLoading,
                      errorMessage: pendingBookingsController.errorMessage,
                      emptyMessage: 'No ongoing bookings yet',
                      status: 'Pending',
                      onRetry: () => pendingBookingsController.fetchPendingBookings(),
                      onCardTap: (booking) {
                        _showServiceDetails(context, booking);
                      },
                    );
                  }),

                  // TAB 3: PAST SLOT
                  Obx(() {
                    return _buildApiListView(
                      bookings: completedBookingsController.completedBookings,
                      isLoading: completedBookingsController.isLoading,
                      errorMessage: completedBookingsController.errorMessage,
                      emptyMessage: 'No completed bookings yet',
                      status: 'Completed',
                      onRetry: () => completedBookingsController.fetchCompletedBookings(),
                      onCardTap: (booking) {
                        _showServiceDetails(context, booking);
                      },
                    );
                  }),
                ],
              ),
            ),
          ],
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
/// todo:: adding a completed button
///
///
///
///
///



import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/routes/app_routes.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';
import 'package:manx_mate/features/home/controllers/home_top_bar_controller.dart';
import 'package:manx_mate/features/booking/widgets/booking_card.dart';
import 'package:manx_mate/core/common/components/custom_network_image.dart';
import 'package:manx_mate/core/network/network_caller.dart';
import 'package:manx_mate/core/network/network_response.dart';
import 'package:manx_mate/core/utils/token_service/token_storage_service.dart';
import 'package:manx_mate/core/common/widgets/app_bottom_sheet.dart';
import 'package:manx_mate/core/common/widgets/time_picker_widget.dart';
import 'package:manx_mate/features/home/widget/inquiry_bottom_sheet.dart';
import 'package:manx_mate/features/home/widget/one_row_calander.dart';
import 'package:manx_mate/features/home/widget/time_selection_widget.dart';
import 'booking_screen_controller.dart';

/// ============================================================================
/// BOOKING SCREEN
/// ============================================================================
class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ActiveSlotBookingsController activeSlotBookingsController = Get.put(ActiveSlotBookingsController());
  final PendingBookingsController pendingBookingsController = Get.put(PendingBookingsController());
  final CompletedBookingsController completedBookingsController = Get.put(CompletedBookingsController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Add listener to fetch data when tab changes
    _tabController.addListener(_handleTabChange);

    // Fetch initial data for first tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🚀 Initializing booking screen...');
      activeSlotBookingsController.fetchActiveSlotBookings();
      pendingBookingsController.fetchPendingBookings();
      completedBookingsController.fetchCompletedBookings();
    });
  }

  void _handleTabChange() {
    print('🔁 Tab changed to index: ${_tabController.index}');
    if (_tabController.index == 0) {
      print('📥 Fetching active bookings for Active Slot...');
      activeSlotBookingsController.fetchActiveSlotBookings();
    } else if (_tabController.index == 1) {
      print('📥 Fetching pending bookings for Ongoing Slot...');
      pendingBookingsController.fetchPendingBookings();
    } else if (_tabController.index == 2) {
      print('📥 Fetching completed bookings for Past Slot...');
      completedBookingsController.fetchCompletedBookings();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  // Helper method to construct full image URL
  String _getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';

    if (imagePath.startsWith('http')) return imagePath;

    String cleanPath = imagePath;
    if (cleanPath.startsWith('public/')) {
      cleanPath = cleanPath.substring(7);
    }

    return '${AppUrl.imageBaseUrl}/$cleanPath';
  }

  // Show service details in bottom sheet
  void _showServiceDetails(BuildContext context, Map<String, dynamic> booking) async {
    debugPrint('📦 Showing service details for booking');

    final service = booking['service'] ?? {};
    final serviceId = service['_id']?.toString() ?? '';

    if (serviceId.isEmpty) {
      Get.snackbar(
        'Error',
        'Service information not available',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

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
        headers: {'Authorization': 'Bearer $accessToken'},
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

      final serviceData = serviceResponse.jsonResponse!['data'] as Map<String, dynamic>?;
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
          headers: {'Authorization': 'Bearer $accessToken'},
        );

        debugPrint('📥 Profile Response: ${profileResponse.jsonResponse}');

        if (profileResponse.isSuccess && profileResponse.jsonResponse != null) {
          profileData = profileResponse.jsonResponse!['data'] as Map<String, dynamic>?;
        }
      }

      Get.back(); // Close loading

      // Show details in bottom sheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withOpacity(0.5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => _buildServiceDetailsSheet(
          context,
          serviceData,
          profileData,
          booking,
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
      Map<String, dynamic> booking,
      ) {
    // Controllers for booking
    final TextEditingController serviceNameTEController = TextEditingController();
    final TextEditingController locationTEController = TextEditingController();
    final TextEditingController additionalNoteTEController = TextEditingController();
    final TextEditingController dateTEController = TextEditingController();
    final TimeController timeController = Get.put(TimeController());

    // Date picker
    final Rx<DateTime> selectedDate = DateTime.now().obs;

    // Extract service info
    final serviceId = serviceData['_id']?.toString() ?? '';
    final serviceTitle = serviceData['title']?.toString() ?? 'Service';
    final serviceDescription = serviceData['description']?.toString() ?? '';
    final serviceLocation = serviceData['location']?.toString() ?? '';
    final serviceImagePath = serviceData['image']?.toString() ?? '';
    final serviceRating = (serviceData['rating'] as num?)?.toDouble() ?? 0.0;
    final ratingCount = (serviceData['ratingCount'] as num?)?.toInt() ?? 0;

    // Build full image URL for service
    final serviceImage = _getFullImageUrl(serviceImagePath);

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
    final providerImage = _getFullImageUrl(providerImagePath);

    // Pre-fill service name controller
    serviceNameTEController.text = serviceTitle;

    // Create GlobalKey for InquiryBottomSheet
    final GlobalKey<InquiryBottomSheetState> inquirySheetKey = GlobalKey<InquiryBottomSheetState>();

    // Extract booking status
    final bookingStatus = booking['status']?.toString() ?? 'Unknown';

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
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
                    children: [
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

                      // Booking Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(bookingStatus).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getStatusColor(bookingStatus),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getStatusIcon(bookingStatus),
                              size: 16,
                              color: _getStatusColor(bookingStatus),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              bookingStatus.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(bookingStatus),
                              ),
                            ),
                          ],
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
                        children: [
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
                        children: [
                          const Icon(Icons.star, size: 18, color: Colors.amber),
                          const SizedBox(width: 8),
                          Text(
                            '${serviceRating.toStringAsFixed(1)} ($ratingCount reviews)',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Only show booking section for active/pending bookings
                      if (bookingStatus.toLowerCase() != 'completed' && bookingStatus.toLowerCase() != 'cancelled') ...[
                        // Date & Time Selection Section
                        const Text(
                          'Book Again',
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
                            timeController.updateSelectedTime(time);
                          },
                        ),
                        const SizedBox(height: 20),
                      ],

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
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
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
                                children: [
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

                                  Row(
                                    children: [
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

                                  if (providerPhone.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
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

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isAvailable
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: isAvailable ? Colors.green : Colors.red,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
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

                      // Action button based on booking status
                      const SizedBox(height: 30),

                      // Action button based on booking status
                      if (bookingStatus.toLowerCase() == 'completed') ...[
                        // Write Review button for completed bookings
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              Get.back();
                              final bookingId = booking['_id'] ?? '';
                              if (bookingId.isNotEmpty) {
                                Get.toNamed(
                                  AppRoutes.reviewPage,
                                  parameters: {
                                    'bookingId': bookingId,
                                    'serviceId': serviceId,
                                  },
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Write Review',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ]
                      else if (bookingStatus.toLowerCase() == 'accepted') ...[
                        // Mark as Completed button for ongoing (accepted) bookings
                        Obx(() => SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: pendingBookingsController.isCompleting.value
                                ? null
                                : () async {
                              final bookingId = booking['_id'] ?? '';

                              if (bookingId.isEmpty) {
                                Get.snackbar(
                                  'Error',
                                  'Booking ID not found',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }

                              // Show confirmation dialog
                              final bool? confirm = await Get.dialog<bool>(
                                AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  title: const Row(
                                    children: [
                                      Icon(Icons.check_circle_outline, color: Colors.green),
                                      SizedBox(width: 8),
                                      Text('Mark as Completed'),
                                    ],
                                  ),
                                  content: const Text(
                                    'Are you sure you want to mark this booking as completed?',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Get.back(result: false),
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Get.back(result: true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      ),
                                      child: const Text('Confirm', style: TextStyle(fontSize: 16)),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                debugPrint('✅ User confirmed completion for booking: $bookingId');

                                final success = await pendingBookingsController.completeBooking(bookingId);

                                if (success) {
                                  Get.back(); // Close bottom sheet

                                  // Refresh the completed bookings list
                                  completedBookingsController.fetchCompletedBookings();
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              disabledBackgroundColor: Colors.grey,
                            ),
                            child: pendingBookingsController.isCompleting.value
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                                : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Mark as Completed',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                      ]
                      else if (bookingStatus.toLowerCase() == 'pending') ...[
                        // Reschedule button for pending bookings
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              final DateTime bookingDate = selectedDate.value;
                              final DateTime selectedDateTime = timeController.selectedTime.value;
                              final String selectedTimeString =
                                  '${selectedDateTime.hour}:${selectedDateTime.minute.toString().padLeft(2, '0')}';

                              Get.back();

                              CustomModalBottomSheet.show(
                                title: 'Book Again',
                                height: MediaQuery.of(context).size.height,
                                context: context,
                                buttonText: 'Confirm',
                                onButtonPressed: () {
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
                            ),
                            child: const Text(
                              'Book Again',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
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

  // Helper method to get status color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Helper method to get status icon
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'accepted':
        return Icons.check_circle_outline;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info_outline;
    }
  }

  /// Helper method to build booking card from API data
  Widget _buildBookingCard(
      Map<String, dynamic> booking,
      String status,
      VoidCallback? onTap,
      ) {
    final service = booking['service'] ?? {};
    final subCategory = service['subCategory'] ?? {};
    final bookingId = booking['_id'] ?? '';
    final serviceId = service['_id'] ?? '';

    // Construct full image URL
    final imagePath = service['image'];
    final imageUrl = _getFullImageUrl(imagePath);

    return HorizontalServiceCard(
      imageUrl: imageUrl.isNotEmpty
          ? imageUrl
          : 'https://images.unsplash.com/photo-1494790108755-2616b772390e?w=400&h=300&fit=crop',
      title: service['name'] ?? 'Unknown Service',
      subtitle: subCategory['name'] ?? 'General',
      description: service['description'] ?? 'No description available',
      bookingId: bookingId,
      serviceId: serviceId,
      status: status,
      tabIndex: _tabController.index,
      controller: activeSlotBookingsController,
      onTap: onTap ?? () {
        print('👆 Card tapped for booking: $bookingId');
      },
      onDelete: () async {
        print('✅ Booking deleted successfully from UI callback');
      },
    );
  }

  // Helper method to build API data list view
  Widget _buildApiListView({
    required RxList<Map<String, dynamic>> bookings,
    required RxBool isLoading,
    required RxString errorMessage,
    required String emptyMessage,
    required String status,
    required VoidCallback onRetry,
    required Function(Map<String, dynamic>) onCardTap,
  }) {
    // LOADING STATE
    if (isLoading.value && bookings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primaryColor),
            SizedBox(height: 16),
            Text('Loading bookings...', style: TextStyle(fontSize: 16, color: Colors.black54)),
          ],
        ),
      );
    }

    // ERROR STATE
    if (errorMessage.isNotEmpty && bookings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(errorMessage.value, style: const TextStyle(fontSize: 16, color: Colors.black54), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // EMPTY STATE
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(emptyMessage, style: const TextStyle(fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 8),
            Text('Your $status bookings will appear here', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor, foregroundColor: Colors.white),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    // SUCCESS STATE - Display bookings
    return RefreshIndicator(
      onRefresh: () async {
        onRetry();
      },
      color: AppColors.primaryColor,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.lg),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: bookings.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildBookingCard(bookings[index], status, () => onCardTap(bookings[index]));
        },
        separatorBuilder: (BuildContext context, int index) {
          return const Column(children: <Widget>[Divider(), SizedBox(height: AppSizes.md)]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final HomeTopBarController controller = Get.put(HomeTopBarController());

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // TOP BAR
            Card(
              elevation: 2,
              color: AppColors.whiteColor,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Obx(() {
                      final imageUrl = controller.getImageUrl();
                      return CircleAvatar(
                        radius: 30,
                        backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                        child: imageUrl.isEmpty ? const Icon(Icons.person, size: 50, color: Colors.grey) : null,
                      );
                    }),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor,
                        border: Border.all(color: AppColors.primaryColor),
                        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                      ),
                      child: IconButton(
                        onPressed: () => Get.toNamed(AppRoutes.notificationPage),
                        icon: const Icon(CupertinoIcons.bell, color: AppColors.primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // TAB BAR
            PreferredSize(
              preferredSize: const Size.fromHeight(50.0),
              child: Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  isScrollable: true,
                  indicatorColor: AppColors.primaryColor,
                  indicatorWeight: 5,
                  tabAlignment: TabAlignment.center,
                  labelColor: Colors.black87,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
                  tabs: const <Widget>[
                    Tab(text: "Active Slot"),
                    Tab(text: "Ongoing Slot"),
                    Tab(text: "Past Slot"),
                  ],
                ),
              ),
            ),

            // Divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: Divider(thickness: 1, color: Colors.grey.withOpacity(0.3)),
            ),

            // TAB BAR VIEW
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  // TAB 1: ACTIVE SLOT
                  Obx(() {
                    return _buildApiListView(
                      bookings: activeSlotBookingsController.activeSlotBookings,
                      isLoading: activeSlotBookingsController.isLoading,
                      errorMessage: activeSlotBookingsController.errorMessage,
                      emptyMessage: 'No active bookings yet',
                      status: 'Active',
                      onRetry: () => activeSlotBookingsController.fetchActiveSlotBookings(),
                      onCardTap: (booking) {
                        _showServiceDetails(context, booking);
                      },
                    );
                  }),

                  // TAB 2: ONGOING SLOT
                  Obx(() {
                    return _buildApiListView(
                      bookings: pendingBookingsController.pendingBookings,
                      isLoading: pendingBookingsController.isLoading,
                      errorMessage: pendingBookingsController.errorMessage,
                      emptyMessage: 'No ongoing bookings yet',
                      status: 'Pending',
                      onRetry: () => pendingBookingsController.fetchPendingBookings(),
                      onCardTap: (booking) {
                        _showServiceDetails(context, booking);
                      },
                    );
                  }),

                  // TAB 3: PAST SLOT
                  Obx(() {
                    return _buildApiListView(
                      bookings: completedBookingsController.completedBookings,
                      isLoading: completedBookingsController.isLoading,
                      errorMessage: completedBookingsController.errorMessage,
                      emptyMessage: 'No completed bookings yet',
                      status: 'Completed',
                      onRetry: () => completedBookingsController.fetchCompletedBookings(),
                      onCardTap: (booking) {
                        _showServiceDetails(context, booking);
                      },
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

