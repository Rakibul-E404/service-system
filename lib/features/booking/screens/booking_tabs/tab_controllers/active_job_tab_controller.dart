import 'package:get/get.dart';

class ActiveJobController extends GetxController {
  RxList<Map<String, dynamic>> activeJobs = <Map<String, dynamic>>[].obs;
  RxBool isLoading = false.obs;

  void fetchActiveJobs() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    activeJobs.value = [
      {'_id': 'a1', 'service': {'name': 'Haircut', 'description': 'Pending'}}
    ];
    isLoading.value = false;
  }
}