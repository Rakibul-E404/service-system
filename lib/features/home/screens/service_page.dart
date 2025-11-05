/**
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../auth/widgets/service_card.dart';
import '../controllers/service_controller.dart';

class ServicesPage extends GetView<ServicesController> {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get arguments safely
    final dynamic args = Get.arguments;
    final String subCategoryName = (args is Map<String, dynamic>)
        ? (args['subCategoryName']?.toString() ?? 'Services')
        : 'Services';
    final String subCategoryId = (args is Map<String, dynamic>)
        ? (args['subCategoryId']?.toString() ?? '')
        : '';

    debugPrint('🚀 ========== SERVICES PAGE BUILD ==========');
    debugPrint('📥 subCategoryName: "$subCategoryName"');
    debugPrint('📥 subCategoryId: "$subCategoryId"');

    // Fetch services only once after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('🎯 PostFrameCallback executing...');
      debugPrint('   - subCategoryId.isNotEmpty: ${subCategoryId.isNotEmpty}');
      debugPrint('   - services.isEmpty: ${controller.services.isEmpty}');
      debugPrint('   - isLoadingServices: ${controller.isLoadingServices.value}');

      if (subCategoryId.isNotEmpty &&
          controller.services.isEmpty &&
          !controller.isLoadingServices.value) {
        debugPrint('✅ Conditions met - fetching services...');
        controller.fetchServicesBySubCategory(subCategoryId, subCategoryName);
      } else {
        debugPrint('⏭️ Skipping fetch - conditions not met');
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(subCategoryName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final isLoading = controller.isLoadingServices.value;
        final errorMsg = controller.servicesErrorMessage.value;
        final servicesList = controller.services.toList(); // Force observable read

        debugPrint('🔄 ========== OBX REBUILD ==========');
        debugPrint('   - isLoading: $isLoading');
        debugPrint('   - errorMsg: "$errorMsg"');
        debugPrint('   - services.length: ${servicesList.length}');

        // Loading state
        if (isLoading) {
          debugPrint('📊 Showing loading indicator');
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading services...'),
                ],
              ),
            ),
          );
        }

        // Error state
        if (errorMsg.isNotEmpty) {
          debugPrint('❌ Showing error: $errorMsg');
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    errorMsg,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      debugPrint('🔄 Retry button pressed');
                      controller.retryServicesWithParams(subCategoryId, subCategoryName);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Empty state
        if (servicesList.isEmpty) {
          debugPrint('📭 Showing empty state');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                const Text(
                  'No services available',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'for $subCategoryName',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    debugPrint('🔄 Retry button pressed from empty state');
                    controller.fetchServicesBySubCategory(subCategoryId, subCategoryName);
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        // Services list
        debugPrint('📋 Showing ${servicesList.length} services');
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: servicesList.length,
          itemBuilder: (context, index) {
            try {
              final service = servicesList[index];

              debugPrint('🎯 Building card $index: ${service.name}');
              debugPrint('   - Image URL: ${service.fullImageUrl}');
              debugPrint('   - Location: ${service.location}');
              debugPrint('   - Rating: ${service.rating}');

              return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ServiceCard(
                    imageUrl: service.fullImageUrl.isNotEmpty
                        ? service.fullImageUrl
                        : 'https://via.placeholder.com/150',
                    title: service.name.isNotEmpty
                        ? service.name
                        : 'Unnamed Service',
                    subtitle: service.description.isNotEmpty
                        ? service.description
                        : 'No description available',
                    location: service.location.isNotEmpty
                        ? service.location
                        : 'Location not specified',
                    rating: service.rating,
                    showFavorite: true,
                    showLocationAndRating: true,
                    onTap: () {
                      debugPrint('👆 Tapped: ${service.name}');
                      Get.toNamed(
                        AppRoutes.homeServiceDetailsRoute,
                        arguments: {
                          'serviceId': service.id,
                          'serviceName': service.name,
                          'serviceDescription': service.description,
                          'serviceLocation': service.location,
                          'serviceRating': service.rating,
                          'serviceImage': service.fullImageUrl,
                        },
                      );
                    },
                  )
              );
            } catch (e, stackTrace) {
              debugPrint('❌ Error building card at index $index: $e');
              debugPrint('📚 StackTrace: $stackTrace');
              return const SizedBox.shrink();
            }
          },
        );
      }),
    );
  }
}
*/




///
///
///
///
/// todo::: addign teh fab button api
///
///
///




import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../auth/widgets/service_card.dart';
import '../controllers/service_controller.dart';
import '../../favorite/controllers/favorite_controller.dart';

class ServicesPage extends GetView<ServicesController> {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize FavoriteController
    final favoriteController = Get.put(FavoriteController());

