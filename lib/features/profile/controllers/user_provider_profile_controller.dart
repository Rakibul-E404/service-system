
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/utils/api/app_url.dart';
import '../../../core/utils/token_service/token_storage_service.dart';
import '../model/user_provider_profile_response_model.dart';

class UserProviderProfileController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();

  // --- Observables ---
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // The core data model
  final Rxn<ProviderInfoData> providerData = Rxn<ProviderInfoData>();

  // --- Methods ---

  /// Fetch the provider profile by ID
  Future<void> fetchProviderProfile(String profileId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = await SharedPrefService().getAccessToken();
      if (token == null) {
        errorMessage.value = "Authentication required.";
        return;
      }

      final String url = AppUrl.userProviderProfile(profileId);

      final response = await _networkCaller.getRequest(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final profileResponse = UserProviderProfileResponseModel.fromJson(response.jsonResponse!);

        if (profileResponse.success && profileResponse.data != null) {
          providerData.value = profileResponse.data;
        } else {
          errorMessage.value = profileResponse.message;
        }
      } else {
        errorMessage.value = response.errorMessage ?? "Failed to load provider profile.";
      }
    } catch (e) {
      debugPrint("Error fetching provider profile: $e");
      errorMessage.value = "An unexpected error occurred.";
    } finally {
      isLoading.value = false;
    }
  }

  ProviderProfile? get profile => providerData.value?.profile;
  List<UserProviderService> get services => providerData.value?.services ?? [];
  bool get hasData => providerData.value != null;
}