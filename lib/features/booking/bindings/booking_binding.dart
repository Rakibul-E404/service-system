/**
import 'package:get/get.dart';
import '../controllers/booking_controller.dart';
import '../controllers/review_controller.dart';

class BookingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookingController>(() => BookingController());
    Get.lazyPut<ReviewController>(() => ReviewController());
  }
}
*/




///
///
///
/// todo:: deviding the bookings into files
///
///
///
///




import 'package:get/get.dart';
import '../controllers/booking_controller.dart';
import '../controllers/review_controller.dart';
import '../screens/booking_tabs/tab_controllers/active_job_tab_controller.dart';
import '../screens/booking_tabs/tab_controllers/ongoing_job_tab_controller.dart';
import '../screens/booking_tabs/tab_controllers/past_job_tab_controller.dart';
import '../screens/booking_tabs/tab_controllers/quote_job_tab_controller.dart';

class BookingBinding extends Bindings {
  @override
  void dependencies() {
    // Main Booking Screen Controller
    Get.lazyPut<BookingScreenController>(() => BookingScreenController());

    // Tab Controllers
    Get.lazyPut<QuoteController>(() => QuoteController());
    Get.lazyPut<ActiveJobController>(() => ActiveJobController());
    Get.lazyPut<OngoingJobController>(() => OngoingJobController());
    Get.lazyPut<PastJobController>(() => PastJobController());

    // Additional Controllers
    Get.lazyPut<ReviewController>(() => ReviewController());
  }
}
