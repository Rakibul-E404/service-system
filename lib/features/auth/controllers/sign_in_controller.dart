import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_strings.dart';
import '../../../core/config/app_constants.dart';
import '../../../core/data/secured_storage.dart';
import '../../../core/routes/app_routes.dart';

class SignInController extends GetxController {
  final RxBool isLoading = false.obs;
  RxString? savedRole = ''.obs;

  Future<void> handleSignIn() async {
    isLoading.value = true;

    Future<dynamic>.delayed(const Duration(seconds: 1));
    final String? savedRole = await SecureStorageService().read(AppConstants.roleType);
    Get.toNamed(
      savedRole == AppStrings.user
          ? AppRoutes.mainBottomNavPage
          : AppRoutes.providerMainBottomNavPage,
    );

    isLoading.value = false;
  }

  final RxBool isTermsAndConditionAgreementAccept = false.obs;

  set updateTermsAndConditionAgreementStatus(bool? value) {
    if (value != null) {
      isTermsAndConditionAgreementAccept.value = value;
    }
  }

  /// [onInit] Lifecycle method called when the controller is initialized.
  ///
  /// Resets loading states, clears existing data, and triggers and more..
  /// initial fetch
  ///
  @override
  Future<void> onInit() async {
    super.onInit();
    savedRole?.value = await SecureStorageService().read(AppConstants.roleType) ?? '';
    isLoading.value = false;
    isTermsAndConditionAgreementAccept.value = false;
  }

  /// [dispose] Lifecycle method called when the controller is destroyed.
  ///
  /// Cleans up by resetting loading states and clearing lists and more...
  @override
  void dispose() {
    isLoading.value = false;
    isTermsAndConditionAgreementAccept.value = false;
    super.dispose();
  }
}
