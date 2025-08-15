import 'package:get/get.dart';

class SignUpController extends GetxController {

  final RxBool isTermsAndConditionAgreementAccept = false.obs;
  set updateTermsAndConditionAgreementStatus(bool? value){
    if(value != null){
      isTermsAndConditionAgreementAccept.value = value;
    }
  }

  /// [onInit] Lifecycle method called when the controller is initialized.
  ///
  /// Resets loading states, clears existing data, and triggers and more..
  /// initial fetch
  /// 
  @override
  void onInit() {
    super.onInit();
    isTermsAndConditionAgreementAccept.value = false;
  }

  /// [dispose] Lifecycle method called when the controller is destroyed.
  ///
  /// Cleans up by resetting loading states and clearing lists and more...
  @override
  void dispose() {
    isTermsAndConditionAgreementAccept.value = false;
    super.dispose();
  }
}
