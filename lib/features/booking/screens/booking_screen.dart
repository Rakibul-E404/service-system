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
      // Fetch active bookings when switching to Active Slot tab
      print('📥 Fetching active bookings for Active Slot...');
      activeSlotBookingsController.fetchActiveSlotBookings();
    } else if (_tabController.index == 1) {
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

  /// Helper method to build booking card from API data
  Widget _buildBookingCard(
      Map<String, dynamic> booking,
      String status,
      VoidCallback? onTap,
      ) {
    final service = booking['service'] ?? {};
    final subCategory = service['subCategory'] ?? {};
    final bookingId = booking['_id'] ?? '';

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
      status: status,
      tabIndex: _tabController.index,
      controller: activeSlotBookingsController, // Pass controller for active slot
      onTap: onTap ?? () {
        print('👆 Card tapped for booking: $bookingId');
      },
      onDelete: () async {
        // Handle delete action - this will be called after successful API deletion
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
    VoidCallback? onCardTap,
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
    if (errorMessage.isNotEmpty && bookings.isEmpty) {
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
                    // Profile Image
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

            /// ================================================================
            /// TAB BAR
            /// ================================================================
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

            /// ================================================================
            /// TAB BAR VIEW - Content for each tab
            /// ================================================================
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  /// ============================================================
                  /// TAB 1: ACTIVE SLOT (API INTEGRATED - ACCEPTED BOOKINGS)
                  /// ============================================================
                  Obx(() {
                    print('🔄 Rebuilding Active Slot tab');
                    return _buildApiListView(
                      bookings: activeSlotBookingsController.activeSlotBookings,
                      isLoading: activeSlotBookingsController.isLoading,
                      errorMessage: activeSlotBookingsController.errorMessage,
                      emptyMessage: 'No active bookings yet',
                      status: 'Active',
                      onRetry: () {
                        activeSlotBookingsController.fetchActiveSlotBookings();
                      },
                      onCardTap: () {
                        // Get.toNamed(AppRoutes.bookingDetails);
                      },
                    );
                  }),

                  /// ============================================================
                  /// TAB 2: ONGOING SLOT (API INTEGRATED - PENDING BOOKINGS)
                  /// ============================================================
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
}*/













///
///
///
///
/// todo:P::::: passing the serviceId
///
///
///
///








// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:manx_mate/core/config/app_colors.dart';
// import 'package:manx_mate/core/routes/app_routes.dart';
// import 'package:manx_mate/core/config/app_sizes.dart';
// import 'package:manx_mate/features/home/controllers/home_top_bar_controller.dart';
// import 'package:manx_mate/features/booking/widgets/booking_card.dart';
// import 'booking_screen_controller.dart';
//
// /// ============================================================================
// /// BOOKING SCREEN
// /// ============================================================================
// class BookingScreen extends StatefulWidget {
//   const BookingScreen({super.key});
//
//   @override
//   State<BookingScreen> createState() => _BookingScreenState();
// }
//
// class _BookingScreenState extends State<BookingScreen> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final ActiveSlotBookingsController activeSlotBookingsController = Get.put(ActiveSlotBookingsController());
//   final PendingBookingsController pendingBookingsController = Get.put(PendingBookingsController());
//   final CompletedBookingsController completedBookingsController = Get.put(CompletedBookingsController());
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//
//     // Add listener to fetch data when tab changes
//     _tabController.addListener(_handleTabChange);
//
//     // Fetch initial data for first tab
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       print('🚀 Initializing booking screen...');
//       activeSlotBookingsController.fetchActiveSlotBookings();
//       pendingBookingsController.fetchPendingBookings();
//       completedBookingsController.fetchCompletedBookings();
//     });
//   }
//
//   void _handleTabChange() {
//     print('🔁 Tab changed to index: ${_tabController.index}');
//     if (_tabController.index == 0) {
//       // Fetch active bookings when switching to Active Slot tab
//       print('📥 Fetching active bookings for Active Slot...');
//       activeSlotBookingsController.fetchActiveSlotBookings();
//     } else if (_tabController.index == 1) {
//       // Fetch pending bookings when switching to Ongoing Slot tab
//       print('📥 Fetching pending bookings for Ongoing Slot...');
//       pendingBookingsController.fetchPendingBookings();
//     } else if (_tabController.index == 2) {
//       // Fetch completed bookings when switching to Past Slot tab
//       print('📥 Fetching completed bookings for Past Slot...');
//       completedBookingsController.fetchCompletedBookings();
//     }
//   }
//
//   @override
//   void dispose() {
//     _tabController.removeListener(_handleTabChange);
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   /// Helper method to build booking card from API data
//   Widget _buildBookingCard(
//       Map<String, dynamic> booking,
//       String status,
//       VoidCallback? onTap,
//       ) {
//     final service = booking['service'] ?? {};
//     final subCategory = service['subCategory'] ?? {};
//     final bookingId = booking['_id'] ?? '';
//     final serviceId = service['_id'] ?? ''; // Extract serviceId
//
//     print('🎴 Building card for booking: $bookingId');
//
//     // Construct full image URL
//     String imageUrl;
//     final imagePath = service['image'];
//
//     if (imagePath != null && imagePath.toString().isNotEmpty) {
//       if (imagePath.toString().startsWith('http')) {
//         imageUrl = imagePath;
//       } else {
//         String cleanPath = imagePath.toString().replaceFirst(RegExp(r'^/'), '');
//         imageUrl = 'https://d7001.sobhoy.com/$cleanPath';
//       }
//     } else {
//       imageUrl = 'https://images.unsplash.com/photo-1494790108755-2616b772390e?w=400&h=300&fit=crop';
//     }
//
//     return HorizontalServiceCard(
//       imageUrl: imageUrl,
//       title: service['name'] ?? 'Unknown Service',
//       subtitle: subCategory['name'] ?? 'General',
//       description: service['description'] ?? 'No description available',
//       bookingId: bookingId,
//       serviceId: serviceId, // Pass serviceId to the card
//       status: status,
//       tabIndex: _tabController.index,
//       controller: activeSlotBookingsController, // Pass controller for active slot
//       onTap: onTap ?? () {
//         print('👆 Card tapped for booking: $bookingId');
//       },
//       onDelete: () async {
//         // Handle delete action - this will be called after successful API deletion
//         print('✅ Booking deleted successfully from UI callback');
//       },
//     );
//   }
//
//   // Helper method to build API data list view
//   Widget _buildApiListView({
//     required RxList<Map<String, dynamic>> bookings,
//     required RxBool isLoading,
//     required RxString errorMessage,
//     required String emptyMessage,
//     required String status,
//     required VoidCallback onRetry,
//     required Function(Map<String, dynamic>) onCardTap, // Changed to accept booking data
//   }) {
//     print('📱 Building $status list view');
//     print('📊 Bookings count: ${bookings.length}');
//     print('🔄 Loading: ${isLoading.value}');
//     print('❌ Error: ${errorMessage.value}');
//
//     // LOADING STATE
//     if (isLoading.value && bookings.isEmpty) {
//       print('⏳ Showing loading indicator for $status');
//       return const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(
//               color: AppColors.primaryColor,
//             ),
//             SizedBox(height: 16),
//             Text(
//               'Loading bookings...',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.black54,
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//
//     // ERROR STATE
//     if (errorMessage.isNotEmpty && bookings.isEmpty) {
//       print('🚨 Showing error state for $status: ${errorMessage.value}');
//       return Center(
//         child: Padding(
//           padding: const EdgeInsets.all(AppSizes.lg),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.error_outline,
//                 size: 60,
//                 color: Colors.red.shade300,
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 errorMessage.value,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   color: Colors.black54,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 24),
//               ElevatedButton.icon(
//                 onPressed: onRetry,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primaryColor,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 24,
//                     vertical: 12,
//                   ),
//                 ),
//                 icon: const Icon(Icons.refresh),
//                 label: const Text('Retry'),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//
//     // EMPTY STATE
//     if (bookings.isEmpty) {
//       print('📭 Showing empty state for $status');
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.history,
//               size: 60,
//               color: Colors.grey.shade400,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               emptyMessage,
//               style: const TextStyle(
//                 fontSize: 16,
//                 color: Colors.black54,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Your $status bookings will appear here',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey.shade500,
//               ),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton.icon(
//               onPressed: onRetry,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primaryColor,
//                 foregroundColor: Colors.white,
//               ),
//               icon: const Icon(Icons.refresh),
//               label: const Text('Refresh'),
//             ),
//           ],
//         ),
//       );
//     }
//
//     // SUCCESS STATE - Display bookings
//     print('✅ Showing ${bookings.length} $status bookings');
//     return RefreshIndicator(
//       onRefresh: () async {
//         print('🔄 Pull to refresh triggered for $status');
//         onRetry();
//       },
//       color: AppColors.primaryColor,
//       child: ListView.separated(
//         padding: const EdgeInsets.symmetric(
//           horizontal: AppSizes.md,
//           vertical: AppSizes.lg,
//         ),
//         physics: const AlwaysScrollableScrollPhysics(),
//         itemCount: bookings.length,
//         itemBuilder: (BuildContext context, int index) {
//           print('📦 Building item $index for $status');
//           return _buildBookingCard(
//               bookings[index],
//               status,
//                   () => onCardTap(bookings[index]) // Pass the specific booking data
//           );
//         },
//         separatorBuilder: (BuildContext context, int index) {
//           return const Column(
//             children: <Widget>[
//               Divider(),
//               SizedBox(height: AppSizes.md),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final HomeTopBarController controller = Get.put(HomeTopBarController());
//
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: <Widget>[
//             // ================================================================
//             // TOP BAR - Profile Avatar and Bell Icon
//             // ================================================================
//             Card(
//               elevation: 2,
//               color: AppColors.whiteColor,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: AppSizes.md,
//                   vertical: AppSizes.lg,
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: <Widget>[
//                     // Profile Image
//                     Obx(() {
//                       final imageUrl = controller.getImageUrl();
//                       return CircleAvatar(
//                         radius: 30,
//                         backgroundImage: imageUrl.isNotEmpty
//                             ? NetworkImage(imageUrl)
//                             : null,
//                         child: imageUrl.isEmpty
//                             ? const Icon(
//                           Icons.person,
//                           size: 50,
//                           color: Colors.grey,
//                         )
//                             : null,
//                       );
//                     }),
//
//                     // Bell Icon Button
//                     Container(
//                       decoration: BoxDecoration(
//                         color: AppColors.whiteColor,
//                         border: Border.all(color: AppColors.primaryColor),
//                         borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
//                       ),
//                       child: IconButton(
//                         onPressed: () {
//                           Get.toNamed(AppRoutes.notificationPage);
//                         },
//                         icon: const Icon(
//                           CupertinoIcons.bell,
//                           color: AppColors.primaryColor,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//             /// ================================================================
//             /// TAB BAR
//             /// ================================================================
//             PreferredSize(
//               preferredSize: const Size.fromHeight(50.0),
//               child: Container(
//                 color: Colors.white,
//                 child: TabBar(
//                   controller: _tabController,
//                   dividerColor: Colors.transparent,
//                   isScrollable: true,
//                   indicatorColor: AppColors.primaryColor,
//                   indicatorWeight: 5,
//                   tabAlignment: TabAlignment.center,
//                   labelColor: Colors.black87,
//                   labelStyle: const TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 18,
//                   ),
//                   unselectedLabelStyle: const TextStyle(
//                     fontWeight: FontWeight.w400,
//                     fontSize: 14,
//                   ),
//                   tabs: const <Widget>[
//                     Tab(text: "Active Slot"),
//                     Tab(text: "Ongoing Slot"),
//                     Tab(text: "Past Slot"),
//                   ],
//                 ),
//               ),
//             ),
//
//             // Divider
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
//               child: Divider(
//                 thickness: 1,
//                 color: Colors.grey.withOpacity(0.3),
//               ),
//             ),
//
//             /// ================================================================
//             /// TAB BAR VIEW - Content for each tab
//             /// ================================================================
//             Expanded(
//               child: TabBarView(
//                 controller: _tabController,
//                 children: <Widget>[
//                   /// ============================================================
//                   /// TAB 1: ACTIVE SLOT (API INTEGRATED - ACCEPTED BOOKINGS)
//                   /// ============================================================
//                   Obx(() {
//                     print('🔄 Rebuilding Active Slot tab');
//                     return _buildApiListView(
//                       bookings: activeSlotBookingsController.activeSlotBookings,
//                       isLoading: activeSlotBookingsController.isLoading,
//                       errorMessage: activeSlotBookingsController.errorMessage,
//                       emptyMessage: 'No active bookings yet',
//                       status: 'Active',
//                       onRetry: () {
//                         activeSlotBookingsController.fetchActiveSlotBookings();
//                       },
//                       onCardTap: (Map<String, dynamic> booking) {
//                         print('👆 Active booking tapped: ${booking['_id']}');
//                         // Add navigation for active bookings if needed
//                         // Get.toNamed(AppRoutes.bookingDetails);
//                       },
//                     );
//                   }),
//
//                   /// ============================================================
//                   /// TAB 2: ONGOING SLOT (API INTEGRATED - PENDING BOOKINGS)
//                   /// ============================================================
//                   Obx(() {
//                     print('🔄 Rebuilding Ongoing Slot tab');
//                     return _buildApiListView(
//                       bookings: pendingBookingsController.pendingBookings,
//                       isLoading: pendingBookingsController.isLoading,
//                       errorMessage: pendingBookingsController.errorMessage,
//                       emptyMessage: 'No ongoing bookings yet',
//                       status: 'Pending',
//                       onRetry: () {
//                         pendingBookingsController.fetchPendingBookings();
//                       },
//                       onCardTap: (Map<String, dynamic> booking) {
//                         print('👆 Ongoing booking tapped: ${booking['_id']}');
//                         // Add navigation for ongoing bookings if needed
//                         // Get.toNamed(AppRoutes.bookingDetails);
//                       },
//                     );
//                   }),
//
//                   /// ============================================================
//                   /// TAB 3: PAST SLOT (API INTEGRATED - COMPLETED BOOKINGS)
//                   /// ============================================================
//                   Obx(() {
//                     print('🔄 Rebuilding Past Slot tab');
//                     return _buildApiListView(
//                       bookings: completedBookingsController.completedBookings,
//                       isLoading: completedBookingsController.isLoading,
//                       errorMessage: completedBookingsController.errorMessage,
//                       emptyMessage: 'No completed bookings yet',
//                       status: 'Completed',
//                       onRetry: () {
//                         completedBookingsController.fetchCompletedBookings();
//                       },
//                       onCardTap: (Map<String, dynamic> booking) {
//                         // Extract serviceId from the specific booking that was tapped
//                         final service = booking['service'] ?? {};
//                         final serviceId = service['_id'] ?? '';
//
//                         print('🎯 Navigating to review page with serviceId: $serviceId for booking: ${booking['_id']}');
//
//                         if (serviceId.isNotEmpty) {
//                           Get.toNamed(
//                             AppRoutes.reviewPage,
//                             parameters: {'serviceId': serviceId},
//                           );
//                         } else {
//                           print('❌ Service ID not found for booking: ${booking['_id']}');
//                           Get.snackbar(
//                             'Error',
//                             'Service information not available for review',
//                             backgroundColor: Colors.red,
//                             colorText: Colors.white,
//                           );
//                         }
//                       },
//                     );
//                   }),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }





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
}