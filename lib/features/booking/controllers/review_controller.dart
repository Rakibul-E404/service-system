import 'package:get/get.dart';

class ReviewController extends GetxController {
   RxDouble qualityRating = 3.0.obs;
  RxDouble timelinessRating = 3.0.obs;
  RxDouble professionalismRating = 3.0.obs;
  RxDouble valueForMoneyRating = 3.0.obs;
  RxDouble flexibilityRating = 3.0.obs;

  // Method to update the ratings
  void updateQualityRating(double rating) {
    qualityRating.value = rating;
  }

  void updateResponseTimeRating(double rating) {
    timelinessRating.value = rating;
  }

  void updateProfessionalismRating(double rating) {
    professionalismRating.value = rating;
  }

  void updateValurForMoney(double rating) {
    valueForMoneyRating.value = rating;
  }

  void updateFlexibilityRating(double rating) {
    flexibilityRating.value = rating;
  }
}
