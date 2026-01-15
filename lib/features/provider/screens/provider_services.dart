import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/features/booking/controllers/booking_action_controller.dart';
import 'package:manx_mate/features/provider/screens/booking_tabs/provider_ongoing_controller.dart';
import '../../../shared/subscriptions_controller.dart';
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
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Safe initialization of controllers using isRegistered
  final ProviderQuoteController quoteController = Get.isRegistered<ProviderQuoteController>()
      ? Get.find<ProviderQuoteController>()
      : Get.put(ProviderQuoteController());

  final ProviderRequestController requestController = Get.isRegistered<ProviderRequestController>()
      ? Get.find<ProviderRequestController>()
      : Get.put(ProviderRequestController());

  final ProviderOngoingController pendingController = Get.isRegistered<ProviderOngoingController>()
      ? Get.find<ProviderOngoingController>()
      : Get.put(ProviderOngoingController());

  final ProviderCompleteController completeController = Get.isRegistered<ProviderCompleteController>()
      ? Get.find<ProviderCompleteController>()
      : Get.put(ProviderCompleteController());

  final BookingActionController actionController = Get.isRegistered<BookingActionController>()
      ? Get.find<BookingActionController>()
      : Get.put(BookingActionController());

  void _fetchDataForIndex(int index) {
    // 🔹 Logic check: Don't fetch Quote data if they don't have access
    final subController = Get.find<SubscriptionsController>();

    switch (index) {
      case 0:
        if (subController.canAccessQuotes) {
          if (quoteController.bookings.isEmpty) {
            quoteController.fetchBookings(refresh: true);
          }
        }
        break;
      case 1:
        if (requestController.bookings.isEmpty) {
          requestController.fetchBookings(refresh: true);
        }
        break;
      case 2:
        if (pendingController.bookings.isEmpty) {
          pendingController.fetchBookings(refresh: true);
        }
        break;
      case 3:
        if (completeController.bookings.isEmpty) {
          completeController.fetchBookings(refresh: true);
        }
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // 1. Force clear everything so the UI starts fresh
    quoteController.bookings.clear();
    requestController.bookings.clear();
    pendingController.bookings.clear();
    completeController.bookings.clear();

    // 2. Listener for tab switches
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _fetchDataForIndex(_tabController.index);
      }
    });

    // 3. Initial fetch for the first tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDataForIndex(0);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🔹 Ensure SubscriptionsController is registered
    final SubscriptionsController subController = Get.isRegistered<SubscriptionsController>()
        ? Get.find<SubscriptionsController>()
        : Get.put(SubscriptionsController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
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
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
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
                children: <Widget>[
                  // 🔹 Quote Tab with Premium Access Logic
                  Obx(() {
                    if (subController.canAccessQuotes) {
                      return const ProviderQuoteTab();
                    } else {
                      return _buildLockedTabOverlay();
                    }
                  }),
                  const RequestTab(),
                  const OngoingTab(),
                  const CompleteTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedTabOverlay() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.lock_outline, size: 64, color: Colors.amber[800]),
            ),
            const SizedBox(height: 24),
            const Text(
              "Premium Feature",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              "The Quote feature is available for Premium members. Upgrade your plan to see and respond to customer inquiries.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[800],
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Get.snackbar(
                  "Premium Upgrade Required",
                  "Upgrade to a Premium plan to unlock Quotes and grow your business.",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.amber[800],
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(15),
                  duration: const Duration(seconds: 4),
                  icon: const Icon(Icons.stars, color: Colors.white),
                );
              },
              child: const Text("Upgrade Now", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}