    // Get arguments safely
    final dynamic args = Get.arguments;
    final String subCategoryName = (args is Map<String, dynamic>)
        ? (args['subCategoryName']?.toString() ?? 'Services')
        : 'Services';
    final String subCategoryId = (args is Map<String, dynamic>)
        ? (args['subCategoryId']?.toString() ?? '')
        : '';

    debugPrint('🚀 ========== SERVICES PAGE BUILD ==========');
    debugPrint('📥 subCategoryName: "$subCategoryName"');
    debugPrint('📥 subCategoryId: "$subCategoryId"');

    // Fetch services only once after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('🎯 PostFrameCallback executing...');
      debugPrint('   - subCategoryId.isNotEmpty: ${subCategoryId.isNotEmpty}');
      debugPrint('   - services.isEmpty: ${controller.services.isEmpty}');
      debugPrint('   - isLoadingServices: ${controller.isLoadingServices.value}');

      if (subCategoryId.isNotEmpty &&
          controller.services.isEmpty &&
          !controller.isLoadingServices.value) {
        debugPrint('✅ Conditions met - fetching services...');
        controller.fetchServicesBySubCategory(subCategoryId, subCategoryName);
      } else {
        debugPrint('⏭️ Skipping fetch - conditions not met');
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(subCategoryName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final isLoading = controller.isLoadingServices.value;
        final errorMsg = controller.servicesErrorMessage.value;
        final servicesList = controller.services.toList();

        debugPrint('🔄 ========== OBX REBUILD ==========');
        debugPrint('   - isLoading: $isLoading');
        debugPrint('   - errorMsg: "$errorMsg"');
        debugPrint('   - services.length: ${servicesList.length}');

        // Loading state
        if (isLoading) {
          debugPrint('📊 Showing loading indicator');
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading services...'),
                ],
              ),
            ),
          );
        }

        // Error state
        if (errorMsg.isNotEmpty) {
          debugPrint('❌ Showing error: $errorMsg');
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    errorMsg,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      debugPrint('🔄 Retry button pressed');
                      controller.retryServicesWithParams(subCategoryId, subCategoryName);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Empty state
        if (servicesList.isEmpty) {
          debugPrint('📭 Showing empty state');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                const Text(
                  'No services available',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'for $subCategoryName',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    debugPrint('🔄 Retry button pressed from empty state');
                    controller.fetchServicesBySubCategory(subCategoryId, subCategoryName);
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        // Services list
        debugPrint('📋 Showing ${servicesList.length} services');
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: servicesList.length,
          itemBuilder: (context, index) {
            try {
              final service = servicesList[index];

              debugPrint('🎯 Building card $index: ${service.name}');
              debugPrint('   - Service ID: ${service.id}');
              debugPrint('   - Image URL: ${service.fullImageUrl}');
              debugPrint('   - Location: ${service.location}');
              debugPrint('   - Rating: ${service.rating}');

              return Obx(() {
                final bool isFavorited = favoriteController.isFavorited(service.id);
                final bool isLoadingFav = favoriteController.isFavoriteLoading(service.id);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Opacity(
                    opacity: isLoadingFav ? 0.6 : 1.0,
                    child: ServiceCard(
                      imageUrl: service.fullImageUrl.isNotEmpty
                          ? service.fullImageUrl
                          : 'https://via.placeholder.com/150',
                      title: service.name.isNotEmpty
                          ? service.name
                          : 'Unnamed Service',
                      subtitle: service.description.isNotEmpty
                          ? service.description
                          : 'No description available',
                      location: service.location.isNotEmpty
                          ? service.location
                          : 'Location not specified',
                      rating: service.rating,
                      showFavorite: true,
                      showLocationAndRating: true,
                      isFavorited: isFavorited,
                      onTap: () {
                        debugPrint('👆 Tapped: ${service.name}');
                        Get.toNamed(
                          AppRoutes.homeServiceDetailsRoute,
                          arguments: {
                            'serviceId': service.id,
                            'serviceName': service.name,
                            'serviceDescription': service.description,
                            'serviceLocation': service.location,
                            'serviceRating': service.rating,
                            'serviceImage': service.fullImageUrl,
                          },
                        );
                      },
                      onFavorite: isLoadingFav
                          ? null // Disable while loading
                          : () {
                        debugPrint('❤️ Favorite tapped for: ${service.name}');
                        debugPrint('   - Service ID: ${service.id}');
                        favoriteController.toggleFavorite(service.id);
                      },
                    ),
                  ),
                );
              });
            } catch (e, stackTrace) {
              debugPrint('❌ Error building card at index $index: $e');
              debugPrint('📚 StackTrace: $stackTrace');
              return const SizedBox.shrink();
            }
          },
        );
      }),
    );
  }
}