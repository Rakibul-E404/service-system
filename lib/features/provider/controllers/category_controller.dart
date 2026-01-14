
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/network/network_caller.dart';
import '../../../core/utils/api/app_url.dart';
import '../../../core/utils/token_service/token_storage_service.dart';
import '../../home/model/categor_model.dart';
import '../../home/model/sub_category_model.dart';

class CategoryController extends GetxController {
  final isLoading = false.obs;
  final isSubLoading = false.obs;

  // Observable lists
  final categories = <CategoryModel>[].obs;
  final subCategories = <SubCategoryModel>[].obs;

  final NetworkCaller _networkCaller = NetworkCaller();

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<String?> _getAuthToken() async {
    return await SharedPrefService().getAccessToken();
  }

  // --- Fetch Main Categories ---
  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final token = await _getAuthToken();
      if (token == null) return;

      final response = await _networkCaller.getRequest(
        AppUrl.allCategory,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.isSuccess && response.jsonResponse != null) {
        CategoryResponse categoryRes = CategoryResponse.fromJson(response.jsonResponse!);
        // Using .categories as defined in your CategoryResponse
        categories.assignAll(categoryRes.categories);
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // --- Fetch Sub-Categories ---
  Future<void> fetchSubCategories(String categoryId) async {
    try {
      isSubLoading.value = true;
      subCategories.clear(); // Clear previous selection

      final token = await _getAuthToken();
      final url = AppUrl.getSubCategoriesUrl(categoryId);

      final response = await _networkCaller.getRequest(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.isSuccess && response.jsonResponse != null) {
        SubCategoryResponse subRes = SubCategoryResponse.fromJson(response.jsonResponse!);

        // FIX: Changed .data to .subCategories to match your Model
        if (subRes.subCategories.isNotEmpty) {
          subCategories.assignAll(subRes.subCategories);
        }
      }
    } catch (e) {
      debugPrint('Error fetching sub-categories: $e');
    } finally {
      isSubLoading.value = false;
    }
  }
}