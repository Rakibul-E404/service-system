import 'package:get/get.dart';
import '../../profile/controllers/profile_controller.dart'; // Import ProfileController
import '../controllers/notification_controller.dart';
import '../controllers/provider_details_controller.dart';
import '../controllers/sub_categories_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/home_service_details_controller.dart';
import '../controllers/search_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<HomeSearchController>(() => HomeSearchController());
    Get.lazyPut<HomeServiceDetailsController>(() => HomeServiceDetailsController());
    Get.lazyPut<SubCategoriesController>(() => SubCategoriesController());
    Get.lazyPut<ProviderDetailsController>(() => ProviderDetailsController());
    Get.lazyPut(() => NotificationController());

    // Use ProfileController instead of HomeTopBarController
    // This ensures the same controller instance is used across the app
    // Get.put(dependency)<ProfileController>(() => ProfileController(), fenix: true);
  }
}