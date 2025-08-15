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
