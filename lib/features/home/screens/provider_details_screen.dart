import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import '../../../core/common/components/custom_network_image.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../../auth/widgets/service_card.dart';
import '../controllers/provider_details_controller.dart';
import '../../favorite/controllers/favorite_controller.dart';

class ProviderDetailsScreen extends GetView<ProviderDetailsController> {
  const ProviderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize FavoriteController
    final favoriteController = Get.put(FavoriteController());

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          // Show loading state
          if (controller.isLoadingProvider.value) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: AppSizes.md),
                  Text('Loading provider details...'),
                ],
              ),
            );
          }

          // Show error state
          if (controller.providerErrorMessage.value.isNotEmpty &&
              controller.providerData.value == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: AppSizes.md),
                    Text(
                      controller.providerErrorMessage.value,
                      textAlign: TextAlign.center,
                      style: context.txtTheme.bodyLarge,
                    ),
                    const SizedBox(height: AppSizes.lg),
                    ElevatedButton.icon(
                      onPressed: () => controller.retryFetchProvider(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Show provider details
          final provider = controller.providerData.value;
          if (provider == null) {
            return const Center(
              child: Text('No provider data available'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenHorizontal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Back button
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(CupertinoIcons.back),
                ),

                // Main Body
                const SizedBox(height: AppSizes.md),

                // Provider Image
                CustomCachedImage(
                  imageUrl: provider.fullImageUrl,
                  width: context.screenWidth,
                  height: context.screenHeight * 0.4,
                ),

                const SizedBox(height: AppSizes.md),

                // Provider Name and Message Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            provider.name,
                            style: context.txtTheme.labelLarge,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (provider.rating != null && provider.rating! > 0)
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${provider.rating} (${provider.ratingCount} reviews)',
                                  style: context.txtTheme.bodySmall,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
                        color: AppColors.primaryColor,
                      ),
                      child: const Row(
                        children: <Widget>[
                          Text("Message"),
                          SizedBox(width: 4),
                          Icon(CupertinoIcons.chat_bubble_text),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.sm),

                // Availability Status
                if (!provider.isAvailable)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Colors.orange),
                        SizedBox(width: 4),
                        Text(
                          'Currently Unavailable',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: AppSizes.sm),

                // Description
                Text(
                  provider.description,
                  style: context.txtTheme.bodyMedium,
                ),

                const SizedBox(height: AppSizes.sm),

                // Location
                Row(
                  children: <Widget>[
                    const Icon(Icons.location_on_outlined),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        provider.location,
                        style: context.txtTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.sm),

                // Phone
                if (provider.phone.isNotEmpty)
                  Row(
                    children: <Widget>[
                      const Icon(Icons.phone_outlined),
                      const SizedBox(width: 4),
                      Text(
                        provider.phone,
                        style: context.txtTheme.bodyMedium,
                      ),
                    ],
                  ),

                const SizedBox(height: AppSizes.md),

                // Profile Completion Status
                if (!provider.isProfileComplete)
                  Container(
                    padding: const EdgeInsets.all(AppSizes.sm),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This provider is still completing their profile',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: AppSizes.md),

                // Provided Services Section
                Text("Provided Services", style: context.txtTheme.titleLarge),
                const SizedBox(height: AppSizes.sm),
                Row(
                  spacing: 8,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.md,
                          vertical: AppSizes.md,
                        ),
                        child: const Column(
                          children: <Widget>[
                            CustomCachedImage(
                              imageUrl: '',
                              height: 100,
                              fit: BoxFit.contain,
                            ),
                            Text("Service 1"),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.md,
                          vertical: AppSizes.md,
                        ),
                        child: const Column(
                          children: <Widget>[
                            CustomCachedImage(
                              imageUrl: '',
                              height: 100,
                              fit: BoxFit.contain,
                            ),
                            Text("Service 2"),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.md),

                // Past Services Section
                Text("Past Services", style: context.txtTheme.titleLarge),
                const SizedBox(height: AppSizes.sm),
                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: 10,
                  itemBuilder: (BuildContext context, int index) {
                    final String serviceId = 'demo_service_$index';

                    return Obx(() {
                      final bool isFavorited = favoriteController.isFavorited(serviceId);
                      final bool isLoadingFav =
                      favoriteController.isFavoriteLoading(serviceId);

                      return ServiceCard(
                        height: context.screenHeight * 0.25,
                        width: double.infinity,
                        imageUrl:
                        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=300&fit=crop',
                        title: 'Service ${index + 1}',
                        subtitle: 'Professional service',
                        location: provider.location,
                        rating: 4.5,
                        isFavorited: isFavorited,
                        onTap: () {
                          Get.toNamed(AppRoutes.homeServiceDetailsRoute);
                        },
                        onFavorite: isLoadingFav
                            ? null
                            : () {
                          debugPrint('❤️ Favorite tapped for service: $serviceId');
                          favoriteController.toggleFavorite(serviceId);
                        },
                      );
                    });
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const SizedBox(height: AppSizes.md);
                  },
                ),
                const SizedBox(height: AppSizes.lg),
              ],
            ),
          );
        }),
      ),
    );
  }
}