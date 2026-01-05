import 'package:get/get.dart';

class OngoingJobController extends GetxController {
  var ongoingJobs = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  void fetchOngoingJobs() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    ongoingJobs.value = [
      {'_id': 'o1', 'service': {'name': 'Massage', 'description': 'Accepted'}}
    ];
    isLoading.value = false;
  }
}