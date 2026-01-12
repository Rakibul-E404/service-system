import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';

// ==============================================
// MODEL: Advertisement Model
// ==============================================

class Advertisement {
  final String id;
  final String title; // Fallback only (not in API)
  final String image; // Mapped from 'content'
  final String profileId; // Mapped from 'profileId'

  Advertisement({
    required this.id,
    required this.title,
    required this.image,
    required this.profileId,
  });

  factory Advertisement.fromJson(Map<String, dynamic> json) {
    return Advertisement(
      id: json['_id']?.toString() ?? '',
      title: 'Sponsored Ad', // API doesn't provide title
      image: json['content']?.toString() ?? '',
      profileId: json['profileId']?.toString() ?? '',
    );
  }

  String get fullImageUrl {
    if (image.isEmpty) return '';
    if (image.startsWith('http')) return image;
    // ✅ Clean URL — no extra spaces!
    return 'https://d7001.sobhoy.com/$image';
  }
}

// ==============================================
// CONTROLLER: AdvertisementController
// ==============================================

class AdvertisementController extends GetxController {
  RxList<Advertisement> advertisements = <Advertisement>[].obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;
  RxInt currentCarouselIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAdvertisements();
  }

  Future<void> fetchAdvertisements() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      advertisements.clear();

      debugPrint('📍 Fetching ads from: ${AppUrl.getAllAdvertisement}');

      final response = await GetConnect().get(
        AppUrl.getAllAdvertisement,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _handleSuccess(response.body);
      } else {
        _handleError('Failed to load ads. Status: ${response.statusCode}');
      }
    } catch (e) {
      _handleException(e);
    } finally {
      isLoading.value = false;
    }
  }

  void _handleSuccess(dynamic body) {
    try {
      final json = body is String ? jsonDecode(body) : body as Map?;

      if (json?['success'] == true && json?['data'] is List) {
        final List<dynamic> adsData = json!['data'];
        final List<Advertisement> ads = [];

        for (var item in adsData) {
          if (item is Map<String, dynamic>) {
            ads.add(Advertisement.fromJson(item));
          }
        }

        advertisements.assignAll(ads);

        if (ads.isEmpty) {
          errorMessage.value = 'No advertisements available';
        }
      } else {
        errorMessage.value = json?['message']?.toString() ?? 'Unexpected response format';
      }
    } catch (e) {
      debugPrint('❌ Parse error: $e');
      errorMessage.value = 'Failed to process ad data';
    }
  }

  void _handleError(String message) {
    errorMessage.value = message;
  }

  void _handleException(dynamic e) {
    if (e.toString().contains('SocketException') ||
        e.toString().contains('Connection refused') ||
        e.toString().contains('Failed host lookup')) {
      errorMessage.value = 'No internet connection';
    } else if (e is FormatException) {
      errorMessage.value = 'Invalid data received';
    } else {
      errorMessage.value = 'Failed to load advertisements';
    }
    debugPrint('💥 Ad fetch error: $e');
  }

  void updateCarouselIndex(int index) {
    if (index >= 0 && index < advertisements.length) {
      currentCarouselIndex.value = index;
    }
  }

  void retryFetch() {
    fetchAdvertisements();
  }

  bool get hasAdvertisements => advertisements.isNotEmpty;
  int get adCount => advertisements.length;
}

// ==============================================
// WIDGET: AdvertisementsSection
// ==============================================

class AdvertisementsSection extends StatelessWidget {
  const AdvertisementsSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure only one instance (safe in StatelessWidget)
    if (!Get.isRegistered<AdvertisementController>()) {
      Get.put(AdvertisementController(), permanent: false);
    }

    return GetBuilder<AdvertisementController>(
      builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(controller),
            Obx(() => _buildContent(controller)),
          ],
        );
      },
    );
  }

  Widget _buildHeader(AdvertisementController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenHorizontal),
      child: Row(
        children: [
          Icon(Icons.campaign_rounded, color: AppColors.primaryColor, size: 24),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Featured Advertisements',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87),
            ),
          ),
          if (controller.hasAdvertisements)
            Obx(() => Text(
              '${controller.currentCarouselIndex.value + 1}/${controller.adCount}',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            )),
        ],
      ),
    );
  }

  Widget _buildContent(AdvertisementController controller) {
    if (controller.isLoading.value && !controller.hasAdvertisements) {
      return _buildLoading();
    }
    if (controller.errorMessage.isNotEmpty) {
      return _buildError(controller);
    }
    if (!controller.hasAdvertisements) {
      return _buildEmpty(controller);
    }
    return _buildCarousel(controller);
  }

  Widget _buildLoading() {
    return Container(
      height: 180,
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.screenHorizontal, vertical: AppSizes.lg),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primaryColor),
            SizedBox(height: AppSizes.md),
            Text('Loading ads...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildError(AdvertisementController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.screenHorizontal, vertical: AppSizes.lg),
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Column(
        children: [
          Icon(Icons.error, color: Colors.red.shade400, size: 48),
          const SizedBox(height: AppSizes.md),
          Text(controller.errorMessage as String, textAlign: TextAlign.center, style: TextStyle(color: Colors.red.shade700)),
          const SizedBox(height: AppSizes.md),
          ElevatedButton.icon(
            onPressed: controller.retryFetch,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(AdvertisementController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.screenHorizontal, vertical: AppSizes.lg),
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.campaign_outlined, color: Colors.grey.shade400, size: 48),
          const SizedBox(height: AppSizes.md),
          const Text('No ads available', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: AppSizes.md),
          ElevatedButton.icon(
            onPressed: controller.retryFetch,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarousel(AdvertisementController controller) {
    return Column(
      children: [
        const SizedBox(height: AppSizes.md),
        CarouselSlider.builder(
          itemCount: controller.adCount,
          itemBuilder: (context, index, realIndex) {
            final ad = controller.advertisements[index];
            return _buildAdCard(ad);
          },
          options: CarouselOptions(
            height: 300,
            viewportFraction: 0.85,
            enlargeCenterPage: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            pauseAutoPlayOnTouch: true,
            onPageChanged: (index, reason) => controller.updateCarouselIndex(index),
          ),
        ),
        const SizedBox(height: AppSizes.md),
        _buildIndicators(controller),
      ],
    );
  }

  Widget _buildIndicators(AdvertisementController controller) {
    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        controller.adCount,
            (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: controller.currentCarouselIndex.value == index ? 20 : 8,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: controller.currentCarouselIndex.value == index
                ? AppColors.primaryColor
                : Colors.grey.shade300,
          ),
        ),
      ),
    ));
  }

  Widget _buildAdCard(Advertisement ad) {
    return GestureDetector(
      onTap: () => Get.snackbar('Advertisement', 'Ad tapped', backgroundColor: AppColors.primaryColor.withOpacity(0.9), colorText: Colors.white),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              Expanded(
                child: _buildImage(ad.fullImageUrl),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('AD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(ad.title, style: const TextStyle(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String url) {
    if (url.isEmpty) {
      return Container(
        color: Colors.grey.shade100,
        child: const Icon(Icons.image, size: 60, color: Colors.grey),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? progress) => progress == null ? child : Container(color: Colors.grey.shade100, child: const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))),
      errorBuilder: (BuildContext context, Object error, StackTrace? stack) => Container(
        color: Colors.grey.shade100,
        child: const Icon(Icons.broken_image, size: 60, color: Colors.grey),
      ),
    );
  }
}