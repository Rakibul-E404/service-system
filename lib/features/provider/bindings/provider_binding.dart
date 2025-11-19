
import 'package:get/get.dart';
import 'package:manx_mate/features/provider/controllers/provider_profile_controller.dart';
import 'package:manx_mate/features/provider/widgets/switch.dart';
import '../../home/widget/add_service_bottomsheet.dart';
import '../controllers/availability_controller.dart';
import '../controllers/provider_controller.dart';
import '../controllers/subscription_controller.dart';

class ProviderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProviderController>(() => ProviderController(), fenix: true);
    Get.lazyPut<ReminderController>(() => ReminderController(), fenix: true);
    Get.put<ProviderProfileController>(ProviderProfileController(), permanent: true); // Changed this line
    Get.lazyPut<AvailabilityController>(() => AvailabilityController(), fenix: true);
    Get.lazyPut<AddServiceCategoryController>(() => AddServiceCategoryController(), fenix: true);
    Get.lazyPut<SubscriptionController>(() => SubscriptionController());
  }
}