import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/routes/app_routes.dart';

import '../../../core/config/app_sizes.dart';
import '../widgets/booking_card.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // Initialize TabController with 3 tabs
  }

  @override
  void dispose() {
    _tabController.dispose(); // Dispose the TabController when done
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Top Container (Profile Avatar and Bell Icon)
            Card(
              elevation: 2,
              color: AppColors.whiteColor,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(
                        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=300&fit=crop',
                      ),
                    ),
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

            // TabBar
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
              child: Divider(thickness: 1, color: Colors.grey.withValues(alpha: 0.3)),
            ),

            // TabBarView with the same controller
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  // Active Slot Tab
                  ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: AppSizes.lg,
                    ),

                    shrinkWrap: true,
                    itemCount: 5,
                    // Increased count for testing
                    itemBuilder: (BuildContext context, int index) {
                      return HorizontalServiceCard(
                        imageUrl:
                            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=300&fit=crop',
                        title: 'TutorPro Academy $index',
                        subtitle: 'Children & Education',
                        location: 'Cork, Ireland',
                        rating: "4.9",
                        onTap: () {
                          // print('Active card $index tapped');
                        },

                        onDelete: () {
                          // print('Respond to active card $index');
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

                  // Ongoing Slot Tab
                  ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: AppSizes.lg,
                    ),

                    itemCount: 3,
                    itemBuilder: (BuildContext context, int index) {
                      return HorizontalServiceCard(
                        imageUrl:
                            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=300&fit=crop',
                        title: 'Ongoing Service $index',
                        subtitle: 'Math & Science',
                        location: 'Dublin, Ireland',
                        rating: "4.7",
                        onTap: () {
                          // print('Ongoing card $index tapped');
                        },

                        onDelete: () {
                          // print('View ongoing card $index');
                        },
                        status: "Requested",
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

                  // Past Slot Tab
                  ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: AppSizes.lg,
                    ),

                    itemCount: 8,
                    itemBuilder: (BuildContext context, int index) {
                      return HorizontalServiceCard(
                        imageUrl:
                            'https://images.unsplash.com/photo-1494790108755-2616b772390e?w=400&h=300&fit=crop',
                        title: 'Past Service $index',
                        subtitle: 'Language & Arts',
                        location: 'Galway, Ireland',
                        rating: "4.8",
                        onTap: () {
                          Get.toNamed(AppRoutes.reviewPage);
                        },

                        onDelete: () {
                          // print('Review past card $index');
                        },
                        status: 'Completed',
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
