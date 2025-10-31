import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/utils/logger_utils.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/routes/app_routes.dart';
import '../../booking/widgets/booking_card.dart';
import '../../home/controllers/home_top_bar_controller.dart';
import '../controllers/favorite_controller.dart';

class FavoriteScreen extends GetView<FavoriteController> {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    controller.fetchFavorites();
    final HomeTopBarController profileController = Get.put(HomeTopBarController());

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar with Profile and Notification
            Card(
              elevation: 2,
              color: AppColors.whiteColor,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    // Profile Image
                    Obx(() {
                      final imageUrl = profileController.getImageUrl();
                      return CircleAvatar(
                        radius: 30,
                        backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                        child: imageUrl.isEmpty
                            ? const Icon(Icons.person, size: 50, color: Colors.grey)
                            : null,
                      );
                    }),
                    // Notification Button
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor,
                        border: Border.all(color: AppColors.primaryColor),
                        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                      ),
                      child: IconButton(
                        onPressed: () {
                          Get.toNamed(AppRoutes.notificationPage);
                        },
                        icon: const Icon(CupertinoIcons.bell, color: AppColors.primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.md),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: Text('My Favorite', style: context.txtTheme.titleLarge),
            ),
            const SizedBox(height: AppSizes.md),

            // Favorites List
            Expanded(
              child: Obx(() {
                // Show loading indicator on initial load
                if (controller.isLoading.value && controller.favorites.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Show error message with retry option
                if (controller.errorMessage.value.isNotEmpty && controller.favorites.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.lg),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            controller.errorMessage.value,
                            style: TextStyle(color: Colors.grey[600], fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => controller.refreshFavorites(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Show empty state
                if (controller.favorites.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.lg),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            'No favorites yet',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start adding services to your favorites\nto see them here',
                            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Show favorites list with pull to refresh
                return RefreshIndicator(
                  onRefresh: () => controller.refreshFavorites(),
                  color: AppColors.primaryColor,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.screenHorizontal,
                      vertical: AppSizes.lg,
                    ),
                    itemCount: controller.favorites.length + (controller.isLoading.value ? 1 : 0),
                    itemBuilder: (BuildContext context, int index) {
                      // Show loading indicator at the bottom for pagination
                      if (index == controller.favorites.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      // Access FavoriteModel object
                      final favorite = controller.favorites[index];
                      final service = favorite.providerService;

                      // Handle null service gracefully
                      if (service == null) {
                        return const SizedBox.shrink();
                      }

                      return HorizontalServiceCard(
                        imageUrl: service.imageUrl,
                        title: service.title,
                        subtitle: service.subcategoryName,
                        description: service.location,
                        onTap: () {
                          // Navigate to service detail page
                          // Get.toNamed(
                          //   AppRoutes.serviceDetail,
                          //   arguments: service.id
                          // );
                        },
                        onDelete: () async {
                          await controller.removeFavorite(service.id ?? '');
                        },
                        showStatus: false,
                        status: '',
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const Column(
                        children: <Widget>[
                          Divider(),
                          SizedBox(height: AppSizes.md),
                        ],
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
