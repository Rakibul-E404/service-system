import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_colors.dart';
import '../../home/widget/home_top_bar.dart';
import '../controllers/booking_controller.dart';
import 'booking_tabs/active_job_tab_screen.dart';
import 'booking_tabs/ongoing_job_tab_screen.dart';
import 'booking_tabs/past_job_tab_screen.dart';
import 'booking_tabs/quote_job_tab_screen.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BookingScreenController controller =
    Get.put(BookingScreenController());

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          // Not logged in view
          if (!controller.profileService.isLoggedIn.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Icon(Icons.person_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Not Logged In',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text('Please login to view your bookings'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Get.offAllNamed('/role-selection');
                    },
                    child: const Text('Go to Login'),
                  ),
                ],
              ),
            );
          }

          // Logged in view
          return Column(
            children: [

              // Top bar
              const HomeTopBar(),

              // TabBar

                TabBar(
                  tabAlignment: TabAlignment.start,
                  controller: controller.tabController,
                  isScrollable: true,
                  indicatorColor: AppColors.primaryColor,
                  indicatorWeight: 4,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: AppColors.blackColor,
                  unselectedLabelColor: AppColors.greyColor,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold, // Bold selected text
                    fontSize: 16,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                  ),
                  tabs: const <Widget>[
                    Tab(text: "Quote"),
                    Tab(text: "Active Job"),
                    Tab(text: "Ongoing Job"),
                    Tab(text: "Past Job"),
                  ],
                ),


              // TabBarView
              Expanded(
                child: TabBarView(
                  controller: controller.tabController,
                  children: [
                    QuoteTab(controller: controller.quoteController),
                    ActiveJobTab(controller: controller.activeController),
                    OngoingJobTab(controller: controller.ongoingController),
                    PastJobTab(controller: controller.pastController),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

