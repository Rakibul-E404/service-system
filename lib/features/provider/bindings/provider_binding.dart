import 'package:get/get.dart';
import 'package:manx_mate/features/provider/controllers/provider_profile_controller.dart';
import 'package:manx_mate/features/provider/widgets/switch.dart';
import '../controllers/availability_controller.dart';
import '../controllers/provider_controller.dart';

class ProviderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProviderController>(() => ProviderController());
    Get.lazyPut<ReminderController>(() => ReminderController());
    Get.lazyPut<ProviderProfileController>(() => ProviderProfileController());
    Get.lazyPut<AvailabilityController>(() => AvailabilityController());
  }
}
