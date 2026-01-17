/**

import 'package:get/get.dart';

class BookingController extends GetxController {

  final RxInt count = 0.obs;

  void increment() => count.value++;



  /// [onInit] Lifecycle method called when the controller is initialized.
  ///
  /// Resets loading states, clears existing data, and triggers and more..
  /// initial fetch
  ///
  @override
  void onInit() {
    super.onInit();
    count.value = 0;
  }

  /// [dispose] Lifecycle method called when the controller is destroyed.
  ///
  /// Cleans up by resetting loading states and clearing lists and more...
  @override
  void dispose() {
    super.dispose();
    count.value = 0;
  }
}









*/







// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../auth/screens/profile_service.dart';
// import '../screens/booking_tabs/tab_controllers/active_job_tab_controller.dart';
// import '../screens/booking_tabs/tab_controllers/ongoing_job_tab_controller.dart';
// import '../screens/booking_tabs/tab_controllers/past_job_tab_controller.dart';
// import '../screens/booking_tabs/tab_controllers/quote_job_tab_controller.dart';
//
// class BookingScreenController extends GetxController
//     with GetSingleTickerProviderStateMixin {
//   late TabController tabController;
//
//   final ProfileService profileService = Get.find<ProfileService>();
//
//   // Tab Controllers
//   final QuoteController quoteController = Get.put(QuoteController());
//   final ActiveJobController activeController = Get.put(ActiveJobController());
//   final OngoingJobController ongoingController = Get.put(OngoingJobController());
//   final PastJobController pastController = Get.put(PastJobController());
//
//   @override
//   void onInit() {
//     super.onInit();
//     tabController = TabController(length: 4, vsync: this);
//
//     tabController.addListener(_handleTabChange);
//
//     // Initial fetch after first frame
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (profileService.isLoggedIn.value) {
//         fetchAllTabs();
//       }
//     });
//   }
//
//   void _handleTabChange() {
//     if (!profileService.isLoggedIn.value) {
//       return;
//     }
//
//     switch (tabController.index) {
//       case 0:
//         quoteController.fetchQuotes();
//         break;
//       case 1:
//         activeController.fetchActiveJobs();
//         break;
//       case 2:
//         ongoingController.fetchOngoingJobs();
//         break;
//       case 3:
//         pastController.fetchPastJobs();
//         break;
//     }
//   }
//
//   void fetchAllTabs() {
//     quoteController.fetchQuotes();
//     activeController.fetchActiveJobs();
//     ongoingController.fetchOngoingJobs();
//     pastController.fetchPastJobs();
//   }
//
//   @override
//   void onClose() {
//     tabController.dispose();
//     super.onClose();
//   }
// }





import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/screens/profile_service.dart';
import '../screens/booking_tabs/tab_controllers/active_job_tab_controller.dart';
import '../screens/booking_tabs/tab_controllers/ongoing_job_tab_controller.dart';
import '../screens/booking_tabs/tab_controllers/past_job_tab_controller.dart';
import '../screens/booking_tabs/tab_controllers/quote_job_tab_controller.dart';

class BookingScreenController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;

  final ProfileService profileService = Get.find<ProfileService>();

  // Reactive variable to control navigation to active jobs tab
  final RxBool navigateToActiveJobsTab = false.obs;

  // Tab Controllers
  final QuoteController quoteController = Get.put(QuoteController());
  final ActiveJobController activeController = Get.put(ActiveJobController());
  final OngoingJobController ongoingController =
  Get.put(OngoingJobController());
  final PastJobController pastController = Get.put(PastJobController());

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 4, vsync: this);

    tabController.addListener(_handleTabChange);

    // Listen for navigation requests to active jobs tab
    ever(navigateToActiveJobsTab, (shouldNavigate) {
      if (shouldNavigate) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          tabController.animateTo(1); // Switch to Active Job tab (index 1)
          activeController.refreshActiveJobs(); // Refresh active jobs
          // Reset the flag after navigation
          navigateToActiveJobsTab.value = false;
        });
      }
    });

    // Initial fetch after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (profileService.isLoggedIn.value) {
        fetchAllTabs();
      }
    });
  }

  void _handleTabChange() {
    if (!profileService.isLoggedIn.value) return;

    switch (tabController.index) {
      case 0:
        quoteController.fetchQuotes();
        break;
      case 1:
        activeController.fetchActiveJobs();
        break;
      case 2:
        ongoingController.fetchOngoingJobs();
        break;
      case 3:
        pastController.fetchPastJobs();
        break;
    }
  }

  void fetchAllTabs() {
    quoteController.fetchQuotes();
    activeController.fetchActiveJobs();
    ongoingController.fetchOngoingJobs();
    pastController.fetchPastJobs();
  }


  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}



