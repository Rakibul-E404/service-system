/**

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
}*/












///
///
/// todo::: showing the banner
///
///




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
  final isLoadingBanners = false.obs; // Add this for banner loading state

  // Observable lists
  final categories = <CategoryModel>[].obs;
  final subCategories = <SubCategoryModel>[].obs;
  final banners = <String>[].obs; // Add this for banners

  final NetworkCaller _networkCaller = NetworkCaller();

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchBanners(); // Call this for banners
  }

  Future<String?> _getAuthToken() async {
    return await SharedPrefService().getAccessToken();
  }

  // --- Fetch Main Categories (with auth) ---
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
        categories.assignAll(categoryRes.categories);
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // --- NEW: Fetch Banners (without auth) ---
  Future<void> fetchBanners() async {
    try {
      isLoadingBanners.value = true;
      banners.clear();

      // Fetch WITHOUT authentication token
      final response = await _networkCaller.getRequest(
        AppUrl.allCategory, // Using same endpoint but without auth
        // No headers - public access
      );

      if (response.isSuccess && response.jsonResponse != null) {
        CategoryResponse categoryRes = CategoryResponse.fromJson(response.jsonResponse!);

        // Extract banners from categories that have bannerImage
        final List<String> bannerImages = [];

        for (var category in categoryRes.categories) {
          if (category.bannerImage != null && category.bannerImage!.isNotEmpty) {
            final rawPath = category.bannerImage!;

            // Construct full URL if needed
            String fullUrl = rawPath;
            if (!rawPath.startsWith('http')) {
              final cleanPath = rawPath.startsWith('/')
                  ? rawPath.substring(1)
                  : rawPath;
              fullUrl = '${AppUrl.imageBaseUrl}/$cleanPath';
            }

            bannerImages.add(fullUrl);
          }
        }

        banners.assignAll(bannerImages);

        debugPrint('✅ Loaded ${banners.length} banners');
      } else {
        debugPrint('❌ Failed to fetch banners');
      }
    } catch (e) {
      debugPrint('Error fetching banners: $e');
      // If API fails, you can set some default banners here
      banners.assignAll([
        'https://via.placeholder.com/800x400/3B82F6/FFFFFF?text=Banner+1',
        'https://via.placeholder.com/800x400/10B981/FFFFFF?text=Banner+2',
      ]);
    } finally {
      isLoadingBanners.value = false;
    }
  }

  // --- Fetch Sub-Categories ---
  Future<void> fetchSubCategories(String categoryId) async {
    try {
      isSubLoading.value = true;
      subCategories.clear();

      final token = await _getAuthToken();
      final url = AppUrl.getSubCategoriesUrl(categoryId);

      final response = await _networkCaller.getRequest(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.isSuccess && response.jsonResponse != null) {
        SubCategoryResponse subRes = SubCategoryResponse.fromJson(response.jsonResponse!);
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

  // Refresh banners
  Future<void> refreshBanners() async {
    await fetchBanners();
  }
}