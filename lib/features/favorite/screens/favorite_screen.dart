import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/routes/app_routes.dart';
import '../../home/controllers/home_top_bar_controller.dart';
import '../../home/controllers/service_controller.dart';
import '../controllers/favorite_controller.dart';
import '../screens/fav_model.dart';
import '../../booking/widgets/booking_card.dart';
import '../../auth/screens/profile_service.dart';
import '../../home/screens/home_service_details_page.dart';

class FavoriteScreen extends GetView<FavoriteController> {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeTopBarController profileController = Get.put(HomeTopBarController());
    final ProfileService profileService = Get.find<ProfileService>();

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          // Not logged in
          if (!profileService.isLoggedIn.value) {
            return Center(
              // child: Column(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: <Widget>[
              //     const Icon(Icons.person_off, size: 64, color: Colors.grey),
              //     const SizedBox(height: 16),
              //     Text('Not Logged In', style: Theme.of(context).textTheme.headlineSmall),
              //     const SizedBox(height: 8),
              //     Text('Please login to view your favorites',
              //         style: Theme.of(context).textTheme.bodyMedium),
              //     const SizedBox(height: 24),
              //     ElevatedButton(
              //       onPressed: () => Get.offAllNamed(AppRoutes.roleSelectionRoute),
              //       child: const Text('Go to Login'),
              //     ),
              //   ],
              // ),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Not Logged In',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text('Please login to view your favorite'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Get.offAllNamed('/role-selection');
                    },
                    child: const Text('Go to Login'),
                  ),
                ],
              ),


            );
          }

          // Logged in - show favorites
          return RefreshIndicator(
            onRefresh: () async => await controller.refreshFavorites(),
            color: AppColors.primaryColor,
            child: _buildContent(context, profileController),
          );
        }),
      ),
    );
  }

  Widget _buildContent(BuildContext context, HomeTopBarController profileController) {
    // Fetch favorites when screen builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.favorites.isEmpty && !controller.isLoading.value) {
        controller.fetchFavorites();
      }
    });

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Card(
            elevation: 2,
            color: AppColors.whiteColor,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() {
                    final String imageUrl = profileController.getImageUrl();
                    return CircleAvatar(
                      radius: 30,
                      backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                      child: imageUrl.isEmpty
                          ? const Icon(Icons.person, size: 50, color: Colors.grey)
                          : null,
                    );
                  }),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      border: Border.all(color: AppColors.primaryColor),
                      borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                    ),
                    child: IconButton(
                      onPressed: () => Get.toNamed(AppRoutes.notificationPage),
                      icon: const Icon(CupertinoIcons.bell, color: AppColors.primaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text('My Favorite', style: context.txtTheme.titleLarge),
          ),
        ),
        Obx(() {
          if (controller.isLoading.value && controller.favorites.isEmpty) {
            return const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (controller.favorites.isEmpty) {
            return SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text('No favorites yet',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        )),
                  ],
                ),
              ),
            );
          }

          return SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                if (index >= controller.favorites.length) return const SizedBox.shrink();

                final FavoriteModel favorite = controller.favorites[index];
                final providerService = favorite.providerService;

                if (providerService == null) return const SizedBox.shrink();

                final String serviceId = favorite.providerServiceId ?? providerService.id;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.screenHorizontal, vertical: AppSizes.md),
                  child: HorizontalServiceCard(
                    imageUrl: providerService.imageUrl,
                    title: providerService.title,
                    subtitle: providerService.subcategoryName,
                    description: providerService.location,
                    bookingId: favorite.id,
                    status: 'Favorite',
                    tabIndex: 3,
                    showStatus: false,
                    onTap: () {
                      // Navigate to HomeServiceDetailsPage using correct serviceId
                      if (serviceId.isNotEmpty) {
                        if (!Get.isRegistered<ServicesController>()) {
                          Get.put(ServicesController());
                        }

                        Get.to(() => HomeServiceDetailsPage(), arguments: {
                          'serviceId': serviceId,
                        });
                      } else {
                        Get.snackbar('Error', 'Service ID missing',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white);
                      }
                    },
                    onDelete: () async {
                      // --- OLD DELETE LOGIC KEPT ---
                      final bool? confirmDelete = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            title: Row(
                              children: <Widget>[
                                Icon(Icons.favorite_border, color: Colors.red[400]),
                                const SizedBox(width: 8),
                                const Text('Remove Favorite'),
                              ],
                            ),
                            content: const Text(
                              'Are you sure you want to remove this service from your favorites?',
                              style: TextStyle(fontSize: 16),
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                ),
                                child: const Text('Remove', style: TextStyle(fontSize: 16)),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmDelete == true) {
                        Get.dialog(
                          const Center(
                            child: CircularProgressIndicator(),
                          ),
                          barrierDismissible: false,
                        );

                        try {
                          final String favoriteId = favorite.id;

                          if (favoriteId.isEmpty) {
                            Get.back();
                            Get.snackbar(
                              'Error',
                              'Unable to remove favorite: Invalid favorite ID',
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            return;
                          }

                          final bool success = await controller.removeFavorite(favoriteId);

                          Get.back();

                          if (success) {
                            controller.favorites.refresh();
                            Get.snackbar(
                              'Success',
                              'Service removed from favorites',
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                              duration: const Duration(seconds: 2),
                              icon: const Icon(Icons.check_circle, color: Colors.white),
                            );
                          } else {
                            Get.snackbar(
                              'Error',
                              'Failed to remove from favorites',
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                              icon: const Icon(Icons.error, color: Colors.white),
                            );
                          }
                        } catch (e) {
                          Get.back();
                          Get.snackbar(
                            'Error',
                            'An error occurred: ${e.toString()}',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                            icon: const Icon(Icons.error, color: Colors.white),
                          );
                        }
                      }
                    },
                  ),
                );
              },
              childCount: controller.favorites.length,
            ),
          );
        }),
      ],
    );
  }
}

