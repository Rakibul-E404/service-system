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
  final isLoadingBanners = false.obs;

  // Observable lists
  final categories = <CategoryModel>[].obs;
  final subCategories = <SubCategoryModel>[].obs;
  final banners = <String>[].obs;

  // NEW: Maps for banner and category lookups
  final RxMap<int, String> bannerToCategoryMap = <int, String>{}.obs;
  final RxMap<int, String> bannerToCategoryIdMap = <int, String>{}.obs; // NEW: Store category IDs
  final RxMap<String, String> categoryNameToIdMap = <String, String>{}.obs; // NEW: Name -> ID mapping

  final NetworkCaller _networkCaller = NetworkCaller();

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchBanners();
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

        // Build name -> ID mapping
        categoryNameToIdMap.clear();
        for (var category in categoryRes.categories) {
          categoryNameToIdMap[category.name] = category.id;
        }

        debugPrint('✅ Category mappings created: ${categoryNameToIdMap.length} categories');
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// --- Fetch Banners (without auth) ---
  Future<void> fetchBanners() async {
    try {
      isLoadingBanners.value = true;
      banners.clear();
      bannerToCategoryMap.clear();
      bannerToCategoryIdMap.clear();

      final response = await _networkCaller.getRequest(AppUrl.allCategory);

      if (response.isSuccess && response.jsonResponse != null) {
        CategoryResponse categoryRes = CategoryResponse.fromJson(response.jsonResponse!);

        final List<String> bannerImages = [];
        int bannerIndex = 0;

        for (var category in categoryRes.categories) {
          if (category.bannerImage != null && category.bannerImage!.isNotEmpty) {
            final rawPath = category.bannerImage!;

            String fullUrl = rawPath;
            if (!rawPath.startsWith('http')) {
              final cleanPath = rawPath.startsWith('/')
                  ? rawPath.substring(1)
                  : rawPath;
              fullUrl = '${AppUrl.imageBaseUrl}/$cleanPath';
            }

            bannerImages.add(fullUrl);

            // Store both name and ID mappings
            bannerToCategoryMap[bannerIndex] = category.name;
            bannerToCategoryIdMap[bannerIndex] = category.id;

            debugPrint('🗺️ Banner $bannerIndex -> ${category.name} (ID: ${category.id})');
            bannerIndex++;
          }
        }

        banners.assignAll(bannerImages);
        debugPrint('✅ Loaded ${banners.length} banners with mappings');
      } else {
        debugPrint('❌ Failed to fetch banners');
      }
    } catch (e) {
      debugPrint('Error fetching banners: $e');
    } finally {
      isLoadingBanners.value = false;
    }
  }

  /// --- Get Category Name by Banner Index ---
  String? getCategoryNameByBannerIndex(int index) {
    return bannerToCategoryMap[index];
  }

  /// --- NEW: Get Category ID by Banner Index ---
  String? getCategoryIdByBannerIndex(int index) {
    return bannerToCategoryIdMap[index];
  }

  /// --- NEW: Get Category ID by Name ---
  String? getCategoryIdByName(String categoryName) {
    return categoryNameToIdMap[categoryName];
  }

  /// --- Fetch Sub-Categories ---
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

  Future<void> refreshBanners() async {
    await fetchBanners();
  }
}