import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/features/provider/screens/booking_tabs/provider_ongoing_controller.dart';
import '../../booking/screens/booking_tabs/quote_job_tab_screen.dart';
import 'booking_tabs/complete_tab.dart';
import 'booking_tabs/ongoing_tab.dart';
import 'booking_tabs/provider_complete_controller.dart';
import 'booking_tabs/provider_quote_controller.dart';
import 'booking_tabs/provider_request_controller.dart';
import 'booking_tabs/quote_tab.dart';
import 'booking_tabs/request_tab.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProviderServicesScreen extends StatefulWidget {
  const ProviderServicesScreen({super.key});

  @override
  State<ProviderServicesScreen> createState() => _ProviderServicesScreenState();
}

class _ProviderServicesScreenState extends State<ProviderServicesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Initialize controllers
  final ProviderQuoteController quoteController = Get.put(ProviderQuoteController());
  final ProviderRequestController requestController = Get.put(ProviderRequestController());
  final ProviderOngoingController pendingController = Get.put(ProviderOngoingController());
  final ProviderCompleteController completeController = Get.put(ProviderCompleteController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    _tabController.addListener(() {
      // Fetch data when switching tabs
      if (!_tabController.indexIsChanging) {
        final int index = _tabController.index;
        switch (index) {
          case 0:
            quoteController.fetchBookings();
            break;
          case 1:
            requestController.fetchBookings();
            break;
          case 2:
            pendingController.fetchBookings();
            break;
          case 3:
            completeController.fetchBookings();
            break;
        }
      }
    });

    // Initial data fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      quoteController.fetchBookings();
      requestController.fetchBookings();
      pendingController.fetchBookings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Title
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Bookings',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Tab Bar
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                isScrollable: true,
                indicatorColor: Colors.blue,
                indicatorWeight: 3,
                labelColor: Colors.black87,
                unselectedLabelColor: Colors.grey[600],
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
                tabs: const <Widget>[
                  Tab(text: "Quote"),
                  Tab(text: "Request"),
                  Tab(text: "Ongoing"),
                  Tab(text: "Complete"),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const <Widget>[
                  ProviderQuoteTab(),
                  RequestTab(),
                  OngoingTab(),
                  CompleteTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}