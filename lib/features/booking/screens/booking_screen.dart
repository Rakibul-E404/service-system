import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/routes/app_routes.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/features/home/controllers/home_top_bar_controller.dart';
import 'package:manx_mate/features/booking/widgets/booking_card.dart';
import 'booking_screen_controller.dart';


// ============================================================================
// BOOKING SCREEN
// ============================================================================
class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
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
      pendingBookingsController.fetchPendingBookings();
      completedBookingsController.fetchCompletedBookings();
    });
  }

  void _handleTabChange() {
    print('🔁 Tab changed to index: ${_tabController.index}');
    if (_tabController.index == 1) {
      // Fetch pending bookings when switching to Ongoing Slot tab
      print('📥 Fetching pending bookings for Ongoing Slot...');
      pendingBookingsController.fetchPendingBookings();
    } else if (_tabController.index == 2) {
      // Fetch completed bookings when switching to Past Slot tab
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

  // Helper method to build booking card from API data
  Widget _buildBookingCard(Map<String, dynamic> booking, String status, VoidCallback? onTap) {
    final service = booking['service'] ?? {};
    final subCategory = service['subCategory'] ?? {};

    print('🎴 Building card for booking: ${booking['_id']}');
    print('🛠️ Service data: $service');
    print('📁 Subcategory data: $subCategory');

    // Construct full image URL - FIXED as per requirement
    String imageUrl;
    final imagePath = service['image'];

    if (imagePath != null && imagePath.toString().isNotEmpty) {
      // Check if image URL is already complete
      if (imagePath.toString().startsWith('http')) {
        imageUrl = imagePath;
      } else {
        // Remove any leading slash and construct URL as: https://d7001.sobhoy.com/{image data}
        String cleanPath = imagePath.toString().replaceFirst(RegExp(r'^/'), '');
        imageUrl = 'https://d7001.sobhoy.com/$cleanPath';
      }
    } else {
      // Fallback image
      imageUrl = 'https://images.unsplash.com/photo-1494790108755-2616b772390e?w=400&h=300&fit=crop';
    }

    print('🖼️ Image URL: $imageUrl');

    // Format date
    String formattedDate = 'Unknown date';
    try {
      final createdAt = booking['createdAt'];
      if (createdAt != null) {
        final dateTime = DateTime.parse(createdAt);
        formattedDate = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      print('❌ Error parsing date: $e');
    }

    return HorizontalServiceCard(
      imageUrl: imageUrl,
      title: service['name'] ?? 'Unknown Service',
      subtitle: subCategory['name'] ?? 'General',
      description: service['description'] ?? 'No description available',
      // rating: "4.8", // Default rating
      onTap: onTap ?? () {
        print('👆 Card tapped for booking: ${booking['_id']}');
      },
      onDelete: () {
        _showDeleteConfirmation(booking['_id'], status);
      },
      status: status,
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
    VoidCallback? onCardTap,
  }) {
    print('📱 Building $status list view');
    print('📊 Bookings count: ${bookings.length}');
    print('🔄 Loading: ${isLoading.value}');
    print('❌ Error: ${errorMessage.value}');

    // LOADING STATE
    if (isLoading.value) {
      print('⏳ Showing loading indicator for $status');
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.primaryColor,
            ),
            SizedBox(height: 16),
            Text(
              'Loading bookings...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    // ERROR STATE
    if (errorMessage.isNotEmpty) {
      print('🚨 Showing error state for $status: ${errorMessage.value}');
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.red.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage.value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
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
            Icon(
              Icons.history,
              size: 60,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your $status bookings will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
              ),
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
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.lg,
        ),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: bookings.length,
        itemBuilder: (BuildContext context, int index) {
          print('📦 Building item $index for $status');
          return _buildBookingCard(bookings[index], status, onCardTap);
        },
        separatorBuilder: (BuildContext context, int index) {
          return const Column(
            children: <Widget>[
              Divider(),
              SizedBox(height: AppSizes.md),
            ],
          );
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
            // ================================================================
            // TOP BAR - Profile Avatar and Bell Icon
            // ================================================================
            Card(
              elevation: 2,
              color: AppColors.whiteColor,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.lg,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    // Profile Image - Dynamically get image from controller
                    Obx(() {
                      final imageUrl = controller.getImageUrl();
                      return CircleAvatar(
                        radius: 30,
                        backgroundImage: imageUrl.isNotEmpty
                            ? NetworkImage(imageUrl)
                            : null,
                        child: imageUrl.isEmpty
                            ? const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.grey,
                        )
                            : null,
                      );
                    }),

                    // Bell Icon Button
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
                        icon: const Icon(
                          CupertinoIcons.bell,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ================================================================
            // TAB BAR
            // ================================================================
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
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
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
              child: Divider(
                thickness: 1,
                color: Colors.grey.withOpacity(0.3),
              ),
            ),

            // ================================================================
            // TAB BAR VIEW - Content for each tab
            // ================================================================
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  // ============================================================
                  // TAB 1: ACTIVE SLOT (Sample Static Data)
                  // ============================================================
                  ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: AppSizes.lg,
                    ),
                    shrinkWrap: true,
                    itemCount: 5,
                    itemBuilder: (BuildContext context, int index) {
                      return HorizontalServiceCard(
                        imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=300&fit=crop',
                        title: 'TutorPro Academy $index',
                        subtitle: 'Children & Education',
                        description: 'Cork, Ireland',
                        // rating: "4.9",
                        onTap: () {
                          print('👆 Active slot card $index tapped');
                        },
                        onDelete: () {
                          _showDeleteConfirmation('active_$index', 'Processing');
                        },
                        status: 'Processing',
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const Column(
                        children: <Widget>[
                          Divider(),
                          SizedBox(height: AppSizes.md),
                        ],
                      );
                    },
                  ),

                  // ============================================================
                  // TAB 2: ONGOING SLOT (API INTEGRATED - PENDING BOOKINGS)
                  // ============================================================
                  Obx(() {
                    print('🔄 Rebuilding Ongoing Slot tab');
                    return _buildApiListView(
                      bookings: pendingBookingsController.pendingBookings,
                      isLoading: pendingBookingsController.isLoading,
                      errorMessage: pendingBookingsController.errorMessage,
                      emptyMessage: 'No ongoing bookings yet',
                      status: 'Pending',
                      onRetry: () {
                        pendingBookingsController.fetchPendingBookings();
                      },
                      onCardTap: () {
                        // Get.toNamed(AppRoutes.bookingDetails);
                      },
                    );
                  }),

                  // ============================================================
                  // TAB 3: PAST SLOT (API INTEGRATED - COMPLETED BOOKINGS)
                  // ============================================================
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
                      onCardTap: () {
                        Get.toNamed(AppRoutes.reviewPage);
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

  void _showDeleteConfirmation(String bookingId, String status) {
    print('🗑️ Delete confirmation for $status booking: $bookingId');
    Get.dialog(
      AlertDialog(
        title: const Text('Remove Booking'),
        content: Text('Are you sure you want to remove this $status booking from your history?'),
        actions: [
          TextButton(
            onPressed: () {
              print('❌ Delete cancelled');
              Get.back();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              print('✅ Delete confirmed for booking: $bookingId');
              // You can add API call to delete booking here
              // _deleteBooking(bookingId);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}


