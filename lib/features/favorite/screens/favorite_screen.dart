import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    final HomeTopBarController profileController = Get.put(HomeTopBarController());

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Trigger the refreshFavorites method to fetch the latest data
            await controller.refreshFavorites();
          },
          color: AppColors.primaryColor,
          child: _buildContent(context, profileController),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, HomeTopBarController profileController) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // Top Bar with Profile and Notification
        SliverToBoxAdapter(
          child: Card(
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
        ),

        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSizes.md),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                child: Text('My Favorite', style: context.txtTheme.titleLarge),
              ),
              const SizedBox(height: AppSizes.md),
            ],
          ),
        ),

        // Favorites List
        Obx(() {
          // Show loading indicator on initial load
          if (controller.isLoading.value && controller.favorites.isEmpty) {
            return const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            );
          }

          // Show error message with retry option
          if (controller.errorMessage.value.isNotEmpty && controller.favorites.isEmpty) {
            return SliverFillRemaining(
              child: Center(
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
              ),
            );
          }

          // Show empty state
          if (controller.favorites.isEmpty) {
            return SliverFillRemaining(
              child: Center(
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
              ),
            );
          }

          // Show favorites list
          return SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
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

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.screenHorizontal,
                    vertical: AppSizes.md,
                  ),
                  child: HorizontalServiceCard(
                    imageUrl: service.imageUrl ?? '',
                    title: service.title ?? 'Service',
                    subtitle: service.subcategoryName ?? 'Category',
                    description: service.location ?? 'Location not specified',
                    bookingId: favorite.id ?? '', // Use favorite ID as bookingId
                    status: 'Favorite', // Custom status for favorites

                    tabIndex: 3, // Use tabIndex 3 for favorites (no delete button)
                    showStatus: true,
                    onTap: () {
                      // Navigate to service detail page
                      // Get.toNamed(
                      //   AppRoutes.serviceDetail,
                      //   arguments: service.id
                      // );
                    },
                    onDelete: () async {
                      // Show confirmation dialog before deletion
                      final bool confirmDelete = await _showDeleteConfirmationDialog(context);

                      if (confirmDelete) {
                        // Show loading indicator
                        Get.dialog(
                          const Center(
                            child: CircularProgressIndicator(),
                          ),
                          barrierDismissible: false,
                        );

                        try {
                          // Remove favorite from server
                          final success = await controller.removeFavorite(favorite.id ?? '');

                          Get.back(); // Close loading dialog

                          if (success) {
                            // Remove from local list
                            controller.favorites.removeWhere((fav) => fav.id == favorite.id);

                            // Show success message
                            Get.snackbar(
                              'Success',
                              'Service removed from favorites',
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                              duration: const Duration(seconds: 2),
                            );
                          } else {
                            // Show error message
                            Get.snackbar(
                              'Error',
                              'Failed to remove from favorites',
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }
                        } catch (e) {
                          Get.back(); // Close loading dialog
                          Get.snackbar(
                            'Error',
                            'An error occurred while removing favorite',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      }
                    },
                  ),
                );
              },
              childCount: controller.favorites.length + (controller.isLoading.value ? 1 : 0),
            ),
          );
        }),
      ],
    );
  }

  // Helper method to show delete confirmation dialog
  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Favorite'),
          content: const Text('Are you sure you want to remove this service from your favorites?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    ) ?? false;
  }
}