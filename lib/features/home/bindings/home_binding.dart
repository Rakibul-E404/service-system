
import 'package:get/get.dart';
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


  }
}









