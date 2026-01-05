import 'package:get/get.dart';

class PastJobController extends GetxController {
  var pastJobs = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  void fetchPastJobs() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    pastJobs.value = [
      {'_id': 'p1', 'service': {'name': 'Manicure', 'description': 'Completed'}}
    ];
    isLoading.value = false;
  }
}