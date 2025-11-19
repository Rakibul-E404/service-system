import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import '../controllers/home_controller.dart';

class AdvertisementsSection extends StatelessWidget {
  const AdvertisementsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();

    return Obx(() {
      // Loading state
      if (controller.isLoadingAds.value) {
        return _buildLoadingState();
      }

      // Error state
      if (controller.adsErrorMessage.isNotEmpty) {
        return _buildErrorState(controller);
      }

      // Empty state
      if (controller.advertisements.isEmpty) {
        return const SizedBox.shrink(); // Hide if no ads
      }

      // Show advertisements carousel
      return _buildAdvertisementsCarousel(controller);
    });
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.xl),
      child: const Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: AppSizes.md),
            Text('Loading advertisements...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(HomeController controller) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              controller.adsErrorMessage.value,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.md),
            ElevatedButton(
              onPressed: () => controller.retryAds(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvertisementsCarousel(HomeController controller) {
    // Controller for carousel
    final CarouselSliderController carouselController = CarouselSliderController();
    final RxInt currentIndex = 0.obs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenHorizontal),
          child: Row(
            children: [
              Icon(
                Icons.campaign_rounded,
                color: AppColors.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Featured Advertisements',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.md),

        // Carousel Slider
        CarouselSlider.builder(
          carouselController: carouselController,
          itemCount: controller.advertisements.length,
          itemBuilder: (context, index, realIndex) {
            final ad = controller.advertisements[index];
            return _buildAdCard(ad);
          },
          options: CarouselOptions(
            height: 300,
            viewportFraction: 0.85,
            enlargeCenterPage: true,
            enlargeFactor: 0.2,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            pauseAutoPlayOnTouch: true,
            onPageChanged: (index, reason) {
              currentIndex.value = index;
            },
          ),
        ),

        const SizedBox(height: AppSizes.md),

        // Carousel Indicators
        Obx(() => Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              controller.advertisements.length,
                  (index) => Container(
                width: currentIndex.value == index ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: currentIndex.value == index
                      ? AppColors.primaryColor
                      : Colors.grey.shade300,
                ),
              ),
            ),
          ),
        )),

        const SizedBox(height: AppSizes.md),
      ],
    );
  }

  Widget _buildAdCard(Map<String, dynamic> ad) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ad Image
            _buildAdImage(ad['image']),

            // Ad Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title
                    Text(
                      ad['title'] ?? 'No Title',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Description
                    Text(
                      ad['description'] ?? 'No Description',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.grey.shade200,
              Colors.grey.shade100,
            ],
          ),
        ),
        child: Center(
          child: Icon(
            Icons.campaign,
            size: 50,
            color: Colors.grey.shade400,
          ),
        ),
      );
    }

    return Image.network(
      imageUrl,
      height: 140,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: 140,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.grey.shade200,
                Colors.grey.shade100,
              ],
            ),
          ),
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 3,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 140,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.red.shade100,
                Colors.red.shade50,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image,
                  size: 40,
                  color: Colors.red.shade300,
                ),
                const SizedBox(height: 4),
                Text(
                  'Image not available',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red.shade400,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}